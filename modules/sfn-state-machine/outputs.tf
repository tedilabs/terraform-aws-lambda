output "arn" {
  description = "The ARN of the state machine."
  value       = aws_sfn_state_machine.this.arn
}

output "id" {
  description = "The ID of the state machine."
  value       = aws_sfn_state_machine.this.id
}

output "name" {
  description = "The name of the state machine."
  value       = aws_sfn_state_machine.this.name
}

output "type" {
  description = "The type of the state machine."
  value       = aws_sfn_state_machine.this.type
}

output "status" {
  description = "The current status of the state machine. Either `ACTIVE` or `DELETING`."
  value       = aws_sfn_state_machine.this.status
}

output "definition" {
  description = "The Amazon States Language definition of the state machine."
  value       = aws_sfn_state_machine.this.definition
}

output "latest_version" {
  description = "The information of the latest version for the state machine."
  value = try({
    arn = aws_sfn_state_machine.this.state_machine_version_arn
    id  = regex("\\d+$", aws_sfn_state_machine.this.state_machine_version_arn)
  }, null)
}

output "versions" {
  description = "A map of versions for the state machine."
  value       = local.state_machine_versions
}

output "aliases" {
  description = "A map of aliases for the state machine."
  value = {
    for name, alias in aws_sfn_alias.this :
    name => {
      arn         = alias.arn
      name        = alias.name
      description = alias.description
      created_at  = alias.creation_date
      routing = [
        for item in alias.routing_configuration : {
          version = {
            arn = item.state_machine_version_arn
            id  = regex("\\d+$", item.state_machine_version_arn)
          }
          weight = item.weight
        }
      ]
    }
  }
}

output "iam_role" {
  description = "The IAM role used by the crawler to access other resources."
  value = {
    arn = aws_sfn_state_machine.this.role_arn
    name = coalesce(
      one(data.aws_iam_role.custom[*].name),
      one(module.role[*].name),
    )
    description = coalesce(
      one(data.aws_iam_role.custom[*].description),
      one(module.role[*].description),
    )
  }
}

output "logging" {
  description = "The configuration to define what execution history events are logged and where they are logged."
  value = {
    enabled                = one(aws_sfn_state_machine.this.logging_configuration[*].level) != "OFF"
    log_level              = one(aws_sfn_state_machine.this.logging_configuration[*].level)
    include_execution_data = one(aws_sfn_state_machine.this.logging_configuration[*].include_execution_data)
    cloudwatch = {
      log_group = var.logging.cloudwatch.log_group
    }
  }
}

output "tracing" {
  description = "The configuration of AWS X-Ray tracing for the state machine."
  value = {
    enabled = one(aws_sfn_state_machine.this.tracing_configuration[*].enabled)
  }
}

output "created_at" {
  description = "The date the state machine was created."
  value       = aws_sfn_state_machine.this.creation_date
}
