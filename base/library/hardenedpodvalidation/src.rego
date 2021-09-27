package hardenedpodvalidation

containers[c] {
  c := input.review.object.spec.containers[_]
}

containers[c] {
  c := input.review.object.spec.initContainers[_]
}

containers[c] {
  c := input.review.object.spec.ephemeralContainers[_]
}

violation [{"msg":msg}] {
  c := containers[_]
  c.securityContext.privileged == true
  msg := sprintf("Privileged container is not allowed: %v", [c.name])
}

violation[{"msg": msg}] {
  c := containers[_]
  # convert the arrays into sets, so we can substract them
  capabilities := { x | x := c.securityContext.capabilities.add[_] }
  allowedCapabilities := { y | y:= input.parameters.allowedCapabilities[_] }
  count(capabilities - allowedCapabilities) > 0
  msg := sprintf("Container has disallowed capabilities: %v", [c.name])
}
