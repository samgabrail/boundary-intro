terraform {
  required_providers {
    boundary = {
      source = "hashicorp/boundary"
      version = "1.1.0"
    }
  }
}

provider "boundary" {
  addr                            = "http://127.0.0.1:9200"
  auth_method_id                  = "ampw_1234567890"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "password"
}


resource "boundary_scope" "global" {
  global_scope = true
  description  = "My first global scope!"
  scope_id     = "global"
}

resource "boundary_scope" "corp" {
  name                     = "Corp One"
  description              = "My first scope!"
  scope_id                 = boundary_scope.global.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

## Use password auth method
resource "boundary_auth_method" "password" {
  name     = "Corp Password"
  scope_id = boundary_scope.corp.id
  type     = "password"
}

## Create user accounts with password: password
resource "boundary_account_password" "users_acct" {
  for_each       = var.users
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_account_password" "readonly_users_acct" {
  for_each       = var.readonly_users
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_user" "users" {
  for_each    = var.users
  name        = each.key
  description = "User resource for ${each.key}"
  scope_id    = boundary_scope.corp.id
}

resource "boundary_user" "readonly_users" {
  for_each    = var.readonly_users
  name        = each.key
  description = "User resource for ${each.key}"
  scope_id    = boundary_scope.corp.id
}

resource "boundary_group" "readonly" {
  name        = "read-only"
  description = "Organization group for readonly users"
  member_ids  = [for user in boundary_user.readonly_users : user.id]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_role" "organization_readonly" {
  name        = "Read-only"
  description = "Read-only role"
  principal_ids = [boundary_group.readonly.id]
  grant_strings = ["id=*;type=*;actions=read"]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_role" "organization_admin" {
  name        = "admin"
  description = "Administrator role"
  principal_ids = concat(
    [for user in boundary_user.users: user.id]
  )
  grant_strings   = ["id=*;type=*;actions=create,read,update,delete"]
  scope_id = boundary_scope.corp.id
}

resource "boundary_scope" "core_infra" {
  name                   = "Core infrastrcture"
  description            = "My first project!"
  scope_id               = boundary_scope.corp.id
  auto_create_admin_role = true
}

resource "boundary_host_catalog_static" "backend_servers" {
  name        = "backend_servers"
  description = "Backend servers host catalog"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host_static" "backend_servers" {
  for_each        = var.backend_server_ips
  type            = "static"
  name            = "backend_server_service_${each.value}"
  description     = "Backend server host"
  address         = each.key
  host_catalog_id = boundary_host_catalog_static.backend_servers.id
}

resource "boundary_host_static" "backend_windows_servers" {
  for_each        = var.backend_windows_server_ips
  type            = "static"
  name            = "backend_windows_server_service_${each.value}"
  description     = "Backend windows server host"
  address         = each.key
  host_catalog_id = boundary_host_catalog_static.backend_servers.id
}

resource "boundary_host_set_static" "backend_servers_ssh" {
  type            = "static"
  name            = "backend_servers_ssh"
  description     = "Host set for backend servers"
  host_catalog_id = boundary_host_catalog_static.backend_servers.id
  host_ids        = [for host in boundary_host_static.backend_servers : host.id]
}

resource "boundary_host_set_static" "backend_windows_servers_ssh" {
  type            = "static"
  name            = "backend_windows_servers_ssh"
  description     = "Host set for backend Windows servers"
  host_catalog_id = boundary_host_catalog_static.backend_servers.id
  host_ids        = [for host in boundary_host_static.backend_windows_servers : host.id]
}

# create target for accessing backend servers on port :8080
// resource "boundary_target" "backend_servers_service" {
//   type         = "tcp"
//   name         = "Backend service"
//   description  = "Backend service target"
//   scope_id     = boundary_scope.core_infra.id
//   default_port = "8080"

//   host_source_ids = [
//     boundary_host_set_static.backend_servers_ssh .id
//   ]
// }

# create target for accessing backend servers on port :22
resource "boundary_target" "backend_servers_ssh" {
  type         = "tcp"
  name         = "Backend servers"
  description  = "Backend SSH target"
  scope_id     = boundary_scope.core_infra.id
  default_port = "22"

  host_source_ids = [
    boundary_host_set_static.backend_servers_ssh.id
  ]
}

# create target for accessing backend servers on port :3389
resource "boundary_target" "backend_servers_rdp" {
  type         = "tcp"
  name         = "Backend RDP"
  description  = "Backend RDP target"
  scope_id     = boundary_scope.core_infra.id
  default_port = "3389"
  session_connection_limit = 2
  host_source_ids = [
    boundary_host_set_static.backend_windows_servers_ssh.id
  ]
}