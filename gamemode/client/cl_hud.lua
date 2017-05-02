
CurrentDayTime = -1
CurrentDayHour = -1

local IsBellRinging = false
local ClassChangeLast = false

sound.Add( {
	name = "RingBell",
	channel = CHAN_STATIC,
	volume = 0.4,
	level = 80,
	sound = "ambient/alarms/alarm1.wav"
} )

local function RingBell()
	if not IsBellRinging then
		IsBellRinging = true
		LocalPlayer():EmitSound("RingBell")

		timer.Simple(
			4,
			function()
				LocalPlayer():StopSound("RingBell")
				IsBellRinging = false
			end
		)
	end
end

local function TimeHud()
	local W, H = ScrW(), ScrH()
	local w,h = 120, 60
	local x,y = 30, 30

	draw.RoundedBox(
		3,
		x,y,
		w,h,
		Color(33,33,33,200)
	)

	draw.SimpleText(
		"Time of Day",
		"CustomFontB",
		x + (w/2),
		y + 5,
		Color(255, 255, 255),
		TEXT_ALIGN_CENTER
	)

	local time = string.FormattedTime(CurrentDayTime)
	local hour = time.h
	local min = time.m
	local side = 'AM'

	if min <= 9 then
		min = "0" .. min
	end

	if hour >= 12 then
		side = "PM"
		time = string.FormattedTime(CurrentDayTime - SecondsInHalfDay)
		hour = time.h
	end

	if hour <= 9 then
		hour = "0" .. hour
	end

	draw.SimpleText(
		hour .. ":" .. min .. " " .. side,
		"CustomFontA",
		x + (w/2),
		y + (h/2),
		Color(255, 255, 255),
		TEXT_ALIGN_CENTER
	)
end

local function ClassHud()
	local W, H = ScrW(), ScrH()
	local w,h = 190, 60
	local x,y = W - w - 30, H - h - 30

	draw.RoundedBox(
		3,
		x,y,
		w,h,
		Color(33,33,33,200)
	)

	draw.SimpleText(
		"Current Period",
		"CustomFontB",
		x + (w/2),
		y + 5,
		Color(255, 255, 255),
		TEXT_ALIGN_CENTER
	)

	local periodID = GetGlobalInt("ClassPeriod")
	local periodName = "Free Time"
	local schedule = databaseGetValue("schedule")

	if periodID > 0 then
		local curtime = GetGlobalInt("ClassPeriodEnds") - CurTime() 
		local realtimec = curtime / LengthOfDay
		local realtime =  realtimec * SecondsInDay / 60

		if realtime > LengthOfPeriodInGame then
			periodName = "Class Change"
			if not ClassChangeLast then
				RingBell()
			end
			ClassChangeLast = true
		elseif periodID > 0 and schedule and schedule[periodID] then
			periodName = CLASSES[schedule[periodID]].Name
			if ClassChangeLast then
				RingBell()
			end
			ClassChangeLast = false
		else
			periodName = "Invalid"
		end
	elseif IsCurfew() then
		periodName = "Lights Out"
	end

	draw.SimpleText(
		periodName,
		"CustomFontA",
		x + (w/2),
		y + (h/2),
		Color(255, 255, 255),
		TEXT_ALIGN_CENTER
	)
end

