#------------------------------------------------------------------------------
# FGT clusters
#------------------------------------------------------------------------------
output "gcp_fgt" {
  value = {
    fgt-1_mgmt   = "https://${module.gcp_fgt.fgt_eip_public}:${local.fgt_admin_port}"
    username     = "admin"
    fgt-1_pass   = module.gcp_fgt.fgt_id
    fgt-1_public = module.gcp_fgt.fgt_eip_public
    api_key      = trimspace(random_string.api_key.result)
  }
}
#------------------------------------------------------------------------------
# Kubernetes cluster export config
#------------------------------------------------------------------------------
output "kubectl_config" {
  value = {
    gcp = {
      command_1 = "export KUBE_HOST=${local.master_public_ip}:${local.api_port}"
      command_2 = "export KUBE_TOKEN=$(redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_cicd-access_token)"
      command_3 = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_master_ca_cert | base64 --decode >${local.db_prefix}_ca.crt"
      command_4 = "kubectl get nodes --token $KUBE_TOKEN -s https://$KUBE_HOST --certificate-authority ${local.db_prefix}_ca.crt"
    }
  }
}
#------------------------------------------------------------------------------
# Kubernetes cluster nodes
#------------------------------------------------------------------------------
output "gcp_node_master" {
  value = module.gcp_node_master.vm
}
#------------------------------------------------------------------------------
# FGT APP details 
#------------------------------------------------------------------------------
# FGT values
output "fgt_values" {
  sensitive = true
  value     = local.fgt_values
}
#-----------------------------------------------------------------------------------------------------
# K8S Clusters (CLI commands to retrieve data from redis)
#-----------------------------------------------------------------------------------------------------
# Commands to get K8S clusters variables
output "k8s_values_cli" {
  sensitive = true
  value = {
    gcp = {
      KUBE_TOKEN       = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_cicd-access_token"
      KUBE_HOST        = "echo ${local.master_public_ip}:${local.api_port}"
      KUBE_CERTIFICATE = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_master_ca_cert"
    }
  }
}
#-----------------------------------------------------------------------------------------------------
# K8S Clusters (CLI commands to retrieve data from redis)
#-----------------------------------------------------------------------------------------------------
output "github_repo_app" {
  value = github_repository.repo_app.html_url
}
output "app_url" {
  value = "http://${local.app_1_dns_name}.${data.aws_route53_zone.route53_zone.name}"
}

#-----------------------------------------------------------------------------------------------------
# FAZ (Optional)
#-----------------------------------------------------------------------------------------------------
output "faz" {
  value = {
    mgmt_url   = length(module.faz) == 0 ? "Not deployed" : "https://${element(module.faz.*.faz_public-ip, 0)}"
    admin_user = "admin"
    admin_pass = length(module.faz) == 0 ? "Not deployed" : element(module.faz.*.faz_id, 0)
  }
}