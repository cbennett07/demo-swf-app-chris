# ACM Certificate for the domain
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-cert"
  }
}

# ACM Certificate Validation
# Note: You'll need to manually add the CNAME records to Cloudflare
# The required DNS records will be output after terraform apply
resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn

  # If using Route 53, you could automate validation with:
  # validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  # For Cloudflare, validation is manual - this will wait until records are added
  timeouts {
    create = "30m"
  }
}
