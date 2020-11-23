local-up:
	docker-compose up -d

local-build:
	docker-compose up -d --build

local-down:
	docker-compose down

local-stop:
	docker-compose stop

local-bash:
	docker-compose exec appium bash

local-log:
	docker-compose logs --tail=50 -f appium

local-ps:
	docker-compose ps