from flask import Flask, render_template, request
from flask_cors import CORS
import subprocess
import shutil
import os
import re

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Absolute path to the Terraform code directory
TERRAFORM_DEFAULT_PATH = '/app/temp/terraform/default'
TERRAFORM_GITHUB_PATH  = '/app/temp/terraform/github'

# Function to clone Terraform code from a git repository
def clone_terraform_code(repository_url, destination_path):
    subprocess.run(['git', 'clone', repository_url, destination_path])

# Function to sanitize inputs
def sanitize_input(input_string):
    # Define a regular expression patterns
    pattern = re.compile(r'[^a-zA-Z0-9.:\/-]')
    # Use the pattern to replace any unwanted characters with an empty string
    sanitized_string = re.sub(pattern, '', input_string)
    
    return sanitized_string

@app.route('/')
def index():
   return render_template('index.html')

# Function to deploy Terraform code
@app.route('/deploy', methods=['POST'])
def deploy():
    aws_role_ext_id = sanitize_input(request.form['iactoken'])
    fortiflex_token = sanitize_input(request.form['fortiflextoken'])
    hub_ip          = sanitize_input(request.form['hubip'])

    # Check if GitHub Terraform code exists, if not, copy to default Terraform folder to deploy
    if os.path.exists(TERRAFORM_GITHUB_PATH):
        print(f"Set work directory {TERRAFORM_GITHUB_PATH}")
         # Move to Terraform code directory
        os.chdir(TERRAFORM_GITHUB_PATH)
    else:
        print(f"Copy default Terraform code directory to {TERRAFORM_DEFAULT_PATH}")
        # Copy Terraform code to a temporary directory
        shutil.copytree('/app/terraform', TERRAFORM_DEFAULT_PATH)
        # Check if there is  Terraform code to deploy
        if os.path.exists(f"{TERRAFORM_DEFAULT_PATH}/main.tf"):
            print(f"Set work directory {TERRAFORM_DEFAULT_PATH}")
            # Move to Terraform code directory
            os.chdir(TERRAFORM_DEFAULT_PATH)
        else:
            return "No Terraform code to deploy."

    # Check if Terraform is initialized
    if not os.path.exists('.terraform'):
        subprocess.run(['terraform', 'init'])

    # Execute terraform apply -auto-approve
    # (It will get rest of necessary variables from ENV TF_VAR_ defined in Dockerfile)
    command = "terraform apply "
    command += f"-var=aws_role_ext_id=\"{aws_role_ext_id}\" "
    command += f"-var=fortiflex_token=\"{fortiflex_token}\" "
    command += f"-var=hub_external_ip=\"{hub_ip}\" "
    command += "-auto-approve"

    print(f"Executing command: {command}")
    # Execute Terraform apply with provided arguments
    subprocess.run([command], shell=True)
    # Get terraform output
    terraform_out_fgt_url   = subprocess.run(['terraform', 'output', '-raw', 'fgt_url'], capture_output=True, text=True)
    terraform_out_fgt_id    = subprocess.run(['terraform', 'output', '-raw', 'fgt_id'], capture_output=True, text=True)
    terraform_out_repo      = subprocess.run(['terraform', 'output', '-raw', 'github_repo_app'], capture_output=True, text=True)
    terraform_out_app_1     = subprocess.run(['terraform', 'output', '-raw', 'app_1_url'], capture_output=True, text=True)
    terraform_out_app_2     = subprocess.run(['terraform', 'output', '-raw', 'app_2_url'], capture_output=True, text=True)
    terraform_out_k8s_cert  = subprocess.run(['terraform', 'output', '-raw', 'k8s_cert_cli'], capture_output=True, text=True)
    terraform_out_k8s_token = subprocess.run(['terraform', 'output', '-raw', 'k8s_token_cli'], capture_output=True, text=True)

    output = f"<br />FGT MGMT URL: {terraform_out_fgt_url.stdout} (may take up to 3 minutes to respond)"
    output += f"<br />Default pass: {terraform_out_fgt_id.stdout} (User admin)"
    output += "<br />"
    output += f"<br />APP-1 URL: {terraform_out_app_1.stdout}"
    output += f"<br />APP-2 URL: {terraform_out_app_2.stdout}" 
    output += "<br />"
    output += f"<br />GitHub Repo: {terraform_out_repo.stdout}"
    output += "<br />"
    output += "<br />(UPDATE GitHub Repo secrets)"
    output += f"<br />KUBE_CERTIFICATE: {terraform_out_k8s_cert.stdout}"
    output += f"<br />KUBE_TOKEN: {terraform_out_k8s_token.stdout}"  

    return f"{output}"

# Function to clone Terraform code repository
@app.route('/clone', methods=['POST'])
def clone():
    git_repository  = sanitize_input(request.form['gitrepo'])

    # Check if there is a Terraform GitHub folder and if Terraform GitHub is deployed
    if os.path.exists(f"{TERRAFORM_GITHUB_PATH}/main.tf"):
        print(f"Terraform GitHub code already cloned {TERRAFORM_GITHUB_PATH}")
        return "Terraform GitHub code already cloned"
    else:
        print(f"Cloning repo {git_repository}")
        # Clone Terraform code from a git repository
        clone_terraform_code(git_repository, TERRAFORM_GITHUB_PATH)
        return "Clone success!"    

# Function to destroy Terraform code
@app.route('/destroy', methods=['POST'])
def destroy():
    aws_role_ext_id = sanitize_input(request.form['iactoken'])

    # Go to Terraform folder with code
    if os.path.exists(TERRAFORM_GITHUB_PATH):
        print(f"Destroying repo in {TERRAFORM_GITHUB_PATH}")
        # Move to Terraform code directory
        os.chdir(TERRAFORM_GITHUB_PATH)
    elif os.path.exists(TERRAFORM_DEFAULT_PATH):
        print(f"Destroying repo in {TERRAFORM_DEFAULT_PATH}")
        # Move to Terraform default directory
        os.chdir(TERRAFORM_DEFAULT_PATH)
    else:
        return "Nothing to destroy."
    
    # Execute terraform destroy -auto-approve
    # (It will get rest of necessary variables from ENV TF_VAR_ defined in Dockerfile)
    command = "terraform destroy "
    command += f"-var=aws_role_ext_id=\"{aws_role_ext_id}\" "
    command += "-var=fortiflex_token=token "
    command += "-var=hub_external_ip=hub_ip "
    command += "-auto-approve"

    print(f"Executing command: {command}")
    subprocess.run([command], shell=True)

    return "Destroy complete!"       

if __name__ == '__main__':
    # Specify the desired port (e.g., 8080)
    port = 8080
    app.run(debug=True,host="0.0.0.0",port=port)