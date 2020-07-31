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
      "matchRegex": "Host\\((`(([a-zA-Z0-9]{1,})|([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\\.)+[a-z]{2,})`(, ?)?)+\\)",
      "inverse": true,
    },
    "review": {
      "namespace": "example",
      "operation": "CREATE",
      "kind": {"kind": "IngressRoute"},
      "object": {
        "metadata": {"name": "test"},
        "spec": {"routes": [
          # violations
          {"match": "PathPrefix(`/test`)"},
          {"match": "Host(`invalid_host.example.com`)"},
          {"match": "Host(`example.com` `another.example.com`)"},
          # not violations
          {"match": "Host(`example.com`)"},
          {"match": "Host(`example.com`, `test-fqdn.example.com`)"},
          {"match": "Host(`test-fqdn.example.com`) && PathPrefix(`/test`)"},
        ]},
      },
    },
  }

  count(results) == 3
}

# Test a regex that blocks the use of the || operator
test_ingressroute_or {
  results := violation with input as {
    "parameters": {"matchRegex": "\\|\\|"},
    "review": {
      "namespace": "example",
      "operation": "CREATE",
      "kind": {"kind": "IngressRoute"},
      "object": {
        "metadata": {"name": "test"},
        "spec": {"routes": [
          # violations
          {"match": "Host(`example.com`) || PathPrefix(`/`)"},
          # not violations
          {"match": "Host(`example.com`)"},
          {"match": "Host(`example.com`) && PathPrefix(`/`)"},
        ]},
      },
    },
  }

  count(results) == 1
}

# Test a regex that blocks a wildcard HostSNI for an IngressRouteTCP
# resource
test_ingressroutetcp_wildcard_sni {
  results := violation with input as {
    "parameters": {"matchRegex": "HostSNI\\([^\\)\\(]*`\\*`[^\\)\\(]*\\)"},
    "review": {
      "namespace": "example",
      "operation": "CREATE",
      "kind": {"kind": "IngressRouteTCP"},
      "object": {
        "metadata": {"name": "test"},
        "spec": {"routes": [
          # violations
          {"match": "HostSNI(`*`)"},
          {"match": "HostSNI(`example.com`, `*`)"},
          # not violations
          {"match": "HostSNI(`example.com`)"},
          {"match": "HostSNI(`example.com`, `another-example.com`)"},
          {"match": "HostSNI(`*.example.com`)"},
        ]},
      },
    },
  }

  count(results) == 2
}

# Test a regex that blocks the use of example.com as a Host or HostSNI value
test_ingressroute_host {
  results := violation with input as {
    "parameters": {"matchRegex": "Host(SNI)?\\([^\\)\\(]*`example.com`[^\\)\\(]*\\)"},
    "review": {
      "namespace": "example",
      "operation": "UPDATE",
      "kind": {"kind": "IngressRoute"},
      "object": {
        "metadata": {"name": "test"},
        "spec": {"routes": [
          # violations
          {"match": "Host(`example.com`)"},
          {"match": "Host(`example.com`, `another-example.com`)"},
          {"match": "Host(`example.com`) && PathPrefix(`/example`)"},
          {"match": "HostSNI(`example.com`)"},
          {"match": "HostSNI(`example.com`, `another-example.com`)"},
          # not violations
          {"match": "Host(`not-example.com`)"},
          {"match": "Host(`not-example.com`, `still-not-example.com`)"},
          {"match": "Host(`not-example.com`) && Headers(`somevalue`, `example.com`)"},
          {"match": "HostSNI(`not-example.com`)"},
          {"match": "HostSNI(`not-example.com`, `still-not-example.com`)"},
        ]},
      },
    },
  }

  count(results) == 5
}
