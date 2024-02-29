#!/bin/bash
# Default variables
function="install"
version=v0.1.3
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
mkdir .bevm
#download binary
#wget https://github.com/btclayer2/BEVM/releases/download/testnet-${version}/bevm-${version}-ubuntu20.04 &> /dev/null
wget https://github.com/btclayer2/BEVM/releases/download/testnet-${version}/bevm-${version}-ubuntu20.04-x86_64.tar.gz && \
tar -xvf $HOME/bevm-${version}-ubuntu20.04-x86_64.tar.gz
rm -rf $HOME/bevm-${version}-ubuntu20.04-x86_64.tar.gz
sleep 1
sudo mv bevm-${version}  /usr/local/bin/bevm
sudo chmod +x /usr/local/bin/bevm
# add var
echo -e "\e[1m\e[32m2. Enter BEVM ADDRESS \e[0m"
read -p "BEVM ADDRESS : " NODE_NAME

sleep 1
#create service node
    echo "[Unit]
Description=BEVM Node Service

[Service]
Type=simple
User=$USER
ExecStart=bevm  --chain=testnet --port=30444 --name=$NODE_NAME --base-path=/root/.bevm --pruning=archive --telemetry-url 'wss://telemetry.bevm.io/submit 0'
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
    sudo systemctl stop bevm.service
    sudo systemctl disable bevm.service
    sudo systemctl daemon-reload
    sudo rm /etc/systemd/system/bevm.service 
    sudo rm -rf /root/.bevm
    sudo rm /usr/local/bin/bevm
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
#wget https://github.com/btclayer2/BEVM/releases/download/testnet-${version}/bevm-${version}-ubuntu20.04 &> /dev/null
wget https://github.com/btclayer2/BEVM/releases/download/testnet-${version}/bevm-${version}-ubuntu20.04-x86_64.tar.gz && \
tar -xvf $HOME/bevm-${version}-ubuntu20.04-x86_64.tar.gz
rm -rf $HOME/bevm-${version}-ubuntu20.04-x86_64.tar.gz
sleep 1
sudo mv bevm-${version} /usr/local/bin/bevm
sudo chmod +x /usr/local/bin/bevm
sleep 1
# Enabling services
    sudo systemctl daemon-reload
# Starting services
    sudo systemctl restart bevm.service
echo -e "Your BEVM node \e[32mUpdate\e[39m!"
cd $HOME
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function