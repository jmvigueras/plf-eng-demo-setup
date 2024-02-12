#------------------------------------------------------------------------------------------------------------
# Create VPCs and subnets Fortigate
# - VPC for MGMT and HA interface
# - VPC for Public interface
# - VPC for Private interface  
#------------------------------------------------------------------------------------------------------------
module "gcp_fgt_vpc" {
  source = "./modules/vpc-fgt"

  region = local.gcp_region["id"]
  prefix = local.prefix

  vpc-sec_cidr = local.fgt_cidr
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster config
#------------------------------------------------------------------------------------------------------------
module "gcp_fgt_config" {
  source = "./modules/fgt-config"

  admin_cidr     = local.fgt_admin_cidr
  admin_port     = local.fgt_admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs = module.gcp_fgt_vpc.subnet_cidrs
  fgt_ni_ips   = module.gcp_fgt_vpc.fgt_ni_ips

  fgt_extra-config = join("\n", data.template_file.gcp_fgt_extra_config.*.rendered)

  license_type    = local.fgt_license_type
  fortiflex_token = local.fortiflex_token

  config_xlb = true
  ilb_ip     = module.gcp_fgt_vpc.ilb_ip

  config_faz = true
  faz_ip     = module.gcp_fgt_vpc.faz_ni_ips["private"]

  vpc-spoke_cidr = [module.gcp_fgt_vpc.subnet_cidrs["bastion"]]
}
# List of ports to create VIPs
locals {
  fgt_vips = [local.api_port, local.db_port, local.app_1_nodeport, local.app_2_nodeport]
}
# Create data template extra-config fgt
data "template_file" "gcp_fgt_extra_config" {
  count    = length(local.fgt_vips)
  template = file("./templates/fgt_extra-config.tpl")
  vars = {
    external_ip   = module.gcp_fgt_vpc.fgt_ni_ips["public"]
    mapped_ip     = local.master_ip
    external_port = local.fgt_vips[count.index]
    mapped_port   = local.fgt_vips[count.index]
    public_port   = "port1"
    private_port  = "port2"
    suffix        = local.fgt_vips[count.index]
  }
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster instances
#------------------------------------------------------------------------------------------------------------
module "gcp_fgt" {
  source = "./modules/fgt"

  region = local.gcp_region["id"]
  prefix = local.prefix
  zone1  = local.gcp_region["zone1"]

  machine        = local.fgt_instance_type
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]
  license_type   = local.fgt_license_type
  fgt_version    = local.fgt_version

  subnet_names = module.gcp_fgt_vpc.subnet_names
  fgt-ni_ips   = module.gcp_fgt_vpc.fgt_ni_ips

  fgt_config = module.gcp_fgt_config.fgt_config
}
#------------------------------------------------------------------------------------------------------------
# Create Internal and External Load Balancer
#------------------------------------------------------------------------------------------------------------
module "gcp_xlb" {
  source = "./modules/xlb"

  region = local.gcp_region["id"]
  prefix = local.prefix
  zone1  = local.gcp_region["zone1"]
  zone2  = local.gcp_region["zone2"]

  vpc_names     = module.gcp_fgt_vpc.vpc_names
  subnet_names  = module.gcp_fgt_vpc.subnet_names
  ilb_ip        = module.gcp_fgt_vpc.ilb_ip
  fgt_self_link = module.gcp_fgt.fgt_self_link
}