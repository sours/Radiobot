#!/bin/sh
mypid=`cat /home/music/RadioBot/loli.pid 2>/dev/null`
myrealpid=`pidof -sx init.lua 2>/dev/null`
 
if [ ! -f /home/music/RadioBot/loli.pid -o $mypid -eq $myrealpid ]; then exit 2; # Stop here if the bot is running or has shut down cleanly.
else lua /home/music/RadioBot/init.lua 1>/dev/null 2>&1; exit 0; # Else since the pid file exists and the process is not running, start the bot.
fi
