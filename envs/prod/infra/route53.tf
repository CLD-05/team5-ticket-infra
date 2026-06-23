resource "aws_route53_zone" "prod_domain" {
  name    = "cloud-infra.shop"
  comment = "team5 prod domain - Managed by Terraform"

  tags = {
    Name        = "team5-cloud-infra-shop"
    Environment = "prod"
  }
}

output "route53_zone_id" {
  description = "Route53 Hosted Zone ID for cloud-infra.shop"
  value       = aws_route53_zone.prod_domain.zone_id
}

output "route53_nameservers" {
  description = "Nameservers for cloud-infra.shop - 도메인 등록 사이트에서 NS 레코드에 등록 필요"
  value       = aws_route53_zone.prod_domain.name_servers
}
