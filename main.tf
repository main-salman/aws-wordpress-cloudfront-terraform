provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "wordpress_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-wordpress-vpc"
    Environment = var.environment
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-1"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-2"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name        = "${var.environment}-wordpress-igw"
    Environment = var.environment
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "wordpress_db_subnet" {
  name       = "${var.environment}-wordpress-db-subnet"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name        = "${var.environment}-wordpress-db-subnet"
    Environment = var.environment
  }
}

# Security Groups
resource "aws_security_group" "wordpress_sg" {
  name        = "${var.environment}-wordpress-sg"
  description = "Security group for WordPress EC2 instance"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add SSH access (optional, for management)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # In production, restrict to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for WordPress RDS instance"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

# RDS Instance
resource "aws_db_instance" "wordpress_db" {
  identifier           = "${var.environment}-wordpress-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = var.database_instance_type
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.wordpress_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name        = "${var.environment}-wordpress-db"
    Environment = var.environment
  }
}

# EC2 Instance
resource "aws_instance" "wordpress" {
  ami                         = var.wordpress_ami
  instance_type              = var.wordpress_instance_type
  subnet_id                  = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  key_name                   = var.key_name

  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name        = "${var.environment}-wordpress-root-volume"
      Environment = var.environment
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              # Wait for system to be updated
              sleep 30
              
              # Update package lists
              dnf update -y
              
              # Install EPEL repository
              dnf install -y epel-release
              
              # Install Apache, PHP, and other required packages
              dnf install -y httpd httpd-tools
              dnf install -y php php-cli php-fpm php-mysqlnd php-json php-opcache php-gd php-curl php-mbstring php-xml php-zip
              dnf install -y mariadb mariadb-server
              
              # Start and enable Apache
              systemctl enable --now httpd
              
              # Download and configure WordPress
              wget https://wordpress.org/latest.tar.gz
              tar -xzf latest.tar.gz
              cp -r wordpress/* /var/www/html/
              
              # Create wp-config.php
              cat > /var/www/html/wp-config.php <<'WPCONFIG'
              <?php
              define( 'DB_NAME', '${var.db_name}' );
              define( 'DB_USER', '${var.db_username}' );
              define( 'DB_PASSWORD', '${var.db_password}' );
              define( 'DB_HOST', '${aws_db_instance.wordpress_db.endpoint}' );
              define( 'DB_CHARSET', 'utf8' );
              define( 'DB_COLLATE', '' );
              define( 'WP_DEBUG', ${var.wordpress_debug} );
              
              define( 'AUTH_KEY',         '${random_password.wp_auth_key.result}' );
              define( 'SECURE_AUTH_KEY',  '${random_password.wp_secure_auth_key.result}' );
              define( 'LOGGED_IN_KEY',    '${random_password.wp_logged_in_key.result}' );
              define( 'NONCE_KEY',        '${random_password.wp_nonce_key.result}' );
              define( 'AUTH_SALT',        '${random_password.wp_auth_salt.result}' );
              define( 'SECURE_AUTH_SALT', '${random_password.wp_secure_auth_salt.result}' );
              define( 'LOGGED_IN_SALT',   '${random_password.wp_logged_in_salt.result}' );
              define( 'NONCE_SALT',       '${random_password.wp_nonce_salt.result}' );
              
              $table_prefix = '${var.wordpress_table_prefix}';
              
              if ( ! defined( 'ABSPATH' ) ) {
                  define( 'ABSPATH', __DIR__ . '/' );
              }
              
              require_once ABSPATH . 'wp-settings.php';
              WPCONFIG
              
              # Set proper permissions
              chown -R apache:apache /var/www/html/
              chmod -R 755 /var/www/html/
              restorecon -Rv /var/www/html/
              
              # Start services
              systemctl restart httpd
              systemctl status httpd
              
              # Enable services to start on boot
              systemctl enable httpd
              
              # Create info.php to test PHP
              echo "<?php phpinfo(); ?>" > /var/www/html/info.php
              EOF

  tags = {
    Name        = "${var.environment}-wordpress"
    Environment = var.environment
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "wordpress_cdn" {
  enabled = true
  
  origin {
    domain_name = aws_instance.wordpress.public_dns
    origin_id   = aws_instance.wordpress.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_instance.wordpress.id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.environment}-wordpress-cdn"
    Environment = var.environment
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
} 

# Generate random strings for WordPress salts
resource "random_password" "wp_auth_key" {
  length  = 64
  special = true
}

resource "random_password" "wp_secure_auth_key" {
  length  = 64
  special = true
}

resource "random_password" "wp_logged_in_key" {
  length  = 64
  special = true
}

resource "random_password" "wp_nonce_key" {
  length  = 64
  special = true
}

resource "random_password" "wp_auth_salt" {
  length  = 64
  special = true
}

resource "random_password" "wp_secure_auth_salt" {
  length  = 64
  special = true
}

resource "random_password" "wp_logged_in_salt" {
  length  = 64
  special = true
}

resource "random_password" "wp_nonce_salt" {
  length  = 64
  special = true
} 