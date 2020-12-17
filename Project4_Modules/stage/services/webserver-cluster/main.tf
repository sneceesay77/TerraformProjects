
#Define the provider, here we are going to use AWS
provider "aws" {
    region = "eu-west-2"
}

#Uncomment this after the first init then run init again. 
// terraform {
//   backend "s3" {
//     #Bucket information
//     bucket = "project3-bucket-fanbondi"
//     key = "stage/services/webserver-cluster/terraform.tfstate"
//     region = "eu-west-2"

//     #DynamoDB information
//     dynamodb_table = "project3-locks"
//     encrypt = true
//   }
// }


module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"
}