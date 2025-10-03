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
    matcher             = 200
    interval            = 10
    timeout             = 6
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "app-tg"
    Env  = "dev"
  }
  depends_on = [aws_vpc.my-vpc]
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
  enable_deletion_protection = true  # Was false - Fixes CKV_AWS_150
  drop_invalid_header_fields = true  # Added - Fixes CKV_AWS_131
  enable_http2               = true  # Added - Best practice

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