
local dSchedule = nil

local notepad = Material("materials/assets/vgui/schedule/notepad.png")

surface.CreateFont( "ScheduleTitle", {
	font = "Arial",
	size = 32
})

surface.CreateFont( "ScheduleInfo", {
	font = "Arial",
	size = 28
})

local movingOut = false
local movingIn = false
local movedIn = true
local movedOut = false

local function DrawSchedule()
	local W,H = ScrW(), ScrH()
	local w,h = 400, 500
	local x,y = W / 2 - w / 2, H / 2 - h / 2
	local topHeight = 50

	dSchedule = vgui.Create("DFrame")
	dSchedule:SetPos(x, y)
	dSchedule:SetSize(w, h)
	dSchedule:SetTitle("")
	dSchedule:SetDraggable(false)
	-- dSchedule:MakePopup()
	dSchedule:ShowCloseButton(false)
	-- dSchedule:SetKeyboardInputEnabled(false)

	dSchedule.Paint = function(s,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(notepad)
		surface.DrawTexturedRect(0, 0, w, h)

		draw.SimpleText(
			"Schedule",
			"ScoreBoardTitle",
			w/2, topHeight/2 + 7,
			Color(0,0,0),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

		local s = databaseGetValue("schedule")

		if s then
			for i=1,#s do
				print (s[i])
				local c = CLASSES[s[i]]
				draw.SimpleText(
					i .. ". " .. c.Name .. " - " .. c.Room,
					"ScheduleInfo",
					70, topHeight + (i - 1) * 45 + 30,
					Color(0,0,0),
					TEXT_ALIGN_LEFT,
					TEXT_ALIGN_CENTER
				)
			end
		end
	end

	movingOut = true
				
	dSchedule:SetVisible(true)
	dSchedule:SetPos(x, y)
	dSchedule:SetAlpha(0)
	dSchedule:AlphaTo(255, 0.25, 0, function()
		movingOut = false
		movedOut = true
		movedIn = false
	end)
end

local function OpenSchedule( ply, bind, pressed )
    if ( bind == "gm_showhelp" ) then 
		if IsValid(dSchedule) then
			if not movingOut and not movingIn then
				if movedIn then
					movingOut = true
					
					dSchedule:SetVisible(true)
					dSchedule:SetAlpha(0)
					dSchedule:AlphaTo(255, 0.25, 0, function()
						movingOut = false
						movedOut = true
						movedIn = false
					end)
				else
					movingIn = true
					dSchedule:AlphaTo(0, 0.25, 0, function()
						movingIn = false
						movedOut = false
						movedIn = true
						dSchedule:SetVisible(false)
					end)
				end
			end
		else
			DrawSchedule()
		end 
	end
end

hook.Add("PlayerBindPress", "OpenSchedule", OpenSchedule)
