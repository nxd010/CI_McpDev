IMAGE_NAME := jenkins-with-python3
CONTAINER_NAME := contrihub-jenkins
JENKINS_HOME := jenkins_home
DOCKER_SOCK := /var/run/docker.sock
NGROK_CONFIG := ~/.ngrok2/ngrok.yml

check_deps:
	@echo "Checking for required dependencies..."
	@command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is not installed. Please install Docker Desktop."; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo >&2 "Git is not installed. Please install Git."; exit 1; }
	@command -v ngrok >/dev/null 2>&1 || { echo >&2 "Ngrok is not installed. Please download and set up ngrok."; exit 1; }
	@echo "All dependencies found."

# This assumes a new WSL environment
install-all: check_deps
	@echo "Installing all prerequisites for the Jenkins CI pipeline..."
	sudo apt-get update
	sudo apt-get install -y python3 python3-pip git zip build-essential

# Rule to build the custom Docker image and start the Jenkins container
# Assumes Docker is already installed and running.
ci-up: check_deps
	@echo "Building custom Jenkins image and starting container..."
	# Build the custom image with the Dockerfile
	docker build -t $(IMAGE_NAME) .
	# Stop and remove any old container and volume to ensure a fresh start
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true
	docker volume rm $(JENKINS_HOME) || true
	# Run the new container, mounting the Docker socket and Jenkins home volume
	docker run -d --name $(CONTAINER_NAME) -p 8080:8080 -p 50000:50000 \
		-v $(JENKINS_HOME):/var/jenkins_home \
		-v $(DOCKER_SOCK):$(DOCKER_SOCK) \
		-u root --group-add $(shell getent group docker | cut -d: -f3) \
		$(IMAGE_NAME)
	@echo "Jenkins container started successfully! Access it at http://localhost:8080"
	@echo "Remember to retrieve the initial admin password from the logs using: docker logs $(CONTAINER_NAME)"

# Rule to create a ngrok tunnel for webhook
# ngrok must be authenticated and configured.
ip-tunnel: check_deps
	@echo "Starting ngrok tunnel for Jenkins webhooks..."
	# Check if ngrok is already running, and start it if not
	@if pgrep ngrok >/dev/null; then \
		echo "Ngrok is already running."; \
	else \
		ngrok http 8080; \
	fi
	@echo "Ngrok tunnel started. Use the forwarded URL in your GitHub webhook settings."

# Rule to stop the Jenkins container 
docker-stop:
	@echo "Stopping Jenkins container and cleaning up..."
	docker stop $(CONTAINER_NAME) || true
	docker rm -f $(CONTAINER_NAME) || true
	docker volume rm $(JENKINS_HOME) || true
	@echo "Jenkins container and volume removed."
	@if pgrep ngrok >/dev/null; then \
		echo "Stopping ngrok tunnel..."; \
		killall ngrok; \
	else \
		echo "Ngrok is not running."; \
	fi
	@echo "Cleanup complete."

.PHONY: check_deps install-all ci-up ip-tunnel docker-stop
