# =========================================================================== #
#            MIT License Copyright (c) 2022 Kris Nóva <kris@nivenly.com>      #
#                                                                             #
#                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 #
#                 ┃   ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗   ┃                 #
#                 ┃   ████╗  ██║██╔═████╗██║   ██║██╔══██╗  ┃                 #
#                 ┃   ██╔██╗ ██║██║██╔██║██║   ██║███████║  ┃                 #
#                 ┃   ██║╚██╗██║████╔╝██║╚██╗ ██╔╝██╔══██║  ┃                 #
#                 ┃   ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║  ┃                 #
#                 ┃   ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝  ┃                 #
#                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 #
#                                                                             #
#                        This machine kills fascists.                         #
#                                                                             #
# =========================================================================== #

all: compile

version     =  0.0.1
target      =  kobfuscate
org         =  kris-nova
authorname  =  Kris Nóva
authoremail =  kris@nivenly.com
license     =  MIT
year        =  2022
copyright   =  Copyright (c) $(year)
image_repo  =  krisnova
image_name  =  kush
image_tag   =  latest
sha         =  $(shell git rev-parse HEAD)

compile: ## Compile for the local architecture ⚙
	@echo "Compiling..."
	go build -installsuffix cgo -ldflags "\
	-X 'github.com/$(org)/$(target).Version=$(version)' \
	-X 'github.com/$(org)/$(target).AuthorName=$(authorname)' \
	-X 'github.com/$(org)/$(target).AuthorEmail=$(authoremail)' \
	-X 'github.com/$(org)/$(target).Copyright=$(copyright)' \
	-X 'github.com/$(org)/$(target).License=$(license)' \
	-X 'github.com/$(org)/$(target).Name=$(target)'" \
	-o $(target) cmd/*.go

install: ## Install the program to /usr/bin 🎉
	@echo "Installing..."
	sudo cp $(target) /usr/bin/$(target)

test: clean compile install ## 🤓 Run go tests
	@echo "Testing..."
	go test -v ./...

container: clean ## Build the kush container
	docker build -t $(image_repo)/$(image_name):$(image_tag) .
	#docker build -t $(image_repo)/$(image_name):$(sha) .

push: ## Push the kush container
	docker push $(image_repo)/$(image_name):$(image_tag)
	#docker push $(image_repo)/$(image_name):$(sha)

container-base: clean ## Build the base container
	docker build -t $(image_repo)/$(image_name)base:$(image_tag) image/
	#docker build -t $(image_repo)/$(image_name)base:$(sha) .

push-base: ## Push the kush container
	docker push $(image_repo)/$(image_name)base:$(image_tag)
	#docker push $(image_repo)/$(image_name)base:$(sh)

exec: ## Run an exec into a kush container
	docker run -it $(image_repo)/$(image_name):$(image_tag) /bin/kush

clean: ## Clean your artifacts 🧼
	@echo "Cleaning..."
	rm -rvf release/*
	rm -rvf kush

.PHONY: release
release: ## Make the binaries for a GitHub release 📦
	mkdir -p release
	GOOS="linux" GOARCH="amd64" go build -ldflags "-X 'github.com/$(org)/$(target).Version=$(version)'" -o release/$(target)-linux-amd64 cmd/*.go
	GOOS="linux" GOARCH="arm" go build -ldflags "-X 'github.com/$(org)/$(target).Version=$(version)'" -o release/$(target)-linux-arm cmd/*.go
	GOOS="linux" GOARCH="arm64" go build -ldflags "-X 'github.com/$(org)/$(target).Version=$(version)'" -o release/$(target)-linux-arm64 cmd/*.go
	GOOS="linux" GOARCH="386" go build -ldflags "-X 'github.com/$(org)/$(target).Version=$(version)'" -o release/$(target)-linux-386 cmd/*.go
	GOOS="darwin" GOARCH="amd64" go build -ldflags "-X 'github.com/$(org)/$(target).Version=$(version)'" -o release/$(target)-darwin-amd64 cmd/*.go

.PHONY: help
help:  ## 🤔 Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'