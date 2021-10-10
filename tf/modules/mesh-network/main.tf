locals {
  subnetList = [
    for k in var.subnets: {
      subnet_region = k.region
      subnet_name = k.name
      subnet_ip = k.range
    }
  ]
  subnet_secondary_ranges = {
    for K in var.subnets: K.name => [
      for V in K.secondary : {
        range_name =  V.name
        ip_cidr_range = V.range
      }
    ]
  }
}
data "google_client_config" "default" {}

module "network" {
  source = "terraform-google-modules/network/google"
  version = "~> 2.5"
  project_id = data.google_client_config.default.region
  network_name = var.name
  subnets = local.subnetList
  secondary_ranges = local.subnet_secondary_ranges
}
