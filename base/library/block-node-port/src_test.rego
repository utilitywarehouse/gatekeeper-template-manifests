package blocknodeport

# test the basic case
test_violation {
  results := violation with input as {"review": {
    "kind": {"kind": "Service"},
    "operation": "CREATE",
    "object": {
      "metadata": {"name": "test"},
      "spec": {"type": "NodePort"},
    },
  }}

  count(results) == 1
}

# test that delete operations are ignored
test_delete {
  results := violation with input as {"review": {
    "kind": {"kind": "Service"},
    "operation": "DELETE",
    "object": {
      "metadata": {"name": "test"},
      "spec": {"type": "NodePort"},
    },
  }}

  count(results) == 0
}

# test that an object with a valid exception isn't blocked
test_exception {
  results := violation with input as {
    "parameters": {"exceptions": [{
      "name": "test",
      "namespace": "test-ns",
      "nodePorts": [8080],
    }]},
    "review": {
      "kind": {"kind": "Service"},
      "operation": "CREATE",
      "namespace": "test-ns",
      "object": {
        "metadata": {"name": "test"},
        "spec": {
          "type": "NodePort",
          "ports": [{"nodePort": 8080}],
        },
      },
    },
  }

  count(results) == 0
}

# test that an unrelated exception doesn't admit a different object
test_exception_unrelated {
  results := violation with input as {
    "parameters": {"exceptions": [{
      "name": "test-2",
      "namespace": "test-ns",
      "nodePorts": [8080],
    }]},
    "review": {
      "kind": {"kind": "Service"},
      "operation": "CREATE",
      "namespace": "test-ns",
      "object": {
        "metadata": {"name": "test"},
        "spec": {
          "type": "NodePort",
          "ports": [{"nodePort": 8080}],
        },
      },
    },
  }

  count(results) == 1
}

# test that a matching svc that defines a subset of the required node ports is
# allowed
test_exception_node_port_subset {
  results := violation with input as {
    "parameters": {"exceptions": [{
      "name": "test",
      "namespace": "test-ns",
      "nodePorts": [8080, 8081],
    }]},
    "review": {
      "kind": {"kind": "Service"},
      "operation": "CREATE",
      "namespace": "test-ns",
      "object": {
        "metadata": {"name": "test"},
        "spec": {
          "type": "NodePort",
          "ports": [{"nodePort": 8080}],
        },
      },
    },
  }

  count(results) == 0
}

# test that a matching svc that defines node ports in addition to the allowed
# set is blocked
test_exception_node_port_additional {
  results := violation with input as {
    "parameters": {"exceptions": [{
      "name": "test",
      "namespace": "test-ns",
      "nodePorts": [8080, 8081],
    }]},
    "review": {
      "kind": {"kind": "Service"},
      "operation": "CREATE",
      "namespace": "test-ns",
      "object": {
        "metadata": {"name": "test"},
        "spec": {
          "type": "NodePort",
          "ports": [
            {"nodePort": 8080},
            {"nodePort": 8081},
            {"nodePort": 8082},
          ],
        },
      },
    },
  }

  count(results) == 1
}
