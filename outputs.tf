output "frontend_url" {
  value = aws_s3_bucket_website_configuration.frontend_config.website_endpoint
}

output "lambda_function_url" {
  value = aws_lambda_function_url.function_url.function_url
}