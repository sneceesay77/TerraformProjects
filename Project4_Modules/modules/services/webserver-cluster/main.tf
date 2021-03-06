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


#Now define a single AWS instance to use. I will comment this infavour of aws_launch_configuration
// resource "aws_instance" "project2"{
//     ami = "ami-0287acb18b6d8efff"
//     instance_type = "t2.micro"
//     vpc_security_group_ids = [aws_security_group.grp.id]
//     key_name = "project2-key"
//     tags = {
//         Name = "Project 2"
//     }

//     user_data = <<-EOF
//     #!/bin/bash
//     sudo apt update -y
//     sudo apt install apache2 -y
//     sudo service apache2 start
//     sudo echo '<h1 style="font:25px; align:center">Welcome to My New Website</h1>' > /var/www/html/index.html
//     EOF
// }

#In most cases or in production environment multiple instances may be prefered to load balance the traffic. 
resource "aws_launch_configuration" "project2"{
    image_id = "ami-0287acb18b6d8efff"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.grp.id]
    key_name = "project2-key"
   

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

#Create autoscale group
resource "aws_autoscaling_group" "project2" {
    name = "project2-asg"
    launch_configuration = aws_launch_configuration.project2.name
    vpc_zone_identifier = data.aws_subnet_ids.default.ids

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10

    lifecycle{
        create_before_destroy = true
    }
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

resource "aws_lb" "project2" {
    name = "project2-asg"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.project2.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "404: Page Not Found"
            status_code = 404
        }
    }
}

#Security group for load balancer. We can have multiple groups like the one above
resource "aws_security_group" "alb" {
   # Allow inbound HTTP requests
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    #Allow all outbound requests
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    } 
}

resource "aws_lb_target_group" "asg" {
    name = "project2-asg"
    port = 80
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "project2" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}



