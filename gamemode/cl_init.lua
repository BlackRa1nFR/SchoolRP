
include("shared.lua")
include("shared/util.lua")
include("shared/sh_points.lua")
include("shared/sh_classes.lua")
include("shared/sh_atmos.lua")

include("client/cl_database.lua")
include("client/cl_fonts.lua")
include("client/cl_hud.lua")
include("client/cl_atmos.lua")
include("client/cl_scoreboard.lua")
include("client/cl_schedule.lua")
include("client/cl_character_creation.lua")
include("client/cl_notifications.lua")
include("client/cl_minimap.lua")

concommand.Add("pos", function(ply)
	local p = ply:GetPos()
	local a = ply:GetAngles()

	print ("{Vector(" .. math.Round(p.x, 3) .. ", " .. math.Round(p.y, 3) .. ", " .. math.Round(p.z, 3) .. "), Angle(" .. math.Round(a.pitch, 3) .. ", " .. math.Round(a.yaw, 3) .. ", 0.0)},")
end)
