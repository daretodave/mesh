variable "name" {
  description = "The app name"
}
variable "image" {
  description = "The app image"
}
variable "port" {
  description = "The app port"
}
variable "health-route" {
  default = "/"
  description = "The app route to get status"
}
