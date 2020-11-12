package deleteannotationrequirement

violation[{"msg": msg, "details": {
  "name": name,
  "kind": kind,
}}] {
  name := input.review.object.metadata.name
  kind := input.review.kind.kind

  input.review.operation == "DELETE"
  not input.review.object.metadata.annotations[input.parameters.name] == input.parameters.value

  msg := sprintf("the %v '%v' must be annotated with '%v: \"%v\"' to be deleted", [kind, name, input.parameters.name, input.parameters.value])
}
