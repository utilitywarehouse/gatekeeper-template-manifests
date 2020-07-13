package ingressrequirehost

test_pass {
  results := violation with input as {
    "review": {
      "operation": "CREATE",
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
              "host": "test.example.com"
            },
            {
              "host": "test.example.com",
              "http": {
                "paths": [
                  {
                    "path": "/",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
                  }
                ]
              }
            },
            {
              "host": "test1.example.com",
              "http": {
                "paths": [
                  {
                    "path": "/",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
                  },
                  {
                    "path": "/api",
                    "backend": {
                      "serviceName": "example-api",
                      "servicePort": 8080
                    }
                  },
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

test_missing_host {
  results := violation with input as {
    "review": {
      "operation": "CREATE",
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
              "http": {
                "paths": [
                  {
                    "path": "/",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
                  }
                ]
              }
            },
            {
              "host": "test.example.com",
              "http": {
                "paths": [
                  {
                    "path": "/",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
                  }
                ]
              }
            },
            {
              "host": "test0.example.com",
              "http": {
                "paths": [
                  {
                    "path": "/"
                  },
                  {
                    "path": "/api",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
                  },
                ]
              }
            },
            {
              "http": {
                "paths": [
                  {
                    "path": "/",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
                  },
                  {
                    "path": "/api",
                    "backend": {
                      "serviceName": "example-api",
                      "servicePort": 8080
                    }
                  },
                ]
              }
            }
          ]
        }
      }
    }
  }
  count(results) == 1
}

test_backend {
  results := violation with input as {
    "review": {
      "operation": "CREATE",
      "kind": {
        "kind": "Ingress"
      },
      "object": {
        "metadata": {
          "name": "test"
        },
        "spec": {
          "backend": {
            "serviceName": "example",
            "servicePort": 8080
          }
        }
      }
    }
  }
  count(results) == 1
}

test_missing_host_and_backend {
  results := violation with input as {
    "review": {
      "operation": "CREATE",
      "kind": {
        "kind": "Ingress"
      },
      "object": {
        "metadata": {
          "name": "test"
        },
        "spec": {
          "backend": {
            "serviceName": "example",
            "servicePort": 8080
          },
          "rules": [
            {
              "http": {
                "paths": [
                  {
                    "path": "/",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
                  }
                ]
              }
            },
            {
              "host": "test.example.com",
              "http": {
                "paths": [
                  {
                    "path": "/",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    }
  }
  count(results) == 2 
}

test_delete {
  results := violation with input as {
    "review": {
      "operation": "DELETE",
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
              "http": {
                "paths": [
                  {
                    "path": "/",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
                  }
                ]
              }
            },
            {
              "host": "test.example.com",
              "http": {
                "paths": [
                  {
                    "path": "/",
                    "backend": {
                      "serviceName": "example",
                      "servicePort": 8080
                    }
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
