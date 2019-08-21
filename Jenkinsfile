@Library('github.com/glarizza/jenkins-devops-libs@gl/fmt_and_plan_updates')_

// Libraries needed for path determination
import java.nio.file.Path;
import java.nio.file.Paths;

def getChangedFiles() {
  changedFiles = sh (
    script: "git diff --name-only origin/master HEAD",
    returnStdout: true
  ).trim().split()
  return changedFiles
}

def readTerraformMappingsFile(mappingsFilePath) {
  if(fileExists(mappingsFilePath)) {
    def terraformDirectoryMap = readYaml file: mappingsFilePath
    return terraformDirectoryMap
  } else {
    error("Error: Could not find Terraform directory mapping file at ${mappingsFilePath}.")
  }
}

def getTerraformRootDirectory(changedFilesList, terraformDirectoriesList) {
  def parentPathList = changedFilesList.collect {
    Path fullPath = Paths.get(it)
    fullPath.getParent()
  }
  terraformRootDirectoryList = []
  for (def changedDirectory in parentPathList) {
    if (changedDirectory == null) {
      continue
    }
    for (def terraformDirectory in terraformDirectoriesList) {
      if (changedDirectory.startsWith(terraformDirectory)) {
        println "The directory '${changedDirectory}' contains file changes and is associated with the '${terraformDirectory}' Terraform implementation directory."
        terraformRootDirectoryList.add(changedDirectory.toString())
      }
    }
  }

  // If nothing was found return null and handle it in the pipeline
  if (terraformRootDirectoryList.size() == 0) {
    return null
  }

  // Error out if more than one Terraform implementation directories have been identified
  if (terraformRootDirectoryList.size() != 1) {
    error("More than one Terraform directories contain file changes within a single PR: [${terraformRootDirectoryList.join(", ")}]. Only 1 Terraform directory may contain file changes within a single PR. Please update the changes in your branch and push again.")
  }

  return terraformRootDirectoryList[0]
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
            terraformDirectoryMap = readTerraformMappingsFile("${env.WORKSPACE}/terraform-directory-mappings.yaml")
            terraformDirectoriesList = terraformDirectoryMap.keySet()
            changedFilesList = getChangedFiles()
            terraformRootDirectory = getTerraformRootDirectory(changedFilesList, terraformDirectoriesList)

            // terraformRootDirectory will only be null of no Terraform directories are found.
            // If no Terraform directories are modified we will exit out cleanly
            if (terraformRootDirectory == null) {
              currentBuild.result = 'SUCCESS'
              println "No Terraform directories were modified in this PR. Exiting..."
              return
            }

            node {
              stage("Validate ${terraformRootDirectory} directory") {
                def gitRoot = "${WORKSPACE}/git"
                def terraformPath = "${gitRoot}/${terraformRootDirectory}"
                dir(gitRoot) {
                  checkout scm: [
                    $class: 'GitSCM', userRemoteConfigs: [
                      [
                        url: 'https://github.com/openinfrastructure/jenkins-terraform-pipelines.git',
                        refspec: "+refs/pull/*:refs/remotes/origin/pr/*",
                      ]
                    ],
                  ]
                }
                terraform.fmt {
                  dir   = terraformPath
                  check = true
                  diff  = true
                }

                terraform.init {
                  dir = terraformPath
                }

                terraform.validate {
                  dir = terraformPath
                }

                def output = terraform.plan {
                  dir = terraformPath
                }

                if (env.CHANGE_ID) {
                  pullRequest.comment("Output of `terraform plan` within the repository's `${terraformRootDirectory}` directory initiated from Jenkins job `${env.JOB_NAME}` build `${env.BUILD_ID}`:\n```\n${output}\n```")
                }
              }
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
