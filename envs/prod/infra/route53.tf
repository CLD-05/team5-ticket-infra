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

  resource "aws_route53_record" "team5" {
    zone_id = aws_route53_zone.prod_domain.zone_id # 👈 위쪽 호스팅 영역 ID를 다이렉트로 물려줍니다.
    name    = "team5.cloud-infra.shop"
    type    = "A"

    alias {
      # ⚠️ 이 값은 ALB 재생성 시마다 변경됩니다.
      # Gateway status.addresses에서 현재 ALB DNS를 확인하고 여기를 업데이트하세요.
      # 확인: kubectl get gateway -n ticketing ticket-gateway -o jsonpath='{.status.addresses}'
      name                   = "k8s-ticketin-ticketga-cc12cdd6d7-2059893157.ap-northeast-2.elb.amazonaws.com"
      zone_id                = "ZWKZPGTI48KDX" # 👈 ap-northeast-2(서울리전) ALB 고정 호스팅존 ID
      evaluate_target_health = false
    }
  }