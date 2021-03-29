locals {
  identities = {
    for identity in var.identities :
    identity.name => {
      namespace  = identity.namespace
      type       = "0"
      resourceID = identity.resource_id
      clientID   = identity.client_id
      binding = {
        name     = "${identity.name}-binding"
        selector = identity.name
      }
    }
  }
}