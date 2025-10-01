// security group

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group with TCP port 80"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

// security group for ec2 instances

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group with TCP port 80"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    // cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb_sg.id] // allow only from alb sg
  }

  tags = {
    Name = "web-sg"
  }
}