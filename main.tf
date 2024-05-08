resource "aws_key_pair" "awskey" {
  key_name   = "terraform-key" 
  public_key = file("${path.cwd}/.ssh/id_rsa.pub")
}

resource "aws_vpc" "k8s-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "Kubernetes VPC"
  }
  
}
resource "aws_subnet" "k8s-subnet" {
  vpc_id = aws_vpc.k8s-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ca-central-1a"
  map_public_ip_on_launch = true
  
}
resource "aws_internet_gateway" "k8s-igw" {
  vpc_id = aws_vpc.k8s-vpc.id 
}

resource "aws_route_table" "k8s-rt" {
    vpc_id = aws_vpc.k8s-vpc.id
     route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-igw.id
  }
}
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.k8s-subnet.id
  route_table_id = aws_route_table.k8s-rt.id
}

resource "aws_security_group" "k8s-sg" {
  name = "Kubernetes-SG"
  vpc_id = aws_vpc.k8s-vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Custom Tcp"
    from_port = 3000
    to_port = 10000
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Https"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Custom Tcp"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Custom Tcp"
    from_port = 30000
    to_port = 32767
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "SMTPS"
    from_port = 465
    to_port = 465
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "SMTP"
    from_port = 25
    to_port = 25
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "K8s-sg"
  }
  
}

resource "aws_instance" "master" {
    ami = "ami-0c4596ce1e7ae3e68"
    instance_type = "t2.medium"
    vpc_security_group_ids = [ aws_security_group.k8s-sg.id ]
    subnet_id = aws_subnet.k8s-subnet.id
    key_name = aws_key_pair.awskey.key_name
    tags = {
      Name = "Master_Node"
    }
    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("/home/haarish/.ssh/id_rsa")
    host     = self.public_ip
  }
    provisioner "file" {
    source      = "master-node.sh"
    destination = "/home/ubuntu/master-script.sh"
  }
    #user_data = "${file("master-node.sh")}"
    provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "cd /home/ubuntu",
      "chmod +x master-script.sh",
      "sudo sh master-script.sh",
    ]
  }
  
}

resource "aws_instance" "worker" {
    ami = "ami-0c4596ce1e7ae3e68"
    instance_type = "t2.medium"
    vpc_security_group_ids = [ aws_security_group.k8s-sg.id ]
    subnet_id = aws_subnet.k8s-subnet.id
    key_name = aws_key_pair.awskey.key_name
    tags = {
      Name = "Worker_Node-1"
    }
    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/home/haarish/.ssh/id_rsa")
    host     = self.public_ip
  }
    provisioner "file" {
    source      = "worker-node.sh"
    destination = "/home/ubuntu/worker-script.sh"
  }
    #user_data = "${file("master-node.sh")}"
    provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "cd /home/ubuntu",
      "chmod +x worker-script.sh",
      "sudo sh worker-script.sh",
    ]
  }
    
  
}
