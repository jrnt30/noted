METALINTER_CONCURRENCY ?= 4
METALINTER_DEADLINE ?= 180

BINPATH := $(GOPATH)/bin
GOMETA := $(BINPATH)/gometalinter
GOMALIGNED := $(BINPATH)/maligned

$(GOMALIGNED):
	@echo "Downloading Depenency ==> maligned"
	@go get github.com/mdempsky/maligned

$(GOMETA): $(GOMALIGNED)
	@echo "Downloading Depenency ==> gometalinter"
	@go get -u github.com/alecthomas/gometalinter

fmt:
	gofmt -w=true $$(find . -type f -name '*.go' -not -path "./vendor/*" -not -path "./pkg/generated/*")
	goimports -w=true -d $$(find . -type f -name '*.go' -not -path "./vendor/*" -not -path "./pkg/generated/*")


check: $(GOMETA)
	$(GOMETA) --concurrency=$(METALINTER_CONCURRENCY) --deadline=$(METALINTER_DEADLINE)s ./... --vendor --linter='errcheck:errcheck:-ignore=net:Close' --cyclo-over=20 \
    		--linter='vet:go tool vet -composites=false {paths}:PATH:LINE:MESSAGE' --disable=interfacer --dupl-threshold=50

local-chrome-extension:
	@cd chrome-extension && \
	pwd && \
	npm install
.PHONY: local-chrome-extension

deploy-apex-terraform:
	cd infrastructure/apex && \
	terraform init && \
	terraform apply
.PHONY: deploy-apex-terraform

.PHONY: fmt check tf-plan-%
