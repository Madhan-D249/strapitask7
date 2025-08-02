output "strapi_url" {
  description = "Public URL of the Strapi application"
  value       = aws_lb.madhan_strapi_alb.dns_name
}
output "ecs_cluster_name" {
  value = aws_ecs_cluster.madhan_strapi_cluster.name
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.madhan_log_group.name
}
