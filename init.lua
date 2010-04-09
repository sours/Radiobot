#! /usr/bin/lua
---------------------------------------------------
--------------- INIT.lua --------------------------
--- This file loads all required resources --------
--- that the bot needs.                    --------
---------------------------------------------------

print("Loading LuaSocket...")
socket = require("socket")
http = require("socket.http")

print("Loading LuaFileSystem...")
require("lfs")

print("Loading LuaGetpid...")
require("LuaGetpid")

print("Loading lua utility libraries...")

for name in lfs.dir("./lualibs") do
	if name ~= "." and name ~= ".." then
		dofile("./lualibs/"..name)
	end
end

print("Loading IRC library...")
dofile("irc.lua")

print("Creating PID file...")
local pidfile, error = io.open("radiobot.pid", "w+")

if not pidfile then
   print("Unable to create pid file! "..error)
   return
end

PID = getpid()
pidfile:write(tostring(PID))
pidfile:close()

print("Starting bot from bot.lua:")
dofile("bot.lua")
