include .env

CMD_ON_PROJECT = cd src && docker-compose run -u www-data --rm fpm
PHP_RUN = $(CMD_ON_PROJECT) php
.DEFAULT_GOAL := start
# TODO chown 1000:1000 src dir
.PHONY: install setup demodata emptydb createuser backup restore start stop
install:
	[ -d db ] || mkdir -p db
	[ -d dump ] || mkdir -p dump
	[ -d src ] || mkdir -p src
	[ -d src ] || mkdir -p export
	./setup.sh
	chown -R 1000:1000 src
	chown -R 1000:1000 db
	chown -R 1000:1000 dump
	chown -R 1000:1000 export
	$(MAKE) setup
	$(MAKE) createuser

setup:
	cp ./docker-compose.override.yml ./src/
#	sed -i 's/docker-compose run -u node --rm node/docker-compose run --rm node/g' src/Makefile 
	cd src && make prod

demodata:
	cd src && make database O="--catalog vendor/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/icecat_demo_dev"

emptydb:
	cd src && make database O="--catalog vendor/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/minimal"
	$(MAKE) createuser

createuser:
	$(PHP_RUN) bin/console pim:user:create

start:
	cd src && docker-compose start
	cd src && docker-compose run --rm -d php php bin/console akeneo:batch:job-queue-consumer-daemon

stop:
	cd src && docker-compose run php pkill -f job-queue-consumer-daemon | true
	cd src && docker-compose stop

backup:
	echo $(shell date )
	cd src && docker-compose exec mysql mysqldump $(APP_DATABASE_NAME) -u$(APP_DATABASE_USER) -p$(APP_DATABASE_PASSWORD) > ../dump/$(shell  date +"%h-%Y-%HH-%MM-%SS").sql
