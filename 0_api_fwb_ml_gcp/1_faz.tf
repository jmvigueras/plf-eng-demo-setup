#------------------------------------------------------------------------------------------------------------
# Create FAZ instance
#------------------------------------------------------------------------------------------------------------
module "faz" {
  count  = local.faz_fortiflex_token != "" ? 1 : fileexists(local.faz_license_file) ? 1 : 0
  source = "./modules/faz"

  prefix  = local.prefix
  region  = local.gcp_region["id"]
  zone    = local.gcp_region["zone1"]
  machine = "n1-standard-4"

  faz_version = "741"

  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  license_file = fileexists(local.faz_license_file) ? local.faz_license_file : "./licenses/licenseFAZ.lic"

  subnet_names = {
    public  = module.gcp_fgt_vpc.subnet_names["public"]
    private = module.gcp_fgt_vpc.subnet_names["bastion"]
  }
  subnet_cidrs = {
    public  = module.gcp_fgt_vpc.subnet_cidrs["public"]
    private = module.gcp_fgt_vpc.subnet_cidrs["bastion"]
  }
  faz_ni_ips = module.gcp_fgt_vpc.faz_ni_ips
}