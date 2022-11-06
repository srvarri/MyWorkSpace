# provider
provider "aws" {
   region     = "us-west-2"
}

# creating VPC
resource "aws_vpc" "temp_vpc" {
  cidr_block       = "192.168.0.0/16"

  tags = {
    Name = "tempvpc"
  }
}

# creating subnet
resource "aws_subnet" "temp-sub" {
  vpc_id     = aws_vpc.temp_vpc.id
  cidr_block = "192.168.0.0/24"
   availability_zone = "us-west-2a"

  tags = {
    Name = "tempsub"
  }
}

# creating aws_internet_gateway
resource "aws_internet_gateway" "temp-igw" {
  vpc_id = aws_vpc.temp_vpc.id

  tags = {
    Name = "tempigw"
  }
}

# internet_gateway attached to vpc
resource "aws_internet_gateway_attachment" "vpc_attach" {
  internet_gateway_id = aws_internet_gateway.temp-igw.id
  vpc_id              = aws_vpc.temp_vpc.id
}

# creating route table
resource "aws_route_table" "temp_rt" {
  vpc_id = aws_vpc.temp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.temp-igw.id
  }
}

# route_table_association with subnet
resource "aws_route_table_association" "assciation" {
  subnet_id      = aws_subnet.temp-sub.id
  route_table_id = aws_route_table.temp_rt.id
}

# creating security group
resource "aws_security_group" "temp_sec" {
  name        = "allow_tcp"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.temp_vpc.id

  ingress {
    description      = "TCP from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TCP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tcp"
  }
}

resource "aws_key_pair" "ssh_key" {
   key_name = "key"
   public_key = file("C:/Users/Sairam/.ssh/id_rsa.pub")
  
}




#resource "aws_instance" "my_instance" {
 # ami                         = "ami-0c09c7eb16d3e8e70"
  #associate_public_ip_address = "true"
  #availability_zone           = "us-west-2a"
  #instance_type               = "t2.micro"
  #key_name                    = "key"
  #security_groups             = [ "${aws_security_group.temp_sec.id}" ]
  #subnet_id                   = aws_subnet.temp-sub.id
  #tags = {
  #  Name = "myinstance"
  #}

#}

# creating Template
resource "aws_launch_template" "my-template" {
  name = "my-template"
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }

  network_interfaces {
    subnet_id = aws_subnet.temp-sub.id
    security_groups = [aws_security_group.temp_sec.id]
    associate_public_ip_address = true
  }

   instance_type = "t2.micro"
   key_name = "key"
   image_id = "ami-0fe8e722313045097"
   placement {
    availability_zone = "us-west-2a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "template"
    }
  }

}

# creating auto scaling groups

resource "aws_autoscaling_group" "my_asg" {
  name = "my_asg"
  availability_zones = ["us-west-2a"]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  health_check_grace_period = 300
  health_check_type = "ELB"


  launch_template {
    id      = aws_launch_template.my-template.id
    version = "$Latest"
  }
}


# Instance Target Group
resource "aws_lb_target_group" "lb-tg" {
  name     = "n-lb-tg"
  port     = 80
  protocol = "TCP"
  target_type = "instance"
  ip_address_type = "ipv4"
  vpc_id   = aws_vpc.temp_vpc.id
  
  health_check {
    protocol = "TCP"
    port = "80"
    healthy_threshold = 3
    interval = 10

  }
}

resource "aws_vpc" "lb_vpc" {
  cidr_block = "192.168.0.0/16"
}

# create aws network-lb
resource "aws_lb" "n-lb" {
  name               = "n-lb"
  internal           = false
  load_balancer_type = "network"
  subnets       = [aws_subnet.temp-sub.id]
  ip_address_type = "ipv4"
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

# creating aws lb listener

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.n-lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.arn
  }
}


#resource "aws_lb_target_group_attachment" "test" {
 # target_group_arn = aws_lb_target_group.lb-tg.arn
 # target_id        = aws_instance.my_instance.id
 # port             = 80
#}



# Create a new load balancer attachment
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.my_asg.id
  lb_target_group_arn    = aws_lb_target_group.lb-tg.arn
}
