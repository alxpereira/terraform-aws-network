# Local Variables
locals {
  zones = {
    "a" = 1
    "b" = 2
    "c" = 3
  }
}

# Declare AWS as a provider
provider "aws" {
  profile = var.profile
  region = var.region
}

###
# Common Resources
###
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = var.environment
    Environment = var.environment
  }
}

resource "aws_eip" "main" {
  vpc = true

  tags = {
    Name = var.environment
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.environment
    Environment = var.environment
  }
}

### 
# Public Resources
###
resource "aws_subnet" "public" {
  for_each = local.zones

  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}${each.key}"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value)

  tags = {
    Name = "${var.region}${each.key}-public"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

### 
# Private Resources
###
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public["a"].id

  tags = {
    Name = var.environment
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  for_each = local.zones

  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}${each.key}"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value+3)

  tags = {
    Name = "${var.region}${each.key}-private"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-private"
    Environment = var.environment
  }
}

resource "aws_main_route_table_association" "private" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
