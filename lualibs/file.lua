file = {}

function file.Write(path,text)
         local f = io.open(path,"w")
         
         if not f then return false end
         
         f:write(text)
         f:close()
         return true
end

function file.OpenDir(path)
         local tbl = {}

         for fname in lfs.dir(path) do
             if fname ~= "." and fname ~= ".." then
                tbl[#tbl + 1] = fname
             end
         end
         
         if #tbl == 0 then
            tbl = false
         end
         
         return tbl
end

function file.GetExtension(name)
         if not string.find(name,".") then return "" end
         
         local ext = string.sub(name,-3)
         return ext
end

function file.Read(path)
         local f = io.open(path,"r")
         if not f then return false end
         return f
end

function file.Exists(path)
         local f = io.open(path,"r")
         local exists = true
         if not f then exists = false else f:close() end
         return exists
end

function file.ReadText(path)
         local f = io.open(path,"r")
         local str = ""

         if not f then return false end

         str = f:read("*a")
         f:close()
         return str
end

function file.Create(path)
         local f = io.open(path,"w")
         
         if not f then return false end

         f:close()
         return true
end

file.CreateDir = lfs.mkdir
file.RemoveDir = lfs.rmdir
