METALINTER_CONCURRENCY ?= 4
METALINTER_DEADLINE ?= 180

fmt:
	gofmt -w=true $$(find . -type f -name '*.go' -not -path "./vendor/*" -not -path "./pkg/generated/*")
	goimports -w=true -d $$(find . -type f -name '*.go' -not -path "./vendor/*" -not -path "./pkg/generated/*")

check:
	gometalinter --concurrency=$(METALINTER_CONCURRENCY) --deadline=$(METALINTER_DEADLINE)s ./... --vendor --linter='errcheck:errcheck:-ignore=net:Close' --cyclo-over=20 \
    		--linter='vet:go tool vet -composites=false {paths}:PATH:LINE:MESSAGE' --disable=interfacer --dupl-threshold=50

.PHONY: fmt check
