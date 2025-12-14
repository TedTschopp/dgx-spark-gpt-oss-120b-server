.DEFAULT_GOAL := help

help:
	@echo "Targets:"
	@echo "  make prereqs      Install docker + nvidia container runtime checks (Spark)"
	@echo "  make up           Start the stack (API + Open WebUI)"
	@echo "  make down         Stop the stack"
	@echo "  make logs         Tail TRT-LLM logs (set CONTAINER_NAME=open_webui for WebUI logs)"
	@echo "  make watch        Periodic one-line status updates"
	@echo "  make health       Run a simple health check"
	@echo "  make status       Show container status (API + WebUI)"

prereqs:
	bash scripts/install_prereqs.sh

up:
	bash scripts/start.sh

down:
	bash scripts/stop.sh

logs:
	bash scripts/logs.sh

watch:
	bash scripts/watch_status.sh

health:
	bash scripts/healthcheck.sh

status:
	@bash -lc 'docker ps --filter "name=trtllm_llm_server" --filter "name=open_webui" 2>/dev/null || sg docker -c "docker ps --filter \\\"name=trtllm_llm_server\\\" --filter \\\"name=open_webui\\\""'
