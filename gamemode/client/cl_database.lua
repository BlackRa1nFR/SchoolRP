
local database = {}

local function databaseReceive(tab)
	if tab.database then
		for k,v in pairs(tab.database) do
			database[k] = v
			last = v
		end
	end
end

net.Receive("database", function(len)
	print("Got something")
	local tab = net.ReadTable()
	databaseReceive(tab)
	PrintTable(tab)
end)

function databaseGetValue(name)
	return database[name]
end
