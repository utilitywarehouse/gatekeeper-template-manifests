FROM golang:1.12 as rego

WORKDIR /go/src/extract-rego

COPY lib/extract-rego/ .
COPY ./base base

RUN go get -d ./...
RUN go run extract-rego.go base/*.yaml

RUN curl -L -o opa https://github.com/open-policy-agent/opa/releases/download/v0.13.3/opa_linux_amd64
RUN chmod 755 opa
RUN ./opa test -v *.rego


FROM alpine:3 as kustomize

COPY ./base base
COPY ./example example

RUN wget -O kustomize \
    https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64
RUN chmod 755 kustomize

RUN ./kustomize build base
RUN ./kustomize build example