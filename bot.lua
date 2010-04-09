---------------------------------------------------
--------------- BOT.lua ---------------------------
--- This file sets up the IRC bot and       -------
--- the command system.                     -------
---------------------------------------------------
---------------------------------------------------

bot = {}
bot.Servers = {}
bot.Debug = false

--Get config
bot.Config = util.LoadConfig("config.txt")
--Get admins
bot.Admins = util.LoadConfig("admins.txt")

if not bot.Config then
   print("[ERROR] Could not find config.txt!")
   return
end

if not bot.Admins then
   print("[WARNING] No admins.txt found, no admin commands will be avaivable.")
end

if bot.Debug then print("[DEBUG] Config table:") printtable(bot.Config) end

function ConnectAll()
         for k,v in pairs(bot.Servers) do
             v:Disconnect(bot.Config.Quitmsg or "Bye!")
         end
		 
         print("Connecting to all servers..")

         for k,srv in pairs(bot.Config.Servers) do
             print("Trying server " .. srv ..":"..bot.Config.Port.." ("..bot.Config.Timeout.."s)...")
    
             local new = IRC_NewClient(srv, bot.Config.Port, bot.Config.Timeout, bot.Debug)
             new:SetNick(bot.Config.Nick)
             new:SetUsername(bot.Config.Username)
             new:SetRealname(bot.Config.Realname)
    
             for k,room in pairs(bot.Config.Channels) do
                 new:JoinRoom(room)
             end

             local succ,err = new:Connect()
			 
             if succ then 
                print("Connection to " ..srv.." succeeded!")
                table.insert(bot.Servers,new)
             else
                print("Failed connection attempt to " .. srv .. "!")
             end
         end
end

function bot.OnConnect(srv)
         if bot.Config.JoinMsg then 
            for k,line in pairs(bot.Config.JoinMsg) do
                srv:SendRaw(line)
            end
         end
end

hook.Add("OnConnect","bot_AutoMsgHook",bot.OnConnect)


function StartMainLoop()
         ConnectAll()

         while IRC_Think() do
               hook.Call("Think")
         end
         
         print("No more active connections!")
end

---------------------------------------------------
-- Admin system - simplified
---------------------------------------------------
Admin = {}
function Admin.AddAdmin(nick,mask)
         bot.Admins[nick] = mask
end

function Admin.IsAdmin(match)
         for nick,mask in pairs(bot.Admins) do
             local pattern = mask:gsub("[%^%$%(%)%%%.%[%]%+%-]", "%%%1"):gsub("%*", ".*"):gsub("%?", ".")
             local f = match:find(pattern) --Allow wildcards
             if f and f > -1 then return true end
         end

         return false
end

---------------------------------------------------
-- Commands system
---------------------------------------------------
CurTime = os.time

Command = {}
Command.ReplyPoll = {}
Command.LastSend = CurTime()
Command.SendInterval = tonumber(bot.Config.PollRate) or 0.5

Command.SilentMode = false
Command.Plugins = {}
Command.Commands = {}

function Command.Register(cmd, func, NumArgs, desc, AdminOnly)
         if AdminOnly == nil then AdminOnly = true end

         cmd = string.upper(cmd)
         desc = desc or "None"
         NumArgs = NumArgs or 0

         local c = {}
         c.Cmd = cmd
         c.Func = func
         c.Desc = desc
         c.Admin = AdminOnly
         c.NumArgs = NumArgs

         Command.Commands[cmd] = c
end

function Command.Alias(alias, cmd)
         Command.Commands[alias] = Command.Commands[cmd]
end

function Command.UnloadAll()
         for cmd,tbl in pairs(Command.Commands) do
             Commands[cmd] = nil
             tbl = nil
         end

         Commands = {}

         for k,tbl in pairs(Command.Plugins) do
             if tbl.Unload then
                 tbl:Unload()
             end

             Command.Plugins[k] = nil
             tbl = nil
         end

         print("Unloaded all plugins!")
end

function Command.LoadAll()
         Command.UnloadAll()

         for k,name in pairs(file.OpenDir(bot.Config.PluginDir)) do
             if table.HasValue(bot.Config.PluginExtensions, file.GetExtension(name)) then
                if Command.LoadPlugin(bot.Config.PluginDir.."/"..name) then
                   print("Loaded plugin " .. name)
                end
             end
         end

         print("Loaded all plugins in folder '"..bot.Config.PluginDir.."'!")
end

