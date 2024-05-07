resource "aws_instance" "master" {
    ami = "ami-0c4596ce1e7ae3e68"
    instance_type = "t2.micro"
  
}

resource "aws_instance" "worker" {
    ami = "ami-0c4596ce1e7ae3e68"
    instance_type = "t2.micro"
  
}