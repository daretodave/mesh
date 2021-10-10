module "cluster" {
  source = "../../tf"

  name = "sample"
  domain = "sample.tool.dave.blue"
  environment = "develop"


  services = {
    sms = {
      image = "nginx:latest"
      port = 80
      env = {
        "PING"   = "ping"
        "DB_USER" = "..."
      }
    }
    test = {
      image = "nginx:latest"
    }
  }
}

output "cluster-name" {
  value = module.cluster.cluster-name
}
