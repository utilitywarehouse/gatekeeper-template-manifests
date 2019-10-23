package ingresshostrestriction

violation[{"msg": msg, "details": {"host": host, "namespace": namespace}}] {
    host := input.review.object.spec.rules[_].host
    namespace := input.review.namespace
    allowed_namespaces := input.parameters.namespaces

    # resource kind is Ingress
    input.review.kind.kind == "Ingress" 

    # ingress host matches blacklisted host
    host == input.parameters.host 
    
    # namespace is not in the list of allowed namespaces
    not allowed(allowed_namespaces, namespace) 

    msg := sprintf("%v is not a permitted host value for ingresses in this namespace (%v)", [host, namespace])
}

allowed(allowed_namespaces, namespace) {
    allowed_namespaces[_] == namespace
}
