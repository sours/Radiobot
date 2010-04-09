function string.Explode ( str,seperator,start )

	local tble={}
	ll=start or 0

	while (true) do

		l = string.find( str, seperator, ll, true )
		
		if (l ~= nil) then
			table.insert(tble, string.sub(str,ll,l-1)) 
			ll=l+1
		else
			table.insert(tble, string.sub(str,ll))
			break
		end
		
	end

	return tble
	
end

function string.Implode(tbl,Sep)
         local str = ""
         
         for k,v in pairs(tbl) do
             str = str .. v .. Sep
         end

         str = string.sub(str,1,-(string.len(Sep) + 1))
         return str
end

function string.findlast(str, fstr)
         local index = 0
         local last = 0

         while index do
               last = index
               index = string.find(str,fstr,index + 1)
         end
         
         return last
end

function string.ToChars(str)
         local tbl = {}

         for i = 1,string.len(str) do
             tbl[i] = string.sub(str,i,i)
         end
         
         return tbl
end

function string.Reverse(str)
         local rev = ""

         for i = string.len(str),1,-1 do
             rev = rev .. string.sub(str,i,i)
         end
         
         return rev
end

function string.GetExtensionFromFilename(path)
	local ExplTable = string.Explode("" ,path)
	for i = table.getn(ExplTable), 1, -1 do
		if ExplTable[i] == "." then return string.sub(path, i+1)end
		if ExplTable[i] == "/" or ExplTable[i] == "\\" then return "" end
	end
	return ""
end

function string.GetPathFromFilename(path)
	local ExplTable = string.Explode("" ,path)
	for i = table.getn(ExplTable), 1, -1 do
		if ExplTable[i] == "/" or ExplTable[i] == "\\" then return string.sub(path, 1, i) end
	end
	return ""
end

function string.GetFileFromFilename(path)
	local ExplTable = string.Explode("" ,path)
	for i = table.getn(ExplTable), 1, -1 do
		if ExplTable[i] == "/" or ExplTable[i] == "\\" then return string.sub(path, i) end
	end
	return ""
end

function string.FormattedTime( TimeInSeconds, Format )
	if not TimeInSeconds then TimeInSeconds = 0 end

	local i = math.floor( TimeInSeconds )
	local h,m,s,ms	=	( i/3600 ),
				( i/60 )-( math.floor( i/3600 )*3600 ),
				TimeInSeconds-( math.floor( i/60 )*60 ),
				( TimeInSeconds-i )*100

	if Format then
		return string.format( Format, m, s, ms )
	else
		return { h=h, m=m, s=s, ms=ms }
	end
end

function string.ToMinutesSecondsMilliseconds( TimeInSeconds )	return string.FormattedTime( TimeInSeconds, "%02i:%02i:%02i")	end
function string.ToMinutesSeconds( TimeInSeconds )		return string.FormattedTime( TimeInSeconds, "%02i:%02i")	end



function string.Left(str, num)
	return string.sub(str, 1, num)
end

function string.Right(str, num)
	return string.sub(str, -num)
end



function string.Replace(str, tofind, toreplace)
	local start = 1
	
        while (true) do
		local pos = string.find(str, tofind, start, true)
	
		if (pos == nil) then
			break
		end
		
		local left = string.sub(str, 1, pos-1)
		local right = string.sub(str, pos + #tofind)
		
		str = left .. toreplace .. right
		start = pos + #toreplace
	end
	return str
end

function string.Trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

