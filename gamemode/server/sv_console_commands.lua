
local models = {
	[1] = "models/player/Group01/male_02.mdl",
	[2] = "models/player/Group01/male_01.mdl",
	[3] = "models/player/Group01/female_06.mdl",
	[4] = "models/player/Group01/female_05.mdl",
}

concommand.Add("changemodel", function(ply, cmd, args)
	local m = math.Round(args[1])
	local model = models[m]

	if m and model then
		ply:dbSetValue("model", model)
		ply:SetModel(model)
	end
end)

concommand.Add("changefirstname", function(ply, cmd, args)
	local name = args[1]

	if name and string.len(name) > 0 then
		ply:dbSetValue("firstName", name)
	end
end)

concommand.Add("changelastname", function(ply, cmd, args)
	local name = args[1]

	if name and string.len(name) > 0 then
		ply:dbSetValue("lastName", name)
	end
end)

concommand.Add("getent", function(ply)
	print( ply:GetEyeTrace().Entity:MapCreationID() )
end)

concommand.Add("checkPoints", function(ply)
	local a = ROAMING_POINTS[math.random(#ROAMING_POINTS)]
	print ("--> " .. a)
	ply:SetPos(POINTS[a][1])
end)

concommand.Add("settime", function(ply, cmd, args)
	if ply and IsValid(ply) and ply:IsAdmin() or ply:IsSuperAdmin() then
		local time = args[1]
		if time and tonumber(time) then
			time = tonumber(time)

			StartNewDay(time)
		end
	end
end)
