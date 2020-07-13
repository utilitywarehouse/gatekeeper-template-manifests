package ingressrequirehost

violation[{"msg": msg}] {
  # resource kind is Ingress
  input.review.kind.kind == "Ingress"

  # always allow deletion of offending ingresses
  input.review.operation != "DELETE"

  # test if each rule has a host
  hosts := [x | x := input.review.object.spec.rules[_].host]
  count(hosts) != count(input.review.object.spec.rules)

  msg := sprintf("Ingress '%v' denied; all rules must have a host defined", [input.review.object.metadata.name])
}

violation[{"msg": msg}] {
  # resource kind is Ingress
  input.review.kind.kind == "Ingress"

  # always allow deletion of offending ingresses
  input.review.operation != "DELETE"

  # test if backend is defined
  _ = input.review.object.spec["backend"]

  msg := sprintf("Ingress '%v' denied; backend must not be defined", [input.review.object.metadata.name])
}
