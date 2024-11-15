# Security Group for EC2 Instance
resource "aws_security_group" "ec2_sg" {
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Vulnerable: SSH open to the world (medium severity)
    # cidr_blocks = ["192.168.0.0/16"] # Secured: SSH restricted to internal IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS Database
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow traffic from EC2 instance to RDS"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port       = 3306 # Port for MySQL
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # Allow only from ec2_sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
