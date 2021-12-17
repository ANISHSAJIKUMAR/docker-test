/********************************
 * # CONFIGURE THE AWS PROVIDER *
 ********************************/

provider "aws" {
    region              = var.region
    access_key          = var.access_key
    secret_key          = var.secret_key
}


/************************************************************
 * ==== VPC'S SECURITY GROUP FOR Dockerdb SERVER ====== *
 ************************************************************/

resource "aws_security_group" "Dockerdb_sg" {
    name        = "Dockerdb_sg_${var.enviroument}"
    description = "security group to allow inbound/outbound from the VPC"
    vpc_id      = var.vpc_id

      ingress   {
        from_port        = 5432
        to_port          = 5432
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
      }

      ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
      }

      ingress   {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
      }

      ingress {
        from_port        = 5050
        to_port          = 5050
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
      }
    
      egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
      }
    
}






/********************************************************************************************
 * #---------------------------- CONFIGURING Dockerdb SERVER----------------------------# *
 ********************************************************************************************/
resource "aws_elb" "docker_elb" {
  availability_zones = ["ap-south-1b", "ap-south-1a", "ap-south-1c"]

  listener {
    instance_port     = 5050
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}


data "template_file" "Dockerdb_userdata" {
  template = "${file("timelinedb.sh")}"
  vars = {
  }
}

resource "aws_instance" "Dockerdb_one" {
    ami                         = var.ami
    instance_type               = var.instance_type_Dockerdb
    count                       = 2
    key_name                    = "docker_key"
    user_data                   = data.template_file.Dockerdb_userdata.rendered
    vpc_security_group_ids    = [aws_security_group.Dockerdb_sg.id]
      
    tags = {
      Name                      = "Dockerdb_normal_Server_one${count.index}"
    }
}


resource "aws_eip" "myeip"{
  count = length(aws_instance.Dockerdb_one)
  vpc =true
  instance = "${element(aws_instance.Dockerdb_one.*.id,count.index)}"

  tags ={
    Name = "eip-docker{count.index + 1}"
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "allow_port" {
  name ="alb"
  description = "Allow inbound traffic"
  vpc_id = var.vpc_id
  
  egress {
      from_port     = 0
      to_port       = 0
      protocol      = "-1"
      cidr_blocks   = ["0.0.0.0/0"]
    }
    ingress {
      from_port     = 80
      to_port       = 80
      protocol      = "tcp"
      cidr_blocks   = ["0.0.0.0/0"]
    }
    ingress {
      from_port     = 443
      to_port       = 443
      protocol      = "tcp"
      cidr_blocks   = ["0.0.0.0/0"]
    }
     ingress {
      from_port     = 5050
      to_port       = 5050
      protocol      = "tcp"
      cidr_blocks   = ["0.0.0.0/0"]
    }

  tags  = {
    Name = "allow ports"
  }
}

data "aws_subnet_ids" "subnet" {
  vpc_id = var.vpc_id
}

resource "aws_lb_target_group" "my-target-group"{
  health_check {
    interval  = 10
    path  = "/"
    protocol  = "HTTP"
    timeout = 5
  }
  name = "my-test-tg"
  port  = 5050
  protocol = "HTTP"
  target_type = "instance"
  vpc_id  = var.vpc_id
}

resource "aws_lb" "my-aws-alb" {
  name = "dockerone-test-alb"
  internal  = false
  security_groups = [
    "${aws_security_group.allow_port.id}",
  ]
  subnets = data.aws_subnet_ids.subnet.ids
  tags  = {
    Name  = "jmsth-test-alb"
  }

  ip_address_type = "ipv4"
  load_balancer_type  = "application"

}

resource "aws_lb_listener" "jmsth-test-alb-listener" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port  = 80
  protocol  = "HTTP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.my-target-group.arn}"
    type  ="forward"
  }
}

resource "aws_alb_target_group_attachment" "ec2_attch" {
  count =length(aws_instance.Dockerdb_one)
  target_group_arn  = aws_lb_target_group.my-target-group.arn
  target_id = aws_instance.Dockerdb_one[count.index].id
}
