# Configure the AWS Provider
provider "aws" {
  region  = "eu-west-2"
  #I removed the AWS access keys from here and used a more secured method. 
}

#test is name scope to terraform
resource "aws_instance" "tut-server"{
    ami = "ami-0287acb18b6d8efff"
    instance_type = "t2.micro"
    availability_zone = "eu-west-2a"
    key_name = "tutorial-key"
    

    tags = {
        Name = "Server 1"
    }

    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.tut-network.id
    }

    user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo service start apache2
    sudo bash -c 'echo "My First Web Server" > /var/www/html/index.html'
    EOF 

}


resource "aws_vpc" "tut-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Tutorial"    
    }
}

#Internet gateway
resource "aws_internet_gateway" "gw"{
     vpc_id     = aws_vpc.tut-vpc.id
}

#Internet custom route
resource "aws_route_table" "tut-route-table" {
  vpc_id = aws_vpc.tut-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tut-route"
  }
}

#Creating a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.tut-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "prod-subnet"
  }
}

#Rout table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.tut-route-table.id
}

#
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Wep traffic"
  vpc_id      = aws_vpc.tut-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_network_interface" "tut-network" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

//   attachment {
//     instance     = aws_instance.tut-server.id
//     device_index = 1
//   }
}

#Assign elstic ip to the network interface. private ip is static public will not be. 
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.tut-network.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}


output "server_public_ip" {
    value = aws_eip.one.public_ip
}