local function ClassTimeHud()
	local periodID = GetGlobalInt("ClassPeriod")

	local W, H = ScrW(), ScrH()
	local cw,ch = 190, 60
	local w,h = 190, 60
	local x,y = W - w - 30, H - h - ch - 30 - 15

	if periodID > 0 then
		draw.SimpleText(
			"F1 to view schedule",
			"CustomFontB",
			x + w / 2 + 5, y - 20,
			Color(255,255,255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

		draw.RoundedBox(
			3,
			x,y,
			w,h,
			Color(33,33,33,200)
		)

		draw.SimpleText(
			"Time Remaining",
			"CustomFontB",
			x + (w/2),
			y + 5,
			Color(255, 255, 255),
			TEXT_ALIGN_CENTER
		)

		local curtime = GetGlobalInt("ClassPeriodEnds") - CurTime() 
		local realtimec = curtime / LengthOfDay
		local realtime =  realtimec * SecondsInDay / 60

		if realtime > LengthOfPeriodInGame then
			curtime = curtime - (LengthOfPeriodInGame * CalcMinute)
		end

		local time = math.ceil(curtime)

		local min = "seconds"

		if time == 1 then
			min = "second"
		elseif time < 0 then
			time = 0
		end

		draw.SimpleText(
			time .. " " .. min,
			"CustomFontA",
			x + (w/2),
			y + (h/2),
			Color(255, 255, 255),
			TEXT_ALIGN_CENTER
		)
	else
		draw.SimpleText(
			"F1 to view schedule",
			"CustomFontB",
			x + w / 2 + 5, y + 50,
			Color(255,255,255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end
end

local function ClassRoom2D3D()
	local periodID = GetGlobalInt("ClassPeriod")
	local schedule = databaseGetValue("schedule")

	if periodID > 0 and schedule and schedule[periodID] then

		local r = CLASSES[schedule[periodID]].Room
		local p = POINTS['d_' .. r][1]

		local pos = p:ToScreen()

		local eyeang = LocalPlayer():EyeAngles().y - 90 -- Face upwards
		local SpinAng = Angle( 0, eyeang, 90 )

		local x = 0
		local y = 0
		local padding = 7
		local offset = 0

		local w, h = surface.GetTextSize( r )
		
		x = pos.x - w 
		y = pos.y - h 
		
		x = x - offset
		y = y - offset

		draw.RoundedBox(4,
			x-padding-2,
			y-padding-2 - 20,
			w+padding*2+4,
			h+padding*2+4,
			Color(33,33,33,210)
		)

		draw.SimpleText(
			r,
			"CustomFontA",
			x + w/2,
			y - 20,
			Color(255,255,255),
			TEXT_ALIGN_CENTER
		)
	end
end

local function DrawHud()

end

local function CalcDayTime()
	local curtime = CurTime() - GetGlobalInt("DayTime")
	local realtimec = curtime / LengthOfDay
	CurrentDayTime =  realtimec * SecondsInDay
	CurrentDayHour =  realtimec * SecondsInDay / 3600.0
end

local function DrawInDetention()
	if IsInDetention and IsInDetention > CurTime() then
		local W, H = ScrW(), ScrH()
		local w,h = 350, 50
		local x,y = W / 2 - w / 2, 30

		draw.RoundedBox(
			5,
			x,y,
			w,h,
			Color(192, 57, 43, 50)
		)

		draw.RoundedBox(
			5,
			x+4,y+4,
			w-8,h-8,
			Color(192, 57, 43, 100)
		)

		draw.SimpleText(
			"Detention Ends in " .. math.Round(IsInDetention - CurTime()) .. " seconds.",
			"CustomFontA",
			x + (w/2), y + (h/2),
			Color(255,255,255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end
end

local function hud()
	CalcDayTime()

	DrawHud()
	TimeHud()
	ClassHud()
	ClassTimeHud()
	ClassRoom2D3D()
	DrawInDetention()
end

hook.Add("HUDPaint", "MyHudName", hud) -- I'll explain hooks and functions in a second

function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudSecondaryAmmo", "CHudAmmo", "CHudCrosshair"}) do
		if v == name then
			return false
		end
	end
end

hook.Add("HUDShouldDraw", "HideOurHud", hidehud)

-- Move to cl_overhead_names.lua

function GM:HUDDrawTargetID()
end

surface.CreateFont( "player_overhead_name", {
	font 		= "Arial",
	size 		= 28,
	weight 		= 700,
})

surface.CreateFont( "player_overhead_title", {
	font 		= "Arial",
	size 		= 20,
	weight 		= 700,
})

local function OverheadNames()
	for k,v in pairs(player.GetAll()) do
		local dist = v:GetPos():Distance(LocalPlayer():GetPos())

		if v ~= LocalPlayer() and dist <= 400 then
			local alphaStrength = 1 - (dist) / 400
			if alphaStrength < 0 then
				alphaStrength = 0
			end

			local zOffset = 100

			local x = v:GetPos().x
			local y = v:GetPos().y
			local z = v:GetPos().z

			local pos = Vector(x, y, z + zOffset)
			local pos2d = pos:ToScreen()

			local firstName = "Barack"
			local lastName = "Obama"
			local title = "13th Grader"

			if v:GetNWString("firstName") ~= "" then
				firstName = v:GetNWString("firstName")
			end

			if v:GetNWString("lastName") ~= "" then
				lastName = v:GetNWString("lastName")
			end

			if v:GetNWInt("grade") and v:GetNWInt("grade") ~= "" then
				title = v:GetNWInt("grade") .. "th Grader"
			end

			draw.DrawText(
				firstName .. " " .. lastName,
				"player_overhead_name",
				pos2d.x, pos2d.y,
				Color(255, 255, 255, 255 * alphaStrength),
				TEXT_ALIGN_CENTER
			)

			draw.DrawText(
				title,
				"player_overhead_title",
				pos2d.x, pos2d.y + 32,
				Color(39, 174, 96, 255 * alphaStrength),
				TEXT_ALIGN_CENTER
			)
		end
	end
end

hook.Add("HUDDrawTargetID", "LoopThroughPlayers", OverheadNames)	
