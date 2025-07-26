# 🚀 Task 7: Automating Strapi CI/CD on AWS ECS Fargate

This project demonstrates how to automate the Continuous Integration and Continuous Deployment (CI/CD) of a Strapi application using **GitHub Actions** and **AWS ECS Fargate**. The process includes building and pushing a Docker image to **Amazon ECR**, and updating an **ECS Fargate Service** with the new task definition.

---

## 🛠️ Tech Stack

- **Strapi v5** (Headless CMS)
- **Docker**
- **GitHub Actions**
- **Amazon ECR**
- **Amazon ECS (Fargate)**
- **Terraform** (for infrastructure provisioning)
- **AWS RDS (PostgreSQL)**

---

## ✅ Workflow Overview

1. **Push to `master` branch** triggers GitHub Actions workflow.
2. **Docker image is built** from the Strapi source code.
3. **Image is tagged** with short SHA and pushed to **Amazon ECR**.
4. **ECS Task Definition** is updated with the new image.
5. **ECS Service** is updated to use the new task definition automatically.

http://madhan-strapi-alb-471650086.us-east-2.elb.amazonaws.com/admin
