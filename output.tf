output "values" {
  value = templatefile("${path.module}/config/aad-pod-identity.yaml.tmpl", {
      identities = chomp(replace(indent(2, yamlencode(local.identities)), "/\"|{|}/", ""))
  })
}
      #identities = yamlencode(local.identities)
