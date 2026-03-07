export SERVER_START="java -Xms7168M -Xmx7168M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar --nogui"
export VIAVERSION_VERSION="$(curl -sL https://hangar.papermc.io/ViaVersion/ViaVersion/versions | grep -oP "[0-9]+\.[0-9]+\.[0-9]+<" | grep -P "^5" | tr -d "<" | sort -V | tail -n 1)"
export VIABACKWARDS_VERSION="$(curl -sL https://hangar.papermc.io/ViaVersion/ViaBackwards/versions | grep -oP "[0-9]+\.[0-9]+\.[0-9]+<" | grep -P "^5" | tr -d "<" | sort -V | tail -n 1)"
export SKRIPT_VERSION="$(curl -sL https://hangar.papermc.io/SkriptLang/Skript/versions | grep -oP "[0-9]+\.[0-9]+\.[0-9]+<" | grep -P "^2" | tr -d "<" | sort -V | tail -n 1)"
export PAPER_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]')
export PAPER_BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION} | jq -r '.builds[-1]')
export PAPER_JAR_NAME="paper-${PAPER_VERSION}-${PAPER_BUILD}.jar"

mkdir server
cd server

wget https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}/builds/${PAPER_BUILD}/downloads/${PAPER_JAR_NAME} -O server.jar

$SERVER_START
echo "eula=true" > eula.txt
sed -i 's|online-mode=true|online-mode=false|g' server.properties
mkdir -p plugins
cd plugins
wget https://hangarcdn.papermc.io/plugins/ViaVersion/ViaVersion/versions/$VIAVERSION_VERSION/PAPER/ViaVersion-$VIAVERSION_VERSION.jar
wget https://hangarcdn.papermc.io/plugins/ViaVersion/ViaBackwards/versions/$VIABACKWARDS_VERSION/PAPER/ViaBackwards-$VIABACKWARDS_VERSION.jar
wget https://hangercdn.papermc.io/plugins/SkriptLand/Skript/versions/$SKRIPT_VERSION/PAPER/Skript-$SKRIPT_VERSION.jar
wget https://api.spiget.org/v2/resources/59556/download -O EnchantmentSolution.jar
wget https://api.spiget.org/v2/resources/59556/download -O CrashAPI.jar
echo "stop" | $SERVER_START

cd EnchantmentSolution
sed -i '/enchanting_table:/,/anvil:/ s/custom_gui: .*/custom_gui: true/' config.yml
sed -i '/anvil:/,/grindstone:/ s/custom_gui: .*/custom_gui: false/' config.yml
sed -i '/grindstone:/,/max_enchantments:/ s/custom_gui: .*/custom_gui: false/' config.yml
sed -i '/enchanting_table:/,/anvil:/ s/level_fifty: .*/level_fifty: false/' config.yml
sed -i 's/reset_on_reload: .*/reset_on_reload: false/' config.yml
sed -i 's/on_login: .*/on_login: false/' config.yml
sed -i '/custom_enchantments:/,$ s/    enabled: true/    enabled: false/g' enchantments.yml

cd ../Skript/scripts
cat << EOF > wall_fix.sk
on join:
    # Use a tiny delay (1 tick) to ensure the player entity is fully loaded
    wait 1 tick
    execute console command "attribute %player% scale base set 0.97"
EOF
cd ..

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

echo "Now, if you restart the codespace, the Minecraft server will automatically start running. The Minecraft server will now be started."
sleep 3
$SERVER_START
