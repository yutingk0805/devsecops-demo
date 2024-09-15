# DevSecOps Terraform Demo

This repository demonstrates a simple 2-tier AWS infrastructure using Terraform, with built-in security checks implemented through Python. The infrastructure and code follow DevSecOps practices by running scans before deployment to ensure secure configurations are used.

## Project Structure

- **demo-infra/**: Contains the Terraform configuration files for deploying the infrastructure.
- **scan.py**: Python script to scan the Terraform templates for security vulnerabilities and misconfigurations based on predefined controls.
- **Makefile**: Automates the deployment process, including the scan, with various options (e.g., deploying without a scan, deploying with scan checks, etc.).

## Controls Implemented

The table below outlines the security controls that the Python script checks before deployment:

| Severity   | Control Description                                                   |
| ---------- | --------------------------------------------------------------------- |
| **HIGH**   | IAM Roles should not have Full Administrator permission attached.     |
| **HIGH**   | RDS DB instances should have encryption at rest enabled.              |
| **HIGH**   | S3 buckets should have server-side encryption enabled (`SSE`).        |
| **MEDIUM** | Security groups should not allow ingress from `0.0.0.0/0` on port 22. |
| **MEDIUM** | Attached EBS volumes should be encrypted at rest.                     |
| **LOW**    | S3 buckets should have logging enabled (logs read and write events).  |

## How It Works

1. **Infrastructure Design**:

   - A simple AWS architecture consisting of an EC2 instance, RDS database, S3 bucket, and associated security groups.
   - Infrastructure is defined using Terraform templates located in the `demo-infra/` directory.

2. **Security Scans**:

   - The `scan.py` script runs security scans on the Terraform templates before deployment.
   - The scan checks the templates for misconfigurations such as unencrypted resources, insecure IAM roles, and open security group rules.

3. **Automated Workflow**:
   - The `Makefile` provides different commands to initialize, plan, apply, and destroy the Terraform infrastructure. It integrates the Python security scan into the workflow to enforce security best practices.
   - The `apply-with-scan` command will:
     - Run the security scan.
     - Abort the deployment if **critical/high** severity issues are found.
     - Prompt for manual confirmation if **medium** severity issues are found.
     - Proceed automatically if only **low** severity issues are found.

## Usage

### Initialize Terraform

Initialize the Terraform project with the following command:

```bash
make init
```

### Plan Infrastructure and Run Scan

Generate an execution plan and run a security scan:

```bash
make plan
```

### Apply Infrastructure Without Scan

Deploy the infrastructure without running the security scan:

```bash
make apply
```

### Apply Infrastructure With Security Scan

Deploy the infrastructure with a security scan. The deployment will be aborted if high-severity issues are found:

```bash
make apply-with-scan
```

### Destroy Infrastructure

Tear down the infrastructure:

```bash
make destroy
```
