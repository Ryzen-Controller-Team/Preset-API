ARGS = $(filter-out $@,$(MAKECMDGOALS))

list:
	@sh -c "echo; $(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'Makefile'| sort"

#############################
# Main actions
#############################

install:
	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Checking docker binary (may use sudo):\033[0m"
	which docker || ( \
		curl -fsSL https://get.docker.com -o /tmp/get-docker.sh && \
		sh /tmp/get-docker.sh \
		bash -c "sudo usermod -aG docker ${USER}" \
		echo "You may need to restart your laptop before starting the local environment." \
        exit 1 \
	)

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Checking docker-compose binary (may use sudo):\033[0m"
	which docker-compose || ( \
		sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
		sudo chmod +x /usr/local/bin/docker-compose \
	)

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Checking mkcert binary (may use sudo):\033[0m"
	which mkcert || ( \
		wget -P /tmp/ https://github.com/FiloSottile/mkcert/releases/download/v1.3.0/mkcert-v1.3.0-linux-amd64 && \
		chmod +x /tmp/mkcert-v1.3.0-linux-amd64 && \
		sudo mv -f /tmp/mkcert-v1.3.0-linux-amd64 /usr/local/bin/mkcert \
	)

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "mkcert certificate storage installation:\033[0m"
	mkcert -install

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Create *.ryzencontroller.localhost certificate:\033[0m"
	mkcert -cert-file "./docker/traefik/certs/_wildcard.ryzencontroller.localhost.pem" \
		-key-file "./docker/traefik/certs/_wildcard.ryzencontroller.localhost.key" \
		"*.ryzencontroller.localhost"

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Docker build:\033[0m"
	docker-compose build

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Admin yarn install:\033[0m"
	docker-compose run --rm admin yarn install --frozen-lockfile

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Encore yarn install:\033[0m"
	docker-compose run --rm yarn

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Building app assets:\033[0m"
	docker-compose run --rm yarn encore dev

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Starting services:\033[0m"
	docker-compose up -d

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Create jwt key:\033[0m"
	docker-compose exec php bin/create-jwt-keys

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Fix file's permissions:\033[0m"
	bash -c "sudo chown `id -u`:`id -g` -R ."

	@echo "\n\033[1;34m----------------------------------------------------------------------"
	@echo "Waiting for container php to be ready (See api/docker/php/docker-entrypoint.sh):\033[0m"
	@bash -c "until docker-compose exec php ls /tmp/ready > /dev/null 2>&1; do sleep 1; done;"

	@echo "\n\033[1;32m----------------------------------------------------------------------"
	@echo "Installation done. Services available:\033[0m"
	@echo "- http://localhost:8080/ => traefik router"
	@echo "- https://api.ryzencontroller.localhost/"
	@echo "- https://admin.ryzencontroller.localhost/"
	@echo "- Database: tcp://localhost:5432/"

permission-fix:
	bash -c "sudo chown `id -u`:`id -g` -R ."

uninstall: permission-fix
	docker-compose down -v
	git clean -fdx

#############################
# Docker machine states
#############################

logs:
	docker-compose logs -f --tail=10 ${ARGS}

state:
	docker-compose ps

start:
	docker-compose start

__silent-start:
	@docker-compose start > /dev/null 2>&1

restart:
	docker-compose restart

stop:
	docker-compose stop

after-dockerfile-update:
	docker-compose down
	docker-compose build --pull
	docker-compose up -d

after-dockercompose-update:
	docker-compose up -d

#############################
# Toolsets
#############################

admin-yarn: __silent-start
	docker-compose stop admin
	docker-compose run --rm admin yarn ${ARGS}

yarn:
	docker-compose run --rm yarn ${ARGS}

shell: __silent-start
	docker-compose exec php sh -c "${ARGS}"

__no-tty-shell: __silent-start
	@docker-compose exec -T php sh -c "${ARGS}"

console: __silent-start
	docker-compose exec php bin/console ${ARGS}

composer: __silent-start
	docker-compose exec php composer ${ARGS}
	docker-compose exec php bin/console cache:clear

db-psql: __silent-start
	docker-compose exec db psql postgres://api-platform:\!ChangeMe\!@db/api ${ARGS}


#############################
# To avoid ${ARGS} errors
#############################

%::
	@:
