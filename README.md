***How to Run a Monero Node, and make your own RPC with These Commands***

***Here is a quick guide to set up and run your Monero node using the provided script and repository:***

Clone the Monero Repository: First, clone the Monero repository from CoreConnect-dev:
```bash
git clone https://github.com/CoreConnect-dev/monero
```

***Navigate to the Monero Directory: Change into the monero directory:***
```bash
cd monero
```

***Make the Script Executable: Ensure that the setup script is executable by running the following command:***
```bash
chmod +x setup_monero_node.sh
```

***Run the Setup Script: Now, run the script to install dependencies, build Monero, and configure the node:***
```bash
./setup_monero_node.sh
```

**Recommendation:** When prompted, it's recommended to choose "yes" for both options (setting up the systemd service and running Monero manually). This will allow the node to run automatically after reboot and start syncing the blockchain right away.
Don’t worry if your server shuts down. The Monero node will resume syncing from where it left off when it starts again.

***Commands to Check If Your Node Is Running and Syncing***

After setting up the node, you can use the following commands to check its status, RPC, and network connectivity.

***1. Check if Your Node is Connected to the XMR Network***
You can use the following curl command to check if your node is connected to the Monero network and gathering blockchain info:
```bash
curl http://127.0.0.1:18081/get_info
```

This will return a JSON object with information such as:

Height: The current block height your node has synced to.
Difficulty: The current difficulty of the Monero network.
Status: Should return OK if the node is functioning correctly.

***2. Check Monero Node Sync Status***
To check if your node is syncing properly, you can view logs to see real-time block syncing:
```bash
tail -f /root/.bitmonero/bitmonero.log
```
This will show you the blocks your node is syncing with and the current progress.

***3. Get RPC Information for External Access***
If you have configured RPC access and wish to use it externally or for wallet integration, use the following curl command to test RPC functionality (assuming your node is bound to 0.0.0.0 for external access):
```bash
curl http://<your-node-ip>:18081/get_info
```
Replace <your-node-ip> with your server's external IP address. This command will return the current status of your Monero node, including the block height, syncing status, and other relevant information.

***4. Get Peer Information***
You can retrieve the list of peers connected to your node using the following command:
```bash
curl http://127.0.0.1:18081/get_peer_list
```
This will give you a list of IP addresses and other details of nodes that are connected to your Monero node, helping you verify that it's actively communicating with the Monero network.

***5. Check the Systemd Service Status (If Enabled)***
To verify that the Monero node is running as a systemd service and will start automatically on reboot, use this command:
```bash
sudo systemctl status monerod
```

If it shows active (running), your node is functioning correctly. If the node isn’t running, you can start it manually with:
```bash
sudo systemctl start monerod
```

***6. Using Your Monero Node with the GUI Wallet***
Steps to Connect the GUI Wallet to Your Node:
Open the Monero GUI Wallet: Launch the Monero GUI Wallet on your local machine.

Select "Advanced" Mode: When setting up your wallet, choose Advanced Mode. This allows you to customize your connection settings.

Go to Settings -> Node: In the Monero GUI, navigate to the "Settings" tab and select the Node option.

Connect to a Remote Node:

Choose Remote node.
In the Remote node address, input your server’s external IP and the RPC port 18081. For example:
```bash
<your-node-ip>:18081
```
No Authentication Needed: Since there is no RPC authentication, you don't need to input a username or password.
Start Syncing: Once connected, the wallet will use your node to sync with the Monero blockchain, allowing you to send and receive transactions without relying on third-party nodes.


Alternatively, you can also add a username and a password by modifying the systemd file, for that you need to navigate to the file with:

```bash
sudo nano /etc/systemd/system/monerod.service
```

And then change the file content with this content, and change myuser:mypassword for your username and password.

```
[Unit]
Description=Monero Full Node
After=network-online.target
Wants=network-online.target

[Service]
User=root
WorkingDirectory=/root/monero
ExecStart=/root/monero/build/Linux/master/release/bin/monerod --data-dir /root/.bitmonero --rpc-bind-ip 0.0.0.0 --rpc-bind-port 18081 --rpc-login myuser:mypassword --confirm-external-bind --non-interactive
Restart=on-failure
RestartSec=10
TimeoutSec=300

[Install]
WantedBy=multi-user.target
```

Save the changes with CTRL+O, press enter, then leave with CTRL+X.

Reload and restart systemctl with the following commands:

```bash
sudo systemctl daemon-reload
```
```bash
sudo systemctl restart monerod
```
```bash
sudo systemctl enable monerod
```

You can then test the connection with:

```bash
curl -u myuser:mypassword http://<your-node-ip>:18081/get_info
```
