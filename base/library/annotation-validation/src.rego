package annotationvalidation

get_message(parameters, _default) = msg {
  not parameters.message
  msg := _default
}

get_message(parameters, _default) = msg {
  msg := parameters.message
}

violation[{"msg": msg}] {
  value := input.review.object.metadata.annotations[key]

  expected := input.parameters.annotations[_]
  expected.key == key
  not re_match(expected.allowedRegex, value)

  def_msg := sprintf("Annotation <%v: %v> does not satisfy allowed regex: %v", [key, value, expected.allowedRegex])
  msg := get_message(input.parameters, def_msg)
}
