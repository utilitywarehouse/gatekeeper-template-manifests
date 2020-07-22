# IngressRouteMatchRestriction

Constrain Traefik v2 `IngressRoute` and `IngressRouteTCP` routes based on
a regular expression match.

## Parameters

### Required

- `matchRegex` - a regular expression supported by the [`re_match`
  function](https://www.openpolicyagent.org/docs/latest/policy-reference/#regex)

### Optional

- `message` - A message that will be returned to the user when the constraint is
  violated. If none is set then a generic message is returned.
- `inverse` - perform an inverse match. The default (`false`) will produce a
  violation for matching routes. Whereas, `true` will block routes that DON'T
  match the regular expression.
- `namespaceWhitelist` - a list of namespaces that are exempt from the constraint.

## Examples

Restrict a particular host to a list of namespaces:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: IngressRouteMatchRestriction
metadata:
  name: example-com
spec:
  match:
    kinds:
      - apiGroups: ["traefik.containo.us"]
        kinds: ["IngressRoute"]
  parameters:
    message: |-
      An IngressRoute matching example.com is not permitted in this namespace
    matchRegex: "Host\\(.*(`|\")example.com(`|\").*\\)"
    namespaceWhitelist:
      - kube-system
      - example-namespace
```

Use an inverse match to require a `Host()` value with valid FQDNs for
`IngressRoute` resources:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: IngressRouteMatchRestriction
metadata:
  name: require-host
spec:
  match:
    kinds:
      - apiGroups: ["traefik.containo.us"]
        kinds: ["IngressRoute"]
  parameters:
    message: "All route matches must contain a Host rule with a valid fqdn"
    matchRegex: "Host\\(((`|\")([a-zA-Z0-9]{1,})(`|\")(,|, )?|(`|\")([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\\.)+[a-z]{2,}(`|\")(,|, )?)+\\)"
    inverse: true
```

Ban the `||` operator in all namespaces except `kube-system`:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: IngressRouteMatchRestriction
metadata:
  name: or-operator
spec:
  match:
    kinds:
      - apiGroups: ["traefik.containo.us"]
        kinds: ["IngressRoute", "IngressRouteTCP"]
  parameters:
    message: "Route matches must not contain ||"
    matchRegex: "||"
    namespaceWhitelist: ["kube-system"]
```

Prevent a wildcard match in `HostSNI` for `IngressRouteTCP` resources:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: IngressRouteMatchRestriction
metadata:
  name: wildcard-hostsni
spec:
  match:
    kinds:
      - apiGroups: ["traefik.containo.us"]
        kinds: ["IngressRouteTCP"]
  parameters:
    message: "HostSNI rules must not contain a wildcard host '*'"
    matchRegex: "HostSNI\\(.*((`|\")(\\*)(`|\"))+.*\\)"
```
