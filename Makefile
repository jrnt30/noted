METALINTER_CONCURRENCY ?= 4
METALINTER_DEADLINE ?= 180

TS := $(shell date +%s)

BINPATH := $(GOPATH)/bin
GOMETA := $(BINPATH)/gometalinter
GOMALIGNED := $(BINPATH)/maligned

AWS_REGION=us-east-1
AWS_CFN_STACK=dev
AWS_S3_BUCKET=dev-noted

# Find all the dirs under functions/
FUNCTION_DIRS =$(wildcard functions/*/)
# Shorthand replacement syntax.
# - Expands the FUNCTION_DIRS var
# - % serves as a wildcard similar to a match group `function/([^/]*)/` replace with match group
FUNCTIONS  =$(FUNCTION_DIRS:functions/%/=%)
# Expands all of the functions and interpolates the string `build-func-$(funcName)`
# for each item to build a list of all the build functions
BUILD_CMDS =$(foreach funcName, $(FUNCTIONS), bins/$(funcName))

# Simply has dep as the `BUILD_CMDS` to easily create a list of all the
# builds to run
build-all: $(BUILD_CMDS)

# Performs a build of a single function
# Probably too cute and not worth the time, but it was interesting to figure out
# Allows us to rebuild our lambda only if vendor/ pkg/ or actual function changes
VENDOR_FILES = $(shell find vendor/ -name '*.go' -type f )
PKG_FILES = $(shell find pkg/ -name '*.go' -type f )
bins/%: functions/%/*.go $(VENDOR_FILES) $(PKG_FILES)
	@echo $*;
	GOOS=linux GOARCH=amd64 go build -o ./bins/$* ./functions/$*;

# Helper function for debugging the rendered value
print-%:
	@echo $* is: [$($*)]

# Helper targets to install required tools
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
	$(GOMETA) \
		--concurrency=$(METALINTER_CONCURRENCY) \
		--deadline=$(METALINTER_DEADLINE)s \
		--vendor \
		--linter='errcheck:errcheck:-ignore=net:Close' \
		--cyclo-over=20 \
    	--linter='vet:go tool vet -composites=false {paths}:PATH:LINE:MESSAGE' \
		--disable=interfacer \
		--dupl-threshold=50 \
		./...

local-chrome-extension:
	@cd chrome-extension && \
	pwd && \
	npm install
.PHONY: local-chrome-extension

deploy-apex-terraform:
	cd apex/infrastructure/apex && \
	terraform init && \
	terraform apply
.PHONY: deploy-apex-terraform

package-sam: build-all
	aws cloudformation package \
		--s3-bucket $(AWS_S3_BUCKET) \
		--template sam/template.yaml \
		--output-template sam/deploys/dev-$(TS).yaml

deploy-sam-%:
	aws cloudformation deploy \
		--region $(AWS_REGION) \
		--stack-name $(AWS_CFN_STACK) \
		--capabilities CAPABILITY_IAM \
		--template-file sam/deploys/dev-$*.yaml

package-and-deploy-sam: package-sam deploy-sam-$(TS)

.PHONY: fmt check tf-plan-%

