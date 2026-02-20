terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

 resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "upload_bucket" {
  bucket = "image-upload-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "compressed_bucket" {
  bucket = "image-compressed-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "image-frontend-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_website_configuration" "frontend_config" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }
}

 

 

# IAM ROLE

resource "aws_iam_role" "lambda_role" {

  name = "image_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "image_lambda_policy"

  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "image_lambda" {
  function_name = "image-compressor-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.10"

  filename         = "lambda/lambda.zip"
  source_code_hash = filebase64sha256("lambda/lambda.zip")

  environment {
    variables = {
      UPLOAD_BUCKET     = aws_s3_bucket.upload_bucket.bucket
      COMPRESSED_BUCKET = aws_s3_bucket.compressed_bucket.bucket
    }
  }
}


resource "aws_lambda_function_url" "function_url" {
  function_name      = aws_lambda_function.image_lambda.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}