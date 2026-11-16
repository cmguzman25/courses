# Environment check: reads the identity of the simulated AWS account.
# A data source only reads; it does not create anything.
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
