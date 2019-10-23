test: opa kustomize constraint

opa:
	@docker run --rm -v $$PWD:/src openpolicyagent/opa test -v /src/base

kustomize:
	@docker build -t gatekeeper-template-manifests-kustomize -f Dockerfile.kustomize .

constraint:
	@docker build -t gatekeeper-template-manifests-constraint -f Dockerfile.constraint .

install-git-hooks:
	@-rm -r .git/hooks
	@ln -sv ../lib/git-hooks .git/hooks