all:
	@docker build -t gatekeeper-template-manifests .

rego:
	@docker build -t gatekeeper-template-manifests-rego --target $@ .

kustomize:
	@docker build -t gatekeeper-template-manifests-kustomize --target $@ .

install-git-hooks:
	@-rm -r .git/hooks
	@ln -sv ../lib/git-hooks .git/hooks