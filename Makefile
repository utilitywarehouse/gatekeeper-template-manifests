SHELL := /bin/bash

.PHONY: test
test: opa kustomize template

.PHONY: opa
opa:
	@docker run --rm -v $$PWD:/src:ro openpolicyagent/opa test --ignore *.yaml --ignore *.json -v /src/base

.PHONY: kustomize
kustomize:
	@docker build -t gatekeeper-template-manifests-kustomize -f Dockerfile.kustomize .

.PHONY: template
template:
	@docker run -i --rm -v $$PWD:/workdir:ro \
	  --entrypoint sh \
	  mikefarah/yq:4.9.8 \
	  -c "/workdir/lib/template-match-src/template-match-src"

.PHONY: install-git-hooks
install-git-hooks:
	@-rm -r .git/hooks
	@ln -sv ../lib/git-hooks .git/hooks
