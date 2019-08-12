@Library('github.com/mschuchard/jenkins-devops-libs')_

def setBuildStatus(String message, String state, String context, String sha) {
    step([
        $class: "GitHubCommitStatusSetter",
        reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/glarizza/jenkins-integration-test"],
        contextSource: [$class: "ManuallyEnteredCommitContextSource", context: context],
        errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
        commitShaSource: [$class: "ManuallyEnteredShaSource", sha: sha ],
        statusBackrefSource: [$class: "ManuallyEnteredBackrefSource", backref: "${BUILD_URL}flowGraphTable/"],
        statusResultSource: [$class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
    ]);
}

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

                  // setBuildStatus("Complete","SUCCESS", "Terraform tests","${gitCommit}")
                  if (env.CHANGE_ID) {
                    def comment = pullRequest.comment('Validation successful...')
                  }
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
