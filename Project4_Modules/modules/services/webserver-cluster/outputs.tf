output "alb_dns_name" {
    value = aws_lb.project2.dns_name
}


#output selected information about your infrastructure. 
#use sensitive switch to hide something sensitive (when not debugging). 
output "public_ip" {
    value = aws_instance.project2.public_ip
    description = "Public ip of webserver"
}