variable "name" {
  description = "The cluster's name"
}

variable "subnets" {
  description = "Subnet list"
  type = list(object({
    name = string
    range = string
    region = string
    secondary = list(object({
      name = string,
      range = string,
    }))
  }))
}

