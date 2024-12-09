variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "db_name" {
  description = "WordPress database name"
  type        = string
  default     = "wordpress_db"
}

variable "db_username" {
  description = "WordPress database username"
  type        = string
}

variable "db_password" {
  description = "WordPress database password"
  type        = string
}

variable "wordpress_ami" {
  description = "AMI ID for WordPress instance"
  type        = string
  default     = "ami-0e731c8a588258d0d"  # Amazon Linux 2023 AMI in us-east-1
}

variable "wordpress_instance_type" {
  description = "Instance type for WordPress EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "database_instance_type" {
  description = "Instance type for RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the EC2 instance"
  type        = string
}

variable "wordpress_db_host" {
  description = "WordPress database host"
  type        = string
  default     = ""
}

variable "wordpress_table_prefix" {
  description = "WordPress table prefix"
  type        = string
  default     = "wp_"
}

variable "wordpress_debug" {
  description = "Enable WordPress debug mode"
  type        = bool
  default     = false
} 