------------------------------------------------------------------------------------------------
-- Web commands
------------------------------------------------------------------------------------------------
PLUGIN.Name = "Web Tools"
PLUGIN.Description = "Implements HTTP related commands."

------------------------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------------------------
function HTTP_TitleOf(url)
         local html,c,h = socket.http.request(string.Trim(AllArgs))

         if not html then return false,"Unknown address!" end

         local f = string.find(html,"<title>")
         if not f then return false,"Could not find the title!" end

         local f2 = string.find(html,"</title>")
         if not f2 then return false,"Could not find the title!" end

         local title = string.sub(html, f + 7, f2 - 1)

         return title
end

function HTTP_TitleLinks(srv, user, mask, room, nick, msg, IsPm)
         local index = string.find(msg,"http://")
         if not index then return end
         
         local endindex = string.find(msg," ",index)
         if not endindex then endindex = string.len(msg) end
         
         local title,err = HTTP_TitleOf(string.sub(msg,index,endindex))
         if not title then return end

         Command.PollChat(room,"\""..title.."\"")
end

--hook.Add("RecieveChat","http_TitleLinks",HTTP_TitleLinks)
------------------------------------------------------------------------------------------------
-- Commands
------------------------------------------------------------------------------------------------
function HTTP_Dump(user,nick,mask,room,args,AllArgs,IsPm)
         local addr = string.Trim(args[1])
         args[1] = ""
         local path = string.Trim(string.Implode(args," "))

         local html,c,h = http.request(addr)
         
         if not html then Command.Reply("Unknown address!") return end

         local f = io.open(path,"w")
         if not f then Command.Reply("Invalid path!") return end
         f:write(html)
         f:close()
         
         print("Retvals: 2.("..type(c)..")"..tostring(c).." 3.("..type(h)..")"..tostring(h))

         Command.Reply("Dumped contents of "..addr.." to: " ..path)
end

Command.Register("HTTPDUMP", HTTP_Dump, 2, "HTTPDUMP <address> <path> - Dumps ", true)

function HTTP_Title(user,nick,mask,room,args,AllArgs,IsPm)
         local title, err = HTTP_TitleOf(AllArgs)
         if not title then Command.Reply(err) return end
         Command.Reply(title)
end

Command.Register("TITLE", HTTP_Title, 1, "TITLE <address> - Prints the title of the webpage at the address.", false)

function HTTP_Google(user,nick,mask,room,args,AllArgs,IsPm)
         --local s = "http://www.google.com/search?client=opera&rls=en&q="..string.Trim(AllArgs).."&sourceid=opera&ie=utf-8&oe=utf-8")
         --local html,c,h = http.request(s)
         --if not html then Command.Reply("Google is down :O") return end
         
         --local i = string.find(html,"Search Results")

end

Command.Register("GOOGLE",HTTP_Google, 1, "GOOGLE <searh> - Prints google results for 'search'.",false)