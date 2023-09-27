output "state_machine" {
  description = "The state machine."
  value       = module.state_machine
}

output "lambda_function" {
  description = "The Lambda Function."
  value       = module.lambda_function
}

output "log_group" {
  description = "The CloudWatch Log Group."
  value       = module.log_group
}
