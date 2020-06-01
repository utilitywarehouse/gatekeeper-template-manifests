package protectedannotation

violation[{"msg": msg}] {
    input.review.object.metadata.annotations[ns_annotations]

    # check namespace has "sensitive" annotations
    glob.match(input.parameters.annotationGlob, [], ns_annotations)
    
    # check namespace is not in the whitelist
    not whitelisted(input.parameters.namespaceGlobWhitelist, input.review.namespace)

    msg := sprintf("Namespace %v not allowed annotation %v", [input.review.namespace, ns_annotations])
}

whitelisted(namespaceGlobWhitelist, namespace) {
    glob.match(namespaceGlobWhitelist[_], [], namespace)
}
