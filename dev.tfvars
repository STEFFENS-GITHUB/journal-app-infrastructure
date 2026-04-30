vpc_cidr_block = "192.168.0.0/16"

public_subnets = [
  {
    cidr_block        = "192.168.1.0/24"
    availability_zone = "us-east-1a"
    dns_name          = true
  },
  {
    cidr_block        = "192.168.2.0/24"
    availability_zone = "us-east-1b"
    dns_name          = true
  }
]

private_subnets = [
  {
    cidr_block        = "192.168.100.0/24"
    availability_zone = "us-east-1a"
    dns_name          = true
  },
  {
    cidr_block        = "192.168.101.0/24"
    availability_zone = "us-east-1b"
    dns_name          = true
  }

]

cloudwatch_logs_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"logs:CreateLogGroup\",\"logs:CreateLogStream\",\"logs:PutLogEvents\"],\"Resource\":\"*\"},{\"Effect\":\"Allow\",\"Action\":[\"ecr:GetDownloadUrlForLayer\",\"ecr:BatchCheckLayerAvailability\",\"ecr:GetAuthorizationToken\",\"ecr:BatchGetImage\"],\"Resource\":\"*\"}]}"

create_nat_gateway = true
# Replace policy with data source