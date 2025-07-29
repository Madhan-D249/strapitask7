# 🚀 Strapi on AWS Fargate with CI/CD & Monitoring using Terraform & GitHub Actions

This project deploys a **Strapi CMS application** to **AWS ECS Fargate**, managed entirely with **Terraform**, and automated using a single **GitHub Actions workflow** (`deploy.yml`). It also includes **CloudWatch logging and monitoring** with metrics dashboards and optional alarms.

---

## 🧱 Architecture Overview

- **Strapi** running in a Docker container
- Hosted on **AWS ECS Fargate**
- **ECR** for container image storage
- **RDS PostgreSQL** as the database backend
- **ALB** for public access
- **CloudWatch** for logs and metrics
- **GitHub Actions** (`deploy.yml`) for CI/CD
- **Terraform** for infrastructure provisioning

---

## 📁 Folder Structure

```bash
.
├── .github/
│   └── workflows/
│       └── deploy.yml         # CI/CD combined workflow
├── docker/
│   └── Dockerfile             # Strapi Docker build
│   ├── dev.tfvars             # Terraform variables
│   └── maxxy.pem              # EC2 SSH key (if used for RDS or testing)
├── terraform/
│   ├── main.tf                # Infrastructure code
│   ├── variables.tf
│   ├── outputs.tf
│   └── ecs-task-def.json      # ECS Task Definition (or use inline HCL)
├── strapi/                    # Your Strapi application code
├── README.md

GitHub repository with secrets:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

AWS_REGION

ECR_REPO_URL

Terraform will provision:

ECS Cluster, Service, Task Definition

ECR Repository

RDS PostgreSQL (if included)

Application Load Balancer

CloudWatch Log Group /ecs/strapi

CloudWatch Dashboard with ECS metrics

3️⃣ GitHub Actions Workflow
✅ .github/workflows/deploy.yml
This single workflow does:

Build Docker image for Strapi

Tag and push image to ECR

Update ECS Task Definition

Trigger new ECS Fargate deployment

You can trigger it on push to main, or manually with workflow_dispatch.

📊 CloudWatch Monitoring
🔹 Logs
Strapi logs are stored under:

bash
Copy
Edit
/ecs/strapi
This is defined in ECS Task Definition:

json
Copy
Edit
"logConfiguration": {
  "logDriver": "awslogs",
  "options": {
    "awslogs-group": "/ecs/strapi",
    "awslogs-region": "us-east-2",
    "awslogs-stream-prefix": "ecs/strapi"
  }
}
🔹 Metrics Dashboard
Using CloudWatch Container Insights + custom dashboard (via Terraform):

Includes:

CPU Utilization

Memory Utilization

Task Count

Network In / Out

Top containers by usage

🌐 Access Strapi
After deployment, Terraform outputs the load balancer DNS:

Outputs:

strapi_url = "http://madhan-strapi-alb-878521055.us-east-2.elb.amazonaws.com"

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
