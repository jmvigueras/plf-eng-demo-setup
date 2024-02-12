locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "webinar-waap"

  tags = {
    Deploy  = "Demo DevSecOps"
    Project = "DevSecOps"
  }
  gcp_region = {
    id    = "europe-west4" // Netherlands
    zone1 = "europe-west4-a"
    zone2 = "europe-west4-c"
  }

  #-----------------------------------------------------------------------------------------------------
  # FGT Clusters
  #-----------------------------------------------------------------------------------------------------
  fgt_admin_port   = "8443"
  fgt_admin_cidr   = "0.0.0.0/0"
  fgt_version      = "726"
  fgt_license_type = "byol"
  fortiflex_token  = "D707C92DE52B13DCD07C" //FGVMELTM23012873

  fgt_instance_type = "n1-standard-2"
  fgt_cidr          = "172.28.0.0/23"

  #-----------------------------------------------------------------------------------------------------
  # K8S Clusters
  #-----------------------------------------------------------------------------------------------------
  k8s_version          = "1.24.10-00"
  node_master_cidrhost = 10 //Network IP address for master node
  disk_size            = 30

  nodes_subnet_cidr = module.gcp_fgt_vpc.subnet_cidrs["bastion"]

  linux_user         = split("@", data.google_client_openid_userinfo.me.email)[0]
  node_instance_type = "e2-standard-4"
  master_public_ip   = module.gcp_fgt.fgt_eip_public
  db_host_public_ip  = module.gcp_fgt.fgt_eip_public
  master_ip          = cidrhost(local.nodes_subnet_cidr, local.node_master_cidrhost)
  db_host            = cidrhost(local.nodes_subnet_cidr, local.node_master_cidrhost)
  db_port            = 6379
  db_pass            = trimspace(random_string.api_key.result)
  db_prefix          = "gcp"

  api_port = 6443

  #--------------------------------------------------------------------------------------------------
  # APPs details
  #--------------------------------------------------------------------------------------------------
  app_1 = "petstore"
  app_2 = "dvwa"
  # AWS Route53 zone
  route53_zone_name = "fortidemoscloud.com"
  # DNS names
  app_1_dns_name = local.app_1 // special character "-" (not allowed "_" or ".")
  app_2_dns_name = local.app_2 // special character "-" (not allowed "_" or ".")
  # variables used in deployment manifest
  app_1_nodeport = "31000"
  app_2_nodeport = "31001"
  # Dockerhub images tag
  app_1_dockerhub_tag = "swaggerapi/petstore:latest"
  app_2_dockerhub_tag = "jviguerasfortinet/dvwa:v3"

  #--------------------------------------------------------------------------------------------------
  # Github repo variables
  #--------------------------------------------------------------------------------------------------
  github_site          = "fortidemoscloud"
  github_repo_name_app = "${local.prefix}-repo"

  git_author_email = "fortidemoscloud@proton.me"
  git_author_name  = "fortidemoscloud"

  # Create secrets values to deploy APP in k8s cluster
  fgt_values = {
    HOST        = "${module.gcp_fgt.fgt_eip_public}:${local.fgt_admin_port}"
    PUBLIC_IP   = module.gcp_fgt.fgt_eip_public
    EXTERNAL_IP = module.gcp_fgt_vpc.fgt_ni_ips["public"]
    MAPPED_IP   = module.gcp_node_master.vm["private_ip"]
    TOKEN       = trimspace(random_string.api_key.result)
  }
  # CLI command to get necessary values from k8s cluster
  k8s_values_cli = {
    KUBE_TOKEN       = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_cicd-access_token"
    KUBE_HOST        = "echo ${local.master_public_ip}:${local.api_port}"
    KUBE_CERTIFICATE = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_master_ca_cert"
  }
  # TOKEN and CERTIFICATE will need to be updated after deploy this terraform
  k8s_values = {
    KUBE_TOKEN       = "get-token-after-deploy"
    KUBE_HOST        = "${local.master_public_ip}:${local.api_port}"
    KUBE_CERTIFICATE = "get-cert-after-deploy"
  }
  #-----------------------------------------------------------------------------------------------------
  # FortiWEB Cloud
  #-----------------------------------------------------------------------------------------------------
  # Fortiweb Cloud template ID
  fwb_cloud_template = "81a6eaa9-4285-4b6b-a628-81e324835baa" //APIprotectionML
  # FortiWEB Cloud regions where deploy
  fortiweb_region = "europe-west8" // Milan
  # FortiWEB Cloud platform names
  fortiweb_platform = "GCP"

  #-----------------------------------------------------------------------------------------------------
  # FAZ (Optional)
  #-----------------------------------------------------------------------------------------------------
  faz_fortiflex_token = ""
  faz_license_file    = "./licenses/licenseFAZ.lic"
}