#!/bin/bash

# Update system and install dependencies
sudo apt update
sudo apt install -y build-essential cmake pkg-config libboost-all-dev libssl-dev \
    libzmq3-dev libsodium-dev libunbound-dev libminiupnpc-dev libprotobuf-dev \
    protobuf-compiler libreadline6-dev libpgm-dev libnorm-dev libhidapi-dev \
    doxygen graphviz libusb-1.0-0-dev net-tools

# Initialize and update submodules (if needed)
git submodule init
git submodule update

# Build Monero
make

# Ensure the blockchain data directory exists
sudo mkdir -p /root/.bitmonero

# Prompt user if they want to set up the systemd service
read -p "Would you like to set up monerod as a systemd service to run on reboot? (yes/no): " setup_service

if [[ "$setup_service" == "yes" ]]; then

  # Create the systemd service for monerod
  sudo bash -c "cat << EOF > /etc/systemd/system/monerod.service
[Unit]
Description=Monero Full Node
After=network-online.target
Wants=network-online.target

[Service]
User=root
ExecStart=/root/monero/build/Linux/master/release/bin/monerod --data-dir /root/.bitmonero --rpc-bind-ip 0.0.0.0 --rpc-bind-port 18081 --confirm-external-bind --non-interactive
Restart=on-failure
RestartSec=10
TimeoutSec=300

[Install]
WantedBy=multi-user.target
EOF"

  # Reload systemd to apply the new service
  sudo systemctl daemon-reload

  # Enable the service so it starts on boot
  sudo systemctl enable monerod

  echo "Monero systemd service has been set up and enabled to start on reboot."
fi

# Optionally, run Monero manually after the build (runs in foreground)
read -p "Would you like to run monerod manually now? (yes/no): " run_now
if [[ "$run_now" == "yes" ]]; then
  echo "Starting monerod and syncing the blockchain..."
  ./build/Linux/master/release/bin/monerod --data-dir /root/.bitmonero --rpc-bind-ip 0.0.0.0 --rpc-bind-port 18081 --confirm-external-bind
fi
