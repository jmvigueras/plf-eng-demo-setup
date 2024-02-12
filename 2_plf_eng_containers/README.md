# Fortinet Platform Engineering - API and WEB servers
## Introduction

This APP is designed to have a portal that deploys Terraform code that can be clone from an external GitHub repository. 

## Requirements
* Docker container server
* Docker compose

## Deployment
* Update enviroments variables for container [docker-compose.yml.example](./docker-compose.yml.example)

```
      TF_VAR_access_key: '{{access_key}}'
      TF_VAR_secret_key: '{{secret_key}}'
      TF_VAR_aws_role_arn: '{{aws_role_arn}}'
      TF_VAR_fwb_cloud_token: '{{fwb_cloud_token}}'
      TF_VAR_github_token: '{{github_token}}'
      TF_VAR_fortidevsec_org: '{{fortidevsec_org}}'
      TF_VAR_fortidevsec_app: '{{fortidevsec_app}}' 
```
* Rename to docker-compose.yml
* Build local container images:
```
# docker build -t web-plf-eng:v1 ./web_plf_eng
# docker build -t api-plf-eng:v1 ./api_plf_eng   
```
* Create new network in docker: 
```
# docker network create net-plf-eng
```
* Deploy containers:
 ```
# docker-compose up -d
```
