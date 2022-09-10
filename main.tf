#############################################################################
# VARIABLES
#############################################################################

variable "region" {
  type    = string
}

variable "access_key" {
  type    = string
}

variable "secret_key" {
  type    = string
}

variable "identifier" {
  type    = string
}

variable "storage_type" {
  type    = string
}

variable "allocated_storage" {
  type    = string
}

variable "engine" {
  type    = string
}

variable "engine_version" {
  type    = string
}

variable "instance_class" {
  type    = string
}

variable "port" {
  type    = string
}

variable "db_name" {
  type    = string
}

variable "username" {
  type    = string
}

variable "password" {
  type    = string
}

variable "parameter_group_name" {
  type    = string
}

variable "publicly_accessible" {
  type    = bool
}

variable "deletion_protection" {
  type    = bool
}

variable "skip_final_snapshot" {
  type    = bool
}

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

resource "random_pet" "server" {
  length = 2
}

resource "random_pet" "database" {
  length = 2
}

locals {
  random_integer = "${random_integer.rand.result}"
  default_aws_db_subnet_group = "default-${aws_default_vpc.default.id}"
  identifier = "${var.identifier}-${random_pet.server.id}" 
  db_name    = "${var.db_name}_${replace("${random_pet.database.id}", "-", "_")}" 
  availability_zone = "${var.region}c"  
}

#############################################################################
# PROVIDERS
#############################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
}

provider "aws" {
  region = var.region
  //access_key = var.access_key
  //secret_key = var.secret_key
}

#############################################################################
# RESOURCES
#############################################################################  

//----------Sets the default vpc----------

resource "aws_default_vpc" "default" { }

//----------db_security_group lookup----------

data "aws_security_groups" "the_db_security_group" {
  
  filter {
    name   = "group-name"
    values = ["db_security_group"]
  }

  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
  
}

//----------Creates the AWS db instance----------

resource "aws_db_instance" "the_postgresql_instance" {
  identifier              = local.identifier
  storage_type            = var.storage_type
  allocated_storage       = var.allocated_storage
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  port                    = var.port
  
  vpc_security_group_ids = data.aws_security_groups.the_db_security_group.ids
  db_subnet_group_name    = local.default_aws_db_subnet_group
  
  db_name                 = local.db_name
  username                = var.username
  password                = var.password
  
  parameter_group_name    = var.parameter_group_name
  availability_zone       = local.availability_zone

  publicly_accessible     = var.publicly_accessible
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
}

##################################################################################
# aws_db_instance - OUTPUT
##################################################################################

output "aws_db_instance_identifier" {
  description = "Server Name"
  value = aws_db_instance.the_postgresql_instance.identifier
}

output "aws_db_instance_db_name" {
  description = "DB Name"
  value = aws_db_instance.the_postgresql_instance.db_name
}

output "aws_db_instance_vpc_security_group_ids" {
  description = "Security Group"
  value = aws_db_instance.the_postgresql_instance.vpc_security_group_ids
}

output "aws_db_instance_db_subnet_group_name" {
  description = "Subnet Group"
  value = aws_db_instance.the_postgresql_instance.db_subnet_group_name
}

output "aws_db_instance_endpoint" {
  description = "Endpoint"
  value = aws_db_instance.the_postgresql_instance.endpoint
}