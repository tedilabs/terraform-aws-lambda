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
  "Comment": "A Hello World example of the Amazon States Language using Pass states",
  "StartAt": "Hello",
  "States": {
    "Hello": {
      "Type": "Pass",
      "Result": "Hello",
      "Next": "World"
    },
    "World": {
      "Type": "Pass",
      "Result": "World",
      "End": true
    }
  }
}
  EOF


  ## Versions & Aliases
  publish_version = true
  aliases = [
    {
      name = "stable"
      routing = [
        {
          version = 1
          weight  = 100
        }
      ]
    }
  ]


  tags = {
    "project" = "terraform-aws-lambda-examples"
  }
}
