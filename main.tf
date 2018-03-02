###############################################################################
# VARIABLES
###############################################################################

variable "aws_region" {
  default = "eu-central-1"
}

variable "ssh_remote_user" {
  default = "docker"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "vpn_data" {
  default = "openvpn-data-default"
}

variable "vpn_port" {
  default = 1194
}

variable "vpn_client_name" {
  default = "awesome-personal-vpn"
}

###############################################################################
# PROVIDERS
###############################################################################

provider "aws" {
  region = "${var.aws_region}"
}

###############################################################################
# RESOURCES
###############################################################################

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-deployer-key"
  public_key = "${file(var.ssh_public_key_path)}"
}

resource "aws_security_group" "vpn" {
  name = "terraform-vpn-security-group"

  ingress {
    from_port   = "${var.vpn_port}"
    to_port     = "${var.vpn_port}"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name = "terraform-ssh-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "outgoing" {
  name = "terraform-outgoing-security-group"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpn" {
  instance_type = "t2.micro"
  ami           = "ami-633ba70c"

  vpc_security_group_ids = [
    "${aws_security_group.vpn.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.outgoing.id}",
  ]

  key_name = "terraform-deployer-key"

  connection {
    user = "${var.ssh_remote_user}"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "docker volume create --name ${var.vpn_data}",
      "docker run -v ${var.vpn_data}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://${aws_instance.vpn.public_dns}",
      "yes 'yes' | docker run -v ${var.vpn_data}:/etc/openvpn --rm -i kylemanna/openvpn ovpn_initpki nopass",
      "docker run -v ${var.vpn_data}:/etc/openvpn -d -p ${var.vpn_port}:${var.vpn_port}/udp --cap-add=NET_ADMIN kylemanna/openvpn",
      "docker run -v ${var.vpn_data}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full ${var.vpn_client_name} nopass",
      "docker run -v ${var.vpn_data}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient ${var.vpn_client_name} > ~/${var.vpn_client_name}.ovpn",
    ]
  }

  provisioner "local-exec" {
    command    = "ssh-keyscan -T 120 ${aws_instance.vpn.public_ip} >> ~/.ssh/known_hosts"
  }

  provisioner "local-exec" {
    command    = "scp ${var.ssh_remote_user}@${aws_instance.vpn.public_ip}:~/${var.vpn_client_name}.ovpn ."
  }

  tags {
    Name = "terraform-openvpn"
  }
}

###############################################################################
# OUTPUT
###############################################################################

output "aws_instance_public_dns" {
  value = "${aws_instance.vpn.public_dns}"
}

output "aws_instance_public_ip" {
  value = "${aws_instance.vpn.public_ip}"
}

output "client_configuration_file" {
  value = "${var.vpn_client_name}.ovpn"
}

output "closing_message" {
  value = "Your VPN is ready! Check out client configuration file to configure your client! Have fun!'"
}
