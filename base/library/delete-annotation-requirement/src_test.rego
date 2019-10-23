package deleteannotationrequirement

# test that an object annotated with "true" is allowed
test_annotated_allowed {
    not violation[{
        "msg": "",
        "details": {
            "name": "example-ns",
            "kind": "Namespace",
            "namespace": "example-ns"
        }
    }] with input as {
        "review": {
            "namespace": "example-ns",
            "kind": {
                "kind": "Namespace"
            },
            "object": {
                "metadata": {
                    "name": "example-ns",
                    "annotations": {
                        "example.com/delete-allowed": "true"
                    }
                }
            },
            "operation": "DELETE"
        },
        "parameters": {
            "name": "example.com/delete-allowed",
            "value": "true",
        }
    }
}

# test that an object annotated with "false" is denied
test_annotated_denied {
    violation[{
        "msg": "the Namespace 'example-ns' must be annotated with 'example.com/delete-allowed: \"true\"' to be deleted",
        "details": {
            "name": "example-ns",
            "kind": "Namespace",
            "namespace": "example-ns"
        }
    }] with input as {
        "review": {
            "namespace": "example-ns",
            "kind": {
                "kind": "Namespace"
            },
            "object": {
                "metadata": {
                    "name": "example-ns",
                    "annotations": {
                        "example.com/delete-allowed": "false"
                    }
                }
            },
            "operation": "DELETE"
        },
        "parameters": {
            "name": "example.com/delete-allowed",
            "value": "true"
        }
    }
}

# test that an object without any annotation at all is denied
test_not_annotated_denied {
    violation[{
        "msg": "the Namespace 'example-ns' must be annotated with 'example.com/delete-allowed: \"true\"' to be deleted",
        "details": {
            "name": "example-ns",
            "kind": "Namespace",
            "namespace": "example-ns"
        }
    }] with input as {
        "review": {
            "namespace": "example-ns",
            "kind": {
                "kind": "Namespace"
            },
            "object": {
                "metadata": {
                    "name": "example-ns"
                }
            },
            "operation": "DELETE"
        },
        "parameters": {
            "name": "example.com/delete-allowed",
            "value": "true",
        }
    }
}

# test that the policy only applies to delete operations
test_create_allowed {
    not violation[{
        "msg": "",
        "details": {
            "name": "example-ns",
            "kind": "Namespace",
            "namespace": "example-ns"
        }
    }] with input as {
        "review": {
            "namespace": "example-ns",
            "kind": {
                "kind": "Namespace"
            },
            "object": {
                "metadata": {
                    "name": "example-ns",
                    "annotations": {
                        "example.com/delete-allowed": "false"
                    }
                }
            },
            "operation": "CREATE"
        },
        "parameters": {
            "name": "example.com/delete-allowed",
            "value": "true",
        }
    }
}