variable "environment" {
  type = string
}
variable "project_name" {
  type    = string
  default = "ticket-platform"
}
variable "rate_limit" {
  type    = number
  default = 2000
}
variable "enable_managed_common" {
  type    = bool
  default = true
}
variable "enable_bad_inputs" {
  type    = bool
  default = true
}
variable "enable_ip_reputation" {
  type    = bool
  default = true
}
variable "log_retention_days" {
  type    = number
  default = 30
}
