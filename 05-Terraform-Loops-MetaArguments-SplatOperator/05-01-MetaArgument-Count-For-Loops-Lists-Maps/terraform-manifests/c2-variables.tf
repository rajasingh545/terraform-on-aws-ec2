# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "ap-south-1"
}

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instnace Type"
  type        = string
  default     = "t3.micro"
}

# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key Pair that need to be associated with EC2 Instance"
  type        = string
  default     = "terraform-key"
}


# AWS EC2 Instance type - List
variable "instance_type_list" {
  description = "EC2 Instance Type"
  type        = list(string)
  default     = ["t3.micro", "t3.small", "t3.medium"]
}

# AWS EC2 Instance type - Map
# This variable is used to map environment names to instance types.
# For example, "dev" maps to "t3.micro", "qas" maps to "t3.small", and "prod" maps to "t3.large".
# This allows for flexible instance type selection based on the environment.
# The map can be easily extended to include more environments and their corresponding instance types.
# This is useful for managing different environments with varying resource requirements.
variable "instance_type_map" {
  description = "Instance Type Map"
  type        = map(string)
  default = {
    "dev"  = "t3.micro"
    "qas"  = "t3.small"
    "prod" = "t3.large"
  }
}
