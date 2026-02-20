terraform{
    required_providers{
        aws = {
            source ="hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "upload_bucket" {
    bucket = "image-upload-bucket-12345"
}

resource "aws_s3_bucket" "compressed_bucket" {
    bucket = "image-compressed-bucket-12345"
}

resource "aws_s3_bucket" "frontend_bucket" {
    bucket = "image-frontend-bucket-12345"
}

resource "aws_s3_bucket_website_configuration" "frontend_config" {
bucket = aws_s3_bucket.frontend_bucket.id 

index_document{
    suffix = "index.html"
}
}

resource "aws_s3_bucket_public_access_block" "frontend_public" {
    bucket = aws_s3_bucket.frontend_bucket.id
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_policy" {
    bucket = aws_s3_bucket.frontend_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = "*"
            Action = ["s3:GetObject"]
            Resource= "${aws_s3_bucket.frontend_bucket.arn}/*"
        }]
    })
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

    role= aws_iam_role.lambda_role.id

    policy =jsonencode({
        Version = "2012-10-17"
        Statement=[
            {
                Effect="Allow"
                Action=[
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
    role = aws_iam_role.lambda_role.arn
    handler="lambda.lambda_handler"
    runtime = "python3.10"

    filename="lambda/lambda.zip"
    source_code_hash = filebase64sha256("lambda/lambda.zip")

    environment {
        variables= {
UPLOAD_BUCKET= aws_s3_bucket.upload_bucket.bucket
COMPRESSED_BUCKET=aws_s3_bucket.compressed_bucket.bucket
        }
    }
}


resource "aws_lambda_function_url" "function_url" {
    function_name = aws_lambda_function.image_lambda.function_name
    authorization_type = "NONE"
}

resource "aws_lambda_permission" "allow_s3" {
    statement_id = "AllowS3Invoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.image_lambda.function_name
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.upload_bucket.arn
}
