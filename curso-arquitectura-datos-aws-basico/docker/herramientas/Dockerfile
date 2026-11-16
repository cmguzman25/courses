# Course toolbox: Terraform + AWS CLI v2 + Python + Postgres client.
# Works on Intel/AMD PCs (x86_64) and Apple Silicon Macs (arm64).
FROM python:3.12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip gnupg lsb-release less jq postgresql-client \
 && rm -rf /var/lib/apt/lists/*

# Terraform from the official HashiCorp repository
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list \
 && apt-get update && apt-get install -y --no-install-recommends terraform \
 && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 (picks the installer for the CPU architecture)
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o /tmp/awscli.zip \
 && unzip -q /tmp/awscli.zip -d /tmp \
 && /tmp/aws/install \
 && rm -rf /tmp/aws /tmp/awscli.zip

# Python libraries used by the course scripts
RUN pip install --no-cache-dir boto3 duckdb

WORKDIR /curso
CMD ["sleep", "infinity"]
