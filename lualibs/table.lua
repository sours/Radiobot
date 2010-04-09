tablex = table

function table.Inherit( t, base )

	for k, v in pairs( base ) do 
		if ( t[k] == nil ) then	t[k] = v end
	end
	
	t["BaseClass"] = base
	
	return t

end

function table.Copy(t, lookup_table)
	if (t == nil) then return nil end
	
	local copy = {}
	setmetatable(copy, getmetatable(t))
	for i,v in pairs(t) do
		if type(v) ~= "table" then
			copy[i] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[t] = copy
			if lookup_table[v] then
				copy[i] = lookup_table[v] -- we already copied this table. reuse the copy.
			else
				copy[i] = table.Copy(v,lookup_table) -- not yet copied. copy it.
			end
		end
	end
	return copy
end

function table.Merge(dest, source)
	for k,v in pairs(source) do
		if type(v)=='table' and type(dest[k])=='table' then
			-- don't overwrite one table with another;
			-- instead merge them recurisvely
			table.Merge(dest[k], v)
		else
			dest[k] = v
		end
	end
	return dest
end

function table.HasValue( t, val )
	for k,v in pairs(t) do
		if (v == val ) then return true end
	end
	return false
end

table.InTable = HasValue

function table.Add( dest, source )

	if (type(source)~= 'table') then return dest end
	
	if (type(dest) ~= 'table') then dest = {} end

	for k,v in pairs(source) do
		table.insert( dest, v )
	end
	
	return dest
end

function table.SortByKey(Table)

	local temp = {}

	for key, _ in pairs(Table) do table.insert(temp, key) end
	table.sort(temp, function(a, b) return Table[a] > Table[b] end)

	return temp
end

function table.Count (t)
  local i = 0
  for k in pairs(t) do i = i + 1 end
  return i
end

function table.GetFirst(t)
         for k,v in pairs(t) do 
             if v ~= nil then
                return k
             end
         end
end

function table.IsSequential(t)
	local i = 1
	for key, value in pairs (t) do
		if not tonumber(i) or key ~= i then return false end
		i = i + 1
	end
	return true
end

function table.ToString(t,n,nice)
	local 		nl,tab  = "",  ""
	if nice then 	nl,tab = "\n", "\t"	end

	local function MakeTable ( t, nice, indent, done)
		local str = ""
		local done = done or {}
		local indent = indent or 0
		local idt = ""
		if nice then idt = string.rep ("\t", indent) end

		local sequential = table.IsSequential(t)

		for key, value in pairs (t) do

			str = str .. idt .. tab .. tab

			if not sequential then
				if type(key) == "number" or type(key) == "boolean" then 
					key ='['..tostring(key)..']' ..tab..'='
				else
					key = tostring(key) ..tab..'='
				end
			else
				key = ""
			end

			if type (value) == "table" and not done [value] then

				done [value] = true
				str = str .. key .. tab .. '{' .. nl
				.. MakeTable (value, nice, indent + 1, done)
				str = str .. idt .. tab .. tab ..tab .. tab .."},".. nl

			else
				
				if 	type(value) == "string" then 
					value = '"'..tostring(value)..'"'
				elseif  type(value) == "Vector" then
					value = 'Vector('..value.x..','..value.y..','..value.z..')'
				elseif  type(value) == "Angle" then
					value = 'Angle('..value.pitch..','..value.yaw..','..value.roll..')'
				else
					value = tostring(value)
				end
				
				str = str .. key .. tab .. value .. ",".. nl

			end

		end
		return str
	end
	local str = ""
	if n then str = n.. tab .."=" .. tab end
	str = str .."{" .. nl .. MakeTable ( t, nice) .. "}"
	return str
end

function table.Sanitise( t, done )

	local done = done or {}
	local tbl = {}

	for k, v in pairs ( t ) do
	
		if ( type( v ) == "table" and not done[ v ] ) then

			done[ v ] = true
			tbl[ k ] = table.Sanitise ( v, done )

		else

			if ( type(v) == "Vector" ) then

				local x, y, z = v.x, v.y, v.z
				if y == 0 then y = nil end
				if z == 0 then z = nil end
				tbl[k] = { __type = "Vector", x = x, y = y, z = z }

			elseif ( type(v) == "Angle" ) then

				local p,y,r = v.pitch, v.yaw, v.roll
				if p == 0 then p = nil end
				if y == 0 then y = nil end
				if r == 0 then r = nil end
				tbl[k] = { __type = "Angle", p = p, y = y, r = r }

			elseif ( type(v) == "boolean" ) then
			
				tbl[k] = { __type = "Bool", tostring( v ) }

			else
			
				tbl[k] = tostring(v)

			end
			
			
		end
		
		
	end
	
	return tbl
	
end

function table.DeSanitise( t, done )

	local done = done or {}
	local tbl = {}

	for k, v in pairs ( t ) do
	
		if ( type( v ) == "table" and not done[ v ] ) then
		
			done[ v ] = true

			if ( v.__type ) then
			
				if ( v.__type == "Vector" ) then
				
					tbl[ k ] = Vector( v.x, v.y, v.z )
				
				elseif ( v.__type == "Angle" ) then
				
					tbl[ k ] = Angle( v.p, v.y, v.r )
					
				elseif ( v.__type == "Bool" ) then
					
					tbl[ k ] = ( v[1] == "true" )
					
				end
			
			else
			
				tbl[ k ] = table.DeSanitise( v, done )
				
			end
			
		else
		
			tbl[ k ] = v
			
		end
		
	end
	
	return tbl
	
end

function table.ForceInsert( t, v )

	if ( t == nil ) then t = {} end
	
	table.insert( t, v )
	
end

function table.SortByMember( Table, MemberName, bAsc )

	if ( bAsc ) then
		table.sort( Table, function(a, b) return a[MemberName] < b[MemberName] end )
	else
		table.sort( Table, function(a, b) return a[MemberName] > b[MemberName] end )
	end
end
