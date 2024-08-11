module "cloud9" {
  source = "../../aws/cloud9"
  for_each = { for cloud9 in local.config.cloud9 : cloud9.name => cloud9 }
  cloud9 = each.value
}