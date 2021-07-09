package blocknodeport

has_node_ports(node_ports) {
  required_node_ports := {x | x := node_ports[_]}
  svc_node_ports := {x | x := input.review.object.spec.ports[_].nodePort}

  count(svc_node_ports - required_node_ports) == 0
}

excepted {
  input.review.object.metadata.name == input.parameters.exceptions[i].name
  input.review.namespace == input.parameters.exceptions[i].namespace
  has_node_ports(input.parameters.exceptions[i].nodePorts)
}

violation[{"msg": msg}] {
  input.review.kind.kind == "Service"
  input.review.object.spec.type == "NodePort"
  input.review.operation != "DELETE"
  not excepted
  msg := "Services of type NodePort are not permitted"
}
