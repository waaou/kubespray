resource "aws_instance" "bastion" {
  ami                    = "ami-0b2f05cf909299b7c"
  instance_type          = var.instancetype
  key_name               = "cka"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  availability_zone      = "${var.region}a"
  subnet_id              = aws_subnet.demo_sn_public_a.id
  user_data              = file("./postInstallScripts/postInstallBastion.sh")
  tags = {
    Name = "bastion_kubernetes"
  }
}

resource "aws_eip" "lb" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.lb.id
  // depends_on = [time_sleep.wait_30_seconds]
}


resource "aws_security_group" "allow_ssh" {
  name   = "bastion-security-group"
  vpc_id = aws_vpc.demo_vpc.id

  dynamic "ingress" {
    for_each = tolist(var.ingress_list)
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "kubernetes" {
  count                  = 4
  ami                    = var.ubuntu_ami
  instance_type          = var.instancetype
  key_name               = "cka"
  vpc_security_group_ids = [aws_security_group.allow_ssh_from_bastion.id, aws_security_group.allow_external_access.id, aws_security_group.allow_internal_access.id ]
  availability_zone      = "${var.region}a"
  subnet_id              = aws_subnet.demo_sn_private_a.id
  private_ip             = "10.0.4.${10 + count.index}"
  associate_public_ip_address = true
  user_data              = file("./postInstallScripts/postInstallK8s.sh")
}

resource "aws_security_group" "allow_ssh_from_bastion" {
  name   = "ssh-kubernetes-security-group"
  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]
  }
}

resource "aws_security_group" "allow_external_access" {
  name   = "external-kubernetes-security-group"
  vpc_id = aws_vpc.demo_vpc.id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "allow_internal_access" {
  name   = "internal-kubernetes-security-group"
  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  /*egress {
    from_port = 0
    to_port   = 65535
    protocol  = "-1"
    self      = true
  }*/
}
