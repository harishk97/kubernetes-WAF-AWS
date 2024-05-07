pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_KEY')
        //AWS_DEFAULT_REGION = "us-east-1"
    }
    parameters {
        choice(
            choices: ['plan','apply','destroy'],
            description: 'Terraform action to apply',
            name: 'action')
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
         stage('validate') {
            steps {
                sh 'terraform validate -no-color'
            }
        }
        stage('plan') {
            when {
                expression { params.action == 'plan' || params.action == 'apply' }
            }
            steps {
                script{
                    //Best practise to save the plan file and give input to apply to have consistency and additional validation
                    sh 'terraform plan -no-color -input=false -out=tfplan'
                }
                //For utilizing vars file in terraform
                //sh 'terraform plan -no-color -input=false -out=tfplan -var "aws_region=${AWS_REGION}" --var-file=environments/${ENVIRONMENT}.vars'
            }
        }
        stage('approval') {
            when {
                expression { params.action == 'apply'}
            }
            steps {
                //get the state file and shows in cli for the approval
                sh 'terraform show -no-color tfplan > tfplan.txt'
                script {
                    //reads saved tfile from show
                    def plan = readFile 'tfplan.txt'
                    input message: "Apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
        stage('apply') {
            when {
                expression { params.action == 'apply' }
            }
            steps {
                sh 'terraform apply -no-color -input=false tfplan'
            }
        }
        stage('Destroy') {
            when {
                expression { params.action == 'destroy' }
            }
            steps {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Delete the stack?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
                sh 'terraform destroy -no-color -auto-approve'
            }
        }
    }
}
