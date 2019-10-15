package ingresshostrestriction

violation[{"msg": msg, "details": {"host": host, "namespace": namespace, "paths": paths}}] {
    name := input.review.object.metadata.name
    namespace := input.review.namespace
    host := input.review.object.spec.rules[i].host
    paths := {x | x = input.review.object.spec.rules[i]["http"]["paths"][_].path}
    whitelist := input.parameters.namespacePathWhitelist

    # resource kind is Ingress
    input.review.kind.kind == "Ingress"

    # operation is CREATE or UPDATE
    operations = {"CREATE", "UPDATE"}
    operations[input.review.operation]

    # ingress host matches the restricted host
    host == input.parameters.host
    
    # namespace+host+path(s) is not in the list of allowed namespaces+paths
    not allowed(whitelist, namespace, paths)

    msg := sprintf("Ingress '%v' denied; the host and/or path values are not permitted for this namespace host=%v namespace=%v paths=%v", [name, host, namespace, paths])
}

allowed(whitelist, namespace, paths) {
    # check that this namespace has whitelisted paths
    count(whitelist[namespace]) > 0

    # find the intersection of the whitelisted paths for this host/namespace and the paths defined in the ingress rule
    whitelisted_paths := {x | x = whitelist[namespace][_]}
    test := paths & whitelisted_paths

    # all the paths should intersect with the list of allowed paths
    count(test) == count(paths)
}
