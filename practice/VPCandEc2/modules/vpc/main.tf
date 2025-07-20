provider "aws" {
  region = "us-east-1"
  
}

resource "aws_vpc" "test_vpc" {
    cidr_block = "10.0.0.0/16"

}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "test_igw" {
    vpc_id = aws_vpc.test_vpc.id
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.test_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.test_igw.id
    }
}       

resource "aws_route_table_association" "public_route_table_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "allow_http" {
    vpc_id = aws_vpc.test_vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [aws_subnet.public_subnet.cidr_block]
    }       

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [aws_subnet.public_subnet.cidr_block]
    }
}     

resource "aws_nat_gateway" "test_nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_subnet.id
}
resource "aws_eip" "nat_eip" {
    vpc = true
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
}   

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.test_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.test_nat.id
    }           
  
}
resource "aws_route_table_association" "private_route_table_association" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_route_table.id
}

