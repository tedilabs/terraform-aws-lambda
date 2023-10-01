# sfn-state-machine

This module creates following resources.

- `aws_sfn_state_machine`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.17 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.18.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |
| <a name="module_role"></a> [role](#module\_role) | tedilabs/account/aws//modules/iam-role | ~> 0.27.0 |

## Resources

| Name | Type |
|------|------|
| [aws_sfn_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_alias) | resource |
| [aws_sfn_state_machine.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.xray](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_sfn_state_machine_versions.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sfn_state_machine_versions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_definition"></a> [definition](#input\_definition) | (Required) The Amazon States Language definition of the state machine. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the state machine. The name should only contain `0-9`, `A-Z`, `a-z`, `-`, `_`. The name cannot be changed after creation. | `string` | n/a | yes |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | (Optional) A list of aliases for the state machine that points to one or two versions of the same state machine. You can set your application to call `StartExecution` with an alias and update the version the alias uses without changing the client's code. You can also map an alias to split `StartExecution` requests between two versions of a state machine. You must also specify the percentage of execution run requests each version should receive. Step Functions randomly chooses which version runs a given execution based on the percentage you specify. To create an alias that points to a single version, specify a single version with a weight set to `100`. You can create up to 100 aliases for each state machine. You must delete unused aliases. Each item of `aliases` as defined below.<br>    (Required) `name` - A name of the state machine alias. To avoid conflict with version ARNs, don't use an integer in the name of the alias.<br>    (Optional) `description` - A description of the alias.<br>    (Required) `routing` - A configuration of the state machine alias routing. `routing` as defined below.<br>      (Required) `version` - The version of the state machine to which the alias points.<br>      (Optional) `weight` - The percentage of traffic routed to the state machine version. Defaults to `100`. | <pre>list(object({<br>    name        = string<br>    description = optional(string, "Managed by Terraform.")<br>    routing = optional(list(object({<br>      version = string<br>      weight  = optional(number, 100)<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_custom_iam_role"></a> [custom\_iam\_role](#input\_custom\_iam\_role) | (Optional) The IAM role friendly name (including path without leading slash), or Amazon Resource Name (ARN) of an IAM role, used by the this state machine. Provide `custom_iam_role` if you want to use the IAM role from the outside of this module. | `string` | `null` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | (Optional) A configuration of the default IAM role used by the state machine to access other resources. It is only used when `custom_iam_role` is not provided. `iam_role` as defined below.<br>    (Optional) `enabled` - Whether to create a default IAM role managed by this module.<br>    (Optional) `policies` - A list of IAM policies ARNs to attach to IAM role.<br>    (Optional) `inline_policies` - Map of inline IAM policies to attach to IAM role. (`name` => `policy`). | <pre>object({<br>    enabled = optional(bool, true)<br>    conditions = optional(list(object({<br>      key       = string<br>      condition = string<br>      values    = list(string)<br>    })), [])<br>    policies        = optional(list(string), [])<br>    inline_policies = optional(map(string), {})<br>  })</pre> | `{}` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | (Optional) The configuration to define what execution history events are logged and where they are logged. Standard Workflows record execution history in AWS Step Functions, although you can optionally configure logging to Amazon CloudWatch Logs. For Express state machines, you must enable logging to inspect and debug executions. `logging` as defined below.<br>    (Optional) `enabled` - Whether to log the state machine's execution history.<br>    (Optional) `log_level` - Indicate which execution history events to log. Valid values are `ALL`, `ERROR`, `FATAL`. Defaults to `ALL`.<br>    (Optional) `include_execution_data` - Whether the log should include execution input, data passed between states, and execution output. Defaults to `false`.<br>    (Optional) `cloudwatch` - A configuration to define where the execution history events are logged. `cloudwatch` as defined below.<br>      (Optional) `log_group` - The ARN (Amazon Resource Name) of the CloudWatch Log Group. | <pre>object({<br>    enabled                = optional(bool, false)<br>    log_level              = optional(string, "ALL")<br>    include_execution_data = optional(bool, false)<br>    cloudwatch = optional(object({<br>      log_group = optional(string, "")<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_publish_version"></a> [publish\_version](#input\_publish\_version) | (Optional) Whether to publish a version of the state machine during creation. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | (Optional) How long to wait for the state machine to be created/updated/deleted. | <pre>object({<br>    create = optional(string, "5m")<br>    update = optional(string, "1m")<br>    delete = optional(string, "5m")<br>  })</pre> | `{}` | no |
| <a name="input_tracing"></a> [tracing](#input\_tracing) | (Optional) The configuration of AWS X-Ray tracing for the state machine. Step Functions will send traces to AWS X-Ray for state machine executions, even when a trace ID is not passed by an upstream service. Standard X-Ray charges apply. `tracing` as defined below.<br>    (Optional) `enabled` - Whether to enable X-Ray tracing. | <pre>object({<br>    enabled = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | (Optional) The type of the state machine. Valid values are `STANDARD` and `EXPRESS`. You cannot update the type of a state machine once it has been created. Defaults to `false`.<br>    `STANDARD` - Durable workflows for ETL, ML, e-commerce and automation. They can run for up to 1 year, and history is stored in Step Functions for auditing and playback. Supported by a feature-rich console debugger. Recommended for new users.<br>    `EXPRESS` - Low cost, high scale workflows for streaming data processing and microservice APIs. They can run for up to 5 minutes, and history can be streamed to CloudWatch Logs. | `string` | `"STANDARD"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aliases"></a> [aliases](#output\_aliases) | A map of aliases for the state machine. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the state machine. |
| <a name="output_created_at"></a> [created\_at](#output\_created\_at) | The date the state machine was created. |
| <a name="output_definition"></a> [definition](#output\_definition) | The Amazon States Language definition of the state machine. |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | The IAM role used by the crawler to access other resources. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the state machine. |
| <a name="output_latest_version"></a> [latest\_version](#output\_latest\_version) | The information of the latest version for the state machine. |
| <a name="output_logging"></a> [logging](#output\_logging) | The configuration to define what execution history events are logged and where they are logged. |
| <a name="output_name"></a> [name](#output\_name) | The name of the state machine. |
| <a name="output_status"></a> [status](#output\_status) | The current status of the state machine. Either `ACTIVE` or `DELETING`. |
| <a name="output_tracing"></a> [tracing](#output\_tracing) | The configuration of AWS X-Ray tracing for the state machine. |
| <a name="output_type"></a> [type](#output\_type) | The type of the state machine. |
| <a name="output_versions"></a> [versions](#output\_versions) | A map of versions for the state machine. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
