#-----------------------------------------------------------------------------------------------------
# Create Github repo and actions secret
#-----------------------------------------------------------------------------------------------------
# Create APP repo
resource "github_repository" "repo_app" {
  name        = local.github_repo_name_app
  description = "An example repository created using Terraform"
}
# Create K8S master secrets
module "k8s_secrets_app" {
  depends_on = [github_repository.repo_app]
  source     = "./modules/github-secrets"

  prefix     = "${local.db_prefix}_"
  repository = github_repository.repo_app.name
  secrets    = local.k8s_values
}
#-----------------------------------------------------------------------------------------------------
# Create GitHub actions yaml
#-----------------------------------------------------------------------------------------------------
locals {
  app_list = [local.app_1, local.app_2]
}
# GitHub actions k8s manifest
data "template_file" "github_actions_workflow_deploy" {
  count    = length(local.app_list)
  template = file("./templates/github-actions-workflow_k8s.tpl")
  vars = {
    prefix   = "${upper(local.db_prefix)}_"
    app_name = local.app_list[count.index]
  }
}
# Create Github actions workflow from template
data "template_file" "github_actions_workflow" {
  template = file("./templates/github-actions-workflow.tpl")
  vars = {
    deploy_k8s = join("\n", data.template_file.github_actions_workflow_deploy.*.rendered)
  }
}
# GitHub actions APP yaml
resource "local_file" "github_actions_workflow" {
  content  = data.template_file.github_actions_workflow.rendered
  filename = "./repo_app/.github/workflows/main.yaml"
}
#-----------------------------------------------------------------------------------------------------
# APP manifest to deploy - Swagger Petstore API 
#-----------------------------------------------------------------------------------------------------
# Create k8s manifest APP
data "template_file" "k8s_deployment_app_1" {
  template = file("./templates/k8s-deployment_petstore.yaml.tpl")
  vars = {
    app_name          = local.app_1
    app_port          = "8080"
    app_nodeport      = local.app_1_nodeport
    app_replicas      = "1"
    app_dockerhub_tag = local.app_1_dockerhub_tag
    app_url           = "http://${local.app_1_dns_name}.${data.aws_route53_zone.route53_zone.name}"
  }
}
# Create k8s deployment APP yaml
resource "local_file" "k8s_deployment_app_1" {
  content  = data.template_file.k8s_deployment_app_1.rendered
  filename = "./repo_app/manifest/k8s-${local.app_1}.yaml"
}
#-----------------------------------------------------------------------------------------------------
# APP manifest to deploy - Swagger DVWA
#-----------------------------------------------------------------------------------------------------
# Create k8s manifest APP
data "template_file" "k8s_deployment_app_2" {
  template = file("./templates/k8s-deployment.yaml.tpl")
  vars = {
    app_name          = local.app_2
    app_port          = "80"
    app_nodeport      = local.app_2_nodeport
    app_replicas      = "1"
    app_dockerhub_tag = local.app_2_dockerhub_tag
  }
}
# Create k8s deployment APP yaml
resource "local_file" "k8s_deployment_app_2" {
  content  = data.template_file.k8s_deployment_app_2.rendered
  filename = "./repo_app/manifest/k8s-${local.app_2}.yaml"
}
#-----------------------------------------------------------------------------------------------------
# Upload content to new repo
#-----------------------------------------------------------------------------------------------------
# Upload content to new repo APP 1
resource "null_resource" "upload_repo_code_app" {
  depends_on = [github_repository.repo_app, module.k8s_secrets_app, local_file.github_actions_workflow, local_file.k8s_deployment_app_1, local_file.k8s_deployment_app_2]
  provisioner "local-exec" {
    command = "cd ./repo_app && rm -rf .git && git init && git add . && git commit -m 'first commit' && git branch -M master && git remote add origin https://${var.github_token}@github.com/${local.github_site}/${local.github_repo_name_app}.git && git push -u origin master"
    environment = {
      GIT_AUTHOR_EMAIL = local.git_author_email
      GIT_AUTHOR_NAME  = local.git_author_name
    }
  }
}