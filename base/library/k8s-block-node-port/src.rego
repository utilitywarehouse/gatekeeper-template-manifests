package k8sblocknodeport

violation[{"msg": msg}] {
  input.review.kind.kind == "Service"
  input.review.object.spec.type == "NodePort"
  msg := "Tenant must be unable to create service of type NodePort"
}
