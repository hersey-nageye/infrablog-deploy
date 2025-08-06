# InfraBlog Deploy - WordPress Deployment with Terraform and GitHub Actions

This project demonstrates how to deploy a WordPress website on AWS EC2 using Infrastructure as Code (IaC) with [Terraform](https://www.terraform.io/) and automate the deployment process using [GitHub Actions](https://docs.github.com/en/actions).

The solution provisions an EC2 instance, installs Apache, PHP, MySQL Server, and WordPress, and configures the database, all through an automated `user_data` script.

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Prerequisites](#prerequisites)
5. [Setup & Deployment](#setup--deployment)
   - [1. Clone the Repository](#1-clone-the-repository)
   - [2. Configure AWS Credentials](#2-configure-aws-credentials)
   - [3. Configure GitHub Repository Secrets](#3-configure-github-repository-secrets)
   - [4. Triggering the Workflow](#4-triggering-the-workflow)
6. [Usage](#usage)
7. [Customisation](#customisation)
8. [Cleanup](#cleanup)
9. [Important Considerations & Limitations](#important-considerations--limitations)
10. [Contributing](#contributing)
11. [Licence](#licence)

## Project Overview

This repository provides a fully automated pipeline to provision a WordPress application on a single AWS EC2 instance. It handles all aspects from cloud resource creation to application setup, making it easy to spin up a new WordPress site for development or testing purposes.

## Architecture

The project deploys the following AWS resources:

- **VPC:** A default VPC (or you can specify a custom one) to host the EC2 instance.
- **Security Group:** Configured to allow SSH (port 22) and HTTP (port 80) access.
- **EC2 Instance:** An Ubuntu Server instance that runs:
  - **Apache2:** Web server to serve WordPress.
  - **PHP:** Required for WordPress.
  - **MySQL Server:** Local database server for WordPress.
  - **WordPress:** The content management system itself.
- **SSH Key Pair:** For secure access to the EC2 instance.

## Features

- **Infrastructure as Code (IaC):** All AWS resources are defined and managed using Terraform.
- **Automated Deployment:** GitHub Actions pipeline orchestrates the `terraform plan` and `terraform apply` steps.
- **Automated WordPress Setup:** A `user_data` script handles the installation of Apache, PHP, MySQL, WordPress core files, and `wp-config.php` configuration.
- **Dynamic Variable Injection:** Sensitive database credentials are securely passed from GitHub Repository Secrets to Terraform and then into the `user_data` script.
- **Easy Cleanup:** Terraform enables straightforward destruction of all provisioned resources.

## Prerequisites

Before you begin, ensure you have the following:

1. **AWS Account:** With appropriate permissions to create EC2 instances, security groups, etc.
2. **Terraform CLI:** Installed locally if you wish to test or run Terraform commands outside of GitHub Actions.
3. **Git:** Installed on your local machine.
4. **GitHub Account:** To host this repository and run GitHub Actions.
5. **An Existing SSH Key Pair:** If you want to SSH into the EC2 instance. If you don't provide one, Terraform will generate a new one, but you'll need to retrieve its private key for access.

## Setup & Deployment

The deployment is fully automated via GitHub Actions. You just need to configure your AWS credentials and database secrets in your GitHub repository.

### 1. Clone the Repository

First, clone this repository to your local machine:

```
git clone https://github.com/hersey-nageye/wordpress-project.git
cd wordpress-project
```

### 2. Configure AWS Credentials

Your GitHub Actions workflow needs AWS credentials to deploy resources.

1. **Create an AWS IAM User:**
   - Go to the AWS IAM console.
   - Create a new user (e.g., `github-actions-user`).
   - Grant this user programmatic access (enable "Access key - Programmatic access").
   - Attach a policy that grants necessary permissions (e.g., `AmazonEC2FullAccess`, `AmazonRDSFullAccess` if you expand to RDS, or a custom policy with least privilege for EC2, Security Groups, VPC, etc.).
   - **Important:** Save the **Access Key ID** and **Secret Access Key**. You will only see the Secret Access Key once.

2. **Add AWS Credentials to GitHub Repository Secrets:**
   - In your GitHub repository, go to `Settings` > `Secrets and variables` > `Actions`.
   - Click `New repository secret`.
   - Create two new secrets:
     - **Name:** `AWS_ACCESS_KEY_ID`
     - **Value:** Paste your AWS Access Key ID
     - **Name:** `AWS_SECRET_ACCESS_KEY`
     - **Value:** Paste your AWS Secret Access Key

### 3. Configure GitHub Repository Secrets

The WordPress installation requires database credentials. These will be passed securely from your GitHub Repository Secrets to Terraform.

1. **In your GitHub repository, go to `Settings` > `Secrets and variables` > `Actions`.**
2. **Click `New repository secret`.**
3. Create the following three secrets:
   - **Name:** `DB_NAME`
     - **Value:** Your desired WordPress database name (e.g., `wordpress_db`)
   - **Name:** `DB_USER`
     - **Value:** Your desired WordPress database username (e.g., `wp_user`)
   - **Name:** `DB_PASSWORD`
     - **Value:** A strong, secure password for your database user.

   **Note:** Ensure the secret names are exactly `DB_NAME`, `DB_USER`, `DB_PASSWORD` as referenced in the workflow. Do NOT add `TF_VAR_` prefix to the secret names themselves.

### 4. Triggering the Workflow

The GitHub Actions workflow is configured to run automatically on `push` to the `main` branch.

1. **Commit your changes:**
   If you've made any local changes (e.g., fixing paths as per previous debugging), commit and push them to your `main` branch:
   ```
   git add .
   git commit -m "Initial project setup / Ready for deployment"
   git push origin main
   ```

2. **Monitor the Workflow:**
   - Go to your GitHub repository.
   - Click on the `Actions` tab.
   - You should see a workflow run in progress. Click on it to view the logs for `Terraform Plan` and `Terraform Apply` steps.
   - The `Terraform Apply` step will provision your EC2 instance.

## Usage

Once the `Terraform Apply` step in your GitHub Actions workflow completes successfully:

1. **Get the Public IP:**
   - In the GitHub Actions log for the `Terraform Apply` step, scroll down to the "Outputs" section.
   - You should find an output named `instance_public_ip` (or similar) with the IP address of your new EC2 instance.
   - Alternatively, go to your AWS EC2 console, find your newly launched instance, and copy its Public IPv4 address.

2. **Access WordPress:**
   - Open your web browser and navigate to `http://<your_instance_public_ip>`.
   - You should be redirected to the WordPress setup page. Follow the prompts to complete the WordPress installation (site title, admin user, etc.).

## Customisation

- **Terraform Variables (`variables.tf`):** Modify variables in `variables.tf` in your root and module directories to change instance type, region, etc.
- **`wordpress-user-data.sh`:** Customise the shell script in `modules/wordpress/wordpress-user-data.sh` to add more software, specific configurations, or pre-populate WordPress content.
- **GitHub Actions Workflow (`.github/workflows/main.yml`):** Adjust the workflow triggers or add more steps as needed.

## Cleanup

To avoid incurring ongoing AWS charges, it's crucial to destroy your infrastructure when you're done.

For this project, the `terraform destroy` operation is **performed manually** via the Terraform CLI on your local machine. The GitHub Actions workflow does *not* include an automated destroy step to prevent accidental resource deletion.

To destroy all provisioned resources:

1. **Ensure AWS Credentials are Configured Locally:** Make sure your local AWS CLI is configured with credentials that have permissions to destroy the resources.

2. **Navigate to the Terraform Root:** Open your terminal and navigate to the root directory of your cloned Terraform project.
   ```
   cd wordpress-project
   ```

3. **Initialise Terraform:**
   ```
   terraform init
   ```

4. **Run Terraform Destroy:**
   ```
   terraform destroy -auto-approve
   ```
   
   **Caution:** This command will permanently delete all resources provisioned by this Terraform configuration in your AWS account. Ensure you are in the correct directory and understand the impact before running.

## Important Considerations & Limitations

- **Database Persistence:** This setup installs MySQL Server directly on the EC2 instance. If the EC2 instance is terminated (e.g., due to `user_data` changes with `user_data_replace_on_change = true`, or manual termination), **all your WordPress data will be permanently lost**.
  - **Recommendation:** For production environments, always use a managed database service like [AWS RDS](https://aws.amazon.com/rds/) for data persistence, backups, and scalability.

- **`user_data_replace_on_change = true`:** This setting ensures that any change to your `user_data` script causes the EC2 instance to be destroyed and recreated, guaranteeing the new script runs. Be mindful of the data loss implication mentioned above if using local MySQL.

- **Scalability:** This is a single-instance WordPress deployment, suitable for development, testing, or small personal sites. For high-traffic production sites, you would need a more complex architecture involving load balancers, auto-scaling groups, and a managed database (like RDS).

- **Security:**
  - Ensure your `DB_PASSWORD` secret is strong and unique.
  - Consider restricting the Security Group's SSH access to specific IP addresses.
  - This setup uses MySQL's `root` user for initial setup from localhost and then creates a dedicated WordPress user. In production, ensure the `root` user is secured.

## Contributing

Feel free to open issues or pull requests if you have suggestions, improvements, or bug fixes.

## Licence

This project is open-source and available under the [MIT Licence](https://www.google.com/search?q=LICENCE).