@Library('github.com/mschuchard/jenkins-devops-libs')_

pipeline {
    agent any

    stages {
       stage('Validate') {
            steps {
              script {
                echo "Dir is: ${env.WORKSPACE}/terraform"
                sh "ls -lah ${env.WORKSPACE}/terraform"
                sh "cat ${env.WORKSPACE}/terraform/main.tf"
                dir("${env.WORKSPACE}/terraform") {
                  sh "terraform init"
                  sh "terraform fmt"
                  sh "terraform validate"
                  def comment = pullRequest.comment('This PR is highly illogical..')
                }

                // Try to invoke the shared library
                //terraform.init {
                //  dir = "${env.WORKSPACE}/terraform"
                //}

                //terraform.validate {
                //  dir = "${env.WORKSPACE}/terraform"
                //}
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
