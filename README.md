 # DevOps-Assignment: Full-Stack Application Deployment on AWS ECS

This repository contains a full-stack application with a FastAPI backend and a Next.js frontend, deployed on AWS Elastic Container Service (ECS) Fargate using Docker, managed by GitHub Actions for CI/CD, and provisioned with Terraform for Infrastructure as Code. Monitoring is set up with AWS CloudWatch.

## Table of Contents

1.  [Project Overview](#1-project-overview)
2.  [Architecture](#2-architecture)
3.  [Prerequisites](#3-prerequisites)
4.  [Local Development Setup](#4-local-development-setup)
5.  [Dockerization](#5-dockerization)
6.  [AWS Deployment with Terraform](#6-aws-deployment-with-terraform)
7.  [CI/CD with GitHub Actions](#7-cicd-with-github-actions)
8.  [Accessing the Deployed Application](#8-accessing-the-deployed-application)
9.  [Monitoring](#9-monitoring)
10. [Security Best Practices](#10-security-best-practices)
11. [Testing](#11-testing)
12. [Troubleshooting](#12-troubleshooting)
13. [Demo Video](#13-demo-video)
14. [Contact](#14-contact)

---

## 1. Project Overview

This project showcases a complete DevOps pipeline for a web application:
*   **Backend:** FastAPI (Python)
*   **Frontend:** Next.js (React)
*   **Containerization:** Docker (single multi-stage Dockerfile)
*   **Container Registry:** AWS Elastic Container Registry (ECR)
*   **Container Orchestration:** AWS Elastic Container Service (ECS) Fargate
*   **Infrastructure as Code (IaC):** Terraform
*   **CI/CD:** GitHub Actions
*   **Monitoring & Alerting:** AWS CloudWatch
*   **Secrets Management:** AWS Secrets Manager

## 2. Architecture

The application is deployed as a single container running both the backend and frontend. An AWS Application Load Balancer (ALB) routes traffic to the ECS Fargate tasks. Secrets are managed via AWS Secrets Manager, and comprehensive monitoring is provided by CloudWatch.

![Architecture Diagram Placeholder](https://example.com/your-architecture-diagram.png)
*(Replace this with your actual architecture diagram image link)*

## 3. Prerequisites

Before you begin, ensure you have the following installed:

*   [Git](https://git-scm.com/downloads)
*   [Docker Desktop](https://www.docker.com/products/docker-desktop)
*   [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (configured with your AWS credentials)
*   [Node.js](https://nodejs.org/en/download/) (LTS version, e.g., 18.x) & npm
*   [Python](https://www.python.org/downloads/) (3.9+) & pip
*   [Terraform](https://developer.hashicorp.com/terraform/downloads) (CLI)

**AWS Credentials:**
Ensure your AWS CLI is configured with credentials that have programmatic access and sufficient permissions to create and manage:
*   VPC, Subnets, Internet Gateway, Route Tables
*   Security Groups
*   ECR Repositories
*   ECS Clusters, Task Definitions, Services
*   IAM Roles and Policies (for ECS task execution and task roles)
*   Application Load Balancers, Target Groups, Listeners
*   Secrets Manager
*   CloudWatch Dashboards, Alarms, SNS Topics

**GitHub Secrets:**
For the CI/CD pipeline, you will need to configure the following secrets in your GitHub repository (`Settings > Secrets and variables > Actions > New repository secret`):
*   `AWS_ACCESS_KEY_ID`
*   `AWS_SECRET_ACCESS_KEY`
*   `ALERT_EMAIL` (Email for CloudWatch alerts, ensure you confirm the SNS subscription email)
*   `DB_CREDENTIALS` (JSON string for database credentials, e.g., `{"username": "your_db_user", "password": "your_db_password"}`)

## 4. Local Development Setup

To run the frontend and backend locally in separate processes:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/singhmohit14072002/DevOps-Assignment.git
    cd DevOps-Assignment
    ```

2.  **Backend Setup:**
    ```bash
    cd backend
    python -m venv venv
    ./venv/Scripts/activate # On Windows PowerShell
    # source venv/bin/activate # On Linux/macOS
    pip install -r requirements.txt
    uvicorn app.main:app --host 0.0.0.0 --port 8000
    ```
    The backend will run on `http://localhost:8000`.

3.  **Frontend Setup:**
    Open a **new terminal window** and navigate to the project root:
    ```bash
    cd frontend
    npm install
    npm run dev
    ```
    The frontend will run on `http://localhost:3000`. It is configured to proxy API requests to `http://localhost:8000` (which is the backend).

## 5. Dockerization

The application is containerized using a multi-stage `Dockerfile` located at the project root. This `Dockerfile` builds the Next.js frontend and then includes its static assets with the FastAPI backend in a single image.

1.  **Build the Docker Image:**
    Ensure you are in the root directory of the project (`DevOps-Assignment`).
    ```bash
    docker build -t devops-assignment-app:local .
    ```

2.  **Run the Docker Container Locally:**
    ```bash
    docker run -p 8000:8000 devops-assignment-app:local
    ```
    The application will be accessible at `http://localhost:8000`.

## 6. AWS Deployment with Terraform

Terraform manages the AWS infrastructure.

1.  **Navigate to the Terraform directory:**
    ```bash
    cd terraform
    ```

2.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

3.  **Review the plan (optional but recommended):**
    ```bash
    terraform plan
    ```

4.  **Apply the Infrastructure:**
    This will provision all necessary AWS resources, including VPC, subnets, ALB, ECS cluster, service, task definition, ECR, IAM roles, Secrets Manager, and CloudWatch.
    ```bash
    terraform apply -auto-approve
    ```
    After successful application, Terraform will output the `alb_dns_name`. This is your application's public URL.

5.  **Destroy the Infrastructure (when no longer needed):**
    **WARNING:** This command will delete all provisioned AWS resources associated with this Terraform configuration, incurring no further costs.
    ```bash
    terraform destroy -auto-approve
    ```

## 7. CI/CD with GitHub Actions

The `ci-cd.yml` workflow automates the build, test, and deployment process.

*   **Location:** `.github/workflows/ci-cd.yml`
*   **Triggers:** Pushes to `develop`, `main`, and `assignment` branches, and Pull Requests to `develop` and `assignment` branches.
*   **Workflow:**
    *   **`build-and-test` Job:**
        *   Checks out code.
        *   Installs backend dependencies and runs `pytest`.
        *   Installs frontend dependencies and runs `jest`.
        *   Configures AWS credentials using GitHub Secrets.
        *   Logs into ECR.
        *   Builds the Docker image with the Git SHA as a tag (on `develop` or `assignment` pushes).
        *   Pushes the Docker image to ECR.
    *   **`deploy` Job:**
        *   Depends on `build-and-test` job's success.
        *   Triggers only on pushes to `develop`, `main`, or `assignment` branches.
        *   Configures AWS credentials.
        *   Installs AWS CLI.
        *   Updates the ECS Task Definition with the new image URI from the `build-and-test` job.
        *   Forces a new deployment to the ECS Service.

## 8. Accessing the Deployed Application

Once the `terraform apply` or a successful GitHub Actions `deploy` job is complete, you can access your application at the Application Load Balancer's DNS name.

**Deployed Application URL:** `http://devops-assignment-alb-28266631.us-east-1.elb.amazonaws.com`
*(Note: The actual DNS name may vary slightly based on your AWS account and region, but you can always get it from `terraform output alb_dns_name` in your `terraform/` directory)*

## 9. Monitoring

AWS CloudWatch dashboards and alarms are configured to monitor the application's health and performance.

*   **CloudWatch Dashboard:** A dashboard named `devops-assignment-dashboard` (or similar, based on your `project_name`) is created, displaying:
    *   ECS Service CPU Utilization
    *   ECS Service Memory Utilization
    *   ALB Request Count
*   **CPU Utilization Alarm:** An SNS alarm is set up to notify `ALERT_EMAIL` if the ECS service's CPU utilization exceeds 70%.

You can access these in the AWS CloudWatch console under "Dashboards" and "Alarms."

## 10. Security Best Practices

*   **Least Privilege:** IAM roles for ECS tasks are configured with minimal necessary permissions.
*   **Secrets Management:** Database credentials are securely stored in AWS Secrets Manager and injected into the container at runtime, never hardcoded.
*   **GitHub Secrets:** Sensitive AWS credentials for CI/CD are stored as GitHub Secrets, not directly in the workflow files.
*   **Network Segmentation:** Security groups isolate the ALB and ECS tasks, allowing only required traffic.

## 11. Testing

Both backend and frontend include automated tests.

*   **Backend Tests:**
    *   Located in `backend/` directory.
    *   Uses `pytest`.
    *   Run locally: `cd backend && pytest`
*   **Frontend Tests:**
    *   Located in `frontend/__tests__/` directory.
    *   Uses `jest` and `@testing-library/react`.
    *   Configured with `babel.config.js` and `jest.config.js` for JSX support and `jsdom` environment.
    *   Run locally: `cd frontend && npm test`

CI/CD pipeline automatically runs these tests on every push.

## 12. Troubleshooting

*   **503 Service Temporarily Unavailable:**
    *   Check ECS service events and task status in the AWS Console. Look for `Stopped` tasks with `ResourceInitializationError` or `CannotPullContainerError`.
    *   Ensure your ECS Task Execution Role has `secretsmanager:GetSecretValue` permissions for your database secret.
    *   Verify the Docker image exists in ECR and the ECS Task Definition points to the correct image tag (e.g., Git SHA).
    *   Check ALB Target Group health checks.
*   **GitHub Actions Workflow Failures:**
    *   Examine the specific step that failed in the workflow logs on GitHub Actions.
    *   Common issues: incorrect environment variables, missing permissions (AWS, ECR, Secrets Manager), syntax errors in workflow, incorrect paths.
    *   `awscli` installation issues: Ensure `sudo ./aws/install --update` is used if `awscli` is pre-existing.
*   **Terraform Errors:**
    *   Always run `terraform plan` before `apply` to see proposed changes.
    *   Review error messages carefully; they often indicate missing permissions or resource conflicts.

## 13. Demo Video

A comprehensive demo video is available, covering the entire project from architecture to live deployment and monitoring.

**Demo Video Link:** [Insert your Demo Video Link Here]

## 14. Contact

For any questions or further assistance, please contact:

Mohit Singh 
Mobile No. 8085110031
https://www.linkedin.com/in/mohit-singh-9b4b42253/