terraform {
  backend "remote" {
    organization = "utahtech-it3110"

    workspaces {
      name = "IT-3110-Terraform"
    }
  }

  required_version = ">= 0.14.0"
}
