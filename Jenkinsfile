pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {
        stage("Git checkout") {
            steps{
                script{
                    git branch: 'main', url: 'https://github.com/harishk97/kubernetes-WAF-AWS.git'
                }
                
            }
        }
        stage('Terraform Version') {
            steps {
                script{
                    sh 'terraform -v'
                }
                
            }
        }
        stage('Initialize terraform') {
            steps {
                script{
                    sh 'terraform init'
                }
                
            }
        }
    }
}
