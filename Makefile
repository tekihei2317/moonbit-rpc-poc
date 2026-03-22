.PHONY: frontend-dev backend-dev build-backend test-api clean

PORT ?= 4000
TEST_PORT ?= 4001

frontend-dev:
	npm run dev

backend-dev:
	moon run backend --target native -- --port $(PORT)

build-backend:
	moon build backend --target native

test-api:
	PORT=$(TEST_PORT) bash backend/api_test/run.sh

clean:
	rm -f contacts.db
	moon clean
