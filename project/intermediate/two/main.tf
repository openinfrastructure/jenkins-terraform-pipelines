/******************************************
  Provider configuration
 *****************************************/
provider "google" {
  version = "~> 2.1"
}

provider "google-beta" {
  version = "~> 2.1"
}

resource "google_compute_address" "external" {
  name         = "jenkins-testing"
  project      = "test-project"
  region       = "us-west1"
  address_type = "EXTERNAL"
}
