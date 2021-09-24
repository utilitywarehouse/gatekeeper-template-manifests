package podnoderestriction

# test that a matching node causes a violation
test_blocked {
  results := violation with input as {
    "parameters": {"matchLabels": {"foo": "bar", "baz": ""}},
    "review": {"operation": "CREATE", "object": {
      "metadata": {"name": "example-ns"},
      "spec": {"nodeName": "foobar"},
    }},
  }
     with data.inventory as {"cluster": {"v1": {"Node": {"foobar": {"metadata": {"labels": {
      "foo": "bar",
      "baz": "",
      "bar": "foo",
    }}}}}}}

  count(results) == 1
}

# test that when no matchLabels are defined, that the node is still blocked
# (no matchLabels == match all)
test_no_matchLabels_blocked {
  results := violation with input as {"review": {"operation": "CREATE", "object": {
    "metadata": {"name": "example-ns"},
    "spec": {"nodeName": "foobar"},
  }}}
     with data.inventory as {"cluster": {"v1": {"Node": {"foobar": {"metadata": {"labels": {
      "foo": "bar",
      "baz": "",
      "bar": "foo",
    }}}}}}}

  count(results) == 1
}

test_message {
  results := violation with input as {
    "parameters": {"message": "TEST_MESSAGE", "matchLabels": {"foo": "bar"}},
    "review": {"operation": "CREATE", "object": {
      "metadata": {"name": "example-ns"},
      "spec": {"nodeName": "foobar"},
    }},
  }
     with data.inventory as {"cluster": {"v1": {"Node": {"foobar": {"metadata": {"labels": {"foo": "bar"}}}}}}}

  count(results) == 1
  results[_].msg == "TEST_MESSAGE"
}

# test that the node isn't matched if it  doesn't contain one of the
# matchLabels
test_missing_label_allowed {
  results := violation with input as {
    "parameters": {"matchLabels": {"foo": "bar", "baz": ""}},
    "review": {"operation": "CREATE", "object": {
      "metadata": {"name": "example-ns"},
      "spec": {"nodeName": "foobar"},
    }},
  }
     with data.inventory as {"cluster": {"v1": {"Node": {"foobar": {"metadata": {"labels": {
      "foo": "bar",
      "bar": "foo",
    }}}}}}}

  count(results) == 0
}

# test that there's no violation when the node isn't in the inventory
test_missing_node_allowed {
  results := violation with input as {
    "parameters": {"matchLabels": {"foo": "bar", "baz": ""}},
    "review": {"operation": "CREATE", "object": {
      "metadata": {"name": "example-ns"},
      "spec": {"nodeName": "foobar"},
    }},
  }
     with data.inventory as {"cluster": {"v1": {"Node": {"not-foobar": {"metadata": {"labels": {
      "foo": "bar",
      "bar": "foo",
    }}}}}}}

  count(results) == 0
}

# test that there's no violation when the inventory is nil
test_no_inventory_allowed {
  results := violation with input as {
    "parameters": {"matchLabels": {"foo": "bar", "baz": ""}},
    "review": {"operation": "CREATE", "object": {
      "metadata": {"name": "example-ns"},
      "spec": {"nodeName": "foobar"},
    }},
  }

  count(results) == 0
}

# test that a pod can be deleted even if it's scheduled to a matching node 
test_blocked {
  results := violation with input as {
    "parameters": {"matchLabels": {"foo": "bar", "baz": ""}},
    "review": {"operation": "DELETE", "object": {
      "metadata": {"name": "example-ns"},
      "spec": {"nodeName": "foobar"},
    }},
  }
     with data.inventory as {"cluster": {"v1": {"Node": {"foobar": {"metadata": {"labels": {
      "foo": "bar",
      "baz": "",
      "bar": "foo",
    }}}}}}}

  count(results) == 0
}
