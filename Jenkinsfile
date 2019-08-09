@Library('github.com/mschuchard/jenkins-devops-libs@v1.3.0')_

pipeline {
    agent any

    stages {
       stage('Validate') {
            steps {
              script {
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
