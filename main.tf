# TODO: Extract "provider" as as module.

# variable "aws_access_key" {}
# variable "aws_secret_key" {}

# NOTICE: An attempt to initialize provider,
# - with different authentication strategies.
# - It failed.
# provider "aws" {
#   count      = "${1 - var.aws_shared_crendetial_file_path}"
#   access_key = "${var.aws_access_key}"
#   secret_key = "${var.aws_secret_key}"
#   region     = "${var.aws_region}"
# }


###############################################################################
# VARIABLES
###############################################################################

variable "aws_shared_crendetial_file_path" {
  description = <<-DESC
  The file path to access AWS credentials.
  If this specified, aws_access_key and aws_secret_key will be ignored.
  DESC

  default = "~/.aws/creds"
}

variable "aws_profile" {
  description = <<-DESC
  The profile that specifies necessary credentials in shared credential file.
  This needs to be specified when aws_shared_crendetial_file_path used.
  DESC

  default = "personal"
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"

  default = 8080
}

###############################################################################
# PROVIDERS
###############################################################################

provider "aws" {
  # count                   = "${var.aws_shared_crendetial_file_path}"
  shared_credentials_file = "${var.aws_shared_crendetial_file_path}"
  profile                 = "${var.aws_profile}"
  region                  = "${var.aws_region}"
}

###############################################################################
# RESOURCES
###############################################################################

resource "aws_security_group" "example_security_group" {
  name = "terraform-example-instance-security-group"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example_instance" {
  instance_type          = "t2.micro"
  ami                    = "ami-76801819"
  vpc_security_group_ids = ["${aws_security_group.example_security_group.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Simplicity is greatest sophistication!" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  tags {
    Name = "terraform-single-web-server-instance"
  }
}

###############################################################################
# OUTPUT
###############################################################################

output "aws_instance_public_dns" {
  value = "${aws_instance.example_instance.public_dns}"
}

output "aws_instance_public_ip" {
  value = "${aws_instance.example_instance.public_ip}"
}
