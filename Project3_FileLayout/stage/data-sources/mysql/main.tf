provider "aws" {
  region = "eu-west-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "project3-database"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  name = "project3_database"
  username = "admin"

  password = var.db_password
}

// terraform {
//   backend "s3" {
//     #Bucket information
//     bucket = "project3-bucket-fanbondi"
//     key = "stage/data-sources/mysql/terraform.tfstate"
//     region = "eu-west-2"

//     #DynamoDB information
//     dynamodb_table = "project3-locks"
//     encrypt = true
//   }
// }