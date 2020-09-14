
#Define the provider, here we are going to use AWS
provider "aws" {
    region = "eu-west-2"
}


#Now define AWS instance to use. 
resource "aws_instance" "project2"{
    ami = "ami-0287acb18b6d8efff"
    instance_type = "t2.micro"
    tags = {
        Name = "Project 2"
    }
}

