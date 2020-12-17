#Add some output variables to see that terraform is using the newly configured backend.
#ARN is Amazon Resource Name. So that is what we want to print. 
output "s3_bucket_arn"{
  value = aws_s3_bucket.project3-state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.project3-locks.name
}
