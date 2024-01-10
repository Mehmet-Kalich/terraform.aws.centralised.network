###############################################################
########## ---- Workload Account Network Resources ---- #######
########## ---------------------------------------- ###########

# Shared VPC
resource "aws_vpc" "shared_vpc" {
  cidr_block         = var.workload_vpc_cidr
  enable_dns_support = true

  tags = {
    Name = "Shared-${var.workload_env}-${var.region}"
  }
}

# Sets Shared VPC Route Table to add route to TGW:
resource "aws_route_table" "shared_vpc_rt" {
  vpc_id = aws_vpc.shared_vpc.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id # reference tgw in network_account.tf
  }
  tags = {
    Name = "Shared-${var.workload_env}-${var.region}"
  }
}

# Set above Route Table as the main Route table for Shared VPC
resource "aws_main_route_table_association" "shared_vpc_main_rt" {
  vpc_id = aws_vpc.shared_vpc.id
  route_table_id = aws_route_table.shared_vpc_rt.id
}

# Workload App Subnets
resource "aws_subnet" "app_subnets" {
  for_each = var.workload_subnets.az

  vpc_id               = aws_vpc.shared_vpc.id
  availability_zone_id = each.value.az_id
  cidr_block           = each.value.app_subnet

  tags = {
    Name = "Shared-${var.workload_env}-app-${each.value.az_id}"
  }
}

# Workload DB Subnets
resource "aws_subnet" "db_subnets" {
  for_each = var.workload_subnets.az

  vpc_id               = aws_vpc.shared_vpc.id
  availability_zone_id = each.value.az_id
  cidr_block           = each.value.db_subnet

  tags = {
    Name = "Shared-${var.workload_env}-DB-${each.value.az_id}"
  }
}

### ---------- Transit Gateway related resources ---------- ###

# Transit Gateway attachment subnets to attach workload VPC to Egress Network VPC
resource "aws_ec2_transit_gateway_subnet" "tgw_subnets" {
  for_each = var.workload_tgw_subnets.az

  transit_gateway_id = aws_ec2_transit_gateway.shared_tgw.id
  cidr_block        = each.value.tgw_subnet_cidr
  availability_zone = each.value.az_id
}

# Transit Gateway attachment to the shared VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attach" {
  for_each = var.workload_tgw_subnets.az

  subnet_ids = [each.value.tgw_subnet_cidr]
  transit_gateway_id = aws_ec2_transit_gateway.shared_tgw.id
  vpc_id               = aws_vpc.shared_vpc.id

  tags = {
    Name = "${var.workload_env}-${var.region}-tgw-to-vpc"
  }
}

### ---------- Resource Access Manager related resources ---------- ###

# RAM Resource share with VPC
resource "aws_ram_resource_share" "vpc_resource_share" {
  name = "${var.workload_env}-${var.region}-VPC-RS"
  allowed_external_principals = false

  tags = {
    Name = "${var.workload_env}-${var.region}-VPC-RS"
  }
}

# RAM Resource association with each of the subnets in workload account
resource "aws_ram_resource_association" "subnet_share_association" {
  for_each = var.workload_subnets.az

  resource_arn = [
    aws_subnet["app-subnet-${each.key}"].arn,
    aws_subnet["db-subnet-${each.key}"].arn,
  ]
}
