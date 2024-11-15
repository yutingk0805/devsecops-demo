# EC2 instance with EBS volume attached
resource "aws_instance" "web" {
  ami             = "ami-0474411b350de35fb"
  instance_type   = "t2.micro"
  subnet_id       = data.aws_subnets.public.ids[0]
  security_groups = [aws_security_group.ec2_sg.id]

  # Attaching EBS Volume (deliberately vulnerable - unencrypted)
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    # encrypted   = false # Medium Severity: Vulnerable (unencrypted EBS)

    # Secure configuration (commented out):
    encrypted = true
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}

# IAM Role for EC2 instance (deliberately vulnerable - Full Admin Access)
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  # Deliberately vulnerable IAM Policy (Full Admin Access)
  inline_policy {
    name = "admin-policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action   = "*",
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }

  # Secure policy (commented out)
  # inline_policy {
  #   name = "s3-rds-policy"
  #   policy = jsonencode({
  #     Version = "2012-10-17",
  #     Statement = [
  #       {
  #         Action   = ["s3:PutObject", "s3:GetObject"],
  #         Effect   = "Allow",
  #         Resource = "${aws_s3_bucket.bucket.arn}/*"
  #       },
  #       {
  #         Action   = ["rds:PutItem"],
  #         Effect   = "Allow",
  #         Resource = aws_db_instance.mysql.arn
  #       }
  #     ]
  #   })
  # }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}
