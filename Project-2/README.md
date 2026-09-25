# 🚀 Project 2 — Provisioning Amazon EKS Using Terraform

![Terraform](https://img.shields.io/badge/Terraform-1.15+-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws&logoColor=white)
![Amazon EKS](https://img.shields.io/badge/Amazon-EKS-FF9900?logo=amazonaws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.36-326CE5?logo=kubernetes&logoColor=white)
![Amazon VPC](https://img.shields.io/badge/Amazon-VPC-FF9900?logo=amazonaws&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Version%20Control-181717?logo=github&logoColor=white)

---

## 📌 Project Overview

This project demonstrates how to provision a complete **Amazon Elastic Kubernetes Service (EKS)** environment on AWS using **Terraform**.

The entire infrastructure is defined as code and can be:

- Created using `terraform apply`
- Reviewed using `terraform plan`
- Validated using `terraform validate`
- Formatted using `terraform fmt`
- Destroyed using `terraform destroy`

The goal of this project is to understand how Terraform can be used to automate the provisioning of AWS networking infrastructure and a managed Kubernetes cluster.

The project creates an AWS VPC containing public and private subnets, configures internet connectivity using an Internet Gateway and NAT Gateway, and deploys an Amazon EKS cluster with a managed worker node group.

---

# 🎯 Project Objectives

The primary objectives of this project are:

1. Learn how to create AWS infrastructure using Terraform.
2. Understand Terraform modules.
3. Create an Amazon VPC using the official Terraform AWS VPC module.
4. Create public and private subnets.
5. Configure an Internet Gateway.
6. Configure a NAT Gateway.
7. Understand public and private subnet architecture.
8. Provision an Amazon EKS cluster.
9. Create an EKS managed node group.
10. Deploy worker nodes into private subnets.
11. Configure security groups.
12. Understand Kubernetes subnet tagging.
13. Enable IAM Roles for Service Accounts (IRSA).
14. Connect the EKS cluster with `kubectl`.
15. Verify Kubernetes worker nodes.
16. Manage the complete infrastructure lifecycle using Terraform.
17. Store the project in Git and GitHub.

---

# 🏗️ High-Level Architecture

The infrastructure follows a typical AWS Kubernetes architecture.

```text
                                  INTERNET
                                     │
                                     │
                                     ▼
                           ┌────────────────────┐
                           │  Internet Gateway   │
                           └──────────┬─────────┘
                                      │
                                      │
                         ┌────────────▼────────────┐
                         │          VPC             │
                         │       10.0.0.0/16        │
                         │                          │
                         │                          │
              ┌──────────┴─────────┐    ┌─────────┴──────────┐
              │                     │    │                    │
              ▼                     ▼    ▼                    ▼
       ┌─────────────┐      ┌─────────────┐        ┌─────────────┐
       │ Public      │      │ Public      │        │ Private     │
       │ Subnet      │      │ Subnet      │        │ Subnet      │
       │10.0.4.0/24  │      │10.0.5.0/24  │        │10.0.1.0/24  │
       └──────┬──────┘      └──────┬──────┘        └──────┬──────┘
              │                    │                       │
              │                    │                       │
              │                    │                ┌──────▼──────┐
              │                    │                │ EKS Worker  │
              │                    │                │    Node      │
              │                    │                │   t3.micro   │
              │                    │                └──────┬───────┘
              │                    │                       │
              │                    │                       │
              │              ┌─────▼─────┐                 │
              │              │    NAT    │◄────────────────┘
              │              │  Gateway  │
              │              └─────┬─────┘
              │                    │
              │                    │
              │              Outbound Internet
              │
              │
              │
              └──────────────────────────────────────────┐
                                                         │
                                                ┌────────▼────────┐
                                                │   EKS Control   │
                                                │      Plane      │
                                                │                 │
                                                │ Managed by AWS  │
                                                └─────────────────┘
