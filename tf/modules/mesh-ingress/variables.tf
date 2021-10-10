variable "name" {
  description = "The cluster's ingress name"
}
variable "namespace-lb" {
  description = "The cluster's nginx load balancers namespace"
}
variable "namespace-cm" {
  description = "The cluster's cert manger's namespace"
}

//variable "cluster-host" {
//  description = "API endpoint for ingress management"
//}
//variable "cluster-cert" {
//  description = "An auth mechanism for calling k8 API"
//}
//variable "cluster-token" {
//  description = "An auth mechanism for calling k8 API"
//}
//

variable "domain" {
  description = "DNS zone available in provider - for dynamic dns"
}
