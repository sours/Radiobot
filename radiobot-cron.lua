#! /usr/bin/lua
 
local pidfile = io.open("/home/music/RadioBot/loli.pid")
 
--if the file doesn't exist, don't do anything
if not pidfile then return end
 
--read pid from file
local pid = pidfile:read("*a")
pidfile:close()
 
--get running pid
local pidof, err = io.popen("pidof -sx init.lua 2>/dev/null")
if not pidof then print(err) return end
 
local realpid = pidof:read("*a")
pidof:close()
 
--end here if the pid matches the pid of the running script 'init.lua'
if tonumber(realpid) == tonumber(pid) then return end
 
--if we came this far, it's time to restart the bot.
--The pid file is there, but the bot isn't running.
io.popen("lua /home/music/RadioBot/init.lua 1>/dev/null 2>&1")
