
GH = https://github.com/orgs/cpan-testers
SRC_DIR = src
REPOS = cpantesters-schema cpantesters-backend cpantesters-web cpantesters-api

.PHONY: src docker docker-base docker-schema docker-backend docker-web docker-api \
    start stop

src:
	for REPO in $(REPOS); do \
	    git clone $(GH)/$$REPO $(SRC_DIR)/$$REPO; \
	done

docker-base:
	@echo "Building base image as cpantesters/base..."
	@docker build . --tag cpantesters/base >build-base.log

docker-schema: docker-base
	@BUILD="schema"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --tag $$TAG >build-$$BUILD.log;

docker-backend: docker-base docker-schema
	@BUILD="backend"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --tag $$TAG >build-$$BUILD.log;

docker-web: docker-base docker-schema
	@BUILD="web"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --tag $$TAG >build-$$BUILD.log;

docker-api: docker-base docker-schema
	@BUILD="api"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --tag $$TAG >build-$$BUILD.log;

docker: docker-backend docker-web docker-api

start:
	@docker-compose up

stop:
	@docker-compose stop
