resource "aws_launch_configuration" "secondary" {
  image_id      = var.ami != "" ? var.ami : local.distro_ami
  instance_type = local.rendered_secondary_instance_type

  key_name = module.common.ssh_key_name

  user_data = data.template_cloudinit_config.config_secondary.rendered

  security_groups = [
    module.lb.sg_lb_to_instance,
    module.common.intra_vpc_and_egress_sg_id,
    module.common.allow_ptfe_sg_id,
  ]

  iam_instance_profile = aws_iam_instance_profile.ptfe.name

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
  }
}

resource "aws_autoscaling_group" "secondary" {
  # Interpolating the LC name into the ASG name here causes any changes that
  # would replace the LC (like, most commonly, an AMI ID update) to _also_
  # replace the ASG.
  name = "${var.prefix}-lc-${aws_launch_configuration.secondary.name}"

  launch_configuration = aws_launch_configuration.secondary.name
  desired_capacity     = var.secondary_count
  min_size             = var.secondary_count
  max_size             = var.secondary_count
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  vpc_zone_identifier = [module.common.private_subnets]
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  target_group_arns = [module.lb.https_group]

  tag {
    key                 = "Name"
    value               = "${var.prefix}-${module.common.install_id}:secondary"
    propagate_at_launch = true
  }

  tag {
    key                 = "Hostname"
    value               = module.lb.endpoint
    propagate_at_launch = true
  }

  tag {
    key                 = "InstallationId"
    value               = module.common.install_id
    propagate_at_launch = true
  }
}

