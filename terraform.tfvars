
region                  = "us-east-1"
access_key              = ""
secret_key              = ""
identifier              = "db-server-postgresql"
storage_type            = "gp2"  
allocated_storage       = 20
engine                  = "postgres"
engine_version          = "13.7"
instance_class          = "db.t3.micro"
port                    = "5432"
db_name                 = "db_postgresql"
username                = "db_master"
password                = "thepwd0963"
parameter_group_name    = "default.postgres13"
publicly_accessible     = true
deletion_protection     = false
skip_final_snapshot     = true