data "aws_partition" "current" {}

locals {
  instance_id = try(
    aws_instance.this.id,
    null,
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# Instance
################################################################################

resource "aws_instance" "this" {
  ami                         = var.ami
  associate_public_ip_address = true
  # availability_zone           = data.aws_availability_zones.available.names[0]
  iam_instance_profile        = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile
  instance_type               = var.instance_type
  subnet_id                   = var.subnet
  vpc_security_group_ids      = var.sgs
  user_data = templatefile("${path.module}/install.tftpl", {
    image = var.docker_image
    tag   = var.image_tag
  })

  tags = merge(
    { "Name" = var.ec2_name },
    var.tags
  )
}

################################################################################
# IAM Role / Instance Profile
################################################################################

locals {
  iam_role_name = try(coalesce(var.iam_role_name, var.ec2_name), "")
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create_iam_instance_profile ? 1 : 0

  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in var.iam_role_policies : k => v if var.create_iam_instance_profile }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  role = aws_iam_role.this[0].name

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path

  tags = merge(var.tags, var.iam_role_tags)

  lifecycle {
    create_before_destroy = true
  }
}
