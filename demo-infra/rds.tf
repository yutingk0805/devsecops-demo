resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  username               = "foo"
  password               = "foobarbaz"
  publicly_accessible    = false
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.default.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id] # Associate with rds_sg
  skip_final_snapshot    = true

  # Deliberately vulnerable (encryption disabled)
  # storage_encrypted = false # High Severity: Vulnerable (unencrypted RDS)

  # Secure configuration (commented out):
  storage_encrypted = true
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = data.aws_subnets.private.ids
}
