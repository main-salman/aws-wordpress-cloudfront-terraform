# AWS WordPress Deployment with CloudFront using Terraform

I couldn't find an existing repo with a simple way to deploy a WordPress site on AWS with CloudFront CDN integration, so I created this Terraform script to do it. This is great to test out CloudFront CDN integration with WordPress on AWS. Bunch of other scripts I found required owning a domain name and a lot of other stuff. This is just a simple script to get you started. Just simply run "terraform init" and "terraform apply" and you're good to go!

Before running the script, the only three things you need to provide are:

1. AWS Access Key
2. AWS Secret Key
3. Key Pair Name

All the other variables are optional and you can change them to your liking.


## Architecture Components

### Network Infrastructure
- VPC with DNS support enabled
- 2 Public Subnets across different availability zones
- Internet Gateway for public internet access
- Route Tables for network traffic management

### Database
- Amazon RDS MySQL 8.0 instance
- Multi-AZ subnet group for high availability
- Dedicated security group for database access

### Web Server
- EC2 instance running Amazon Linux 2023
- Apache web server with PHP
- WordPress latest version
- 20GB GP3 encrypted root volume
- Auto-configured wp-config.php

### Content Delivery
- CloudFront distribution for global content delivery
- HTTPS enabled with CloudFront's default certificate
- Optimized cache settings for WordPress

### Security
- Dedicated security groups for EC2 and RDS
- SSH access for management
- HTTPS redirection enabled
- Database accessible only from WordPress EC2 instance

## Prerequisites

1. AWS Account with appropriate permissions
2. Terraform (version 0.12 or later)
3. SSH key pair created in your AWS account

## Configuration Files

- `main.tf` - Main infrastructure configuration
- `variables.tf` - Variable definitions
- `variables.tfvars` - Variable values (sensitive information)
- `outputs.tf` - Output values after deployment


## Deployment Instructions

1. Clone the repository:
```bash
git clone <repository-url>
cd wordpress-terraform-aws
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the deployment plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. After successful deployment, Terraform will output:
- WordPress instance IP
- WordPress instance DNS name
- CloudFront domain name
- RDS endpoint

## Accessing WordPress

1. Wait approximately 5-10 minutes after deployment for all services to start
2. Access your WordPress site via the CloudFront domain name
3. Complete the WordPress installation using:
   - Database Name: wordpress_db
   - Database User: (from terraform.tfvars)
   - Database Password: (from terraform.tfvars)
   - Database Host: (RDS endpoint from output)

## SSH Access

To connect to the EC2 instance:
```bash
ssh -i /path/to/key-pair.pem ec2-user@<instance-ip>
```

## Security Considerations

1. Store `terraform.tfvars` securely and never commit it to version control
2. Consider using AWS Secrets Manager for sensitive values
3. Restrict SSH access to specific IP ranges in production
4. Regularly update WordPress and plugins
5. Monitor AWS CloudWatch logs and metrics

## Clean Up

To destroy the infrastructure:
```bash
terraform destroy
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
```
