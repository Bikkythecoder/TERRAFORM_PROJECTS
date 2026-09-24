# Terraform AWS Infrastructure Project

This project uses **Terraform** to provision and manage AWS infrastructure as Infrastructure as Code (IaC).

The project creates a custom VPC with two public subnets, an Internet Gateway, route table, security group, two EC2 web servers, an Application Load Balancer (ALB), and an S3 bucket.

Terraform state is stored remotely in an **Amazon S3 backend**, with **S3-native state locking** enabled using `use_lockfile = true`.

---

## 🏗️ Architecture

```text
                              Internet
                                  │
                                  ▼
                     ┌────────────────────────┐
                     │ Application Load       │
                     │ Balancer (ALB)         │
                     │ HTTP : 80              │
                     └───────────┬────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
          ┌──────────────────┐      ┌──────────────────┐
          │    EC2 Server 1  │      │    EC2 Server 2  │
          │   us-east-1a     │      │   us-east-1b     │
          │  10.1.2.0/24     │      │  10.1.3.0/24     │
          └──────────────────┘      └──────────────────┘
                    │                         │
                    └────────────┬────────────┘
                                 │
                       ┌─────────▼─────────┐
                       │       VPC         │
                       │    10.1.0.0/16    │
                       └─────────┬─────────┘
                                 │
                       Internet Gateway
                                 │
                                 ▼
                              Internet


              Terraform Remote State
                         │
                         ▼
               ┌─────────────────────┐
               │     S3 Backend      │
               │                     │
               │ terraform.tfstate  │
               │ + S3 lock file      │
               └─────────────────────┘
```

---

# 🚀 AWS Resources Created

Terraform provisions the following resources.

### 1. VPC

```text
CIDR: 10.1.0.0/16
```

### 2. Public Subnets

| Subnet   | CIDR          | Availability Zone |
| -------- | ------------- | ----------------- |
| Subnet 1 | `10.1.2.0/24` | `us-east-1a`      |
| Subnet 2 | `10.1.3.0/24` | `us-east-1b`      |

Both subnets have:

```hcl
map_public_ip_on_launch = true
```

### 3. Internet Gateway

An Internet Gateway is attached to the VPC to provide internet connectivity to the public subnets.

### 4. Route Table

The route table contains:

```text
0.0.0.0/0 → Internet Gateway
```

Both public subnets are associated with this route table.

### 5. Security Group

The security group allows:

| Protocol     | Port | Source      |
| ------------ | ---: | ----------- |
| HTTP         |   80 | `0.0.0.0/0` |
| SSH          |   22 | `0.0.0.0/0` |
| All outbound |  All | `0.0.0.0/0` |

### 6. S3 Bucket

Terraform creates an S3 bucket using the variable:

```hcl
bucket = var.bucket_name
```

### 7. EC2 Instances

Two EC2 instances are created:

```text
EC2 Instance 1 → us-east-1a
EC2 Instance 2 → us-east-1b
```

The AMI and instance type are provided through Terraform variables.

Each EC2 instance also uses a separate user-data script:

```text
userdata1.sh
userdata2.sh
```

### 8. Application Load Balancer

An internet-facing Application Load Balancer is created across both public subnets.

The ALB listens on:

```text
HTTP : 80
```

### 9. Target Group

The target group uses:

```text
Protocol: HTTP
Port: 80
Health Check Path: /
```

Both EC2 instances are registered as targets.

---

# 🗄️ Remote Terraform Backend

This project uses an **Amazon S3 remote backend** to store Terraform state.

Instead of keeping the Terraform state only on the local machine, the state is stored in an S3 bucket.

Example backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket       = "YOUR-BACKEND-BUCKET"
    key          = "project-1/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
```

## Backend Configuration

| Configuration  | Purpose                                  |
| -------------- | ---------------------------------------- |
| `bucket`       | S3 bucket used to store Terraform state  |
| `key`          | Path where the state is stored           |
| `region`       | AWS region containing the backend bucket |
| `use_lockfile` | Enables S3-native state locking          |

The remote state is stored at:

```text
s3://YOUR-BACKEND-BUCKET/project-1/terraform.tfstate
```

---

# 🔐 Terraform State Locking

This project uses:

```hcl
use_lockfile = true
```

Terraform uses an S3 lock file to help prevent multiple Terraform operations from modifying the same state simultaneously.

For this configuration, a **DynamoDB locking table is not required**.

This project therefore does not require a separate DynamoDB table for state locking.

---

# 📁 Project Structure

```text
TERRAFORM_PROJECTS/
│
├── .gitignore
│
└── Project-1/
    │
    ├── main.tf
    ├── provider.tf
    ├── variables.tf
    ├── backend.tf
    ├── userdata1.sh
    ├── userdata2.sh
    └── .terraform.lock.hcl
