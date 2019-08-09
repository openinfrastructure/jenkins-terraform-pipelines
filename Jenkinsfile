pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo "Workspace is: ${env.WORKSPACE}"
                echo "ENV is: ${env}"
                echo 'Building..'
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
