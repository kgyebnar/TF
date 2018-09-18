# Internet VPC
resource "aws_vpc" "main" {
    cidr_block = "10.119.56.0/21"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "main"
    }
}

resource "aws_customer_gateway" "main" {
  bgp_asn    = 65411
  ip_address = "195.228.45.144"
  type       = "ipsec.1"

tags = "${merge(
    local.common_tags,
    map(
      "Name", "testLocals"
    )
  )}"

#  tags {
#    Name = "main-customer-gateway,${var.AppID},${var.AppName},${var.BillingID}" 
# }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.main.id}"
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_subnet" "main-private-1" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.119.56.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "eu-central-1a"
    tags {
        Name = "main-private-1"
    }
}
resource "aws_subnet" "main-private-2" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.119.57.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "eu-central-1b"
    tags {
        Name = "main-private-2"
    }
}

// create the private route table
resource "aws_route_table" "private-1" {
  vpc_id = "${aws_vpc.main.id}"
#        cidr_block = "0.0.0.0/0"

tags = "${merge(
    local.route_tags,
    map(
      "Name", "testLocals"
    )
  )}"
}

// associate private routes to the private subnets
resource "aws_route_table_association" "private-1" {
  subnet_id = "${aws_subnet.main-private-1.id}"
  route_table_id = "${aws_route_table.private-1.id}"
}

output "VPCID" {
  value = "${aws_vpc.main.id}"
}
output "VPCPrivateRouteTable" {
 value       = "${aws_route_table.private-1.id}"
}
output "PrivateSubnets1" {
  value       = "${aws_subnet.main-private-1.*.id}"
}
output "PrivateSubnets2" {
  value       = "${aws_subnet.main-private-2.*.id}"
}

output "VPNGatewayID" {
  value       = "${aws_vpn_gateway.vpn_gateway.id}"
}
output "DHCPTemplate" {
  value       = "${aws_vpc_dhcp_options.dns_resolvers.id}"
}

#output "S3PrivateEndPoint" {
#  value       = "${aws_vpc_dhcp_options.dns_resolvers.id}"
#}

