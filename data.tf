data "aws_vpc" "vpc" {
  tags = {
    "[vpc_tag]" = "[vpc_tag_value]",
  }
}

data "aws_route53_zone" "cloudmap" {
  name   = "[hz_name]"
  vpc_id = data.aws_vpc.vpc.id
}