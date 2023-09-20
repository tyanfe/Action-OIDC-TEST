terraform {
  backend "s3" {
    bucket  = "landmark-automation-kenmak"
    region  = "us-west-2"
    key     = "oidc/terraform.tfstate"
    encrypt = true
  }
}