.PHONY: frontend-dev backend-dev build-backend clean

PORT ?= 4000

frontend-dev:
	npm run dev

backend-dev:
	moon run backend --target native -- --port $(PORT)

build-backend:
	moon build backend --target native

clean:
	rm -f contacts.db
	moon clean
