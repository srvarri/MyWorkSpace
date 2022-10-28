//create a vpc
resource "aws_vpc" "nitervpc" {
    cidr_block = var.cidr_block
   tags = {
     "Name" = "ntier"
   }
          
}

#create subnets
resource "aws_subnet" "subnet" {
    count = length(var.subnet_name_tags)
    cidr_block = cidrsubnet(var.cidr_block, 8, count.index)
    vpc_id = aws_vpc.nitervpc.id
    tags = {
      "Name" = "test"
    }
  depends_on = [
   aws_vpc.nitervpc 
  ]
}
