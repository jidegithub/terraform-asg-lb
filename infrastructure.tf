resource "aws_security_group" "launch_configuration_http" {
  name        = "launch_configuration_http"
  description = "Allow HTTP inbound connections"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Allow HTTP Security Group"
  }
}
resource "aws_security_group_rule" "launch_configuration_http-ingress" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.launch_configuration_http.id
}

resource "aws_security_group_rule" "launch_configuration_http-egress" {
  type = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.launch_configuration_http.id
}

resource "aws_launch_configuration" "web" {
  name_prefix = "web-"

  image_id = "ami-0947d2ba12ee1ff75" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  key_name = "genserver"

  security_groups = [ aws_security_group.launch_configuration_http.id ]
  associate_public_ip_address = true

  user_data = <<USER_DATA
    #!/bin/bash
    yum update
    yum -y install nginx
    echo "$(curl http://169.254.169.254/latest/meta-data/local-ipv4)" > /usr/share/nginx/html/index.html
    chkconfig nginx on
    service nginx start
  USER_DATA

  lifecycle {
    create_before_destroy = true
  }
}