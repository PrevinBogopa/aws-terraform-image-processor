# Serverless Image Compressor 🖼️⚡

A fully serverless image compression project using **AWS + Terraform**.  

> Built as a learning project to explore serverless architectures, Lambda, S3, and Terraform workflows — no frontend included.  

## Architecture

1️⃣ **API** – Lambda Function URL returns pre-signed S3 upload URLs  
2️⃣ **Worker** – Lambda triggered on S3 uploads, compressing images using Pillow  
3️⃣ **Download** – Compressed images appear in S3 for download  

## Key Learnings

- `jsondecode` vs `jsonencode` in Terraform can break IAM policies  
- Lambda zip files must be packaged correctly to avoid deployment errors  
- S3 bucket names are globally unique — randomness helps  
- Half-created resources are normal — `terraform destroy` is a lifesaver  
- Account-level S3 Block Public Access can block public bucket policies  

## How to Run

1. Clone the repo:  
```bash
git clone https://github.com/previnbogopa/image-compressor.git

Go to the project folder:

cd image-compressor

Initialize Terraform:

terraform init

Apply Terraform:

terraform apply

Upload images via Lambda Function URL (see terraform output)

Compressed images appear in the S3 output bucket

Notes

No frontend is included — this is a backend/serverless demo

Pillow library is required in the Lambda function zip

Buckets are private; direct access requires AWS credentials
