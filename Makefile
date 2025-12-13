
GH = https://github.com/orgs/cpan-testers
SRC_DIR = src
REPOS = cpantesters-schema cpantesters-backend cpantesters-web cpantesters-api
ENV = dev
DOCKER_CONTEXT = cpantesters-${ENV}
STACK_NAME = cpantesters
COMPOSE_FILE = swarm-compose.yml

API_PORT = 8000
METABASE_PORT = 8250

export API_PORT METABASE_PORT

.PHONY: src docker docker-base docker-schema docker-backend docker-web docker-api \
    start stop compose connect data restart

src:
	for REPO in $(REPOS); do \
	    git clone $(GH)/$$REPO $(SRC_DIR)/$$REPO; \
	done

docker-base:
	@echo "Building base image as cpantesters/base..."
	@docker build . --platform linux/amd64 --tag cpantesters/base >build-base.log \
	    || echo "ERR: Build failed. See build-base.log";

docker-schema: docker-base
	@BUILD="schema"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --platform linux/amd64 --tag $$TAG >build-$$BUILD.log \
	    || echo "ERR: Build failed. See build-$$BUILD.log";

docker-backend: docker-base docker-schema
	@BUILD="backend"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --platform linux/amd64 --tag $$TAG >build-$$BUILD.log \
	    || echo "ERR: Build failed. See build-$$BUILD.log";

docker-web: docker-base docker-schema
	@BUILD="web"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --platform linux/amd64 --tag $$TAG >build-$$BUILD.log \
	    || echo "ERR: Build failed. See build-$$BUILD.log";

docker-api: docker-base docker-schema
	@BUILD="api"; \
	REPO="cpantesters-$$BUILD"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building repo $$REPO as $$TAG..."; \
	docker build $(SRC_DIR)/$$REPO --platform linux/amd64 --tag $$TAG >build-$$BUILD.log \
	    || echo "ERR: Build failed. See build-$$BUILD.log";

docker-cpan:
	@BUILD="cpan"; \
	TAG="cpantesters/$$BUILD"; \
	echo "Building $$TAG..."; \
	docker build . -f Dockerfile.cpan --platform linux/amd64 --tag $$TAG >build-$$BUILD.log \
	    || echo "ERR: Build failed. See build-$$BUILD.log";

docker: docker-backend docker-web docker-api

publish:
	@echo 'Publishing cpantesters to Docker Hub'
	@for IMAGE in cpantesters/{base,schema,backend,api,web,cpan}; do docker push $$IMAGE; done

deploy:
	# XXX: The only way to update config and secrets is to remove the entire stack and re-deploy it...
	# So, for zero-downtime deployments, we will likely need to make a ${STACK_NAME}-blue and ${STACK_NAME}-green
	# and then choosing which one is inactive to remove and replace with the new deployment.
	@echo "Deploying to Swarm (context ${DOCKER_CONTEXT})"
	@RESTORE_CONTEXT=${docker context show}; \
		docker context use ${DOCKER_CONTEXT}; \
		docker stack remove ${STACK_NAME}; \
		sleep 10; \
		docker stack deploy ${STACK_NAME} --compose-file ${COMPOSE_FILE};

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
	@COMPOSE_FILE=docker-compose.yml:docker-compose.daemon.yml \
	    docker-compose build
	@COMPOSE_FILE=docker-compose.yml:docker-compose.daemon.yml \
	    docker-compose up

build-cert:
	@COMPOSE_FILE=docker-compose.yml:docker-compose.$(ENV).yml \
	    docker-compose run certbot

list-cert:
	@COMPOSE_FILE=docker-compose.yml:docker-compose.$(ENV).yml \
	    docker-compose run certbot certificates

