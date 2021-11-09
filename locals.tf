locals {
  iam_principal = { arn = try(var.object_storage_iam_user.arn, module.service_accounts.iam_role.arn) }
}
