#Variables, various datatypes available see page ~84
#To refer to a variable name ijn User Data section use "${...}" e.g. "${var.ssh_port}"
variable "ssh_port" {
    description = "Stores SSH PORT"
    type = number
    default = 22
}