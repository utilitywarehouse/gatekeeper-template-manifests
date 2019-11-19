package namelabelmatch

test_matching_name_allowed {
    results := violation with input as {
        "review": {
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
    count(results) == 0
}

test_not_matching_name_denied {
    results := violation with input as {
        "review": {
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
    count(results) > 0
}

test_no_label_allowed {
    results := violation with input as {
        "review": {
            "object": {
                "metadata": {
                    "name": "example-ns"
                }
            }
        }
    }
    count(results) == 0
}