@Library('github.com/mschuchard/jenkins-devops-libs@v1.2.1')_

pipeline {
    agent any

    stages {
       stage('Validate') {
            steps {
              script {
                echo "Dir is: ${env.WORKSPACE}/terraform"
                sh "ls -lah ${env.WORKSPACE}/terraform"
                sh "cat ${env.WORKSPACE}/terraform/main.tf"

                // Try to invoke the shared library
                terraform.init {
                  dir = "${env.WORKSPACE}/terraform"
                }

                terraform.validate {
                  dir = "${env.WORKSPACE}/terraform"
                }
              }
            }
        }
        stage('Cleanup') {
            steps {
              echo "Cleanup goes here..."
              //sh "rm -Rf ${env.WORKSPACE}"
            }
        }
    }
}
