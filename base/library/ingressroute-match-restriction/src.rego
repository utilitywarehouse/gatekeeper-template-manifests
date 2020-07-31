package ingressroutematchrestriction

ingressroute_kinds := {"IngressRoute", "IngressRouteTCP"}

kind := input.review.kind.kind

match_regex := input.parameters.matchRegex

get_message(parameters, _default) = msg {
  not parameters.message
  msg := _default
}

get_message(parameters, _default) = msg {
  msg := parameters.message
}

# inverse = false
violation[{"msg": msg}] {
  # only operate on supported kinds
  ingressroute_kinds[kind]

  # always allow deletion of offending ingressroutes
  input.review.operation != "DELETE"

  # a match == a violation
  not input.parameters.inverse

  # match the regex to the route match field
  match := input.review.object.spec.routes[_].match
  re_match(match_regex, match)

  def_msg := sprintf("%s matches the restricted pattern: %s", [match, match_regex])

  msg := get_message(input.parameters, def_msg)
}

# inverse = true
violation[{"msg": msg}] {
  # only operate on supported kinds
  ingressroute_kinds[kind]

  # always allow deletion of offending ingressroutes
  input.review.operation != "DELETE"

  # no match == a violation
  input.parameters.inverse

  # the route match field doesn't match the regex
  match := input.review.object.spec.routes[_].match
  not re_match(match_regex, match)

  def_msg := sprintf("%s doesn't match the required pattern: %s", [match, match_regex])

  msg := get_message(input.parameters, def_msg)
}
