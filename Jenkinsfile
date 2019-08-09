pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo "Workspace is: ${env.WORKSPACE}"
                echo "ENV is: ${env}"
                sh 'ls -lah'
                sh 'cat Jenkinsfile'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
