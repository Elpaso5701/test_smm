################################################################################
# EC2 configuration
################################################################################
#Amazon Linux 2023 AMI 2023.8.20250808.1 x86_64 HVM kernel-6.1 in us-east1
ami          = "ami-0de716d6197524dd9"
docker_image = "node"
image_tag    = "18-alpine"
subnet       = "subnet-0db42289c5dffb71f"
ec2_name     = "nodejs-server"
sgs          = ["sg-07eeecb1610e417d5"]
iam_role_policies = {
  ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
