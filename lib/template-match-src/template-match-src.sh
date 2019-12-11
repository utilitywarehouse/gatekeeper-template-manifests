#!/bin/sh

# exit 1 for template.yaml files where spec.targets[0].rego doesn't match the
# contents of src.rego in the same directory

code=0

rego_field="spec.targets[0].rego"

while read template_file; do
	src_file=$(dirname ${template_file})/src.rego
	IFS=
	if [[ "$(cat ${src_file})" != "$(yq r "${template_file}" "${rego_field}")" ]]; then
		echo "${template_file}: the contents of ${rego_field} don't match ${src_file}"
		code=1
	fi
done <<-EOT
	$(find "${1:-.}" -type f -name template.yaml)
EOT

exit $code
