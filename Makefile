.PHONY: frontend-dev backend-dev build-backend test-api lsp-frontend lsp-backend lsp-reset clean

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

lsp-frontend:
	moon info shared --target js
	moon info frontend/app --target js

lsp-backend:
	moon info backend --target native

lsp-reset:
	rm -rf _build .mooncakes
	moon update
	moon info shared --target js
	moon info frontend/app --target js
	moon info backend --target native

clean:
	rm -f contacts.db
	moon clean
