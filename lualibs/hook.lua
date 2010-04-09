-------------------------------
--Hook library--------------
-------------------------------
hook = {}
hook.Hooks = {}

--Default hooks, for reference
hook.HookNames = {"Think",
				  "RecieveLine", --server,line //done
				  "RecieveChat", --server,user,mask,room,nick,msg //done
				  "PrivateMessage", --server, from, msg
				  "OnMeJoin", -- server, chan //done
				  "OnJoin", --server,nick,user,mask,room //done
				  "OnMePart", --server, chan //done
				  "OnPart", --server, chan,nick,msg
				  "OnConnect", -- server,port
				  "FailConnect", -- server,port
				  "OnKick", --server,chan,nick,kicker
				  "NickChange", --server,old nick, new nick
				  "OnQuit",--server,nick, msg
				  "OnBan"} --server,nick,banner,reason

function hook.Add(HookName, ID, func)
		 if not hook.Hooks[HookName] then hook.Hooks[HookName] = {} end
		 
		 hook.Hooks[HookName][ID] = func
end

function hook.Remove(HookName,ID)
		 if not hook.Hooks[HookName] then return end
		 hook.Hooks[HookName][ID] = nil
end
		 
function hook.Call(HookName, ...)
		 if not hook.Hooks[HookName] then hook.Hooks[HookName] = {} end
		 
                 local bool = false
		 
		 for id,func in pairs(hook.Hooks[HookName]) do
			 bool = func(unpack(arg)) or false
		 end
		 
		 if string.lower(type(bool)) ~= "boolean" then bool = false end

		 return bool
end