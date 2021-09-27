package hardenedpodvalidation

test_allow_unprivileged {
  results := violation with input as {
    "review": {"operation": "CREATE", "object": {
      "spec": {"containers":[
        {"name":"example1","securityContext": {}}
      ]}
    }}
  }
  count(results) == 0
}

test_disallow_privileged_containers {
  results := violation with input as {
    "review": {"operation": "CREATE", "object": {
      "spec": {"containers":[
        {"name":"example1","securityContext": {"privileged":true}}
      ]}
    }}
  }
  count(results) == 1
}

test_disallow_privileged_initContainers {
  results := violation with input as {
    "review": {"operation": "CREATE", "object": {
      "spec": {"initContainers":[
        {"name":"example1","securityContext": {"privileged":true}}
      ]}
    }}
  }
  count(results) == 1
}

test_disallow_privileged_ephemeralContainers {
  results := violation with input as {
    "review": {"operation": "CREATE", "object": {
      "spec": {"ephemeralContainers":[
        {"name":"example1","securityContext": {"privileged":true}}
      ]}
    }}
  }
  count(results) == 1
}

test_allow_no_capabilities {
  results := violation with input as {
    "review": {"operation": "CREATE", "object": {
      "spec": {"containers":[
      	{"name":"example1","securityContext": {"capabilities": {"add": []}}}
      ]}
    }}
  }
  count(results) == 0
}

test_allow_allowed_capabilities {
  results := violation with input as {
    "parameters": {"allowedCapabilities": ["alpha"]},
    "review": {"operation": "CREATE", "object": {
      "spec": {"containers":[
      	{"name":"example1","securityContext": {"capabilities": {"add": ["alpha"]}}}
      ]}
    }}
  }
  count(results) == 0
}

test_allow_allowed_capabilities_2 {
  results := violation with input as {
    "parameters": {"allowedCapabilities": ["alpha","beta"]},
    "review": {"operation": "CREATE", "object": {
      "spec": {"containers":[
      	{"name":"example1","securityContext": {"capabilities": {"add": ["beta"]}}}
      ]}
    }}
  }
  count(results) == 0
}

test_disallow_unallowed_capabilities {
  results := violation with input as {
    "parameters": {"allowedCapabilities": []},
    "review": {"operation": "CREATE", "object": {
      "spec": {"containers":[
      	{"name":"example1","securityContext": {"capabilities": {"add": ["something"]}}}
      ]}
    }}
  }
  count(results) == 1
}

test_disallow_unallowed_capabilities_2 {
  results := violation with input as {
    "parameters": {"allowedCapabilities": ["alpha"]},
    "review": {"operation": "CREATE", "object": {
      "spec": {"containers":[
      	{"name":"example1","securityContext": {"capabilities": {"add": ["alpha","beta"]}}}
      ]}
    }}
  }
  count(results) == 1
}
