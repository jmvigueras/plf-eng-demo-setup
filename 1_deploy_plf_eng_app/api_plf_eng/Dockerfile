FROM ubuntu:20.04

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get install -y wget unzip vim && \
    apt-get install -y git jq curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Terraform
WORKDIR /tmp
RUN wget https://releases.hashicorp.com/terraform/0.15.0/terraform_0.15.0_linux_amd64.zip && \
    unzip terraform_0.15.0_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_0.15.0_linux_amd64.zip

# Set the working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Expose the port
EXPOSE 8080

# Start the application
CMD ["python3", "app.py"]