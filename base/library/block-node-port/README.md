# block-node-port

Block services of type `NodePort` unless they belong to a specific list of
exceptions.

## Examples

Block all `NodePort` services:

```
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: BlockNodePort
metadata:
  name: block-node-port
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Service"]
```

Block all `NodePort` services, except for `test/foo` on ports `31280/31433` and
`test/bar` on port `31522`.

```
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: BlockNodePort
metadata:
  name: block-node-port
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Service"]
  parameters:
    exceptions:
      - name: foo
        namespace: test
        nodePorts: [31280, 31433]
      - name: bar
        namespace: test
        nodePorts: [31522]
```
