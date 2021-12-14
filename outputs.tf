output "arn" {
  value = aws_lambda_function.function.arn
}

output "endpoint" {
  value = var.enable_apigw ? module.apigw[0].endpoint : null
}