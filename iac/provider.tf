provider "aws" {
  region                  = var.region
  shared_credentials_file = "${var.pathprefix}/${var.pathsuffix}"
  profile                 = "terraform"
}