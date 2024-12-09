output "wordpress_instance_ip" {
  value = aws_instance.wordpress.public_ip
}

output "wordpress_instance_dns" {
  value = aws_instance.wordpress.public_dns
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.wordpress_cdn.domain_name
}

output "rds_endpoint" {
  value = aws_db_instance.wordpress_db.endpoint
} 