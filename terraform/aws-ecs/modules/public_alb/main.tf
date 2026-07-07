# ==========================================================================
# PUBLIC APPLICATION LOAD BALANCER
# ==========================================================================
resource "aws_lb" "public" {
  name               = "${var.name_prefix}-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-alb"
  })
}

# ==========================================================================
# DEFAULT TARGET GROUP (Fallback)
# ==========================================================================
# This target group handles unmatched requests.
resource "aws_lb_target_group" "default" {
  name        = "${var.name_prefix}-default-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for ECS Fargate compatibility

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-default-tg"
  })
}

resource "aws_lb_target_group" "exposed" {
  for_each    = var.exposed_services
  name        = "${var.name_prefix}-${each.key}-tg"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    path    = each.value.health_check_path

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399" # Accept redirects if dashboards forward pages internally
  }
}


# ==========================================================================
# ALB HTTP LISTENER (Port 80)
# ==========================================================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_lb_listener_rule" "exposed" {
  for_each     = var.exposed_services
  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.exposed[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.path]
    }
  }
}
