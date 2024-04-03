resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true # Enable auto-assign public IP
}

# Create Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Launch EC2 Instance
# Launch EC2 Instance
resource "aws_instance" "my_instance" {
  ami             = var.ami_id
  instance_type   = "t2.micro"
  key_name        = var.keypair_name
  subnet_id       = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true # Enable auto-assign public IP for the instance

  tags = {
    Name = "ExampleInstance"
  }

  # Connection block to execute remote commands
  connection {
    type        = "ssh"
    user        = "ec2-user" # For Amazon Linux
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  # Provisioner to install Apache and add HTML file
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "echo '<!DOCTYPE html><html><head><title>Server IP Address</title></head><body><h1>Server IP Address</h1><p>The local IP address of this server is: <?php echo $_SERVER[\"SERVER_ADDR\"]; ?></p></body></html>' | sudo tee /var/www/html/index.html"
    ]
  }
}


# Define Security Group
resource "aws_security_group" "my_security_group" {
  name        = "example-security-group"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

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