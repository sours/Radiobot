------------------------------------------------------------------------------------------------
-- Default commands, for IRC and admin system
------------------------------------------------------------------------------------------------
PLUGIN.Name = "Default Commands"
PLUGIN.Description = "This plugin initializes general IRC commands, and admin system commands."

------------------------------------------

-- Basic commands

------------------------------------------
function CMD_ListPlugins(user,nick,mask,room,args,AllArgs,IsPm)
         Command.Reply("Found " .. table.Count(Command.Plugins) .. " loaded plugins:")
         
         for k,tbl in pairs(Command.Plugins) do
             Command.Reply(string.upper(tbl.Name).." ("..tbl.FilePath..")")
             Command.Reply(tbl.Description)
         end
end

Command.Register("PLUGINS" ,CMD_ListPlugins ,0,"PLUGINS - Lists all plugins.",true)

function CMD_Reload(user,nick,mask,room,args,AllArgs,IsPm)
         Command.LoadAll()
         Command.Reply("Reloaded all plugins!")
end

Command.Register("RELOADPLUGINS", CMD_Reload,0, "RELOADPLUGINS - Reloads all plugins.", true)

function CMD_Restart(user,nick,mask,room,args,AllArgs,IsPm)
         Command.Reply("Will restart bot!")
		 
         for k,v in pairs(bot.Servers) do
             v:SendQuit(AllArgs or "Restarting")
         end

         os.remove("loli.pid")

         --OS is nil on linux
         if os.getenv("OS") == "Windows_NT" then
            io.popen("cmd.exe /C RadioBot.bat")
            os.exit()
         else
            io.popen("./start")
            os.exit()
         end
end

Command.Register("RESTART", CMD_Restart, 0, "RESTART [reason] - Restarts bot.", true)

function CMD_ReloadConfig(user,nick,mask,room,args,AllArgs,IsPm)
         Command.Reply("Reloading config file..")
         bot.Config = util.LoadConfig("config.txt")
         Command.Reply("Reloading plugins...")
         Command.LoadAll()
         Command.Reply("Done!")
end

Command.Register("RELOADCONFIG", CMD_ReloadConfig,0, "RELOADCONFIG - Reloads the config file.", true)

function CMD_Memory(user,nick,mask,room,args,AllArgs,IsPm)
         local mem = math.floor(collectgarbage("count"))
         Command.Reply("Currently using " .. mem .. "kb of memory.")
end

Command.Register("MEMORY", CMD_Memory,0, "MEMORY - Shows the current memory usage of the bot.", true)

function CMD_Shutdown(user,nick,mask,room,args,AllArgs,IsPm)
         os.remove("loli.pid")
         os.exit()
end

Command.Register("SHUTDOWN", CMD_Shutdown,0, "SHUTDOWN - Immediately shuts down the bot.", true)

function CMD_Botinfo(user,nick,mask,room,args,AllArgs,IsPm)
         local CurOS = "Unix/Linux"
         CurOS = os.getenv("OS") or CurOS

         local mem = math.floor(collectgarbage("count"))
         
         Command.Reply("Bot directory: " .. lfs.currentdir())
         Command.Reply("Host OS: " .. CurOS)
         Command.Reply("Process ID: ".. (tostring(PID) or "Not avaivable"))
         Command.Reply("Memory usage: " .. mem .. "kb")
end

Command.Register("BOTINFO", CMD_Botinfo,0, "BOTINFO - Shows general information about the bot.", true)
------------------------------------------

-- IRC control commands

------------------------------------------
function CMD_ToggleReplyMode(user,nick,mask,room,args,AllArgs,IsPm)
         Command.SilentMode = not Command.SilentMode
         
         Command.Reply("Toggled reply mode!")
end

Command.Register("REPLYMODE" ,CMD_ToggleReplyMode ,0,"REPLYMODE - Toggles the current replymode. Either PRIVMSG or NOTICE.",true)

function CMD_SetPollRate(user,nick,mask,room,args,AllArgs,IsPm)
         if string.Trim(AllArgs) == "" then Command.Reply("The current poll rate is: " .. Command.SendInterval) return end
         local pollrate = tonumber(AllArgs)
         
         if not pollrate then Command.Reply("Invalid number!") return end
         
         Command.SendInterval = pollrate
         Command.Reply("Set new poll rate to " .. pollrate..".")
end

Command.Register("SETPOLLRATE" ,CMD_SetPollRate ,1,"SETPOLLRATE <seconds> - Sets the poll interval for spam protection.",true)




function CMD_Desc(user,nick,mask,room,args,AllArgs,IsPm)
         local cmd = string.upper(AllArgs)
         
         local cmdtbl = Command.Commands[cmd]
         
         if not cmdtbl then
            Command.Reply("No such command!")
            return
         end
         
         local extra = ""
         
         if cmdtbl.Admin then
		    if not Admin.IsAdmin(mask) then
			   Command.Reply("No such command!")
			   return
			end
			
            extra = " (Admin only)"
         end

         Command.Reply("Description: " .. cmdtbl.Desc..extra)
