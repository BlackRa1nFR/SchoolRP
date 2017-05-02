
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("shared/util.lua")
AddCSLuaFile("shared/sh_points.lua")
AddCSLuaFile("shared/sh_atmos.lua")
AddCSLuaFile("shared/sh_classes.lua")

AddCSLuaFile("client/cl_database.lua")
AddCSLuaFile("client/cl_fonts.lua")
AddCSLuaFile("client/cl_hud.lua")
AddCSLuaFile("client/cl_atmos.lua")
AddCSLuaFile("client/cl_scoreboard.lua")
AddCSLuaFile("client/cl_schedule.lua")
AddCSLuaFile("client/cl_character_creation.lua")

-- Resources
resource.AddFile("materials/assets/vgui/scoreboard/chalkboard.png")
resource.AddFile("materials/assets/vgui/schedule/notepad.png")

include("shared.lua")

include("shared/util.lua")
include("shared/sh_points.lua")
include("shared/sh_atmos.lua")
include("shared/sh_classes.lua")

include("server/sv_database.lua")
include("server/sv_player.lua")
include("server/sv_classes.lua")
include("server/sv_atmos.lua")

function GM:PlayerConnect(name, ip)
	print("Player: " .. name .. " has joined.")
end

function GM:PlayerAuthed(player, steamID, uniqueID)
	player:dbCheck()
	print("Player: " .. player:Nick() .. " has authed.")
end

function GM:PlayerInitialSpawn(player)
	player:SetModel("models/player/Group01/male_02.mdl")

	if player:dbGetValue("firstName") == "" or player:dbGetValue("lastName") == "" then
		print ("-------->> YOu need to make character :)")
		-- The *really* lazy way of telling client to open menu.
		umsg.Start("CreateCharacter", player)
	        umsg.Short( "1" ) 
	    umsg.End()
	else
		print ("-------->> character made! :)")
	end

	print("Player: " .. player:Nick() .. " has spawned.")
end

function GM:PlayerDisconnected(player)
end

function GM:PlayerSpawn(player)
end

function GM:Think()
	AtmosGlobal:Think()
end

if #player.GetAll() > 0 then
	for k,v in pairs(player.GetAll()) do
		v:dbCheck()
	end
end

timer.Simple(55,
	function()
		-- Remove a random table that blocks NPCs in lunch room.
		if ents.GetMapCreatedEntity(2246) then
			ents.GetMapCreatedEntity(2246):Remove()
		end

		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "prop_door_rotating" then
				v:SetSaveValue("m_bLocked", false)
				v:Fire("Open")
			end
		end
	end)

timer.Simple(
	60,
	function()
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "prop_door_rotating" then
				v:SetSaveValue("m_bLocked", true)
			end
		end
	end)


--------------- Temp solution. Will move to sv_console_commands.lua later.
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