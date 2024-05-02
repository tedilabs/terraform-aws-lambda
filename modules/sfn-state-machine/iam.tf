data "aws_caller_identity" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id

  custom_iam_role_enabled = !(var.custom_iam_role == null && var.iam_role.enabled)
}

data "aws_iam_role" "custom" {
  count = local.custom_iam_role_enabled ? 1 : 0

  name = (startswith(var.custom_iam_role, "arn:aws")
    ? split(":role/", var.custom_iam_role)[1]
    : var.custom_iam_role
  )
}


###################################################
# IAM Role for State Machine
###################################################

module "role" {
  count = !local.custom_iam_role_enabled ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.29.1"

  name        = "aws-sfn-state-machine-${local.metadata.name}"
  path        = "/"
  description = "Role for AWS Step Functions State Machine (${local.metadata.name})"

  force_detach_policies = true

  trusted_service_policies = [
    {
      services = ["states.amazonaws.com"]
      conditions = [
        {
          key       = "aws:SourceAccount"
          condition = "StringEquals"
          values    = [local.account_id]
        },
      ]
    },
  ]
  conditions = var.iam_role.conditions

  policies = var.iam_role.policies
  inline_policies = merge(
    var.logging.enabled ? {
      "cloudwatch-logs" = data.aws_iam_policy_document.cloudwatch[0].json,
    } : {},
    var.tracing.enabled ? {
      "xray" = data.aws_iam_policy_document.xray[0].json,
    } : {},
    var.service_integrations["lambda"].enabled ? {
      "lambda" = data.aws_iam_policy_document.lambda[0].json,
    } : {},
    var.iam_role.inline_policies,
  )

  resource_group_enabled = false
  module_tags_enabled    = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}


###################################################
# IAM Policy for CloudWatch Logging
###################################################

data "aws_iam_policy_document" "cloudwatch" {
  count = (!local.custom_iam_role_enabled && var.logging.enabled) ? 1 : 0

  statement {
    sid = "ConfigureCloudWatchLogging"

    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    sid = "ExecuteCloudWatchLogging"

    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${var.logging.cloudwatch.log_group}:*"
    ]
  }
}


###################################################
# IAM Policy for X-Ray Tracing
###################################################

data "aws_iam_policy_document" "xray" {
  count = (!local.custom_iam_role_enabled && var.tracing.enabled) ? 1 : 0

  statement {
    sid = "ConfigureXrayTracing"

    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
    ]
    resources = [
      "*",
    ]
  }
}


###################################################
# IAM Policy for Invoking Lambda Functions
###################################################

locals {
  lambda_integration_detected_functions = distinct(flatten(regexall(
    "\"(arn:aws:lambda:[a-z0-9-]+:[0-9]+:function:[a-zA-Z0-9-_./]+)\"",
    var.definition
  )))
  lambda_integration_functions = coalescelist(var.service_integrations["lambda"].functions, local.lambda_integration_detected_functions)
}

data "aws_iam_policy_document" "lambda" {
  count = (!local.custom_iam_role_enabled && var.service_integrations["lambda"].enabled) ? 1 : 0

  statement {
    sid = "InvokeLambdaFunctions"

    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = local.lambda_integration_functions
  }
}
