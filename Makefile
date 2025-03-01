project_name = melange-atdgen-codec-runtime

DUNE = opam exec -- dune

.DEFAULT_GOAL := help

.PHONY: help
help: ## Print this help message
	@echo "List of available make commands";
	@echo "";
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}';
	@echo "";

.PHONY: create-switch
create-switch: ## Create opam switch
	opam switch create . 4.14.1 -y --deps-only

.PHONY: init
init: create-switch install ## Configure everything to develop this repository in local

.PHONY: install
install: ## Install development dependencies
	yarn
	opam update
	# Needed for melange-jest, only for development
	opam pin add melange-webapi.dev -y git+https://github.com/melange-community/melange-webapi.git#17a6998985253bca49602fc29ec8735f899458ae
	opam pin -y add $(project_name).dev . --working-dir

.PHONY: build
build: ## Build the project
	$(DUNE) build @melange

.PHONY: build_verbose
build_verbose: ## Build the project
	$(DUNE) build --verbose @melange

.PHONY: clean
clean: ## Clean build artifacts and other generated files
	$(DUNE) clean

.PHONY: format
format: ## Format the codebase with ocamlformat
	$(DUNE) build @fmt --auto-promote

.PHONY: format-check
format-check: ## Checks if format is correct
	$(DUNE) build @fmt

.PHONY: watch
watch: ## Watch for the filesystem and rebuild on every change
	$(DUNE) build --watch @melange

.PHONY: test
test: ## Run the tests
	$(DUNE) build @runtest --no-buffer

.PHONY: test-watch
test-watch: ## Run the tests and watch for changes
	$(DUNE) build -w @runtest
