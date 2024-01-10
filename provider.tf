provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.account_number}:role/TerraformRole"
    session_name = "terraform"
  }
}

provider "aws" { # provider alias for egress network account resources
  region = var.region
  alias  = "egress"

  assume_role {
    role_arn = "arn:aws:iam::${var.egress_account_id}:role/TerraformRole"
  }
}
