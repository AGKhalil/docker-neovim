.PHONY: build

CONTAINERNAME=nvim-env
IMAGENAME=thornycrackers/neovim

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup: ## Clone down additional repos that are needed for building
	git clone git@github.com:thornycrackers/.nvim.git nvim
	git clone git@github.com:thornycrackers/vim-options.git
	git clone git@github.com:thornycrackers/.vim.git vim
	git clone https://github.com/sunaku/dasht

build: ## Build the base image
	docker build -t thornycrackers/neovim .

build-nocache: ## Build the base image with no cache
	docker build --no-cache=true -t thornycrackers/neovim .

up: build ## Bring the container up
	docker run -dP -v $(CURDIR):/root/app --name $(CONTAINERNAME) $(IMAGENAME) /bin/bash -c 'while true; do echo hi; sleep 1; done;'

down: ## Stop the container
	docker stop $(CONTAINERNAME) || echo 'No container to stop'

enter: ## Enter the running container
	docker exec -it $(CONTAINERNAME) /bin/bash

clean: down ## Remove the image and any stopped containers
	docker rm $(CONTAINERNAME) || echo 'No container to remove'
	
push:
	docker push $(IMAGENAME)
