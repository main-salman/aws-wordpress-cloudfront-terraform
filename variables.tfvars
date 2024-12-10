aws_access_key = "XXXXXXXXXXXXXXXXXXXX"    # Replace with your actual access key
aws_secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  # Replace with your actual secret key
db_username    = "wordpress_user"
db_password    = "your-secure-password"
environment    = "production"
wordpress_ami = "ami-0e731c8a588258d0d"  # Only add this if you want to override the default
key_name      = "XXXXXXXXXXXXXXXXXXXX"     # Specify your existing key pair name here
wordpress_table_prefix = "wp_"
wordpress_debug       = false

# EC2 instance type options:
# - t2.micro  (1 vCPU, 1 GB RAM)
# - t2.small  (1 vCPU, 2 GB RAM)
# - t2.medium (2 vCPU, 4 GB RAM)
# - t3.small  (2 vCPU, 2 GB RAM)
# - t3.medium (2 vCPU, 4 GB RAM)
wordpress_instance_type = "t3.medium"

# RDS instance type options:
# - db.t3.micro    (1 vCPU, 1 GB RAM)
# - db.t3.small    (1 vCPU, 2 GB RAM)
# - db.t3.medium   (2 vCPU, 4 GB RAM)
# - db.t3.large    (2 vCPU, 8 GB RAM)
# - db.t3.xlarge   (4 vCPU, 16 GB RAM)
database_instance_type = "db.t3.large"
