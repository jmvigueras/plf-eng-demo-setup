#------------------------------------------------------------------------------
# FGT clusters
#------------------------------------------------------------------------------
output "fgt_hub" {
  value = {
    fgt-1_mgmt   = "https://${module.aws_fgt.fgt_eip_public}:${local.fgt_admin_port}"
    username     = "admin"
    fgt-1_pass   = module.aws_fgt.fgt_id
    fgt-1_public = module.aws_fgt.fgt_eip_public
    api_key      = trimspace(random_string.api_key.result)
  }
}
