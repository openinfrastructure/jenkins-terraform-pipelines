@Library('github.com/mschuchard/jenkins-devops-libs@1.3.0')_

pipeline {
    agent any

    stages {
       stage('Validate') {
            steps {
                terraform.init {
                  dir = "${env.WORKSPACE}/terraform"
                }

                terraform.validate {
                  dir = "${env.WORKSPACE}/terraform"
                }
            }
        }
        stage('Cleanup') {
            steps {
                //sh "rm -Rf ${env.WORKSPACE}"
            }
        }
    }
}
