
# 🚀 Strapi Blue/Green Deployment on AWS using Terraform + GitHub Actions

This project automates the **Blue/Green deployment** of a Dockerized Strapi application on AWS ECS Fargate using:

- **Terraform** for infrastructure provisioning.
- **AWS CodeDeploy** for Blue/Green traffic shifting.
- **GitHub Actions** for CI/CD.
- **GitHub Artifacts** for Terraform state storage (no S3 required).

---

## 📂 Project Structure
github/workflows/
| ci.yml 
│ └── cd.yml # Terraform CD pipeline
├── terraform/
│ ├── main.tf # Main Terraform config
│ ├── variables.tf # Variable definitions
│ └── terraform.tfstate # State file (downloaded/uploaded via GitHub)
├── Dockerfile # Strapi Docker config
└── README.md

## 🔑 Secrets Required

Set these in your repository's GitHub secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID`
- `APP_KEYS`
- `JWT_SECRET`
- `ADMIN_JWT_SECRET`
- `API_TOKEN_SALT`


## 📦 Terraform Modules Used

- `aws_ecs_service`
- `aws_codedeploy_app`
- `aws_codedeploy_deployment_group`
- `aws_iam_role`
- `aws_lb` and `aws_lb_target_group`


# 🔍 Observability

- **CloudWatch Dashboard** for CPU & Memory.
- **CodeDeploy Events** for deployment progress.
- **Logs** streamed from ECS to CloudWatch.

---

## 📸 Example: Blue/Green Visualization
ALB --> [BLUE Target Group maddy)] --> ECS Fargate

--> [GREEN Target Group maxxy] --> ECS Fargate (on new deployment)
# Strapi ECS Deployment (Task #10)

## ✅ Project Summary

This project demonstrates how to deploy a **Strapi application** using **AWS ECS Fargate**, **Terraform**, and **GitHub Actions**. The backend is containerized, pushed to ECR, and deployed with an ALB.

---

## 📦 Tech Stack

- Strapi (Node.js headless CMS)
- Docker
- AWS ECS Fargate
- AWS ALB
- ECR
- Terraform
- GitHub Actions
- PostgreSQL (via AWS RDS or Docker)

---

## 🚀 Deployment Steps

1. **Containerize the Strapi App**
   - Dockerfile and docker-compose are set up in the `my-strapi/` folder.

2. **Push Docker Image to ECR**
   - Done using GitHub Actions CI workflow: `.github/workflows/deploy.yml`.

3. **Provision AWS Infrastructure**
   - Terraform files define ECS Cluster, Task Definition, Service, ALB, Security Groups, IAM Roles, etc.

4. **Deploy to ECS**
   - Terraform deploys the image from ECR to ECS Fargate.

---

## 🌐 Deployed URL

```text
http://madhan-strapi-alb-1555952243.us-east-2.elb.amazonaws.com
The homepage loads successfully with a 200 OK response.

⚠️ API Testing Status
Admin panel opens but content types could not be created or published directly in the deployed environment.

So, collection types (book, author, publisher) were created and published locally in development mode.

Roles & Permissions were set locally to allow public access.

The schema is deployed and visible in the repo under my-strapi/src/api/.

 API like /api/books returns 404 Not Found in production, as the data was not created on the deployed DB.

Local Development
Clone repo and go into the my-strapi/ folder.

Run:

bash
Copy
Edit
docker-compose up
Open http://localhost:1337/admin and create the first admin.

Create collection types and publish content.

terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
my-strapi/
├── src/api/book/
├── src/api/author/
├── src/api/publisher/
├── Dockerfile
├── docker-compose.yml

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
