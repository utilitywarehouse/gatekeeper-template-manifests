# gatekeeper-template-manifests

![Github Actions](https://github.com/utilitywarehouse/gatekeeper-template-manifests/actions/workflows/test.yaml/badge.svg)

This repository provides a library of Open Policy Agent gatekeeper `ConstraintTemplates` as a Kustomize base.

## Usage

Reference the base in your `kustomization.yaml`, like so:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
  - github.com/utilitywarehouse/gatekeeper-template-manifests/base?ref=1.2.4
```

Refer to the `example/`.

## Requires

- https://github.com/kubernetes-sigs/kustomize

```
go get -u sigs.k8s.io/kustomize
```

## Testing

The rego policies, `ConstraintTemplates` and kustomize build can be tested with `make`.

Or the tests can be ran separately:

```
$ make opa
$ make template
$ make kustomize
```

You can also install a `pre-push` git hook that will run the tests on push:

```
$ make install-git-hooks
```
