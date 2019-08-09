pipeline {
    agent any

    stages {
       stage('Validate') {
            steps {
                sh "cd ${env.WORKSPACE}/terraform"
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
