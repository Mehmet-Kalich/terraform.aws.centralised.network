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

workload_account_number = "111111111111"

workload_env = "dev"

workload_subnets = {
  az = {
    az = {
      az_id          = "euw2-az1"
      app_subnet = ""
      db_subnet  = ""
    }
    az2 = {
      az_id          = "euw2-az2"
      app_subnet = ""
      db_subnet  = ""
    }
    az3 = {
      az_id          = "euw2-az3"
      app_subnet = ""
      db_subnet  = ""
    }
  }
}

workload_tgw_subnets = {
  az = {
    az = {
      az_id            = "euw2-az1"
      tgw_subnet_cidr = ""
    }
    az2 = {
      az_id            = "euw2-az2"
      tgw_subnet_cidr = ""
    }
    az3 = {
      az_id            = "euw2-az3"
      tgw_subnet_cidr = ""
    }
  }
}
