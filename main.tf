// Define the AWS provider and region
provider "aws" {
  region = "ap-southeast-1"
}

// Create the S3 bucket with public-read ACL
resource "aws_s3_bucket" "bucket" {
  bucket = "terrademo2m"
  website {
    index_document = "index.html"
  }
}


// Define IAM policy document for public read access to index.html
data "aws_iam_policy_document" "public_read_index_html" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}


// Attach the public read policy to the bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.public_read_index_html.json
}


resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket,
    aws_s3_bucket_public_access_block.bucket,
  ]

  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
}


// Upload index.html to the S3 bucket
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  source = "index.html"  // This assumes index.html is in the root of your
  content_type = "text/html"
}
