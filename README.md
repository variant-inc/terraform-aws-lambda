# Terraform AWS Lambda Function module

- [Terraform AWS Lambda Function module](#terraform-aws-lambda-function-module)
  - [Input Variables](#input-variables)
  - [Variable definitions](#variable-definitions)
    - [name](#name)
    - [description](#description)
    - [create_role](#create_role)
    - [policy](#policy)
    - [role](#role)
    - [memory_size](#memory_size)
    - [timeout](#timeout)
    - [package_type](#package_type)
    - [publish](#publish)
    - [image_uri](#image_uri)
    - [image_config](#image_config)
    - [filename](#filename)
    - [handler](#handler)
    - [runtime](#runtime)
    - [dead_letter_target](#dead_letter_target)
    - [kms_key_arn](#kms_key_arn)
    - [environment_variables](#environment_variables)
    - [tracing_mode](#tracing_mode)
    - [vpc_config](#vpc_config)
    - [aliases](#aliases)
    - [lambda_permissions](#lambda_permissions)
    - [event_invoke](#event_invoke)
    - [enable_retry_logic](#enable_retry_logic)
    - [reciever_lambda](#reciever_lambda)
    - [filter_pattern](#filter_pattern)
  - [Examples](#examples)
    - [`main.tf`](#maintf)
    - [`terraform.tfvars.json`](#terraformtfvarsjson)
    - [`provider.tf`](#providertf)
    - [`variables.tf`](#variablestf)
    - [`outputs.tf`](#outputstf)

## Input Variables
| Name     | Type    | Default   | Example     | Notes   |
| -------- | ------- | --------- | ----------- | ------- |
| name | string |  | "test-lambda" |  |
| description | string | "" | "Test Lambda function" |  |
| create_role | bool | true | false |  |
| policy | list(any) | [] | `see below` |  |
| role | string | "" | "arn:aws:iam::319244236588:role/service-role/test-lambda-role" |  |
| memory_size | number | 128 | 4096 |  |
| timeout | number | 3 | 600 |  |
| package_type | string | "Image" | "Zip" |  |
| publish | bool | true | false |  |
| image_uri | string | "" | "319244236588.dkr.ecr.us-east-1.amazonaws.com/test-image:latest" |  |
| image_config | any | {} | `see below` |  |
| filename | string | "" | "test-lambda.zip" |  |
| handler | string | "" | "index.test" |  |
| runtime | string | "" | "python3.9" | [Runtimes]<https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime> |
| dead_letter_target | string | "" | "arn:aws:sns:us-east-1:319244236588:test-sns-lambda-dl" |  |
| kms_key_arn | string | "" | "arn:aws:kms:us-east-1:319244236588:key/dfed962d-0968-42b4-ad36-7762dac7ca20" |  |
| environment_variables | any | {} | {"var1": "value1"} |  |
| tracing_mode | string | "" | "PassThrough" |  |
| vpc_config | map(list(string)) | {} | `see below` |  |
| aliases | any | `see below` | `see below` |  |
| lambda_permissions | any | {} | `see below` |  |
| event_invoke | any | {} | `see below` |  |
| enable_retry_logic | bool | false | true |  |
| reciever_lambda | string | "receive-alert" | "some-other-lambda" |  |
| filter_pattern | string | "?ERROR ?event_log" | "?INFO" |  |

## Variable definitions

### name
Name of the Lambda Function. Used for naming other connected resources.
```json
"name": "<Lambda Function name>"
```

### description
Description of the lambda function.
```json
"description": "<Lambda Function description>"
```

Default:
```json
"description": ""
```

### create_role
Specifies if IAM role for the Lambda Function will be created in module or externally.
`true` - created with module
`false` - created externally
```json
"create_role": <true or false>
```

Default:
```json
"create_role": true
```

### policy
Additional inline policy statements for Lambda execution role.
Effective only if `create_role` is set to `true`.
```json
"policy": [<list of inline policies>]
```

Default:
```json
"policy": []
```

### role
ARN of externally created role. Use in case of `create_role` is set to `false`.
```json
"role": "<role ARN>"
```

Default:
```json
"role": ""
```

### memory_size
Number of Mega Bytes (MB) assigned to Lambda Function.
Valid values are whole numbers between 128 and 10240.
```json
"memory_size": <number of MB>
```

Default:
```json
"memory_size": 128
```

### timeout
Timeout for Lambda function in seconds.
Maximum 900 (15 min)
```json
"timeout": <number of seconds>
```

Default:
```json
"timeout": 3
```

### package_type
Type of package for Lambda Function.
```json
"package_type": "<Image or Zip>"
```

Default:
```json
"package_type": "Image"
```

### publish
Specifies should new version be published with each change in lambda configuration or code.
```json
"publish": <true or false>
```

Default:
```json
"publish": true
```

### image_uri
URI of ECR image used for this Lambda Function.
Conflicts with `filename`, use only if `package_type` is set to `"Image"`.
```json
"image_uri": "<image uri from ECR>"
```

Default:
```json
"image_uri": ""
```

### image_config
Additional config for image, used to override entrypoint, command and working directory.
```json
"image_config": {
  "command": ["<list of strings used as command when running lambda>"],
  "entry_point": ["<list of strings used as enty point when running lambda>"],
  "working_directory": "<string used as working directory when running lambda>"
}
```

Default:
```json
"image_config": {}
```

### filename
Filename of Zip archive containing the code.
Conflicts with `image_uri`, use only if `package_type` is set to `"Zip"`.
```json
"filename": "<Zip archive name>"
```

Default:
```json
"filename": ""
```

### handler
Custom entrypoint which can be used if we use file based deployment.
```json
"handler": "<name of custom handler file>"
```

Default:
```json
"handler": ""
```
| runtime | string | "" | "python3.9" | [Runtimes]<https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime> |

### runtime
Runtime config for file based deployment.
Supported runtimes: <https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime>
```json
"runtime": "<name of the runtime>"
```

Default:
```json
"runtime": ""
```

### dead_letter_target
ARN of deadletter target, SNS topic or SQS queue supported.
```json
"dead_letter_target": "<ARN of SNS topic or SQS queue>"
```

Default:
```json
"dead_letter_target": ""
```

### kms_key_arn
ARN of the KSM key used to encrypt environment variables.
```json
"kms_key_arn": "<ARN of KMS key>"
```

Default:
```json
"kms_key_arn": ""
```

### environment_variables
Map containing all environment variables and their values.
```json
"environment_variables": {<map of env variables and values>}
```

Default:
```json
"environment_variables": {}
```

### tracing_mode
Tracing mode for controllin x-ray tracing.
Valid values are: `PassThrough` and `Active`
```json
"tracing_mode": "<PassThrough or Active>"
```

Default:
```json
"tracing_mode": ""
```

### vpc_config
Configuration for integrating Lambda inside the VPC.
Supports multiple subnets and security groups.
```json
"vpc_config": {
  "security_group_ids": ["<list of security group IDs>"],
  "subnet_ids": ["<List of subnet IDs>"]
}
```

Default:
```json
"vpc_config": {}
```

### aliases
ARN of the KSM key used to encrypt environment variables.
Multiple aliases can be specified together with waighted versions.
```json
"aliases": "<ARN of KMS key>"
```

Default:
```json
"aliases": {
  "prod": {
    "description": "Default alias",
    "version": "$LATEST"
  }
}
```

### lambda_permissions
Map of resource based permissions for this Lambda Function.
Used to allow other services to invoke this Lambda Function.
```json
"lambda_permissions": {
  "<permission sid>": {
    "action": "<action, mostly lambda:InvokeFunction>",
    "principal": "<service principal which will invoke the Function>",
    "source_arn": "<ARN of source which will invoke, without it principal from any account could invoke this Function>"
  }
}
```

Default:
```json
"lambda_permissions": {}
```

### event_invoke
Configuration for asynchronus execution together wi
```json
"event_invoke": {
  "<name of config>": {
    "max_age": <maximum age of invocation in seconds>,
    "max_retry": <number of retries if failed>,
    "qualifier": "<version or alias for which this config applies>",
    "destination_config": {
      "failure_destination": "<ARN of destination for failed invocations>",
      "success_destination": "<ARN of destination for successful invocations>"
    }
  }
}
```

Default:
```json
"event_invoke": {}
```

### enable_retry_logic
Enabling retry logic with [SREve bot]<https://drivevariant.atlassian.net/wiki/spaces/SRE/pages/2267185175/Retry+Bot+Setup+Checklist>.
If `true` creates CloudWatch log group and subscription filter with data specified in `reciever_lambda` and `filter_pattern`.
```json
"enable_retry_logic": <true or false>
```

Default:
```json
"enable_retry_logic": false
```

### reciever_lambda
Name of the Lambda function that receives failed attemts through cloudwatch log filter.
Which is later on used in [SREve bot]<https://drivevariant.atlassian.net/wiki/spaces/SRE/pages/2267185175/Retry+Bot+Setup+Checklist>
```json
"reciever_lambda": "<Lambda name>"
```

Default:
```json
"reciever_lambda": "receive-alert"
```

### filter_pattern
Pattern for defining log subscription filter to be used with [SREve bot]<https://drivevariant.atlassian.net/wiki/spaces/SRE/pages/2267185175/Retry+Bot+Setup+Checklist>
```json
"filter_pattern": "<Pattern to for log subscription filter>"
```

Default:
```json
"filter_pattern": "?ERROR ?event_log"
```

## Examples
### `main.tf`
```terarform
module "lambda" {
  source = "github.com/variant-inc/terraform-aws-lambda?ref=v1"

  name        = var.name
  description = var.description
  create_role = var.create_role
  policy      = var.policy
  role        = var.role

  memory_size   = var.memory_size
  timeout       = var.timeout
  package_type  = var.package_type

  publish       = var.publish
  image_uri     = var.image_uri
  image_config  = var.image_config
  filename      = var.filename
  handler       = var.handler
  runtime       = var.runtime

  dead_letter_target    = var.dead_letter_target
  kms_key_arn           = var.kms_key_arn
  environment_variables = var.environment_variables
  tracing_mode          = var.tracing_mode
  vpc_config            = var.vpc_config
  aliases               = var.aliases
  lambda_permissions    = var.lambda_permissions
  event_invoke          = var.event_invoke
  enable_retry_logic    = var.enable_retry_logic
  reciever_lambda       = var.reciever_lambda
  filter_pattern        = var.filter_pattern
}
```

### `terraform.tfvars.json`
```json
{
  "name": "test-lambda",
  "description": "This is Lambda for testing the module.",
  "create_role": true,
  "memory_size": 128,
  "timeout": 5,
  "package_type": "Image",
  "publish": true,
  "image_uri": "319244236588.dkr.ecr.us-east-1.amazonaws.com/luka-test:latest",
  "image_config": {
    "command": [],
    "entry_point": [],
    "working_directory": ""
  },
  "dead_letter_target": "arn:aws:sns:us-east-1:319244236588:test-sns-lambda",
  "kms_key_arn": "",
  "environment_variables": {
    "env_var_1": "test-env-variable"
  },
  "tracing_mode": "",
  "vpc_config": {
    "security_group_ids": [],
    "subnet_ids": []
  },
  "aliases": {
    "prod": {
      "description": "Production alias.",
      "version": 1
    },
    "dev": {
      "version": "$LATEST"
    }
  },
  "lambda_permissions": {
    "allowCloudWatch": {
      "action": "lambda:InvokeFunction",
      "principal": "logs.us-east-1.amazonaws.com",
      "source_arn": "arn:aws:logs:us-east-1:319244236588:log-group:/aws/lambda/*"
    }
  },
  "event_invoke": {
    "prod": {
      "max_age": 6000,
      "max_retry": 2,
      "qualifier": "prod",
      "destination_config": {
        "failure_destination": "arn:aws:sns:us-east-1:319244236588:test-sns-lambda",
        "success_destination": "arn:aws:sqs:us-east-1:319244236588:test-lambda-sqs"
      }
    }
  },
  "enable_retry_logic": true,
  "reciever_lambda": "receive-alert",
  "filter_pattern": "?ERROR ?event_log"
}
```

Basic
```json
{
  "name": "test-lambda",
  "image_uri": "319244236588.dkr.ecr.us-east-1.amazonaws.com/luka-test:latest"
}
```

### `provider.tf`
```terraform
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      team : "DataOps",
      purpose : "lambda_test",
      owner : "Luka"
    }
  }
}
```

### `variables.tf`
copy ones from module

### `outputs.tf`
```terraform
output "lambda_arn" {
  value       = module.lambda.arn
  description = "ARN of Lambda Function"
}
```