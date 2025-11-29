.PHONY: all build-image start-redis check-redis start-kong setup-api setup-plugin clean stop help

# Default target
all: build-image start-redis check-redis start-kong setup-api setup-plugin

# Build Kong custom image from Dockerfile
build-image:
	@echo "Building Kong custom image..."
	docker build -t kong-custom:latest .

# Start Redis cluster
start-redis:
	@echo "Starting Redis cluster..."
	docker-compose -f redis-cluster/redis-cluster.yaml up -d
	@echo "Waiting for Redis containers to be ready..."
	@timeout /t 15 /nobreak > nul

# Check Redis cluster health
check-redis:
	@echo "Checking Redis cluster health..."
	@powershell -Command "\
		$$maxAttempts = 30; \
		$$attempt = 0; \
		$$healthy = $$false; \
		while ($$attempt -lt $$maxAttempts) { \
			try { \
				$$info = docker exec redis-master-1 redis-cli cluster info 2>$$null; \
				if ($$info -match 'cluster_state:ok') { \
					Write-Host 'Redis cluster is healthy!'; \
					$$healthy = $$true; \
					break; \
				} \
			} catch {} \
			$$attempt++; \
			Write-Host \"Attempt $$attempt/$$maxAttempts - Waiting for cluster...\"; \
			Start-Sleep -Seconds 2; \
		} \
		if (-not $$healthy) { \
			Write-Host 'Redis cluster failed to become healthy' -ForegroundColor Red; \
			exit 1; \
		}"

# Start Kong
start-kong:
	@echo "Starting Kong..."
	docker-compose -f kong-working.yaml up -d
	@echo "Waiting for Kong to be ready..."
	@timeout /t 10 /nobreak > nul

# register test service in kong
setup-api:
	@echo "Registering Test Sample Service API..."
	@powershell -ExecutionPolicy Bypass -File sample-api-registration.ps1


# Setup Kong plugin
setup-plugin:
	@echo "Configuring Kong plugin..."
	@powershell -ExecutionPolicy Bypass -File redis-test-plugin-setup.ps1

# Stop all services
stop:
	@echo "Stopping Kong..."
	-docker-compose -f kong-working.yaml  down
	@echo "Stopping Redis cluster..."
	-docker-compose -f redis-cluster/redis-cluster.yaml down

# Clean up everything (including volumes)
clean: stop
	@echo "Cleaning up volumes and networks..."
	-docker-compose -f kong-working.yaml down 
	-docker-compose -f redis-cluster/redis-cluster.yaml down 
	@echo "Removing custom Kong image..."
	

# Restart everything
restart: stop all

# Show logs
logs-kong:
	docker-compose -f kong-working.yaml logs -f

logs-redis:
	docker-compose -f redis-cluster/redis-cluster.yaml logs -f

# Show help
help:
	@echo "Available targets:"
	@echo "  all           - Build image, start Redis, check health, start Kong, setup api ,setup plugin"
	@echo "  build-image   - Build Kong custom image"
	@echo "  start-redis   - Start Redis cluster"
	@echo "  check-redis   - Check Redis cluster health"
	@echo "  start-kong    - Start Kong"
	@echo "  setup-api     - Register Test Sample Service API"
	@echo "  setup-plugin  - Configure Kong plugin"
	@echo "  stop          - Stop all services"
	@echo "  clean         - Stop services and remove volumes"
	@echo "  restart       - Restart everything"
	@echo "  logs-kong     - Show Kong logs"
	@echo "  logs-redis    - Show Redis logs"
	@echo "  help          - Show this help message"
