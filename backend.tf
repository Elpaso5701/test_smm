terraform {
  backend "s3" {
    bucket         = "my-terraform-stateee"
    region         = "eu-north-1"
    key            = "s3-github-actions/terraform.tfstate"
    encrypt = true
  }
