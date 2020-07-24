package ingressroutematchrestriction

# Test an inverse match that should produce a violation if a match doesn't
# contain a valid fqdn provided in a Host() rule.
#
# The regular expression is adapted from the regex used to validate the host
# field in regular Ingress rules:
# - https://github.com/kubernetes/kubernetes/blob/18856dace935db46d3ba84374ce23438922e272b/staging/src/k8s.io/apimachinery/pkg/util/validation/validation.go#L198
test_ingressroute_inverse {
  results := violation with input as {
    "parameters": {
      "matchRegex": "Host\\(((`|\")([a-zA-Z0-9]{1,})(`|\")|(`|\")([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\\.)+[a-z]{2,}(`|\"))\\)",
      "inverse": true,
    },
    "review": {
      "namespace": "example",
      "operation": "CREATE",
      "kind": {"kind": "IngressRoute"},
      "object": {
        "metadata": {"name": "test"},
        "spec": {"routes": [
          {"match": "Host(`example.com`)"},
          {"match": "Host(\"test-fqdn.example.com\") && PathPrefix(\"/test\")"},
          # these matches should produce violations
          {"match": "Host(`example.com`, \"test-fqdn.example.com\")"},
          {"match": "PathPrefix(\"/test\")"},
          {"match": "Host(`invalid_host.example.com`)"},
          {"match": "Host(`example.com` `another.example.com`)"},
        ]},
      },
    },
  }

  count(results) == 4
}

# Test that a matching route doesn't produce a violation if it's whitelisted
test_ingressroute_whitelist {
  results := violation with input as {
    "parameters": {
      "matchRegex": "Host\\(.*(`|\")example.com(`|\").*\\)",
      "namespaceWhitelist": ["kube-system", "example"],
    },
    "review": {
      "namespace": "example",
      "operation": "CREATE",
      "kind": {"kind": "IngressRoute"},
      "object": {
        "metadata": {"name": "test"},
        "spec": {"routes": [
          {"match": "Host(`example.com`)"},
          {"match": "Host(\"example.com\")"},
          {"match": "Host(`example.com`, `not-example.com`)"},
          {"match": "Host(\"not-example.com\", \"example.com\")"},
          {"match": "Host(`not-example.com`)"},
        ]},
      },
    },
  }

  count(results) == 0
}

# Test that a matching route produces a violation if it isn't in the whitelist
test_ingressroute_whitelist_violation {
  results := violation with input as {
    "parameters": {
      "matchRegex": "Host\\(.*(`|\")example.com(`|\").*\\)",
      "namespaceWhitelist": ["kube-system", "example"],
    },
    "review": {
      "namespace": "notwhitelisted",
      "operation": "CREATE",
      "kind": {"kind": "IngressRoute"},
      "object": {
        "metadata": {"name": "test"},
        "spec": {"routes": [
          {"match": "Host(`example.com`)"},
          {"match": "Host(\"example.com\")"},
          {"match": "Host(`example.com`, `not-example.com`)"},
          {"match": "Host(\"not-example.com\", \"example.com\")"},
          {"match": "Host(\"not-example.com\", \"example.com\") && PathPrefix(`/example`)"},
          # shouldn't produce a violation
          {"match": "Host(`not-example.com`)"},
        ]},
      },
    },
  }

  count(results) == 5
}

# Test that a matching string produces a violation
test_ingressroute {
  results := violation with input as {
    "parameters": {"matchRegex": "\\|\\|"},
    "review": {
      "namespace": "example",
      "operation": "CREATE",
      "kind": {"kind": "IngressRoute"},
      "object": {
        "metadata": {"name": "test"},
        "spec": {"routes": [
          {"match": "Host(`example.com`) || PathPrefix(`/`)"},
          # these matches shouldn't cause a violation
          {"match": "Host(`example.com`) && PathPrefix(`/`)"},
          {"match": "Host(`example.com`) && PathPrefix(`/`)"},
        ]},
      },
    },
  }

  count(results) == 1
}

# Test matching an IngressRouteTCP resource. The regular expression tests for a
# wildcard HostSNI
test_ingressroutetcp_wildcard_sni {
  results := violation with input as {
    "parameters": {"matchRegex": "HostSNI\\(.*((`|\")(\\*)(`|\"))+.*\\)"},
    "review": {
      "namespace": "example",
      "operation": "CREATE",
      "kind": {"kind": "IngressRouteTCP"},
      "object": {
        "metadata": {"name": "test"},
        "spec": {"routes": [
          {"match": "HostSNI(`*`)"},
          {"match": "HostSNI(\"*\")"},
          {"match": "HostSNI(`*`, `example.com`)"},
          {"match": "HostSNI(\"example.com\", \"*\")"},
          # these matches shouldn't cause a violation
          {"match": "HostSNI(\"example.com\", \"another-example.com\")"},
          {"match": "HostSNI(\"example.com\")"},
          {"match": "HostSNI(\"*.example.com\")"},
        ]},
      },
    },
  }

  count(results) == 4
}