function Command.LoadPlugin(path)
         local OldVar = PLUGIN
         PLUGIN = {Name="NoName",Description="None"}
         
         local WorkingPlugin = true
         local func, err = loadfile(path)

         if func then
            local succ,err,_ = pcall(func)
            
            if not succ then
               print("Errored loading plugin " ..path..": "..err)
               WorkingPlugin = false
            end
         else
            print("Errored loading plugin " ..path..": "..err)
            WorkingPlugin = false
         end

         PLUGIN.FilePath = path
         table.insert(Command.Plugins,PLUGIN)

         if PLUGIN.Load then
            PLUGIN:Load()
         end

         PLUGIN = OldVar
         
         return WorkingPlugin
end

function Command.Reply(msg,urgent)
         local cmd = "PRIVMSG"
         local target = Command.ReplyRoom
         if Command.SilentMode then cmd = "NOTICE" target = Command.ReplyNick end

         if urgent or Command.SendInterval <= 0 then
            Command.ReplyServer:SendRaw(cmd.." "..target.." :"..msg)
         else
            table.insert(Command.ReplyPoll, cmd.." "..target.." :"..msg)
         end
end

function Command.PollChat(target,msg)
         if Command.SendInterval <= 0 then
            Command.ReplyServer:SendRaw("PRIVMSG " .. target .. " :"..msg)
         else
            table.insert(Command.ReplyPoll, "PRIVMSG " .. target .. " :"..msg)
         end
end

function Command.PollNotice(target,msg)
         if Command.SendInterval <= 0 then
            Command.ReplyServer:SendRaw("NOTICE " .. target .. " :"..msg)
         else
            table.insert(Command.ReplyPoll, "NOTICE " .. target .. " :"..msg)
         end
end

function Command.SpamProtection()
         if #Command.ReplyPoll == 0 then return end

         if CurTime() - Command.LastSend > Command.SendInterval then
            local k = table.GetFirst(Command.ReplyPoll)
            Command.ReplyServer:SendRaw(Command.ReplyPoll[k])
            table.remove(Command.ReplyPoll,k)

            Command.LastSend = CurTime()
         end
end

hook.Add("Think","bot_SpamProtection",Command.SpamProtection)

function Command.SetupReply(srv,nick,room)
         Command.ReplyServer = srv
         Command.ReplyNick = nick
         Command.ReplyRoom = room
end

function Command.CommandHandler(srv, user, mask, room, nick, msg, IsPm)
         local prefix = string.sub(msg,1,string.len(bot.Config.CmdPrefix))

         if prefix ~= bot.Config.CmdPrefix then return end

         if IsPm then
            Command.SetupReply(srv,nick,nick)
         else
            Command.SetupReply(srv,nick,room)
         end

         local Split = string.Explode(msg," ")
         if not Split[1] then return end

         local cmd = string.upper(string.sub(Split[1],string.len(bot.Config.CmdPrefix) + 1))
         Split[1] = ""

         if not Command.Commands[cmd] then print("["..room.."] "..nick.." tried unknown command '" .. cmd.."'") return end
         local CmdTbl = Command.Commands[cmd]

         if CmdTbl.Admin and not Admin.IsAdmin(mask) then
            print("["..room.."] " .. nick .. " was refused command " .. cmd..": Needs admin rights.")
            return
         end

         local args = {}
         local AllArgs = ""

         if table.Count(Split) > 1 then
            for k,v in pairs(Split) do
                if string.Trim(v) ~= "" then
                   table.insert(args,string.Trim(v))
                end
            end

            AllArgs = string.Implode(args," ")
          end

          if table.Count(args) < CmdTbl.NumArgs then
             print("Not enough arguments!")
             Command.Reply("Not enough arguments!")
             print("["..room.."] " .. nick .. " was refused command " .. cmd..": Not enough arguments.")
             return
          end

          local succ,err,retval = pcall(CmdTbl.Func,user,nick,mask,room,args,AllArgs,IsPm)

          if not succ then
            print("["..room.."] " .. nick .. " errored executing command " .. cmd..": "..err)
            Command.Reply("ERROR in command '"..cmd.." "..AllArgs.."': " .. err)
          else
            print("["..room.."] " .. nick .. " executed command: '" .. cmd.." "..AllArgs.."'")
          end
end

hook.Add("RecieveChat","bot_CommandHandler",Command.CommandHandler)

---------------------------------------------------
-- Hand control to the main loop
---------------------------------------------------
Command.LoadAll()
StartMainLoop()
