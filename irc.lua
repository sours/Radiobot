---------------------------------------------------
--------------- IRC.lua ---------------------------
--- This file sets up the IRC server object -------
----------- This lib needs hook.lua ---------------
---------------------------------------------------

--object vars
local irc = {}
irc.__index = irc

local ircs = {}

irc.Nick = "LuaBot"
irc.AddToNick = ""
irc.Username = "lua_bot"
irc.Realname = "Bot Robotson"

irc.Address = ""
irc.Port = 6667
irc.Timeout = 10
irc.Channels = {}
irc.MaxBlockTime = 0.5

irc.Debug = false
irc.Connected = false

--global functions
function IRC_NewClient(addr,port,timeout,debug)
         local n = {}
         setmetatable(n,irc)

         --defaults
         n.Address = addr or ""
         n.Port = port or 6667
         n.Timeout = timeout or 10
         n.Debug = debug

         n.Socket = socket.tcp()

         table.insert(ircs,n)
         return n
end

function IRC_Think()
         local connected = false

         for k,v in pairs(ircs) do
             if v.Connected then
                connected = true
                v:Think()
             end
         end
         
         return connected
end


function IRC_RecieveLine(connection)
      connection:timeout(0)   -- do not block
      local s, status = connection:receive(2^10)
     
      if status == "timeout" then
        coroutine.yield(connection)
      end

      return s, status
end

--methods
function irc:Think()
         if not self.Socket then
            self.Connected = false
            return
         end

         --if not self.RecieveThread then
         --   self.RecieveThread = coroutine.Create()
         --end

         local line = self.Socket:receive("*l")
         
         if not line then return end
         line = string.Trim(line)
         if line == "" then return end

         if self.Debug then print(line) end
         hook.Call("RecieveLine",line)

         --send into parser
         local prefix, cmd, params, msg = self:Parse(line)
         
         --Handle parsed message
         self:Handle(prefix,cmd,params,msg)
end

--IRC
function irc:Connect(addr,port,timeout)
         self.Address = addr or self.Address
         self.Port = port or self.Port
         self.Timeout = timeout or self.Timeout
         
         self.Socket:settimeout(self.Timeout)
         succ, err = self.Socket:connect(self.Address,self.Port)
         self.Socket:settimeout(self.MaxBlockTime,"t") --Lets any script using this 'think' every 0.2 seconds
         self.Socket:settimeout(self.MaxBlockTime,"b")
         
         self.Connected = succ

         if succ then
            self:Auth()
         else
            hook.Call("FailConnect",self)
         end

         return succ, err
end

function irc:Disconnect(msg)
         if msg then
		    self:SendRaw("QUIT :" ..msg)
		 end
		 
         self.Socket:close()
         self.Connected = false

         if self.Debug then
            print("Disconnected from " .. self.Address .."!")
         end
         
         hook.Call("OnDisconnect",self)
end

function irc:IsConnected()
         return self.Connected
end

irc.LastSend = os.time()

function irc:SendRaw(msg)
         if self.Debug then
            print("Sent message: " .. msg)
         end

         self.Socket:send(msg.."\r\n")
         irc.LastSend = os.time() - irc.LastSend
end

function irc:JoinRoom(room)
         self.Channels[room] = {}
         
         if self.Connected then
            self:SendRaw("JOIN " .. room)
         end
end

function irc:LeaveRoom(room)
         self.Channels[room] = nil

         if self.Connected then
            self:SendRaw("PART " .. room)
            print("Left room " .. room)
            hook.Call("OnMePart",self,room)
         end
end

function irc:Parse(line)
         --Parse line
         local prefix, cmd, params, msg = "","",{},""
         local push = 0
         
         local ColonSplit
         local Split = string.Explode(line," ")

         if string.find(line,":") == 1 then
            prefix = string.sub(Split[1],2)
            push = 1

            ColonSplit = string.Explode(string.sub(line,2),":")
         else
            prefix = false
            ColonSplit = string.Explode(line,":")
         end

         cmd = Split[1+push]
         msg = ""

         for k,v in pairs(ColonSplit) do
             if k > 1 then
                msg = msg .. v .. ":"
             end
         end

         msg = msg:sub(1,-2)

         local Split2 = string.Explode(ColonSplit[1]," ")

         for k,v in pairs(Split2) do
             if k > 1 + push then
                if string.Trim(v) ~= "" then
                   table.insert(params,string.Trim(v))
                end
             end
         end

         return prefix, cmd, params, msg
