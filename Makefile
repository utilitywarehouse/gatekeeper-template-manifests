test: opa kustomize template

opa:
	@docker run --rm -v $$PWD:/src openpolicyagent/opa test --ignore *.yaml --ignore *.json -v /src/base

kustomize:
	@docker build -t gatekeeper-template-manifests-kustomize -f Dockerfile.kustomize .

template:
	@docker run --rm -v $$PWD:/workdir mikefarah/yq /bin/sh ./lib/template-match-src/template-match-src.sh

install-git-hooks:
	@-rm -r .git/hooks
	@ln -sv ../lib/git-hooks .git/hooks
