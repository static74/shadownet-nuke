# Variables
APP_NAME := shadownet-nuke
SERVICE_FILE := /etc/systemd/system/$(APP_NAME).service
INSTALL_DIR := /hunter/Software/
REPO_URL := https://github.com/your-repo/$(APP_NAME).git
DEPENDENCIES := git curl libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
                libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base \
                gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
                gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools \
                gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl \
                gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio \
                vlc build-essential libboost-all-dev

# Default target
all: install

# Install dependencies
install-deps:
	@echo "Installing dependencies..."
	apt-get update && apt-get install -y $(DEPENDENCIES)

# Clone the repository and move the contents
install-app: install-deps
	@echo "Installing $(APP_NAME)..."
	-git clone $(REPO_URL) /tmp/$(APP_NAME)
	@echo "Moving $(APP_NAME) to $(INSTALL_DIR)..."
	mkdir -p $(INSTALL_DIR)
	mv /tmp/$(APP_NAME)/* $(INSTALL_DIR)
	chmod +x $(INSTALL_DIR)/run.sh
	rm -rf /tmp/$(APP_NAME)

# Create the service file
create-service:
	@echo "Creating systemd service file..."
	echo "[Unit]" > $(SERVICE_FILE)
	echo "Description=$(APP_NAME) service" >> $(SERVICE_FILE)
	echo "After=network.target" >> $(SERVICE_FILE)
	echo "[Service]" >> $(SERVICE_FILE)
	echo "Type=simple" >> $(SERVICE_FILE)
	echo "ExecStart=$(INSTALL_DIR)/run.sh" >> $(SERVICE_FILE)
	echo "Restart=always" >> $(SERVICE_FILE)
	echo "[Install]" >> $(SERVICE_FILE)
	echo "WantedBy=multi-user.target" >> $(SERVICE_FILE)
	chmod 644 $(SERVICE_FILE)

# Enable and start the service
enable-service: create-service
	@echo "Enabling and starting the service..."
	systemctl daemon-reload
	systemctl enable $(APP_NAME)
	systemctl start $(APP_NAME)

# Full installation process
install: install-app enable-service

# Update the application files from the Git repository
update:
	@if [ -d "$(INSTALL_DIR)" ]; then \
		echo "Updating $(APP_NAME)..."; \
		cd $(INSTALL_DIR); \
		git pull; \
	else \
		echo "$(APP_NAME) is not installed. Run 'make install' first."; \
	fi

# Clean up
clean:
	@echo "Cleaning up..."
	rm -rf $(INSTALL_DIR)
	rm -f $(SERVICE_FILE)
	systemctl stop $(APP_NAME)
	systemctl disable $(APP_NAME)
	systemctl daemon-reload

.PHONY: all install install-deps install-app create-service enable-service clean
