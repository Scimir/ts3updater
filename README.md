# TS3 Updater [x64 Linux]
# Will take care of your TS3 server updates!

This script only works with x64 installations. Tested on Ubuntu Server 18.04.03 LTS!
Only updates to newest stable TS3 version!

# What it does
- Checks current and newest stable version available
- Creates backup of your sqlitedb, which contains the most important data
- Updates your server if a newer version is available

# How to use
- Copy the folder containing the script into your teamspeak server directory
- Adjust paths in the config file
- Use chmod +x to make .sh files executable
- Run start_ts3update.sh 
OR
- Create a cronjob with crontab -e
- I recommend switching to the directory first: cd /(path to script/ && ./start_ts3update.sh

# Before you use this
- Never use root for this kind of scripts
- No guarantee for its functionality

# What it exactly does
- Extracts local version out of the CHANGELOG file
- Extracts newest version from https://files.teamspeak-services.com/releases/server/
- Compares local and newest version
- If a newer version is available the script looks up the downloadlink
- Downloads newest version with wget and extracts the .bzip2 file
- Stops server, backs up the db, copies updated files and restarts server

# FAQ
- Aren't there better ones? 
I hope there are :D
- Why would you write it yourself then?
After finding quite a few scripts, that either contain hidden features, cost money or have limited functionality in the free version I decided to write one on my own and share it
