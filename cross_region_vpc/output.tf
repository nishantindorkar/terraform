output "VPC-ID-US-EAST-1" {
  value = aws_vpc.vpc-one.id
}

output "VPC-ID-AP-SOUTH-1" {
  value = aws_vpc.vpc-two.id
}

output "PEERING-CONNECTION-ID" {
  value = aws_vpc_peering_connection.request-peering.id
}