package ingresshostrestriction

# test the simplest case: all values in the resource are in the whitelist
test_matching_host_matching_namespace_matching_path_allowed {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test a path that isn't in the whitelist
test_matching_host_matching_namespace_different_path_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/disallowed"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test a host and path combination in a namespace that isn't whitelisted
test_matching_host_different_namespace_matching_path_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "different-example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test an ingress request for the right host where the neither the namespace or path are whitelisted
test_matching_host_different_namespace_different_path_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "different-example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/disallowed"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test that a different host is ignored by the constraint, regardless of a matching namespace/path
test_different_host_matching_namespace_matching_path_allowed {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "different.example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test that a different host is ignored by the constraint, regardless of a matching namespace
test_different_host_matching_namespace_different_path_allowed {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "different.example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/disallowed"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test that a different host is ignored by the constraint, regardless of a matching path
test_different_host_different_namespace_matching_path_allowed {
    results := violation with input as {
        "request": {
            "operation": "CREATE"
        },
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "namespace": "different-example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "different.example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test that a completely unrelated ingress is ignored by the constraint
test_different_host_different_namespace_different_path_allowed {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "different-example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "different.example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/different"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test that an ingress with a matching host/path combination but another unrelated rule is allowed
test_multiple_host_host_matching_path_matching_allowed {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "different.example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        },
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test that an invalid rule is still denied even when there is another unrelated rule
test_multiple_host_host_matching_path_different_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "different.example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        },
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/different"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test that an invalid rule is still denied even when there is another unrelated rule
test_multiple_host_host_different_path_matching_allowed {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "different.example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        },
                        {
                            "host": "different-2.example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test multiple whitelisted paths are allowed
test_multiple_paths_all_matching_allowed {
    results := violation with input as {
        "request": {
            "operation": "CREATE"
        },
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                        "/example"
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    },
                                    {
                                        "path": "/example"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test that one bad path results in denial
test_multiple_paths_one_different_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                        "/example"
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {

                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    },
                                    {
                                        "path": "/different"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test that the resource is denied when all paths are different
test_multiple_paths_all_different_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                        "/example"
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/different"
                                    },
                                    {
                                        "path": "/another-different"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test that an ingress is allowed, even if it doesn't define ALL of the paths that are whitelisted
test_multiple_paths_more_whitelisted_allowed {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/",
                        "/example",
                        "/example2",
                        "/example3",
                        "/example4"
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    },
                                    {
                                        "path": "/example2"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test that an ingress is denied if the ingresshostrestriction doesn't have any paths against the namespace
test_no_whitelisted_paths_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": []
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test that an ingress is denied if the whitelist is defined as a string
test_namespace_path_list_string_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": ""
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test that an ingress is denied if the whitelist is defined as an object
test_namespace_path_list_object_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": {}
                },
            "host": "example.com"
        },
        "review": {
            "operation": "CREATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test that a delete request is allowed, even when the resource violates the constraint
test_delete_request_allowed {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/"
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "DELETE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/different"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}

# test that a violating update request is denied
test_update_request_denied {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/"
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "UPDATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/different"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) > 0
}

# test that a valid update request is denied
test_update_request_allowed {
    results := violation with input as {
        "parameters": {
            "namespacePathWhitelist":
                {
                    "example-ns": [
                        "/"
                    ]
                },
            "host": "example.com"
        },
        "review": {
            "operation": "UPDATE",
            "namespace": "example-ns",
            "kind": {
                "kind": "Ingress"
            },
            "object": {
                "metadata": {
                    "name": "test"
                },
                "spec": {
                    "rules": [
                        {
                            "host": "example.com",
                            "http": {
                                "paths": [
                                    {
                                        "path": "/"
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    count(results) == 0
}
