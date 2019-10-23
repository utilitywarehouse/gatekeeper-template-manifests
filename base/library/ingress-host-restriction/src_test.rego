package ingresshostrestriction

test_matching_host_denied {
    violation[{
        "msg": "example.com is not a permitted host value for ingresses in this namespace (example-ns)",
        "details": {
            "host": "example.com",
            "namespace": "example-ns"
        }
    }] with input as {
        "parameters": {
            "namespaces": [],
            "host": "example.com"
        },
        "review": {
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "spec": {
                    "rules": [
                        {
                            "host": "example.com"
                        }
                    ]
                }
            }
        }
    }
}

test_different_host_allowed {
    not violation[{
        "msg": "", 
        "details": {
            "host": "",
            "namespace": ""
        }
    }] with input as {
        "parameters": {
            "namespaces": [
                "different-example-ns"
            ],
            "host": "example.com"
        },
        "review": {
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "spec": {
                    "rules": [
                        {
                            "host": "different.example.com"
                        }
                    ]
                }
            }
        }
    }   
}

test_matching_namespace_allowed {
    not violation[{
        "msg": "",
        "details": {
            "host": "",
            "namespace": ""
        }
    }] with input as {
        "parameters": {
            "namespaces": [
                "example-ns"
            ],
            "host": "example.com"
        },
        "review": {
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "spec": {
                    "rules": [
                        {
                            "host": "example.com"
                        }
                    ]
                }
            }
        }
    }
}