end

Command.Register("DESC", CMD_Desc, 1, "DESC <command> - Displays a description of 'command'", false)

function CMD_List(user,nick,mask,room,args,AllArgs,IsPm)
         local list = ""
		 local IsAdmin = Admin.IsAdmin(mask)
		 
         local num = 0
         for k,v in pairs(Command.Commands) do
			 
             local extra = ""
             
             if v.Admin then
                extra = " (Admin only)"
             end
             
			 if not v.Admin then
				list = list .. k..extra ..", "
				num = num + 1
			 elseif IsAdmin then 
			    list = list .. k..extra ..", "
				num = num + 1
			 end
         end

         Command.PollNotice(nick,"Listing all commands ("..num.." in list)")
         Command.PollNotice(nick,string.sub(list,1,-3))
         Command.PollNotice(nick,"Use DESC <command> to see the description of a command.")
end

Command.Register("LIST", CMD_List,0, "LIST - Displays a list of commands.", false)

function CMD_Pm(user,nick,mask,room,args,AllArgs,IsPm)
         local target = args[1]
         local msg = ""
         
         for k,v in pairs(args) do
             if k > 1 then
                msg = msg .. v .. " "
             end
         end

         msg = string.sub(msg,1,-2)

         Command.PollChat(target,msg)
         Command.PollNotice(nick,"PM'ed \""..target.."\" with: "..msg)
end

Command.Register("PM", CMD_Pm, 2, "PM <nick/room> <msg> - Sends a chat message.", true)

function CMD_Me(user,nick,mask,room,args,AllArgs,IsPm)
         local target = args[1]
         local msg = ""
         
         for k,v in pairs(args) do
             if k > 1 then
                msg = msg .. v .. " "
             end
         end

         msg = string.sub(msg,1,-2)

         Command.PollChat(target, string.char(1).."ACTION " .. msg .. string.char(1))
end

Command.Register("ME", CMD_Me, 2, "ME <nick/room> <msg> - Action goodness.", true)

function CMD_SetDebug(user,nick,mask,room,args,AllArgs,IsPm)
         Command.ReplyServer.Debug = not Command.ReplyServer.Debug
         
         if Command.ReplyServer.Debug then
            Command.Reply("Debug is now on.")
         else
            Command.Reply("Debug is now off.")
         end
end

Command.Register("DEBUG", CMD_SetDebug, 0, "DEBUG - Toggles debug for the current server.", true)

function CMD_SetNick(user,nick,mask,room,args,AllArgs,IsPm)
         Command.ReplyServer:SetNick(AllArgs)
         Command.Reply("Set new nick to '"..AllArgs.."'!")
end

Command.Register("SETNICK", CMD_SetNick, 1, "SETNICK <nick> - Changes the bots nick.", true)

function CMD_JoinRoom(user,nick,mask,room,args,AllArgs,IsPm)
         Command.ReplyServer:JoinRoom(AllArgs)
         Command.Reply("Joined room: " .. AllArgs)
end

Command.Register("JOIN", CMD_JoinRoom, 1, "JOIN <room> - Joins a room.", true)

function CMD_PartRoom(user,nick,mask,room,args,AllArgs,IsPm)
         Command.ReplyServer:LeaveRoom(AllArgs)
         Command.Reply("Left room: " .. AllArgs)
end

Command.Register("PART", CMD_PartRoom, 1, "PART <room> - Leaves a room.", true)

function CMD_Quit(user,nick,mask,room,args,AllArgs,IsPm)
         Command.ReplyServer:SendQuit(AllArgs or "bye!")
end

Command.Register("QUIT", CMD_Quit, 0, "QUIT <message> - Quits current server.", true)

------------------------------------------

-- Admin commands

------------------------------------------
function CMD_Login(user,nick,mask,room,args,AllArgs,IsPm)
         if not IsPm then Command.PollNotice(nick,"You have to send this command in PM!") return end

         print("'" .. AllArgs.."'")
         if AllArgs == bot.Config.LoginPass then
            bot.Admins[nick] = mask
            print(nick.." ("..mask..") logged in as admin.")
            Command.PollNotice(nick,"Logged in! (note that it doesn't write your update to admins.txt)")
         else
            Command.PollNotice(nick,"Wrong password!")
         end
end

Command.Register("LOGIN", CMD_Login, 1, "LOGIN <password> - Logs in with admin rights.", false)

function CMD_ListAdmins(user,nick,mask,room,args,AllArgs,IsPm)
         for nick,mask in pairs(bot.Admins) do
             Command.PollNotice(nick, nick.. " @ " .. mask)
         end
         
         Command.PollNotice(nick,"Listed " .. table.Count(bot.Admins) .. " admins.")
end

Command.Register("ADMIN_LIST", CMD_ListAdmins, 0, "ADMIN_LIST - Lists all admins.", true)