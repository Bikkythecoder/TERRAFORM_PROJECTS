terraform {
  backend "s3" {
    bucket = "vik-0610-example.com"
    key = "project-1/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true

  }
}