resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all-worker-management-"
  description = "Security group for EKS worker node management"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "all-worker-management"
  }
}

# Allow inbound traffic from private networks
resource "aws_vpc_security_group_ingress_rule" "all_worker_mgmt_ingress" {
  security_group_id = aws_security_group.all_worker_mgmt.id

  cidr_ipv4   = "10.0.0.0/8"
  ip_protocol = "-1"

  description = "Allow inbound traffic from private networks"
}

resource "aws_vpc_security_group_ingress_rule" "all_worker_mgmt_ingress_172" {
  security_group_id = aws_security_group.all_worker_mgmt.id

  cidr_ipv4   = "172.16.0.0/12"
  ip_protocol = "-1"

  description = "Allow inbound traffic from private networks"
}

resource "aws_vpc_security_group_ingress_rule" "all_worker_mgmt_ingress_192" {
  security_group_id = aws_security_group.all_worker_mgmt.id

  cidr_ipv4   = "192.168.0.0/16"
  ip_protocol = "-1"

  description = "Allow inbound traffic from private networks"
}

# Allow all outbound IPv4 traffic
resource "aws_vpc_security_group_egress_rule" "all_worker_mgmt_egress" {
  security_group_id = aws_security_group.all_worker_mgmt.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow all outbound IPv4 traffic"
}