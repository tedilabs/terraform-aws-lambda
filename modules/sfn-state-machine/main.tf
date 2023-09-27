locals {
  metadata = {
    package = "terraform-aws-lambda"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}


###################################################
# State Machine for Step Functions
###################################################

# INFO: Not supported attributes
# - `name_prefix` (Not used)
# - `description` (Not Implemented)
# - `version_description` (Not Implemented)
resource "aws_sfn_state_machine" "this" {
  name = var.name
  type = var.type

  definition = var.definition

  publish = var.publish_version

  ## Observability
  logging_configuration {
    level = (var.logging.enabled
      ? var.logging.log_level
      : "OFF"
    )
    include_execution_data = var.logging.include_execution_data

    log_destination = (var.logging.enabled
      ? "${var.logging.cloudwatch.log_group}:*"
      : ""
    )
  }

  tracing_configuration {
    enabled = var.tracing.enabled
  }


  ## Security
  role_arn = coalesce(one(data.aws_iam_role.custom[*].arn), one(module.role[*].arn))


  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Versions and Aliases for State Machine
###################################################

data "aws_sfn_state_machine_versions" "this" {
  statemachine_arn = aws_sfn_state_machine.this.arn
}

locals {
  state_machine_versions = {
    for arn in data.aws_sfn_state_machine_versions.this.statemachine_versions :
    regex("\\d+$", arn) => {
      arn = arn
      id  = regex("\\d+$", arn)
    }
  }
}

resource "aws_sfn_alias" "this" {
  for_each = {
    for alias in var.aliases :
    alias.name => alias
  }

  name        = each.key
  description = each.value.description

  dynamic "routing_configuration" {
    for_each = each.value.routing

    content {
      state_machine_version_arn = local.state_machine_versions[routing_configuration.value.version].arn
      weight                    = routing_configuration.value.weight
    }
  }
}
