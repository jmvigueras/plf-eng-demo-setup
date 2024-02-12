#------------------------------------------------------------------------------------------------------------
# Create cluster nodes: master and workers
#------------------------------------------------------------------------------------------------------------
# Create pubic IP for master node
resource "google_compute_address" "master_node_pip" {
  name         = "${local.prefix}-master-public-ip"
  address_type = "EXTERNAL"
  region       = local.gcp_region["id"]
}
# Deploy cluster master node
module "gcp_node_master" {
  source = "./modules/gcp_new_vm"
  prefix = "${local.prefix}-master"
  region = local.gcp_region["id"]
  zone   = local.gcp_region["zone1"]

  machine_type   = local.node_instance_type
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = local.linux_user
  user_data      = data.template_file.gcp_node_master.rendered
  disk_size      = local.disk_size

  public_ip   = google_compute_address.master_node_pip.address
  private_ip  = local.master_ip
  subnet_name = module.gcp_fgt_vpc.subnet_names["bastion"]
}
# Create data template for master node
data "template_file" "gcp_node_master" {
  template = file("./templates/k8s-master.sh")
  vars = {
    cert_extra_sans = local.master_public_ip
    script          = data.template_file.gcp_node_master_script.rendered
    k8s_version     = local.k8s_version
    db_pass         = local.db_pass
    linux_user      = local.linux_user
  }
}
data "template_file" "gcp_node_master_script" {
  template = file("./templates/export-k8s-cluster-info.py")
  vars = {
    db_host         = local.db_host
    db_port         = local.db_port
    db_pass         = local.db_pass
    db_prefix       = local.db_prefix
    master_ip       = local.master_ip
    master_api_port = local.api_port
  }
}