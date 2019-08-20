@Library('github.com/glarizza/jenkins-devops-libs@gl/fmt_and_plan_updates')_

def getParentDirectoriesOfChangedFiles() {
  changedFiles = sh (
    script: "git diff --name-only origin/master HEAD",
    returnStdout: true
  ).trim().split()
  list = []
  for (int i = 0; i < changedFiles.size(); i++) {
    parent = sh (
      script: "dirname ${changedFiles[i]}",
      returnStdout: true
    ).trim()
    list.add(parent)
  }
  return list.unique()
}

def readTerraformMappingsFile(mappingsFilePath) {
  if(fileExists(mappingsFilePath)) {
    def terraformDirectoryMap = readYaml file: mappingsFilePath
    return terraformDirectoryMap
  } else {
    error("Error: Could not find Terraform directory mapping file at ${mappingsFilePath}.")
  }
}

pipeline {
    agent any
    environment {
      TF_DIR = "${env.WORKSPACE}/terraform"
    }
    stages {
      stage('Determine Terraform Directories') {
        steps {
          script {
            // Bug around scoping
            // See: https://issues.jenkins-ci.org/browse/JENKINS-44928
            def localWorkspacePath = env.WORKSPACE

            // Compare a mapping of Terraform implementation directories within
            // a monorepo to the directories containing changed files in this
            // PR. If a file has been changed within a known terraform
            // implementation directory then validate and plan that directory.
            def terraformDirectoriesToValidate = []
            terraformDirectoryMap = readTerraformMappingsFile("${env.WORKSPACE}/terraform-directory-mappings.yaml")
            terraformDirectoriesList = terraformDirectoryMap.keySet()
            changedDirectoriesList = getParentDirectoriesOfChangedFiles()
            changedDirectoriesList.each {
              println "Looping through parent directories of changed files. Now checking: ${it}"
              if (terraformDirectoriesList.contains(it)) {
                println "Found ${it} in ${terraformDirectoriesList}"
                terraformDirectoriesToValidate.add(it)
              }
            }
            terraformDirectoriesToValidate.each { directory ->
              node {
                stage("Validate ${directory} directory") {
                  terraform.fmt {
                    dir   = "${localWorkspacePath}/${directory}"
                    check = true
                    diff  = true
                  }

                  terraform.init {
                    dir = "${localWorkspacePath}/${directory}"
                  }

                  terraform.validate {
                    dir = "${localWorkspacePath}/${directory}"
                  }

                  def output = terraform.plan {
                    dir = "${localWorkspacePath}/${directory}"
                  }

                  if (env.CHANGE_ID) {
                    pullRequest.comment("Output of `terraform plan` within the repository's `${directory}` directory initiated from Jenkins job `${env.JOB_NAME}` build `${env.BUILD_ID}`:\n```\n${output}\n```")
                  }
                }
              }
            }
          }
        }
      }
       stage('Causes') {
          steps {
            script {
              sh "env"

              def causes = currentBuild.getBuildCauses()
              def specificCause = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause')

              echo "Causes is: ${causes}"
              echo "Causes Class is: ${causes.getClass()}"
              causes[0].each { key, val ->
                println "Key: ${key} and Val: ${val}"
              }
              echo "Specific Cause is: ${specificCause}"
              echo "Specific Cause Class is: ${specificCause.getClass()}"
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
