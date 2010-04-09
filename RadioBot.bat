echo off
color 02
CD binaries
TITLE IRCBot
cls

echo loading lua interpreter from binaries/lua51.exe...
echo -------------------------
lua51.exe ../init.lua
echo -------------------------
echo lua51.exe left control.
pause