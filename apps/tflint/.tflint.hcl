plugin "terraform" {
  enabled = true
  preset  = "all"
}

# `tflint --init` needed
plugin "aws" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# rule "terraform_required_version" {
#   enabled = false
# }
#
# rule "terraform_required_providers" {
#   enabled = false
# }
