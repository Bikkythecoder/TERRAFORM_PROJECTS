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

An internet-facing Application Load Balancer is created across both public subn
