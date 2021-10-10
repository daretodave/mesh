variable "name" {
  description = "The cluster's name"
}
variable "environment" {
  description = "Optional mode, or environment to segment mesh cluster and resources"
  default =  ""
}
variable "domain" {
  description = "DNS zone available in provider - for dynamic dns"
}

variable "services" {
  default =  []
}

variable "default_primary_range_nodes" {
  description = "CIDR for nodes's ip range"
  default =   "10.142.0.0/20"
}
variable "default_primary_range_pods" {
  description = "CIDR for pod's ip range"
  default =   "10.20.0.0/16"
}
variable "default_primary_range_services" {
  description = "CIDR for pod's ip range"
  default =   "10.30.0.0/16"
}
