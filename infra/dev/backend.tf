terraform {
  backend "s3" {
    bucket        = "sma-terraform-state-unique123"
    key           = "dev/terraform.tfstate"
    region        = "us-east-1"
  
    encrypt       = true
  }
}
