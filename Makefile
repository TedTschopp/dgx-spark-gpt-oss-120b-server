.DEFAULT_GOAL := help

help:
	@echo "Targets:"
	@echo "  make prereqs      Install docker + nvidia container runtime checks (Spark)"
	@echo "  make up           Start the API server"
	@echo "  make down         Stop the API server"
	@echo "  make logs         Tail logs"
	@echo "  make health       Run a simple health check"
	@echo "  make status       Show container status"

prereqs:
	bash scripts/install_prereqs.sh

up:
	bash scripts/start.sh

down:
	bash scripts/stop.sh

logs:
	bash scripts/logs.sh

health:
	bash scripts/healthcheck.sh

status:
	docker ps --filter "name=trtllm_llm_server"
