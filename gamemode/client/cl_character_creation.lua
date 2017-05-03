
local dCharacterCreation = nil

local notepad = Material("materials/assets/vgui/schedule/notepad.png")

surface.CreateFont( "CharacterCreationTitle", {
	font = "Arial",
	size = 32
})

surface.CreateFont( "CharacterCreationInfo", {
	font = "Arial",
	size = 28
})

local movingOut = false
local movingIn = false
local movedIn = true
local movedOut = false

local function DrawCharacterCreation()
	local W,H = ScrW(), ScrH()
	local w,h = 500, 500
	local x,y = W / 2 - w / 2, H / 2 - h / 2
	local topHeight = 50

	dCharacterCreation = vgui.Create("DFrame")
	dCharacterCreation:SetPos(x, y)
	dCharacterCreation:SetSize(w, h)
	dCharacterCreation:SetTitle("")
	dCharacterCreation:SetDraggable(false)
	dCharacterCreation:MakePopup()
	dCharacterCreation:ShowCloseButton(true)

	dCharacterCreation.Paint = function(s,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(notepad)
		surface.DrawTexturedRect(0, 0, w, h)

		draw.SimpleText(
			"Character Creation",
			"CharacterCreationTitle",
			w/2, topHeight/2 + 7,
			Color(0,0,0),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

		draw.SimpleText(
			"First Name:",
			"CharacterCreationInfo",
			90, topHeight + (1 - 1) * 45 + 30,
			Color(0,0,0),
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)

		draw.SimpleText(
			"Last Name:",
			"CharacterCreationInfo",
			90, topHeight + (3 - 1) * 45 + 30,
			Color(0,0,0),
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)

		draw.SimpleText(
			"Model:",
			"CharacterCreationInfo",
			90, topHeight + (5 - 1) * 45 + 30,
			Color(0,0,0),
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)
	end

	local dFirstName = vgui.Create( "DTextEntry", dCharacterCreation)
	dFirstName:SetPos(90, topHeight + (2 - 1) * 45 + 16)
	dFirstName:SetSize(250, 30)
	dFirstName:SetText("")
	dFirstName:SetFont("CharacterCreationInfo")
	dFirstName:SetValue(LocalPlayer():GetNWString("firstName"))

	local dLastName = vgui.Create( "DTextEntry", dCharacterCreation)
	dLastName:SetPos(90, topHeight + (4 - 1) * 45 + 14)
	dLastName:SetSize(250, 30)
	dLastName:SetText("")
	dLastName:SetFont("CharacterCreationInfo")
	dLastName:SetValue(LocalPlayer():GetNWString("lastName"))

	local models = {
		[1] = "models/player/Group01/male_02.mdl",
		[2] = "models/player/Group01/male_01.mdl",
		[3] = "models/player/Group01/female_06.mdl",
		[4] = "models/player/Group01/female_05.mdl",
	}

	local selected = 1

	for i=1,#models do
		local dicon = vgui.Create("DPanel", dCharacterCreation)
		dicon:SetSize((w - 90) / 4 + 40, 150)
		dicon:SetPos(50 + (i - 1) * (dicon:GetWide() - 40), topHeight + (6 - 1) * 45 + 15)
		dicon.Paint = function(s,w,h)
			if selected == i then
				draw.RoundedBox(
					0,
					20,15,
					w-40,h,
					Color(33,33,33,200)
				)
			else
				draw.RoundedBox(
					0,
					20,15,
					w-40,h,
					Color(33,33,33,66)
				)
			end
		end

		local icon = vgui.Create( "DModelPanel", dicon )
		icon:SetSize(dicon:GetWide(), dicon:GetTall())
		icon:SetPos(0, 0)
		icon:SetModel(models[i])
		function icon:LayoutEntity( Entity ) return end
		icon.DoClick = function()
			if selected ~= i then
				RunConsoleCommand("changemodel", selected)
				selected = i
			end
		end
	end

	local dButton = vgui.Create("DButton", dCharacterCreation)
	dButton:SetPos(w-132, h-52)
	dButton:SetSize(110, 40)
	dButton:SetText("Submit!")
	dButton:SetFont("CharacterCreationInfo")
	dButton.DoClick = function()
		RunConsoleCommand("changefirstname", dFirstName:GetValue())
		RunConsoleCommand("changelastname", dLastName:GetValue())
		dCharacterCreation:Remove()
	end

	movingOut = true
				
	dCharacterCreation:SetVisible(true)
	dCharacterCreation:SetPos(x, y)
	dCharacterCreation:SetAlpha(0)
	dCharacterCreation:AlphaTo(255, 0.25, 0, function()
		movingOut = false
		movedOut = true
		movedIn = false
	end)
end

function OpenCharacterCreation()
	if not IsValid(dCharacterCreation) then
		DrawCharacterCreation()
	end 
end

usermessage.Hook("CreateCharacter", OpenCharacterCreation)

-- DrawCharacterCreation()
