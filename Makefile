
GH = https://github.com/orgs/cpan-testers
SRC_DIR = src
REPOS = cpantesters-schema cpantesters-backend cpantesters-web cpantesters-api

.PHONY: src docker docker-base docker-schema docker-backend docker-web docker-api \
    start stop compose connect data restart

src:
	for REPO in $(REPOS); do \
	    git clone $(GH)/$$REPO $(SRC_DIR)/$$REPO; \
	done

docker-base:
	@echo "Building base image as cpantesters/base..."
	@docker build . --tag cpantesters/base >build-base.log \
	    || echo "ERR: Build failed. See build-base.log";

docker-schema: docker-base
	@BUILD="schema"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --tag $$TAG >build-$$BUILD.log \
	    || echo "ERR: Build failed. See build-$$BUILD.log";

docker-backend: docker-base docker-schema
	@BUILD="backend"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --tag $$TAG >build-$$BUILD.log \
	    || echo "ERR: Build failed. See build-$$BUILD.log";

docker-web: docker-base docker-schema
	@BUILD="web"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --tag $$TAG >build-$$BUILD.log \
	    || echo "ERR: Build failed. See build-$$BUILD.log";

docker-api: docker-base docker-schema
	@BUILD="api"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --tag $$TAG >build-$$BUILD.log \
	    || echo "ERR: Build failed. See build-$$BUILD.log";

docker: docker-backend docker-web docker-api

compose: docker
	@echo 'Refreshing docker-compose services'
	@docker-compose build
	@docker-compose up --no-start

start:
	@docker-compose start

stop:
	@docker-compose stop

restart:
	@docker-compose stop
	@docker-compose start

connect:
	@docker-compose exec db_tester mysql cpantesters

data:
	@echo "Fetching data for $(DIST)"
	@docker-compose run deploy cpantesters-schema fetch --dist $(DIST) report release

daemon:
	@COMPOSE_FILE="docker-compose.yml:docker-compose.devel.yml" \
	    docker-compose build && docker-compose up
