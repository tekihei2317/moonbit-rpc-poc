.PHONY: frontend-dev backend-dev build-backend test-api clean

PORT ?= 4000
TEST_PORT ?= 4001

frontend-dev:
	bun --cwd frontend run dev

backend-dev:
	moon -C backend run . --target native -- --port $(PORT)

build-backend:
	moon -C backend build --target native

test-api:
	PORT=$(TEST_PORT) bash backend/api_test/run.sh

clean:
	rm -f contacts.db
	moon -C shared clean
	moon -C frontend clean
	moon -C backend clean
