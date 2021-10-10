output "cluster-name" {
  value = module.cluster.name
}
output "cluster-location" {
  value = module.cluster.location
}
output "cluster-cert" {
  value = module.cluster.ca_certificate
}
output "cluster-endpoint" {
  value = module.cluster.endpoint
}
