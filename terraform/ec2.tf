resource "aws_instance" "web1" {
  ami                         = "ami-08982f1c5bf93d976" // amazon linux 2
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = false  # ✅ FIX: Changed from true to false
  monitoring                  = true   # ✅ ADD: For detailed monitoring
  
  # ✅ ADD: IMDSv2 configuration (blocks Metadata Service v1)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  
  # ✅ ADD: Root volume encryption
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  user_data = file("setup.sh")
  tags = {
    Name = "webserver-1"
    Env  = "dev"
  }
}

resource "aws_instance" "web2" {
  ami                         = "ami-08982f1c5bf93d976" // amazon linux 2
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = false  # ✅ FIX: Changed from true to false
  monitoring                  = true   # ✅ ADD: For detailed monitoring
  
  # ✅ ADD: IMDSv2 configuration (blocks Metadata Service v1)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  
  # ✅ ADD: Root volume encryption
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  user_data = file("setup.sh")
  tags = {
    Name = "webserver-2"
    Env  = "dev"
  }
}