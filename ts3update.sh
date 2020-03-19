#!/bin/bash

## TeamSpeak3 Server Updater ##


## variables

# server path
SERVER_DIR="$(cat config_ts3update.txt | cut -s -d":" -f2 | head -1)"

# local server version
LOCAL_VER=""

# newest server version available
NEWEST_VER=""

## change working directory
cd $SERVER_DIR

#start logging to file
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>${SERVER_DIR}/ts3update_logs/ts3update.log 2>&1

## check internet connection

function checkConnection()
{
	if ping -q -c 1 -W 1 teamspeak.com >/dev/null; then
		echo "The network is up, script starting"
		return 0
	else
		echo "The network is down, exiting"
		return 1
	fi
}

## get local server version

function checkLocalVersion()
{

		grep -m 1 -a  "Release" CHANGELOG > LOCAL_VERSION.txt
	 
		LOCAL_VER=$(cut -d" " -f4 LOCAL_VERSION.txt)
	 
		rm LOCAL_VERSION.txt
}

## get newest available version

function checkNewestVersion()
{
	wget -t 1 -T 3 'https://files.teamspeak-services.com/releases/server/' -q -O - | grep -Ei 'a href="[0-9]+' | grep -Eo ">(.*)<" | tr -d ">" | tr -d "<" | uniq | sort -V -r > NEWEST_VERSION.txt

	NEWEST_VER=$(head -1 NEWEST_VERSION.txt)
	
	rm NEWEST_VERSION.txt

}

## compare versions

function compareVersions()
{
	
	echo "Local version is" $LOCAL_VER
	echo $LOCAL_VER > local.txt
	echo "Newest version is" $NEWEST_VER
	echo $NEWEST_VER > newest.txt
	
	diff -s local.txt newest.txt 1>/dev/null && rm local.txt && rm newest.txt
	if [[ $? == "0" ]]
		then
			echo "The server is up to date. Exiting..."
			exit
		else
			echo "Newer version available. Starting download..."
			downloadNewestVersion
	fi
}

function downloadNewestVersion()
{
	wget "https://files.teamspeak-services.com/releases/server/${NEWEST_VER}/teamspeak3-server_linux_amd64-${NEWEST_VER}.tar.bz2" -P $SERVER_DIR
}

function installNewestVersion()
{
#delete old backup
rm -d -r ${SERVER_DIR}/Backup

#shutdown server server first. be sure to update when nobody is online!
${SERVER_DIR}/ts3server_startscript.sh stop
echo "Waiting 5s for server to stop"
sleep 5s

#backs up the db
echo "Creating Backup in ${SERVER_DIR}/Backup"
mkdir ${SERVER_DIR}/Backup
cp ${SERVER_DIR}/ts3server.sqlitedb ${SERVER_DIR}/Backup

#decompressing and extracting the update files
tar -xvjf *.tar.bz2

cp -r ${SERVER_DIR}/teamspeak3-server_linux_amd64/* ${SERVER_DIR}
rm -d -r ${SERVER_DIR}/teamspeak3-server_linux_amd64

#checking EULA file

#start server
${SERVER_DIR}/ts3server_startscript.sh start

#clean up
rm ${SERVER_DIR}/*tar.bz2

}
## the actual program

checkConnection
if [[ $? -eq 0 ]]
	then
		checkLocalVersion
		checkNewestVersion
		
		#script will stop if server is up to date after version check
		compareVersions
		
		#will also check for eula file
		installNewestVersion
		
	else
	echo "no connection to the teamspeak servers!"
	
fi

#stop logging, save log file
exec 1>&-

