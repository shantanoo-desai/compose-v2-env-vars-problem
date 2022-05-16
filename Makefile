.PHONY: build compose clean run

include .env

SERVICES_DIR=services
COMPOSE_FILES=-f docker-compose.base.yml -f $(SERVICES_DIR)/docker-compose.grafana.yml

define OPTIONS
  - grafana -
endef
export OPTIONS

SERVICES:=$(filter-out ${OPTIONS},$(ARGS))
.PHONY: $(OPTIONS)



build:
	make compose grafana

compose:
	docker compose $(COMPOSE_FILES) config > docker-compose.yml

clean:
	docker compose down

run:
	docker compose $(SERVICES) up -d