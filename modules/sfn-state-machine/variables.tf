variable "name" {
  description = "(Required) The name of the state machine. The name should only contain `0-9`, `A-Z`, `a-z`, `-`, `_`. The name cannot be changed after creation."
  type        = string
  nullable    = false
}

variable "type" {
  description = <<EOF
  (Optional) The type of the state machine. Valid values are `STANDARD` and `EXPRESS`. You cannot update the type of a state machine once it has been created. Defaults to `false`.
    `STANDARD` - Durable workflows for ETL, ML, e-commerce and automation. They can run for up to 1 year, and history is stored in Step Functions for auditing and playback. Supported by a feature-rich console debugger. Recommended for new users.
    `EXPRESS` - Low cost, high scale workflows for streaming data processing and microservice APIs. They can run for up to 5 minutes, and history can be streamed to CloudWatch Logs.
  EOF
  type        = string
  default     = "STANDARD"
  nullable    = false

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.type)
    error_message = "Valid values for `type` are `STANDARD` or `EXPRESS`."
  }
}

variable "definition" {
  description = "(Required) The Amazon States Language definition of the state machine."
  type        = string
  nullable    = false

  validation {
    condition     = can(jsondecode(var.definition))
    error_message = "The value of `definition` should be JSON document."
  }
}

variable "publish_version" {
  description = "(Optional) Whether to publish a version of the state machine during creation. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "aliases" {
  description = <<EOF
  (Optional) A list of aliases for the state machine that points to one or two versions of the same state machine. You can set your application to call `StartExecution` with an alias and update the version the alias uses without changing the client's code. You can also map an alias to split `StartExecution` requests between two versions of a state machine. You must also specify the percentage of execution run requests each version should receive. Step Functions randomly chooses which version runs a given execution based on the percentage you specify. To create an alias that points to a single version, specify a single version with a weight set to `100`. You can create up to 100 aliases for each state machine. You must delete unused aliases. Each item of `aliases` as defined below.
    (Required) `name` - A name of the state machine alias. To avoid conflict with version ARNs, don't use an integer in the name of the alias.
    (Optional) `description` - A description of the alias.
    (Required) `routing` - A configuration of the state machine alias routing. `routing` as defined below.
      (Required) `version` - The version of the state machine to which the alias points.
      (Optional) `weight` - The percentage of traffic routed to the state machine version. Defaults to `100`.
  EOF
  type = list(object({
    name        = string
    description = optional(string, "Managed by Terraform.")
    routing = optional(list(object({
      version = string
      weight  = optional(number, 100)
    })), [])
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for alias in var.aliases :
      length(alias.routing) > 0 && length(alias.routing) <= 2
    ])
    error_message = "Each alias should have 1 - 2 versions for routing."
  }
}

variable "custom_iam_role" {
  description = "(Optional) The IAM role friendly name (including path without leading slash), or Amazon Resource Name (ARN) of an IAM role, used by the this state machine. Provide `custom_iam_role` if you want to use the IAM role from the outside of this module."
  type        = string
  default     = null
  nullable    = true
}

variable "iam_role" {
  description = <<EOF
  (Optional) A configuration of the default IAM role used by the state machine to access other resources. It is only used when `custom_iam_role` is not provided. `iam_role` as defined below.
    (Optional) `enabled` - Whether to create a default IAM role managed by this module.
    (Optional) `policies` - A list of IAM policies ARNs to attach to IAM role.
    (Optional) `inline_policies` - Map of inline IAM policies to attach to IAM role. (`name` => `policy`).
  EOF
  type = object({
    enabled = optional(bool, true)
    conditions = optional(list(object({
      key       = string
      condition = string
      values    = list(string)
    })), [])
    policies        = optional(list(string), [])
    inline_policies = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "logging" {
  description = <<EOF
  (Optional) The configuration to define what execution history events are logged and where they are logged. Standard Workflows record execution history in AWS Step Functions, although you can optionally configure logging to Amazon CloudWatch Logs. For Express state machines, you must enable logging to inspect and debug executions. `logging` as defined below.
    (Optional) `enabled` - Whether to log the state machine's execution history.
    (Optional) `log_level` - Indicate which execution history events to log. Valid values are `ALL`, `ERROR`, `FATAL`. Defaults to `ALL`.
    (Optional) `include_execution_data` - Whether the log should include execution input, data passed between states, and execution output. Defaults to `false`.
    (Optional) `cloudwatch` - A configuration to define where the execution history events are logged. `cloudwatch` as defined below.
      (Optional) `log_group` - The ARN (Amazon Resource Name) of the CloudWatch Log Group.
  EOF
  type = object({
    enabled                = optional(bool, false)
    log_level              = optional(string, "ALL")
    include_execution_data = optional(bool, false)
    cloudwatch = optional(object({
      log_group = optional(string, "")
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = anytrue([
      var.logging.enabled == false,
      var.logging.enabled && contains(["ALL", "ERROR", "FATAL"], var.logging.log_level)
    ])
    error_message = "Valid values for `log_level` are `ALL`, `ERROR`, `FATAL`."
  }
  validation {
    condition = anytrue([
      var.logging.enabled == false,
      var.logging.enabled && !endswith(var.logging.cloudwatch.log_group, ":*")
    ])
    error_message = "Log Group ARN must not be provided with ':*' suffix."
  }
}

variable "tracing" {
  description = <<EOF
  (Optional) The configuration of AWS X-Ray tracing for the state machine. Step Functions will send traces to AWS X-Ray for state machine executions, even when a trace ID is not passed by an upstream service. Standard X-Ray charges apply. `tracing` as defined below.
    (Optional) `enabled` - Whether to enable X-Ray tracing.
  EOF
  type = object({
    enabled = optional(bool, false)
  })
  default  = {}
  nullable = false
}

variable "timeouts" {
  description = "(Optional) How long to wait for the state machine to be created/updated/deleted."
  type = object({
    create = optional(string, "5m")
    update = optional(string, "1m")
    delete = optional(string, "5m")
  })
  default  = {}
  nullable = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
  nullable    = false
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
  nullable    = false
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}
