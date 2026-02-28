# Codespace-Minecraft-Server
An easy way to set up a Minecraft Server for free using GitHub Codespaces! (Also supports [PrismarineJS/prismarine-web-client](https://github.com/PrismarineJS/prismarine-web-client))

This repository provides an easy way to set up a [Paper](papermc.io) Minecraft server on GitHub Codespaces with some preinstalled plugins like [ViaVersion](viaversion.com), [ViaBackwards](viaversion.com), and [ViaRewind](viaversion.com). It also has automatic [PrismarineJS/prismarine-web-client](https://github.com/PrismarineJS/prismarine-web-client) support because for the Minecraft server to be public, GitHub codespaces would need to port forward it via TCP, which I don't think is possible in the free version. If you want to play on the server, go to port forwarding and get the URL for port 8080 and play on the Minecraft server using [PrismarineJS/prismarine-web-client](https://github.com/PrismarineJS/prismarine-web-client). The server IP will be: ```wss://<codespaces URL without the https:// at the beginning>```

To begin, create a codespace using this repository and run this command: ```./start.sh```.
