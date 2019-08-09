pipeline {
    agent any

    stages {
        stage('Install Terraform') {
            steps {
                sh "scripts/install_terraform.sh '0.12.6'"
            }
        }
        stage('Validate') {
            steps {
                sh "cd terraform"
                sh "terraform init"
                sh "terraform fmt"
                sh "terraform validate"
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
