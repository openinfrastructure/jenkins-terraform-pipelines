@Library('github.com/glarizza/jenkins-devops-libs@gl/fmt_and_plan_updates')_

// Libraries needed for path determination
import java.nio.file.Path;
import java.nio.file.Paths;

def getChangedFiles() {
  /* Gather a list of files changed within the PR.

     Returns: A list of relative file paths within the repo that were changed
  */
  changedFiles = sh (
    script: "git diff --name-only origin/master HEAD",
    returnStdout: true
  ).trim().split()
  return changedFiles
}

def readTerraformMappingsFile(mappingsFilePath) {
  /* Read a YAML file of managed terraform implementation directories and
     return a list of that file's contents.

     Arguments:
       mappingsFilePath: The path to the YAML mapping file

     Returns: A list containing the relative paths to all the terraform
      implementation directories within the repository
  */
  if(fileExists(mappingsFilePath)) {
    def terraformDirectoryList = readYaml file: mappingsFilePath
    return terraformDirectoryList
  } else {
    error("Error: Could not find Terraform directory mapping file at ${mappingsFilePath}.")
  }
}

def getTerraformRootDirectory(changedFilesList, terraformDirectoriesList) {
  /* Determine the terraform implementation directory that should be validated
     and planned based on a list of changed files and the map of the YAML
     mapping file data.

     Arguments:
       changedFilesList: A list of relative file paths within the repo that
         were changed.
       terraformDirectoriesList: A list of relative paths in the repo that
         correspond to individual terraform implementation directories.

      Returns: The path to the terraform implementation directory relative to the root of
        the repository
  */
  // Convert the list of changed files to a list of parent directories that
  // can be compared against the list of Terraform directories
  def parentPathList = changedFilesList.collect {
    Path fullPath = Paths.get(it)
    fullPath.getParent()
  }

  // Iterate through the list of parent directories and determine if any of
  // them are descendents of terraform implementation directories. If so, store
  // the terraform implementation directory into a list
  terraformRootDirectoryList = []
  for (def changedDirectory in parentPathList) {
    // Null entries correspond to the root of the repo - ignore them
    if (changedDirectory == null) {
      continue
    }
    for (def terraformDirectory in terraformDirectoriesList) {
      if (changedDirectory.startsWith(terraformDirectory)) {
        println "The directory '${changedDirectory}' contains file changes and is associated with the '${terraformDirectory}' Terraform implementation directory."
        terraformRootDirectoryList.add(terraformDirectory.toString())
      }
    }
  }

  // Strip duplicates from the list (in the event that multiple subdirectories
  // of an implementation directory have been changed)
  terraformRootDirectoryList.unique()

  // If terraformRootDirectoryList is empty it means that there weren't any
  // changes identified within a terraform implementation directory. In this case
  // return a null value so the validation step can be skipped.
  if (terraformRootDirectoryList.size() == 0) {
    return null
  }

  // If terraformRootDirectoryList contains more than one element it means that
  // changes to more than one terraform implementation directory within a single
  // PR have been identified. We are restricting changes to a single terraform
  // implementation directory per each PR.
  if (terraformRootDirectoryList.size() != 1) {
    error("More than one Terraform directories contain file changes within a single PR: [${terraformRootDirectoryList.join(", ")}]. Only 1 Terraform directory may contain file changes within a single PR. Please update the changes in your branch and push again.")
  }

  return terraformRootDirectoryList[0]
}

pipeline {
  agent any
  stages {
    stage('Checkout PR') {
      steps {
        script {
          GIT_ROOT = "${WORKSPACE}/git"
          dir(GIT_ROOT) {
            // First fetch refs for Pull requests, then checkout to the FETCH_HEAD
            checkout scm: [
              $class: 'GitSCM',
              userRemoteConfigs: [
                [
                  url: 'https://github.com/openinfrastructure/jenkins-terraform-pipelines.git',
                  refspec: "+refs/pull/${env.CHANGE_ID}/head:refs/remotes/origin/${env.GIT_BRANCH}"
                ]
              ],
              branches: [
                [
                  name: "FETCH_HEAD"
                ]
              ],
              extensions: [
                [
                  // LocalBranch needs to be used to prevent being in a detached head state
                  $class: 'LocalBranch'
                ]
              ]
            ]
          }
        }
      }
    }

    stage('Determine Terraform Directory') {
      steps {
        script {
          dir(GIT_ROOT) {
            def terraformDirectoriesList = readTerraformMappingsFile("${env.WORKSPACE}/.terraform_directories.yaml")
            def changedFilesList = getChangedFiles()
            // terraformRootDirectory is accessed in a later stage, so don't use "def" to
            // define it (which makes it local in scope)
            terraformRootDirectory = getTerraformRootDirectory(changedFilesList, terraformDirectoriesList)

            // terraformRootDirectory will only be null if changes do not reside in any
            // terraform implementation directories. In that case skip the Validation stage
            // and exit with success.
            if (terraformRootDirectory == null) {
              currentBuild.result = 'SUCCESS'
              TF_HOME = null
              println "No Terraform directories were modified in this PR. Exiting..."
              return
            }

            TF_HOME = terraformRootDirectory
          }
        }
      }
    }

    stage("Validate Terraform Directory") {
      when {
        expression {
          // TF_HOME will be null if changes do not reside in any terraform implementation
          // directories. This is the conditional check that will allow for skipping the
          // validation stage.
          TF_HOME != null
        }
      }
      steps {
        script {
          def terraformPath = "${GIT_ROOT}/${TF_HOME}"
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

          // The env.CHANGE_ID variable will only be populated within a PR, so this
          // conditional check allows us to only return a PR comment within a PR context
          if (env.CHANGE_ID) {
            pullRequest.comment("Output of `terraform plan` within the repository's `${terraformRootDirectory}` directory initiated from Jenkins job `${env.JOB_NAME}` build `${env.BUILD_ID}`:\n```\n${output}\n```")
          }
        }
      }
    }
  }
}
