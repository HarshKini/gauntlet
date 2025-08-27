package harsh.security

deny contains msg if {
  input.resource.type == "aws_s3_bucket"
  input.resource.public == true
  msg := "Public S3 bucket is not allowed"
}
