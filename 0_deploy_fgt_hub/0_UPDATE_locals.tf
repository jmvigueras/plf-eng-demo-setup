locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "plf-eng-hub"

  # Clouds to deploy
  csps = ["aws"]

  tags = {
    Deploy  = "demo platform-engineering"
    Project = "platform-engineering"
  }
  aws_region = {
    id  = "eu-west-3" // Paris
    az1 = "eu-west-3a"
    az2 = "eu-west-3c"
  }

  #-----------------------------------------------------------------------------------------------------
  # FGT Cluster
  #-----------------------------------------------------------------------------------------------------
  fgt_admin_port = "8443"
  fgt_admin_cidr = "0.0.0.0/0"

  fgt_license_type = "byol"
  fortiflex_token  = "FB124947F7368618D92B" //FGVMELTM23013220

  fgt_build         = "build1575" // version 7.2.6
  fgt_instance_type = "c6i.large"

  #-----------------------------------------------------------------------------------------------------
  # FGT SDWAN HUB
  #-----------------------------------------------------------------------------------------------------
  hub = [{
    id                = "hub"
    bgp_asn_hub       = "65000"
    bgp_asn_spoke     = "65000"
    vpn_cidr          = "10.10.10.0/24"
    vpn_psk           = var.aws_role_ext_id
    cidr              = "172.16.0.0/24"
    ike_version       = "2"
    network_id        = "1"
    dpd_retryinterval = "5"
    mode_cfg          = true
    vpn_port          = "public"
    local_gw          = ""
  }]

  aws_nodes_subnet_id   = module.aws_fgt_vpc.subnet_az1_ids["bastion"]
  aws_nodes_subnet_cidr = module.aws_fgt_vpc.subnet_az1_cidrs["bastion"]
  aws_nodes_sg_id       = module.aws_fgt_vpc.nsg_ids["allow_all"]
}