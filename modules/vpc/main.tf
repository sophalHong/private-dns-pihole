## VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = "${merge(tomap({Name = var.vpc_name}), var.tags)}"
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = "${merge(tomap({Name = var.vpc_name}), var.tags)}"
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = var.aws_zones[0]
  map_public_ip_on_launch = true

  tags = "${merge(tomap({Name =  format("%v-public-%v", var.vpc_name, var.aws_zones[0])}), var.tags)}"
}

resource aws_nat_gateway nat {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_subnet.id

  tags = "${merge(tomap({Name = format("%v-nat-%v", var.vpc_name, var.aws_zones[0])}), var.tags)}"

  depends_on = [aws_eip.nat, aws_internet_gateway.gw, aws_subnet.public_subnet]
}

## Routing (public subnets)
resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.vpc.id}"

  # Default route through Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = "${merge(tomap({Name = format("%v-public-route-table", var.vpc_name)}), var.tags)}"
}

resource "aws_route_table_association" "route" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route.id
}
