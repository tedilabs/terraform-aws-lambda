###################################################
# CloudWatch Log Group
###################################################

module "log_group" {
  source  = "tedilabs/observability/aws//modules/cloudwatch-log-group"
  version = "~> 0.2.0"

  name = "/aws/vendedlogs/states/hello-world"

  retention_in_days = 1

  tags = {
    "project" = "terraform-aws-lambda-examples"
  }
}
