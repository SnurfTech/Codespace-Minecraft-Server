#!/usr/bin/env bash

export SERVER_START="java -Xms7168M -Xmx7168M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar --nogui"

mkdir server
cd server

curl -L https://fill-data.papermc.io/v1/objects/51157c86280ef0c9f5a10f775b6ebb516dfcfe4f67820305847eccaae31df944/paper-1.21.11-123.jar -o server.jar

$SERVER_START
echo "eula=true" > eula.txt
sed -i 's|online-mode=true|online-mode=false|g' server.properties
mkdir -p plugins
cd plugins
wget https://hangarcdn.papermc.io/plugins/ViaVersion/ViaVersion/versions/5.7.1/PAPER/ViaVersion-5.7.1.jar
wget https://hangarcdn.papermc.io/plugins/ViaVersion/ViaBackwards/versions/5.7.1/PAPER/ViaBackwards-5.7.1.jar
wget https://hangarcdn.papermc.io/plugins/ViaVersion/ViaRewind/versions/4.0.14/PAPER/ViaRewind-4.0.14.jar

echo "If you would like to add any custom plugins to the server, you can now. (Using URLs.) When you are done, type \"done\"."

links=()

while true; do
    read -p "Link: " input
    
    # Check if the user wants to stop (case-insensitive)
    if [[ "${input,,}" == "done" ]]; then
        break
    fi

    # Check if the input is empty
    if [[ -z "$input" ]]; then
        echo "Please enter a valid link or 'done'."
        continue
    fi

    # Add the link to our array
    links+=("$input")
done

for link in "${links[@]}"; do
    wget $link
done

cd ..
mkdir -p world/datapacks
cd world/datapacks

echo "If you would like to add any datapacks to the server, you can now. (Using URLs.) When you are done, type \"done\"."

links=()

while true; do
    read -p "Link: " input
    
    # Check if the user wants to stop (case-insensitive)
    if [[ "${input,,}" == "done" ]]; then
        break
    fi

    # Check if the input is empty
    if [[ -z "$input" ]]; then
        echo "Please enter a valid link or 'done'."
        continue
    fi

    # Add the link to our array
    links+=("$input")
done

for link in "${links[@]}"; do
    wget $link
done

cd ../..
nvm install 24
nvm use 24
nvm alias default 24
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
