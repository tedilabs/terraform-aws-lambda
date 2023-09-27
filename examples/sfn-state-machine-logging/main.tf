provider "aws" {
  region = "us-east-1"
}


###################################################
# State Machine for Step Functions
###################################################

module "state_machine" {
  source = "../../modules/sfn-state-machine"
  # source  = "tedilabs/lambda/aws//modules/sfn-state-machine"
  # version = "~> 0.2.0"

  name = "hello-world"
  type = "STANDARD"

  definition = <<EOF
  {
    "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
    "StartAt": "HelloWorld",
    "States": {
      "HelloWorld": {
        "Type": "Task",
        "Resource": "${module.lambda_function.lambda_function_arn}",
        "End": true
      }
    }
  }
  EOF


  ## Observability
  logging = {
    enabled                = true
    log_level              = "ALL"
    include_execution_data = true

    cloudwatch = {
      log_group = module.log_group.arn
    }
  }


  ## Security
  iam_role = {
    enabled = true
  }


  tags = {
    "project" = "terraform-aws-lambda-examples"
  }
}
