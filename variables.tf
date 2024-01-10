variable "region" {
  type        = string
  description = "The AWS region."
}

variable "egress_vpc_cidr" {
  type        = string
  description = "IP CIDR range for the network account Egress VPC"
}

variable "egress_account_id" {
  description = "Egress Network Account ID."
  type        = string
}

variable "egress_env" {
  description = "Egress Environment name"
  type        = string
}

variable "egress_subnets" {
  # type = object()
  description = "Object containing variables for az and subnet configuration"
}

variable "workload_vpc_cidr" {
  type        = string
  description = "IP CIDR range for the workload account VPC"
}

variable "workload_account_number" {
  description = "Workload Account ID."
  type        = string
}

variable "workload_env" {
  description = "Workload Environment name"
  type        = string
}

variable "workload_subnets" {
  # type = object()
  description = "Object containing variables for the workload app & db subnet configurations
                over 3 availability zones."
}

variable "workload_tgw_subnets" {
  # type = object()
  description = "Object containing variables for the workload transit gateway subnet configurations
                over 3 availability zones."
}

variable "create_s3_gateway_endpoint" {
  description = "Condition for an S3 gateway endpoint"
  type        = bool
}
