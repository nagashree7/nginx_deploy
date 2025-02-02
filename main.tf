provider "aws" {
  region = "us-east-1"
}

# EC2 Security Group allowing HTTP and SSH
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2_sg"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx_instance" {
  ami                    = "ami-0c614dee691cbbf37"  # Update with a valid Ubuntu AMI ID
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              echo "<h1>Welcome to Cloud Practice</h1>" > /usr/share/nginx/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "Nginx-Server"
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.nginx_instance.public_ip
}
