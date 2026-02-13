🚀 AWS CodePipeline → CodeBuild → CodeDeploy (Ubuntu + Nginx)

This project demonstrates a complete CI/CD pipeline on AWS to deploy a static HTML website on an Ubuntu EC2 server using Nginx, powered by:

AWS CodePipeline

AWS CodeBuild

AWS CodeDeploy

Amazon S3 (artifacts)

Amazon EC2 (Ubuntu Server)

📌 Architecture Overview
GitHub Repository
        ↓
AWS CodePipeline
        ↓
AWS CodeBuild (creates artifact)
        ↓
Amazon S3 (artifact storage)
        ↓
AWS CodeDeploy
        ↓
Ubuntu EC2 (Nginx serves website)

📁 Project Structure
mybuildpro/
├── buildspec.yml          # CodeBuild configuration
├── appspec.yml            # CodeDeploy configuration
├── index.html             # Static website
└── scripts/               # Deployment scripts
    ├── install_nginx.sh
    └── start_nginx.sh

📄 Files Explanation
1️⃣ index.html

Simple static web page that will be served by Nginx.

2️⃣ buildspec.yml (CodeBuild)

Responsible for:

Preparing build artifacts

Copying index.html into a build/ directory

Packaging required files for CodeDeploy

version: 0.2

phases:
  build:
    commands:
      - mkdir -p build
      - cp index.html build/

artifacts:
  files:
    - appspec.yml
    - build/index.html
    - scripts/**


⚠️ Important

Never use /var/www/html in CodeBuild

Artifacts must be workspace-relative paths only

3️⃣ appspec.yml (CodeDeploy)

Defines:

Where files are copied on EC2

Which scripts run during deployment lifecycle

version: 0.0
os: linux

files:
  - source: build/index.html
    destination: /var/www/html

hooks:
  AfterInstall:
    - location: scripts/install_nginx.sh
      timeout: 300
      runas: root

  ApplicationStart:
    - location: scripts/start_nginx.sh
      timeout: 300
      runas: root


📌 Rule

appspec.yml must be at the root of the artifact

4️⃣ scripts/install_nginx.sh

Installs and enables Nginx on Ubuntu EC2.

#!/bin/bash
set -e

apt-get update -y
apt-get install -y nginx
mkdir -p /var/www/html
systemctl enable nginx

5️⃣ scripts/start_nginx.sh

Starts or restarts Nginx after deployment.

#!/bin/bash
systemctl restart nginx

🔑 Permissions & IAM Roles
✅ CodeDeploy Service Role

Must include:

AWSCodeDeployRole

S3 read permissions:

s3:GetObject

s3:GetObjectVersion

s3:ListBucket

✅ EC2 Instance Role

AmazonEC2RoleforAWSCodeDeploy

🪣 S3 Bucket

Private bucket

No bucket policy required

Access controlled via IAM roles

🖥️ EC2 Setup (Ubuntu)

Launch Ubuntu 20.04 / 22.04

Open inbound port:

HTTP (80)

Attach EC2 IAM role

Install CodeDeploy agent:

sudo apt update -y
sudo apt install -y ruby wget
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x install
sudo ./install auto
sudo systemctl start codedeploy-agent


Verify:

sudo systemctl status codedeploy-agent

🔄 Deployment Process
Option 1️⃣ (Recommended): Via CodePipeline

Push code to GitHub

Click Release change in CodePipeline

CodePipeline automatically passes artifact to CodeDeploy

✅ Do NOT manually set revision location

Option 2️⃣ Manual Deployment (ZIP Required)

CodeDeploy manual deployments require a ZIP file.

zip -r mybuildpro.zip appspec.yml build scripts
aws s3 cp mybuildpro.zip s3://myartifact-9328/mybuildpro.zip


Revision location:

s3://myartifact-9328/mybuildpro.zip

🌐 Verify Deployment

Open browser:

http://<EC2_PUBLIC_IP>


You should see your deployed HTML page.
