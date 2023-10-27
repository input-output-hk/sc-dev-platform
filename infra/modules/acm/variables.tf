variable "domains" {
  type = map(string)
}

variable "wait_for_validation" {
  type    = bool
  default = true
}