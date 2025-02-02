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

# EC2 Instance
resource "aws_instance" "nginx_instance" {
  ami                    = "ami-0c55b159cbfafe1f0"  # Update with a valid Ubuntu AMI ID
  instance_type          = "t2.micro"
  #key_name               = aws_key_pair.ec2_key.key_name
  security_group         = aws_security_group.ec2_sg.id
  associate_public_ip_address = true

  # Install and configure Nginx using user data
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install nginx -y
              echo "<h1>Hello from Terraform Nginx!</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "Nginx-Server"
  }

  # # Wait for the EC2 instance to be ready before applying other actions
  # wait_for_capacity_timeout = "0"
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.nginx_instance.public_ip
}
