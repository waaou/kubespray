resource "aws_vpc" "demo_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "kubernetes_vpc"
  }
}


resource "aws_internet_gateway" "demo_vpc_igtw" {
  vpc_id = aws_vpc.demo_vpc.id
}


/*
  Public Subnet
*/
resource "aws_subnet" "demo_sn_public_a" {
  vpc_id = aws_vpc.demo_vpc.id

  cidr_block        = var.public_subnet_a_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "bastion_sn_public_a"
  }
}

/*
  Private Subnet
*/
resource "aws_subnet" "demo_sn_private_a" {
  vpc_id = aws_vpc.demo_vpc.id

  cidr_block        = var.private_subnet_a_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "kubernetes_sn_private_a"
  }
}


/* add route to public subnet */

/* ici on autorise le réseau "public" à accéder à la Gateway internet */

resource "aws_route_table" "demo_vpc_rt_public" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_vpc_igtw.id
  }

  tags = {
    Name = "bastion_vpc_rt_public"
  }
}


resource "aws_route_table_association" "demo_vpc_rta_public_a" {
  subnet_id      = aws_subnet.demo_sn_public_a.id
  route_table_id = aws_route_table.demo_vpc_rt_public.id
}


resource "aws_route_table_association" "demo_vpc_rta_private_a" {
  subnet_id      = aws_subnet.demo_sn_private_a.id
  route_table_id = aws_route_table.demo_vpc_rt_public.id
}


/* ici on autorise le réseau "privé" à accéder à la NAT Gateway */
/*
resource "aws_route_table" "demo_vpc_rt_a_private" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.demo_nat_a_gw.id
  }

  tags = {
    Name = "demo_vpc_rt_private"
  }
}

resource "aws_route_table_association" "demo_vpc_rta_private_a" {
  subnet_id      = aws_subnet.demo_sn_private_a.id
  route_table_id = aws_route_table.demo_vpc_rt_a_private.id
}
*/

/*
resource "aws_route53_zone" "demo_private_zone" {
  name   = "${var.private_dns_zone}"
  
  vpc {
    vpc_id = "${aws_vpc.demo_vpc.id}"
  }

  tags {
    Environment = "private_hosted_zone"
  }
}
*/