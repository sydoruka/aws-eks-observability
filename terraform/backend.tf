terraform {
  backend "s3" {
    bucket       = "eks-2101-terraform-state"
    key          = "dev/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}