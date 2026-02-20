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
