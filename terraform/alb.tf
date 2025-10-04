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