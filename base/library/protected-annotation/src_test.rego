package kubernetes.validating.annotaion

test_ns_whitelisted {
    results := violation with input as {
       "kind": "AdmissionReview",
       "parameters": {
           "annotationGlob": "scheduler.alpha.kubernetes.io/*",
           "namespaceGlobWhitelist": [
               "kube-system",
               "sys-*",
               "example-ns"
           ]
       },
       "review": {
           "kind": {
               "kind": "Namespace",
               "version": "v1"
           },
           "namespace": "example-ns",
           "object": {
               "metadata": {
                   "annotations": {
                       "costcenter": "fakecode",
                       "scheduler.alpha.kubernetes.io/defaultTolerations": "escaped-json",
                       "scheduler.alpha.kubernetes.io/tolerationsWhitelist": "escaped-json"
                   },
                   "name": "example-ns"
               }
           },
           "operation": "CREATE"
       }
    }
    count(results) == 0
}

test_ns_not_whitelisted {
    results := violation with input as {
       "kind": "AdmissionReview",
       "parameters": {
           "annotationGlob": "scheduler.alpha.kubernetes.io/*",
           "namespaceGlobWhitelist": [
               "kube-system",
               "sys-*"
           ]
       },
       "review": {
           "kind": {
               "kind": "Namespace",
               "version": "v1"
           },
           "namespace": "example-ns",
           "object": {
               "metadata": {
                   "annotations": {
                       "costcenter": "fakecode",
                       "scheduler.alpha.kubernetes.io/defaultTolerations": "escaped-json",
                       "scheduler.alpha.kubernetes.io/tolerationsWhitelist": "escaped-json"
                   },
                   "name": "example-ns"
               }
           },
           "operation": "CREATE"
       }
    }
    count(results) == 2
}
