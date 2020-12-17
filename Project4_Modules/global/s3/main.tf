#Managing terraform state. Using shared resources. This is great interms
#of collaboration. 

provider "aws" {
  region = "eu-west-2"
}

// terraform {
//   backend "s3" {
//     #Bucket information
//     bucket = "project3-bucket-fanbondi"
//     key = "global/s3/terraform.tfstate"
//     region = "eu-west-2"

//     #DynamoDB information
//     dynamodb_table = "project3-locks"
//     encrypt = true
//   }
// }

#Create an S3 bicket
resource "aws_s3_bucket" "project3-state" {
  bucket = "project3-bucket-fanbondi"
  force_destroy = true

  #Prevent accidental deletion, even with terraform destroy. 
  #To delete comment it out. 
  // lifecycle {
  //   prevent_destroy = true
  // }

  #Enable versioning
  versioning {
    enabled = true
  }

  #Enable server side encryption
  server_side_encryption_configuration{
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

#Create AWS dynamo DB resource for locking with a 
#state file is acquired by a collaborator

resource "aws_dynamodb_table" "project3-locks" {
  name = "project3-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
