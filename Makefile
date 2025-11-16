setup:
	bin/setup

env-prepare:
	cp -n .env.example .env || true

install:
	bundle install

console:
	bin/rails console

start:
	bin/rails s -p "3000" -b "0.0.0.0"

test:
	bin/rails test

lint:
	rubocop
	make lint-slim

lint-slim:
	slim-lint app/**/*.slim

lint-fix:
	rubocop -A

db-migrate:
	bin/rails db:migrate

compose-start:
	docker compose up -d

compose-clear:
	docker compose down -v

.PHONY: test