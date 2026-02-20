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
