#!/bin/bash
#
#
#
#
#
#
#
#
#  AWS VPC Creation Shell Script
#=================================
#variables
#=========
REGION="ap-south-1"
VPC_NAME="MyVpc"
VPC_CIDR="10.10.0.0/16"
SUBNET_CIDR="10.10.0.0/24"
SUBNET_AZ="ap-south-1a"
SUBNET_NAME="my-subnet"
SEC_NAME="mysec"
INSTANCE_NAME="myinstance"
IMAGE_ID="ami-024c319d5d14b463e"
TYPE="t2.micro"
KEY_NAME="id_rsa"
CHECK_FREQUENCY=5
#
#creating vpc
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --query 'Vpc.{VpcId:VpcId}' \
  --output text \
  --region $REGION)
echo "  VPC ID '$VPC_ID' CREATED in '$REGION' region."

# Add Name tag to V PC
aws ec2 create-tags \
  --resources $VPC_ID \
  --tags "Key=Name,Value=$VPC_NAME" \
  --region $REGION
echo "  VPC ID '$VPC_ID' NAMED as '$VPC_NAME'."

# Create  Subnet
echo "Creating Subnet..."
SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_CIDR \
  --availability-zone $SUBNET_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $REGION)
echo "  Subnet ID '$SUBNET_ID' CREATED in '$SUBNET_AZ'" \
  "Availability Zone."

# Add Name tag to Subnet
aws ec2 create-tags \
  --resources $SUBNET_ID \
  --tags "Key=Name,Value=$SUBNET_NAME" \
  --region $REGION
echo "  Subnet ID '$SUBNET_ID' NAMED as" \
  "'$SUBNET_NAME'."

# Create Internet gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
  --output text \
  --region $REGION)
echo "  Internet Gateway ID '$IGW_ID' CREATED."

# Attach Internet gateway to VPC
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID \
  --region $REGION
echo "  Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."

# Create Route Table
echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.{RouteTableId:RouteTableId}' \
  --output text \
  --region $REGION)
echo "  Route Table ID '$ROUTE_TABLE_ID' CREATED."

# Create route to Internet Gateway
OUTPUT=$(aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $REGION)
echo "  Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to" \
  "Route Table ID '$ROUTE_TABLE_ID'."

# Associate Subnet with Route Table
OUTPUT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $REGION)
echo "  Public Subnet ID '$SUBNET_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'."

#creating security group
SecGrpID=$(aws ec2 create-security-group --group-name PubSecGrp \
            --description "Security Group for public instances" \
            --vpc-id "$VPC_ID" \
            --output text)

# Add Name tag to security group
aws ec2 create-tags \
  --resources $SecGrpID \
  --tags "Key=Name,Value=$SEC_NAME" \
  --region $REGION
echo "  SEC ID '$SecGrpID' NAMED as '$SEC_NAME'."

#inbond rule port 22 add to security group
aws ec2 authorize-security-group-ingress \
  --group-id $SecGrpID \
  --protocol "tcp" \
  --port 22 \
  --cidr "0.0.0.0/0"
  echo "  port 22 to '0.0.0.0/0'  ADDED to" \
      "Security Group ID '$SecGrpID'."


#inbond rule port 8080 add to security group
aws ec2 authorize-security-group-ingress \
    --group-id  $SecGrpID \
    --protocol "tcp" \
    --port 8080 \
    --cidr "0.0.0.0/0"
     echo "  port 8080 to '0.0.0.0/0'  ADDED to" \
      "Security Group ID '$SecGrpID'."

#INSTANCE CREATION  
# ==================
EC2_ID=$(aws ec2 run-instances \
  --image-id $IMAGE_ID \
  --count 1 \
  --security-group-ids $SecGrpID \
  --subnet-id $SUBNET_ID \
  --instance-type $TYPE \
  --key-name $KEY_NAME \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=my-instance}]" \
  --query 'Instances[0].{InstanceId:InstanceId}')
  echo "  EC2 ID '$EC2_ID' CREATED in '$REGION' region."