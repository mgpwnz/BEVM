#!/bin/bash
# Default variables
function="install"
version=v0.1.1
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in|--install)
            function="install"
            shift
            ;;
        -un|--uninstall)
            function="uninstall"
            shift
            ;;
	    -up|--update)
            function="update"
            shift
            ;;
        *|--)
		break
		;;
	esac
done
install() {
sudo apt update &> /dev/null
apt-get install protobuf-compiler -y
apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq
sleep 3
sudo apt install wget -y &> /dev/null
cd $HOME
mkdir subspace_adv
#download binary
wget https://github.com/btclayer2/BEVM/releases/download/testnet-${version}/bevm-${version}-ubuntu20.04 &> /dev/null
sleep 1
mkdir bevm_node
sudo mv bevm-${version}-ubuntu20.04 /roo/bevm_node/bevm
sudo chmod +x /root/bevm_node/bevm
# add var
echo -e "\e[1m\e[32m2. Enter BEVM EVM ADDRESS \e[0m"
read -p "EVM ADDRESS : " NODE_NAME

echo -e "\e[1m\e[92m EVM ADDRESS: \e[0m" $NODE_NAME

sleep 1
#create service node
    echo "[Unit]
Description=BEVM Node Service

[Service]
Type=simple
User=$USER
ExecStart=/root/bevm_node/bevm  ---chain=testnet --name="$NODE_NAME" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
Restart=always
RestartSec=0

[Install]
WantedBy=multi-user.target
    " > $HOME/bevm.service

    sudo mv $HOME/bevm.service /etc/systemd/system

# Enabling services
    sudo systemctl daemon-reload
    sudo systemctl enable bevm.service

# Starting services
    sudo systemctl restart bevm.service
#logs
    echo -e "\e[1m\e[32mTo check the BEVN Node Logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u bevm.service -f \n \e[0m" 

}
uninstall() {
read -r -p "You really want to delete the node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
    sudo systemctl disable bevm.service
    sudo rm /etc/systemd/system/bevm.service 
    sudo rm -rf /root/bevm_node
    echo "Done"
    cd $HOME
    ;;
    *)
        echo Сanceled
        return 0
        ;;
esac
}
update() {
cd $HOME
sudo apt update &> /dev/null
#download cli
wget https://github.com/btclayer2/BEVM/releases/download/testnet-${version}/bevm-${version}-ubuntu20.04 &> /dev/null
sleep 1
sudo mv bevm-${version}-ubuntu20.04 /roo/bevm_node/bevm
sudo chmod +x /root/bevm_node/bevm
sleep 1
# Enabling services
    sudo systemctl daemon-reload
# Starting services
    sudo systemctl restart bevm.service
echo -e "Your subspace node \e[32mUpdate\e[39m!"
cd $HOME
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function