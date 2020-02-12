terraform {
  backend "s3" {
    bucket = "rneumann-tfstate"
    key    = "states"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
}