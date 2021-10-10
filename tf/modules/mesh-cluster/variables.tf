variable "name" {
  description = "The cluster's name"
}


variable "network" {
  description = "The cluster's network"
  type = object({
    name = string
    ranges = object({
      range_pods = string
      range_nodes = string
      range_services = string
    })
    range = string
  })
}


