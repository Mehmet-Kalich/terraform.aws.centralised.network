###############################################################
########## ---- Egress Account Network Resources ---- #########
########## ---------------------------------------- ###########

# Egress Network Account VPC
resource "aws_vpc" "egress_vpc" {
  provider           = aws.egress
  cidr_block         = var.egress_vpc_cidr
  enable_dns_support = true

  tags = {
    Name = "egress - ${var.region}"
    Env  = "${var.egress_env}"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  provider = aws.egress
  for_each = var.egress_subnets.az

  vpc_id               = aws_vpc_egress_vpc.id
  availability_zone_id = each.value.az_id
  cidr_block           = each.value.subnet_cidr_public

  tags = {
    Name = "egress - Public - ${each.value.az_id}"
    Env  = "${var.egress_env}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  provider = aws.egress
  for_each = var.egress_subnets.az

  vpc_id               = aws_vpc_egress_vpc.id
  availability_zone_id = each.value.az_id
  cidr_block           = each.value.subnet_cidr_private

  tags = {
    Name = "egress - Private - ${each.value.az_id}"
    Env  = "${var.egress_env}"
  }
}

### ---------- Transit Gateway related resources ---------- ###

# Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  provider                       = aws.egress
  description                    = "Directs dev, uat, prd vpc traffic to and from egress/ingress network vpc"
  auto_accept_shared_attachments = "enable"

  tags = {
    Name = "egress-${var.region}-tgw"
    Env  = "${var.egress_env}"
  }
}

# Transit Gateway attachment to egress VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment" {
  provider           = aws.egress
  vpc_id             = aws_vpc_egress_vpc.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids         = [for subnet in aws_subnet.private_subnets : subnet.id]

  tags = {
    Name = "egress-${var.region}-tgw-to-egress-vpc-attachment"
    Env  = "${var.egress_env}"
  }
}

# Create route table for TGW
resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
  provider           = aws.egress
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "egress-${var.region}-routetable"
    Env  = "${var.egress_env}"
  }
}

# Create TGW route entry in route table for directing traffic to the internet
resource "aws_ec2_transit_gateway_route" "tgw_to_internet" {
  provider                       = aws.egress
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attachment.id
}

### ---------- NAT Gateway related resources ---------- ###

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  provider = aws.egress
  vpc_id   = aws_vpc_egress_vpc.id

  tags = {
    Name = "egress - ${var.region}"
    Env  = "${var.egress_env}"
  }
}

# Elastic IP addresses to allocate to each NAT gateway (this ensures a consistent
# unchanging public IP address for outbound communication from private subnet -> NAT)
resource "aws_eip" "egress_eip" {
  provider = aws.egress
  for_each = var.egress_subnets.az

  network_border_group = var.region
  vpc                  = true

  tags = {
    Name = "Egress - Nat Gateway eip - ${each.value.az_id}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

# NAT gateway for each subnet az
resource "aws_nat_gateway" "egress_nat" {
  provider = aws.egress
  for_each = var.egress_subnets.az

  allocation_id = aws_eip.egress_eip[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id

  tags = {
    Name = "Egress - ${each.value.az_id}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

# Route tables for public egress subnets with route entry pointing at transit gateway
# (for workload accounts) and route to internet gateway
resource "aws_route_table" "egress_public_route_table" {
  provider = aws.egress
  for_each = var.egress_subnets.az

  vpc_id = aws_vpc_egress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  route {
    cidr_block         = ""
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "Egress - Public RT - ${each.value.az_id}"
  }
}

# Public egress subnets association with the egress public route tables
resource "aws_route_table_association" "egress_public_route_table_association" {
  provider = aws.egress
  for_each = var.egress_subnets.az

  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.egress_public_route_table[each.key].id
}

# Route table for private egress subnets, directing all outbound traffic to NAT Gateway for internet access
resource "aws_route_table" "egress_private_route_table" {
  provider = aws.egress
  for_each = var.egress_subnets.az

  vpc_id = aws_vpc_egress_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.egress_nat[each.key].id
  }

  tags = {
    Name = "Egress - Private RT - ${each.value.az_id}"
  }
}

# Public egress subnets association with the egress public route tables
resource "aws_route_table_association" "egress_private_route_table_association" {
  provider = aws.egress
  for_each = var.egress_subnets.az

  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.egress_private_route_table[each.key].id
}
