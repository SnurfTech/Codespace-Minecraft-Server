#!/bin/bash

export SERVER_START="java -Xmx2G -jar forge-1.20.1-47.4.16.jar nogui"

mkdir server
cd server

wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.16/forge-1.20.1-47.4.16-installer.jar
yes | sdk install java 17.0.10-tem
sdk use java 17.0.10-tem
java -jar forge-1.20.1-47.4.16-installer.jar --installServer
rm forge-1.20.1-47.4.16-installer.jar

echo "eula=true" > eula.txt
mkdir -p mods
cd mods

wget https://mediafilez.forgecdn.net/files/4587/214/player-animation-lib-forge-1.0.2-rc1%2B1.20.jar
wget https://cdn.modrinth.com/data/8BmcQJ2H/versions/HVdLnQMI/geckolib-forge-1.20.1-4.8.3.jar
wget https://cdn.modrinth.com/data/t5W7Jfwy/versions/SQpqSgAE/Pehkui-3.8.2%2B1.20.1-forge.jar
wget https://cdn.modrinth.com/data/oaG6aa1j/versions/u7GegV7U/kleiders_custom_renderer-7.4.1-forge-1.20.1.jar
wget https://cdn.modrinth.com/data/gzevkJbM/versions/QMpCACei/photon-forge-1.20.1-1.1.0.jar

cd ..
echo "stop" | $SERVER_START
sed -i 's|online-mode=true|online-mode=false|g' server.properties

npm install -g bun
wget https://github.com/zardoy/mwc-proxy/raw/refs/heads/main/bun/ws-proxy.ts
sed -i 's|const THIS_WS_PORT = 80|const THIS_WS_PORT = 8080|g' ws-proxy.ts

echo "cd server" >> ~/.bashrc
echo "bun run ws-proxy.ts > /dev/null 2>&1 &" >> ~/.bashrc
echo "gh codespace ports visibility 8080:public -c $CODESPACE_NAME" >> ~/.bashrc
echo "$SERVER_START" >> ~/.bashrc
echo "gh codespace stop -c $CODESPACE_NAME" >> ~/.bashrc

echo "Now, whenever you stop the Minecraft server with the stop command, the GitHub codespace will also stop running. And if you restart the codespace, the Minecraft server will automatically start running. The Minecraft server will now be started."
sleep 3
$SERVER_START
