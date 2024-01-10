region = ""

egress_vpc_cidr = ""

egress_account_id = "000000000000"

egress_env = "egress"

egress_subnets = {
  az = {
    az = {
      az_id               = "euw2-az1"
      subnet_cidr_public  = ""
      subnet_cidr_private = ""
    }
    az2 = {
      az_id               = "euw2-az2"
      subnet_cidr_public  = ""
      subnet_cidr_private = ""
    }
    az3 = {
      az_id               = "euw2-az3"
      subnet_cidr_public  = ""
      subnet_cidr_private = ""
    }
  }
}

workload_vpc_cidr = ""

workload_account_number = "333333333333"

workload_env = "prd"

workload_subnets = {
  az = {
    az = {
      az_id          = "euw2-az1"
      az1_app_subnet = ""
      az1_db_subnet  = ""
    }
    az2 = {
      az_id          = "euw2-az2"
      az2_app_subnet = ""
      az2_db_subnet  = ""
    }
    az3 = {
      az_id          = "euw2-az3"
      az3_app_subnet = ""
      az3_db_subnet  = ""
    }
  }
}

workload_tgw_subnets = {
  az = {
    az = {
      az_id            = "euw2-az1"
      tgw_sub_cidr_az1 = ""
    }
    az2 = {
      az_id            = "euw2-az2"
      tgw_sub_cidr_az2 = ""
    }
    az3 = {
      az_id            = "euw2-az3"
      tgw_sub_cidr_az3 = ""
    }
  }
}

create_s3_gateway_endpoint = false
