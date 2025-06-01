plugin "terraform" {
  enabled = true
  preset  = "all"
}

# `tflint --init` needed
plugin "aws" {
  enabled = true
  # deep_check = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# `tflint --init` needed
plugin "google" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# resource名はスネークケース表記
rule "terraform_naming_convention" {
  enabled = true
}

# コメントは#を使う(//は使わない)
rule "terraform_comment_syntax" {
  enabled = true
}

# variable ブロックや output ブロックは variables.tf や outputs.tf に定義する
rule "terraform_standard_module_structure" {
  enabled = true
}

# terraformブロック内に必ずrequired_versionを宣言させる
# ref. https://github.com/erueru-tech/infra-testing-google-sample
# rule "terraform_required_version" {
#   enabled = false
# }
#
# rule "terraform_required_providers" {
#   enabled = false
# }
