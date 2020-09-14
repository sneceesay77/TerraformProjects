
#Define the provider, here we are going to use AWS
provider "aws" {
    region = "eu-west-2"
}


#Now define AWS instance to use. 
resource "aws_instance" "project2"{
    ami = "ami-0287acb18b6d8efff"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.grp.id]
    key_name = "project2-key"
    tags = {
        Name = "Project 2"
    }

    user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo service apache2 start
    sudo echo '<h1 style="font:25px; align:center">Welcome to My New Website</h1>' > /var/www/html/index.html
    EOF
}

#Security group. By default EC2 instances are closed in and out. So here we define
#incoming and outgoing ports using ingress and egress. Without the egress the server
#would not be able to reach outside.
resource "aws_security_group" "grp" {
    name = "project2-instance-security-group"

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
   }
}

#Variables, various datatypes available see page ~84
#To refer to a variable name ijn User Data section use "${...}" e.g. "${var.ssh_port}"
variable "ssh_port" {
    description = "Stores SSH PORT"
    type = number
    default = 22
}

#output selected information about your infrastructure. 
#use sensitive switch to hide something sensitive (when not debugging). 
output "public_ip" {
    value = aws_instance.project2.public_ip
    description = "Public ip of webserver"
}

