provider "aws" {
  assume_role {
    role_arn = var.aws_role_arn
  }
}
