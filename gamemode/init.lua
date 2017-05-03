
util.AddNetworkString("notification")

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
AddCSLuaFile("client/cl_notifications.lua")
AddCSLuaFile("client/cl_minimap.lua")

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
include("server/sv_console_commands.lua")
include("server/sv_chat_commands.lua")

CurrentDayTime = -1
CurrentDayHour = -1

local function CalcDayTime()
	local curtime = CurTime() - GetGlobalInt("DayTime")
	local realtimec = curtime / LengthOfDay
	CurrentDayTime =  realtimec * SecondsInDay
	CurrentDayHour =  realtimec * SecondsInDay / 3600.0
end

function GM:PlayerConnect(name, ip)
	print("Player: " .. name .. " has joined.")
end

function GM:PlayerAuthed(player, steamID, uniqueID)
	player:dbCheck()
	print("Player: " .. player:Nick() .. " has authed.")
end

function GM:PlayerInitialSpawn(player)
	player:SetModel("models/player/Group01/male_02.mdl")
	player:AllowFlashlight(true)
	player:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	
	local p = POINTS[DORM_POINTS[1][math.random(#DORM_POINTS[1])]]
	player:SetPos(p[1])
	player:SetAngles(p[2])

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
	player:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	local p = POINTS[DORM_POINTS[1][math.random(#DORM_POINTS[1])]]
	player:SetPos(p[1])
	player:SetAngles(p[2])
end

function GM:Think()
	AtmosGlobal:Think()
	CalcDayTime()
end

-- If ya refresh, you need to fix things that may break.
if #player.GetAll() > 0 then
	for k,v in pairs(player.GetAll()) do
		v:dbCheck()
		v.inDetention = false
	end
end

local keepDoorsShut = {
	[1581] = true,
	[1582] = true,
}

timer.Simple(55,
	function()
		-- Remove a random table that blocks NPCs in lunch room.
		if ents.GetMapCreatedEntity(2246) then
			ents.GetMapCreatedEntity(2246):Remove()
		end

		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "prop_door_rotating" then
				v:SetSaveValue("m_bLocked", false)
				if keepDoorsShut[v:MapCreationID()] then
					v:Fire("Close")
				else
					v:Fire("Open")
				end
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
