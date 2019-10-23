package namelabelmatch

test_matching_name_allowed {
    not violation[{
        "msg": "",
        "details": {
            "label_name": "example-ns",
            "metadata_name": "example-ns",
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
                    "labels": {
                        "name": "example-ns"
                    }
                }
            }
        }
    }
}

test_not_matching_name_denied {
    violation[{
        "msg": "the label 'name' (other-ns) must match the actual name of the object (example-ns)",
        "details": {
            "label_name": "other-ns",
            "metadata_name": "example-ns",
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
                    "labels": {
                        "name": "other-ns"
                    }
                }
            }
        }
    }
}

test_no_label_allowed {
    not violation[{
        "msg": "the label 'name' () must match the actual name of the object (example-ns)",
        "details": {
            "label_name": "",
            "metadata_name": "example-ns",
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
            }
        }
    }
}