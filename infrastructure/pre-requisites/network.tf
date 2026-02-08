data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "NaVa"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "NaVa IGW"
  }
}

resource "aws_eip" "nat" {
  count  = 1
  domain = "vpc"

  tags = {
    Name = "NAT Gateway EIP A"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "NAT GW A"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index * 16}.0/20"          # 10.0.0.0/20, 10.0.16.0/20, 10.0.32.0/20
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet AZ ${["A", "B", "C"][count.index]}"
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${(count.index + 3) * 16}.0/20"                # 10.0.48.0/20, 10.0.64.0/20, 10.0.80.0/20
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private Subnet AZ ${["A", "B", "C"][count.index]}"
  }
}

resource "aws_subnet" "database" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${(count.index + 6) * 16}.0/20"                # 10.0.96.0/20, 10.0.112.0/20, 10.0.128.0/20
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Database Subnet AZ ${["A", "B", "C"][count.index]}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "NaVa private RT"
  }
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count          = 3
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.private.id
}
