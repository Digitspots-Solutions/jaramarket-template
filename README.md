# Jaramarket Infrastructure Template

This repository contains the Terraform template for the Jaramarket e-commerce platform infrastructure. The platform is designed using a serverless-first approach on AWS to ensure high availability, scalability, and operational efficiency.

## Architecture Overview

The infrastructure relies primarily on AWS Fargate for container orchestration and utilizes AWS managed services for data persistence, caching, and delivery.

* **Compute (AWS Fargate):** The application runs three independent microservices orchestrated by Amazon ECS on AWS Fargate. Fargate was selected to eliminate the operational overhead of OS patching and underlying node management, focusing strictly on application delivery.
* **Network (VPC):** The network spans two Availability Zones for high availability. It features public subnets for the Application Load Balancer and NAT Gateways, alongside private subnets to isolate the ECS tasks, databases, and caches.
* **Database (Amazon RDS):** A Multi-AZ Amazon RDS (PostgreSQL) instance is provisioned to provide automated failover, backups, and secure persistent data storage.
* **Caching & Session Management (Amazon ElastiCache):** A Redis cluster handles in-memory data caching and user session management efficiently.
* **Content Delivery & DNS:** Amazon CloudFront acts as a global CDN to accelerate static and dynamic content delivery, while Amazon Route 53 manages DNS records and performs automated endpoint health checks.
* **Load Balancing:** An Application Load Balancer (ALB) securely routes incoming HTTP/HTTPS traffic to the corresponding microservice tasks.
* **Container Registry (Amazon ECR):** Container images are securely stored in Amazon ECR. Vulnerability scanning is configured to run automatically upon image push.
* **CI/CD Automation:** Fully automated deployment pipelines are defined using AWS CodePipeline and CodeBuild for build/test workflows, integrated with AWS CodeDeploy for zero-downtime blue-green deployments to ECS.

## Project Structure

* `network.tf`: Virtual Private Cloud (VPC), Subnets, Route Tables, Internet Gateway, and NAT Gateways.
* `ecs.tf`: Amazon ECS Cluster, Task Definitions, ECS Services, IAM Roles, and Amazon ECR configuration.
* `database.tf`: Amazon RDS Multi-AZ instances, Amazon ElastiCache (Redis) setup, and Subnet Groups.
* `alb_cdn.tf`: Application Load Balancer, Listener Rules, Target Groups, CloudFront distribution, and Route 53 DNS records.
* `cicd.tf`: CI/CD automation utilizing CodePipeline, CodeBuild, and CodeDeploy.
* `variables.tf`: Input variables required to parameterize the environment.
* `outputs.tf`: Useful outputs exported after a successful Terraform application.

## Getting Started

1. Ensure you have the [Terraform CLI](https://www.terraform.io/downloads.html) and [AWS CLI](https://aws.amazon.com/cli/) installed.
2. Configure your AWS credentials using `aws configure` or environment variables.
3. Define the required sensitive parameters and environment-specific variables (such as `db_username`, `db_password`, `domain_name`, `acm_certificate_arn`) in a `terraform.tfvars` file.
4. Initialize the Terraform workspace:
   ```bash
   terraform init
   ```
5. Review the execution plan to understand the changes that will be made to your AWS environment:
   ```bash
   terraform plan
   ```
6. Apply the configuration to provision the infrastructure:
   ```bash
   terraform apply
   ```

## Security Posture

* **Network Isolation:** All backend resources (ECS tasks, RDS database, ElastiCache cluster) reside strictly within private subnets. They are entirely inaccessible directly from the internet.
* **Vulnerability Management:** Container images are automatically scanned for vulnerabilities when pushed to the ECR repositories.
* **Least Privilege Access:** Security Groups enforce strict boundaries, ensuring services only communicate with permitted dependencies (e.g., ALB to ECS tasks, ECS tasks to RDS).
