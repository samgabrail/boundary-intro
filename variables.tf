variable "users" {
  type    = set(string)
  default = [
    "Jim",
    "Mike",
    "Todd",
    "Jeff",
    "Randy",
    "Susmitha"
  ]
}

variable "readonly_users" {
  type    = set(string)
  default = [
    "Chris",
    "Pete",
    "Justin"
  ]
}

variable "backend_server_ips" {
  type    = set(string)
  default = [
    "192.168.1.80",
    "master-1.home",
    "worker-1.home",
    "worker-2.home",
    "worker-3.home"
  ]
}

variable "backend_windows_server_ips" {
  type    = set(string)
  default = [
    "192.168.1.7"
  ]
}
