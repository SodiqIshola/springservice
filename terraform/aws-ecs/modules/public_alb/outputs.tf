output "alb_id" {
  description = "The ID of the public ALB"
  value       = aws_lb.public.id
}

output "alb_arn" {
  description = "The ARN of the public ALB"
  value       = aws_lb.public.arn
}

output "alb_dns_name" {
  description = "The public DNS name of the ALB to configure domain CNAME records"
  value       = aws_lb.public.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the ALB (used for Route 53 Alias records)"
  value       = aws_lb.public.zone_id
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener to attach microservice routing rules dynamically"
  value       = aws_lb_listener.http.arn
}

output "target_group_arns" {
  description = "ALB target group ARNs keyed by exposed service name"
  value       = { for name, target_group in aws_lb_target_group.exposed : name => target_group.arn }
  depends_on  = [aws_lb_listener_rule.exposed]
}
