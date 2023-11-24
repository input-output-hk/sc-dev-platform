# ======================================================================================================= #
#
#  THIS CONIFIGURATION IS AUTOMATED TO RUN DAILY FROM A CRON JOB ON THE BASTION HOST. PLEASE DON'T EDIT 
#  UNLESS YOU KNOW WHAT YOU ARE DOING I.E. YOU HAVE READ THIS DOC: <TO BE UPDATED>
#
# ======================================================================================================= #

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    encrypt        = true
    bucket         = "tf-state-dapps-world-us-east-1"
    key            = "looker-studio-db/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    profile        = "dapps-world"
  }
}

provider "aws" {
  profile = "dapps-world"
  region  = "us-east-1"
}

data "aws_db_snapshot" "db_snapshot" {
  most_recent = true
  db_instance_identifier = "prod-marlowe-runtime-db"
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "dapps-world-looker-studio-db"

  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.m5d.large"

  db_subnet_group_name  = "default-vpc-069bcddaa7f85475c"
  vpc_security_group_ids = ["sg-09f5cd27a8e66ff32"]

  publicly_accessible = true

  snapshot_identifier = "${data.aws_db_snapshot.db_snapshot.id}"

  tags = {
    Owner       = "Terraform"
    Application = "Marlowe Runtime"
  }

  # DB parameter group
  family = "postgres15"

  # DB option group
  major_engine_version = "15"

  performance_insights_enabled = true

  skip_final_snapshot = true

  # Database Deletion Protection
  deletion_protection = false
}
