# terraform-aws-lambda

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-lambda?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-lambda?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform module which creates lambda related resources on AWS.

- [sfn-state-machine](./modules/sfn-state-machine)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-lambda) were written to manage the following AWS Services with Terraform.

- **AWS Lambda**
  - Function (Comming soon!)
- **AWS SFN (State Functions)**
  - State Machine
    - Versions & Aliases


## Examples

### AWS Lambda


### AWS SFN (State Functions)

- [sfn-state-machine-flow](./examples/sfn-state-machine-flow)
- [sfn-state-machine-hello-world](./examples/sfn-state-machine-hello-world)
- [sfn-state-machine-logging](./examples/sfn-state-machine-logging)
- [sfn-state-machine-tracing](./examples/sfn-state-machine-tracing)
- [sfn-state-machine-version-aliases](./examples/sfn-state-machine-version-aliases)


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-lambda). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2023, [Byungjin Park](https://www.posquit0.com).
