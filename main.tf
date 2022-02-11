locals {
  async_destinations = try(distinct(flatten([for i in values(var.event_invoke) : values(i.destination_config)])), [])
}

resource "aws_iam_role" "role" {
  count = var.create_role ? 1 : 0
  name  = format("AWSLambdaServiceRole-%s", var.name)
  tags  = var.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
  ]

  dynamic "inline_policy" {
    for_each = length(var.dead_letter_target) != 0 ? [true] : []

    content {
      name = "lambda-deadletter"
      policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "deadletteraccess"
            "Effect" : "Allow",
            "Action" : [
              "sqs:SendMessage",
              "sns:Publish"
            ],
            "Resource" : var.dead_letter_target
          }
        ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = length(local.async_destinations) != 0 ? [true] : []

    content {
      name = "lambda_async_destination_permissions"
      policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "asyncdestaccess"
            "Effect" : "Allow",
            "Action" : [
              "sqs:SendMessage",
              "sns:Publish",
              "lambda:InvokeFunction",
              "events:PutEvents"
            ],
            "Resource" : local.async_destinations
          }
        ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.policy

    content {
      name   = lookup(inline_policy.value, "name", "")
      policy = jsonecode(lookup(inline_policy.value, "policy", {}))
    }
  }
}

resource "aws_lambda_permission" "permission" {
  for_each = var.lambda_permissions

  statement_id  = each.key
  action        = lookup(each.value, "action", "lambda:InvokeFunction")
  function_name = aws_lambda_function.function.function_name
  principal     = lookup(each.value, "principal", null)
  source_arn    = lookup(each.value, "source_arn", null)
}

resource "aws_lambda_function_event_invoke_config" "event_invoke" {
  for_each = var.event_invoke

  depends_on = [
    aws_lambda_function.function,
    aws_lambda_alias.alias
  ]

  function_name = aws_lambda_function.function.function_name

  maximum_event_age_in_seconds = lookup(each.value, "max_age", null)
  maximum_retry_attempts       = lookup(each.value, "max_retry", null)
  qualifier                    = lookup(each.value, "qualifier", null)

  dynamic "destination_config" {
    for_each = lookup(each.value, "destination_config", {}) != {} ? [lookup(each.value, "destination_config", {})] : []

    content {
      on_failure {
        destination = lookup(destination_config.value, "failure_destination", null)
      }

      on_success {
        destination = lookup(destination_config.value, "success_destination", null)
      }
    }
  }
}

resource "aws_lambda_function" "function" {
  function_name = var.name
  description   = var.description
  tags          = var.tags
  role          = var.create_role ? aws_iam_role.role[0].arn : var.role

  memory_size  = var.memory_size
  timeout      = var.timeout
  package_type = var.package_type
  publish      = var.publish

  image_uri = var.package_type == "Image" ? var.image_uri : null
  dynamic "image_config" {
    for_each = var.image_config != {} ? [var.image_config] : []

    content {
      command           = lookup(image_config.value, "command", [])
      entry_point       = lookup(image_config.value, "entry_point", [])
      working_directory = lookup(image_config.value, "working_directory", "")
    }
  }

  filename         = var.package_type == "Zip" ? var.filename : null
  source_code_hash = var.package_type == "Zip" ? filebase64sha256(var.filename) : null
  handler          = var.package_type == "Zip" ? var.handler : null
  runtime          = var.package_type == "Zip" ? var.runtime : null

  dynamic "dead_letter_config" {
    for_each = length(var.dead_letter_target) != 0 ? [true] : []

    content {
      target_arn = var.dead_letter_target
    }
  }

  kms_key_arn = length(var.kms_key_arn) != 0 ? var.kms_key_arn : null
  dynamic "environment" {
    for_each = var.environment_variables != {} ? [true] : []

    content {
      variables = var.environment_variables
    }
  }

  dynamic "tracing_config" {
    for_each = length(var.tracing_mode) != 0 ? [true] : []

    content {
      mode = var.tracing_mode
    }
  }

  dynamic "vpc_config" {
    for_each = [var.vpc_config]

    content {
      security_group_ids = lookup(vpc_config.value, "security_group_ids", [])
      subnet_ids         = lookup(vpc_config.value, "subnet_ids", [])
    }
  }
}

resource "aws_lambda_alias" "alias" {
  for_each = var.aliases

  name             = each.key
  description      = lookup(each.value, "description", null)
  function_name    = aws_lambda_function.function.arn
  function_version = lookup(each.value, "version", "$LATEST")
  dynamic "routing_config" {
    for_each = lookup(each.value, "additional_version_weights", {}) != {} ? [true] : []

    content {
      additional_version_weights = lookup(each.value, "additional_version_weights", {})
    }
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = format("/aws/lambda/%s", var.name)
  tags = var.tags
}

data "aws_lambda_function" "reciever" {
  count = var.enable_retry_logic ? 1 : 0

  function_name = var.reciever_lambda
}

resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
  count = var.enable_retry_logic ? 1 : 0

  name            = format("%s-retry-logfilter", var.name)
  log_group_name  = aws_cloudwatch_log_group.log_group.name
  filter_pattern  = var.filter_pattern
  destination_arn = data.aws_lambda_function.reciever[0].arn
}

module "apigw" {
  source = "github.com/variant-inc/terraform-aws-apigateway-v2?ref=v1"
  count = var.enable_apigw ? 1 : 0

  name = format("%s-apigw", var.name)
  description   = format("API Gateway created for %s Lambda by terraform.", var.name)
  tags = var.tags
  integrations = {
    for k,v in var.aliases : k => merge(
      {"integration_uri" = aws_lambda_alias.alias[k].invoke_arn},
      {"payload_format_version" = "2.0"},
      v
    )
  }
}

resource "aws_lambda_permission" "apigw" {
  count = var.enable_apigw ? 1 : 0

  statement_id  = module.apigw[0].id
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = join("/", [split("/", module.apigw[0].default_arn)[0], "*", "$default"])
}