end

function irc:ParsePrefix(prefix)
         if not prefix then return end

         local NickSplit = string.Explode(prefix,"!")
         nick = NickSplit[1]

         local HostSplit = string.Explode(NickSplit[2],"@")
         user = HostSplit[1]
         mask = HostSplit[2]
         
         return nick, user, mask
end

function irc:Auth()
         self:SendRaw("USER " .. self.Username .. " * 0 :"..self.Realname)
         self:SendRaw("NICK " .. self.Nick)
end

function irc:Handle(prefix, cmd, params, msg)
         local NumArgs = #params

         if self.Debug then
            local strParams = "{"
            for k,v in pairs(params) do
                strParams = strParams..v..","
            end

            strParams = string.sub(strParams,1,-2).."}"

            print("Prefix: '" .. tostring(prefix) .. "' Cmd: '" .. cmd .. "' Params: " .. strParams .. " Msg: '" ..msg.."'")
         end

         --notice
         if cmd == "NOTICE" then

            --auth
            --if params[1] == "AUTH" and string.find(string.lower(msg),"checking ident") then

            --end

            --pong that ping
         elseif cmd == "PING" then
            self:SendRaw("PONG " .. msg)

            --handle privmsgs
         elseif cmd == "PRIVMSG" then
            local nick,user,mask = self:ParsePrefix(prefix)

            local room = params[1] or "GLOBAL"

            if self.Debug then print("["..room.."] "..user.."@"..mask.." " ..nick..": " ..msg) end
            
            local IsPm = false

            if room == self.Nick then IsPm = true end

            hook.Call("RecieveChat",self,user,mask,room,nick,msg,IsPm)
         elseif cmd == "JOIN" then
            local nick,user,mask = self:ParsePrefix(prefix)
            local room = params[1] or "GLOBAL"
            hook.Call("OnJoin",self,nick,user,mask,room)

         elseif cmd == "PART" then
            local nick,user,mask = self:ParsePrefix(prefix)
            local room = params[1] or "GLOBAL"
            hook.Call("OnJoin",self,nick,user,mask,room)

            --errors
         elseif cmd == "ERROR" then
            if string.find(string.lower(msg),"closing link") then
               print(self.Address .. " closed link! Message: " .. msg)
               self:Disconnect()
            end

            --Pure info print
         elseif cmd == "001" or cmd == "002" or cmd == "003" or cmd == "401" then
            print(msg)

            --Join channels
         elseif cmd == "005" then
            hook.Call("OnConnect",self)
            
            for room,_ in pairs(self.Channels) do
                self:SendRaw("JOIN " .. room)
            end

            --nick already in use
         elseif cmd == "433" then
            self.AddToNick = self.AddToNick .. "_"
            print("Nick already in use, trying with " ..  self.Nick ..self.AddToNick)
            self:SendRaw("NICK " ..self.Nick ..self.AddToNick)
         end
end

function irc:SendChat(room,msg) self:SendRaw("PRIVMSG " .. room .." :"..msg) end
function irc:SendNotice(room,msg) self:SendRaw("NOTICE " .. room .." :"..msg) end
function irc:SendQuit(msg) self:SendRaw("QUIT :" ..msg) self:Disconnect() end
function irc:SetMode(room,modes,args) self:SendRaw("MODE "..room.." "..modes.." "..args) end

--sets
function irc:SetNick(nick)
         self.Nick = nick
         
         if self.Connected then
            self:SendRaw("NICK "..self.Nick)
         end
end

function irc:SetTimeout(timeout) self.Socket:settimeout(timeout) end
function irc:SetDebug(bool) self.Debug = bool end
function irc:SetUsername(usr) self.Username = usr end
function irc:SetRealname(name) self.Realname = name end