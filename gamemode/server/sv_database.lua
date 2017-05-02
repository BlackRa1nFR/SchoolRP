
local player = FindMetaTable("Player")

util.AddNetworkString("database")

local defaultValues = {
	["money"] = 100,
	["xp"] = 0,
	["grade"] = "9th Grade",
	["firstName"] = "",
	["lastName"] = "",
	["model"] = "models/player/Group01/male_02.mdl",
	["schedule"] = {
		[1] = "AlgerbraI",
		[2] = "BiologyI",
		[3] = "Lunch",
		[4] = "English9",
		[5] = "WorldHistory",
	},
}

local tables = {
	["schedule"] = true,
}

local nws = {
	['firstName'] = true,
	['lastName'] = true,
	['grade'] = true,
}

function player:dbNW(name, v)
	if type(v) == "string" then
		self:SetNWString(name, v)
	elseif type(v) == "integer" then
		self:SetNWInt(name, v)
	else
		print ("Found none. Type: " .. type(v))
	end
end

function player:dbDefault()
	for k,v in pairs(defaultValues) do
		if true or self:dbGetValue(k) == nil then
			self:dbSetValue(k, v)
		end
	end
end

function player:dbCheck()
	self:dbDefault()
	self:dbSendAll()

	for k,v in pairs(nws) do
		self:dbNW(k, self:dbGetValue(k))
	end
end

function player:dbSendAll()
	endtab = {}

	for k,v in pairs(defaultValues) do
		endtab[k] = self:dbGetValue(k)
	end

	net.Start("database")
		net.WriteTable({
			["database"] = endtab
		})
	net.Send(self)
	print("Sent All database")
end

function player:dbSend(name)
	net.Start("database")
		net.WriteTable({
			["database"] = {
				name = self:dbGetValue(name),
			}
		})
	net.Send(self)
	print("Sent database")
end

function player:dbSetValue(name, v)
	if not v then return end

	if type(v) == "table" then
		v = util.TableToKeyValues(v)
	end

	if nws[name] then
		self:dbNW(name, v)
	end

	util.SetPData(self:SteamID(), 'srp_' .. name, v)
end

function player:databaseChangeValue(name, v)
	if not v or v == 0 then return end


	self:dbSetValue(name, self:dbGetValue(name) + v)
end

function player:dbGetValue(name)
	local v = util.GetPData(self:SteamID(), 'srp_' .. name, nil)

	if v and tables[name] then
		v = util.KeyValuesToTable(v)
	end

	return v
end

function GM:ShowHelp(player)
	player:ConCommand("inventory")
end