```

---

# 📄 Terraform Files

| File                  | Description                                                       |
| --------------------- | ----------------------------------------------------------------- |
| `main.tf`             | Defines AWS infrastructure resources                              |
| `provider.tf`         | Configures the AWS provider                                       |
| `variables.tf`        | Defines Terraform input variables                                 |
| `backend.tf`          | Configures the S3 remote backend                                  |
| `userdata1.sh`        | Startup script for EC2 instance 1                                 |
| `userdata2.sh`        | Startup script for EC2 instance 2                                 |
| `.terraform.lock.hcl` | Locks Terraform provider versions                                 |
| `.gitignore`          | Prevents state and temporary Terraform files from being committed |

---

# 🔧 Prerequisites

Install the following tools:

* Terraform
* AWS CLI
* Git
* An AWS account

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI:

```bash
aws --version
```

Verify Git:

```bash
git --version
```

---

# 🔑 AWS Authentication

Configure your AWS credentials:

```bash
aws configure
```

Verify your AWS identity:

```bash
aws sts get-caller-identity
```

Make sure the AWS credentials have sufficient permissions to create the required resources.

---

# ⚙️ Terraform Variables

The project uses variables for values such as:

```text
AMI ID
Instance Type
S3 Bucket Name
```

Example:

```hcl
ami_value     = "YOUR_AMI_ID"
instance_type = "t3.micro"
bucket_name   = "YOUR-UNIQUE-BUCKET-NAME"
```

These values can be supplied through a `terraform.tfvars` file.

> `terraform.tfvars` is ignored by Git and should not be committed if it contains sensitive information.

---

# ▶️ Deployment

Navigate to the Terraform project:

```bash
cd TERRAFORM_PROJECTS/Project-1
```

## Initialize Terraform

```bash
terraform init
```

Terraform will initialize the AWS provider and connect to the S3 remote backend.

## Format the configuration

```bash
terraform fmt
```

## Validate the configuration

```bash
terraform validate
```

## Create an execution plan

```bash
terraform plan
```

Review the resources Terraform plans to create.

## Apply the infrastructure

```bash
terraform apply
```

Enter:

```text
yes
```

when Terraform asks for confirmation.

---

# 🌐 Access the Application

After deployment, Terraform outputs the Application Load Balancer DNS name.

Run:

```bash
terraform output loadbalancerdns
```

Example:

```text
myalb-123456789.us-east-1.elb.amazonaws.com
```

Open it in a browser:

```text
http://<ALB-DNS-NAME>
```

The ALB forwards requests to the two EC2 web servers.

---

# 🔍 Verify the Infrastructure

View Terraform outputs:

```bash
terraform output
```

View the Terraform state:

```bash
terraform show
```

Check AWS EC2 instances:

```bash
aws ec2 describe-instances
```

Check S3 buckets:

```bash
aws s3 ls
```

Check the remote Terraform state:

```bash
aws s3 ls s3://YOUR-BACKEND-BUCKET/project-1/
```

---

# 🗂️ Terraform State and Git

Terraform state files are **not stored in this GitHub repository**.

The `.gitignore` file excludes:

```text
*.tfstate
*.tfstate.*
.terraform/
```

This prevents files such as:

```text
terraform.tfstate
terraform.tfstate.backup
.terraform/
```

from being committed to Git.

The actual Terraform state is maintained remotely in the configured S3 backend.

The following file **is intentionally committed**:

```text
.terraform.lock.hcl
```

This allows the project to maintain consistent Terraform provider versions.

---

# 🔄 Working With the Remote Backend

When another machine clones this repository, Terraform can initialize the existing remote state by running:

```bash
terraform init
```

If the backend configuration has changed:

```bash
terraform init -reconfigure
```

Terraform will then use the configured S3 backend instead of creating a new local state workflow.

---

# 🧹 Destroy Infrastructure

When the project is no longer required:

```bash
terraform destroy
```

Confirm with:

```text
yes
```

This removes the AWS infrastructure managed by this Terraform configuration.

> The remote S3 backend bucket is separate from the S3 bucket created as an application resource. Destroying Terraform-managed resources does not necessarily mean the backend bucket should be deleted.

---

# 🔐 Security Considerations

This project is intended for **learning and lab purposes**.

The current security group allows SSH from:

```text
0.0.0.0/0
```

and HTTP from:

```text
0.0.0.0/0
```

For a production environment, SSH should be restricted to trusted IP addresses or replaced with a more controlled access method.

A production architecture would also typically use separate security groups for:

```text
Internet
   ↓
ALB Security Group
   ↓
EC2 Security Group
```

The EC2 security group can then allow HTTP traffic only from the ALB security group.

---

# 🧠 Terraform Concepts Demonstrated

This project demonstrates the following Terraform and AWS concepts:

* Infrastructure as Code (IaC)
* Terraform providers
* Terraform resources
* Input variables
* Resource dependencies
* Terraform outputs
* VPC creation
* Public subnets
* Availability Zones
* Internet Gateway
* Route tables
* Route table associations
* Security groups
* EC2 instances
* EC2 user data
* S3 bucket creation
* S3 remote backend
* S3 state locking
* Application Load Balancer
* Target groups
* Target group attachments
* Health checks
* ALB listeners
* Terraform state management
* `.terraform.lock.hcl`
* Git and GitHub version control

---

# 🔄 Git Workflow

The project is maintained using Git.

Typical workflow:

```bash
git status
git add .
git commit -m "Update Terraform configuration"
git push
```

Terraform state files and `.terraform/` are excluded through `.gitignore`.

---

# 👨‍💻 Author

**Bikky Roy**

GitHub: **Bikkythecoder**

Repository:

`TERRAFORM_PROJECTS`

---

## 📌 Project Summary

This project demonstrates how Terraform can be used to build a complete AWS web infrastructure while maintaining Terraform state remotely using **Amazon S3** and **S3-native state locking**.

The architecture includes:

```text
VPC
 ├── Public Subnet 1
 │    └── EC2 Web Server 1
 │
 ├── Public Subnet 2
 │    └── EC2 Web Server 2
 │
 ├── Internet Gateway
 │
 ├── Route Table
 │
 └── Application Load Balancer
      └── Target Group
           ├── EC2 Web Server 1
           └── EC2 Web Server 2

Terraform State
 └── Amazon S3 Remote Backend
      └── S3 Lock File
```
