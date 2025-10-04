// target group
resource "aws_lb_target_group" "tg1" {
  name        = "ntc-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.my-vpc.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-tg"
    Env  = "dev"
  }
}

//attach instances to target group
resource "aws_lb_target_group_attachment" "ntc-tg-attach1" {
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ntc-tg-attach2" {
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# Create S3 bucket for ALB access logs
resource "aws_s3_bucket" "alb_logs" {
  bucket = "ntc-alb-logs-${random_id.suffix.hex}"

  tags = {
    Name        = "NTC ALB Access Logs"
    Environment = "dev"
    Project     = "ntcapp"
  }
}

# Block public access to the logs bucket
resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable bucket versioning for extra protection
resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket policy for ALB logging
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::127311923021:root"  # ELB service account for us-east-1
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs.arn
      }
    ]
  })
}

// application load balancer
resource "aws_lb" "alb" {
  name               = "ntc-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
  
  # ✅ SECURITY FIXES
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  enable_http2               = true

  # ✅ ACCESS LOGGING
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
    prefix  = "alb-logs"
  }

  tags = {
    Name = "ntc-alb"
    Env  = "dev"
  }
}

// listener for alb
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }
}