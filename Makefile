COMPOSE_PRODUCTION = bin/production.sh
COMPOSE_TEST       = bin/test.sh

.PHONY: ci
ci: test

.PHONY: prod
prod: up

.PHONY: build
build:
	$(COMPOSE_TEST) build

.PHONY: pull
pull:
	$(COMPOSE_PRODUCTION) pull

.PHONY: test
test: .env build up fixtures
	$(COMPOSE_TEST) run --rm test

.PHONY: clean
clean:
	$(COMPOSE_TEST) down -v --remove-orphans

.env:
	cp .env.dist .env

.PHONY: logs
logs:
	$(COMPOSE_PRODUCTION) logs db
	$(COMPOSE_PRODUCTION) logs ssl
	$(COMPOSE_PRODUCTION) logs mta
	$(COMPOSE_PRODUCTION) logs mda
	$(COMPOSE_PRODUCTION) logs filter
	$(COMPOSE_PRODUCTION) logs virus
	$(COMPOSE_PRODUCTION) logs web

.PHONY: up
up: .env
	$(COMPOSE_PRODUCTION) up -d

.PHONY: fixtures
fixtures:
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console domain:add flind.ch
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --admin --password=aequ4Ayais --enable admin flind.ch
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 --enable --sendonly sendonly flind.ch
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 --enable --quota=1 quota flind.ch
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 disabled flind.ch
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 --sendonly disabledsendonly flind.ch
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console alias:add foo@flind.ch admin@flind.ch
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console dkim:setup flind.ch --enable --selector 1337

.PHONY: unofficial-sigs
unofficial-sigs:
	cd virus/contrib/unofficial-sigs; docker build -t virus_unof_sig_updater .

.PHONY: setup
setup:
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/setup.sh

.PHONY: lint
lint:
	.ci/bin/dockerfile_lint.sh
	.ci/bin/yamllint.sh
