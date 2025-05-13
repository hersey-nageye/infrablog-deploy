# Creating a public hosted zone to host my Cloudfare domain
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}
