
local developerMat = Material("icon16/application_osx_terminal.png")
local superadminMat = Material("icon16/color_wheel.png")
local adminMat = Material("icon16/shield.png")
local vipMat = Material("materials/assets/won.png")
local regularMat = Material("icon16/user.png")

local chalkboard = Material("materials/assets/vgui/scoreboard/chalkboard.png")

function GM:ScoreboardShow()
end

function GM:ScoreboardHide()
end

local scoreboard = nil

local movingOut = false
local movingIn = false
local movedIn = true
local movedOut = false

hook.Add("ScoreboardShow", "sScoreBoardShow", function()
	if IsValid(ScoreBoardMain) then
		if not movingOut and not movingIn then
			if movedIn then
				movingOut = true
				
				ScoreBoardMain:Update()
				ScoreBoardMain:SetVisible(true)
				ScoreBoardMain:SetAlpha(0)
				ScoreBoardMain:AlphaTo(255, 0.5, 0, function()
					movingOut = false
					movedOut = true
					movedIn = false
				end)
			else
				movingIn = true
				ScoreBoardMain:AlphaTo(0, 0.5, 0, function()
					movingIn = false
					movedOut = false
					movedIn = true
					ScoreBoardMain:SetVisible(false)
				end)
			end
		end
	else
		CreateScoreboard()
	end 
end)

hook.Add("ScoreboardHide", "sScoreBoardHide", function()
	if (ScoreBoardMain) then
		if not movingOut and not movingIn and movedOut then
			movingIn = true
			ScoreBoardMain:AlphaTo(0, 0.5, 0, function()
				movingIn = false
				movedIn = true
				movedOut = false
				ScoreBoardMain:SetVisible(false)
			end)
		end
	end
end)

surface.CreateFont( "ScoreBoardTitle", {
	font = "Arial",
	size = 32
})

surface.CreateFont( "ScoreBoardPlayerNames", {
	font = "Arial",
	size = 24
})

surface.CreateFont( "ScoreBoardPlayerSub", {
	font = "Arial",
	size = 18
})

function CreateScoreboard()
	local W,H = ScrW(), ScrH()
	local w,h = W * 0.75, H * 0.75
	local x,y = W * 0.25 / 2, H * 0.25 / 2
	local topHeight = 50

	ScoreBoardMain = vgui.Create("DFrame")
	ScoreBoardMain:SetPos(x, y)
	ScoreBoardMain:SetSize(w,h)
	ScoreBoardMain:SetTitle("")
	ScoreBoardMain:SetDraggable(false)
	ScoreBoardMain:MakePopup()
	ScoreBoardMain:ShowCloseButton(false)
	ScoreBoardMain:SetKeyboardInputEnabled(false)

	ScoreBoardMain.Paint = function(s,w,h)
		draw.RoundedBox(
			5,
			0,0,
			w,h,
			Color(33,33,33,250)
		)

		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(chalkboard)
		surface.DrawTexturedRect(5, 5, w-10, h-10)

		draw.SimpleText(
			GetHostName(),
			"ScoreBoardTitle",
			w/2, topHeight/2 + 5,
			Color(255,255,255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end

	local scrollpanel = ScoreBoardMain:Add("DScrollPanel")
	scrollpanel:SetPos(20, topHeight+10)
	scrollpanel:SetSize(ScoreBoardMain:GetWide()-40, ScoreBoardMain:GetTall()-topHeight-35)

	scrollpanel.Paint = function(s,w,h)
		draw.RoundedBox(
			4,
			0,0,
			w,h,
			Color(0,0,0,220)
		)
	end
	scrollpanel.VBar.Paint = function() end
	
	ScoreBoardMain.Update = function()
		scrollpanel:Clear()

		local sortedPlayers = player.GetAll()

		table.sort(sortedPlayers, function (a, b) 
			return a:Frags() > b:Frags()
		end)

		local index = 1
		local w,h = scrollpanel:GetWide() - 16, 64
		local padding = 2

		for k,v in pairs(sortedPlayers) do
			local panel = scrollpanel:Add("DPanel")
			panel:SetSize(w, h)
			panel:SetPos(0, index * (h + padding) - (h + padding) + padding)

			index = index + 1
			
			local avatar = panel:Add("AvatarImage")
			avatar:SetSize(54, 54)
			avatar:SetPos(5, 5)
			avatar:SetPlayer(v)
			
			local SteamProfile = vgui.Create( "DButton",avatar )
			SteamProfile:SetSize( avatar:GetWide(), avatar:GetTall() ) 
			SteamProfile:SetText(" ")

			function SteamProfile:Paint(w,h)
			end

			if v:SteamID64() then
				function SteamProfile:DoClick()
					gui.OpenURL( "https://steamcommunity.com/profiles/"..v:SteamID64() )
				end
			end
			
			if v != LocalPlayer() then
				local MuteButton = panel:Add( "DImageButton" )
				MuteButton:SetSize(32,32)
				MuteButton:SetPos(w - 50, h / 2 / 2) 
				MuteButton:SetText(" ")
				function MuteButton:Paint(w,h)
				end
				if v:IsMuted() then
					MuteButton:SetImage("icon32/muted.png")
				else
					MuteButton:SetImage("icon32/unmuted.png")
				end
				function MuteButton:DoClick()
					v:SetMuted(!v:IsMuted())
					
					if v:IsMuted() then
						MuteButton:SetImage("icon32/muted.png")
					else
						MuteButton:SetImage("icon32/unmuted.png")
					end
				end
			end
	
			local name = v:GetName()
			local icon = regularMat
			local title = "9th Grader"
			local status = "Player"

			if v.SteamID64 and v:SteamID64() then
				icon = developerMat
				status = "Developer"
			elseif v:IsSuperAdmin() then
				icon = superadminMat
				status = "Owner"
			elseif v:IsAdmin() then
				icon = adminMat
				status = "Admin"
			elseif v.VIP then
				icon = vipMat
				status = "VIP"
			end

			panel.Paint = function(self, w, h)
				if not v:IsValid() then
					ScoreBoardMain:Update()
					return
				end

				draw.SimpleText(
					name,
					"ScoreBoardPlayerNames",
					90,
					h / 2,
					Color(255,255,255),
					TEXT_ALIGN_LEFT,
					TEXT_ALIGN_CENTER
				)

				draw.SimpleText(
					title,
					"ScoreBoardPlayerSub",
					w - 290,
					h / 2,
					Color(255,255,255),
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_CENTER
				)

				if status then
					draw.SimpleText(
						status,
						"ScoreBoardPlayerSub",
						w - 170,
						h / 2,
						Color(255,255,255),
						TEXT_ALIGN_CENTER,
						TEXT_ALIGN_CENTER
					)
				end

				surface.SetDrawColor(Color(255,255,255))
				surface.SetMaterial(icon)
				surface.DrawTexturedRect(
					w - 100,
					h / 2 - 8, 16, 16
				)

			end
		end
	end
	
	ScoreBoardMain:Update()

	movingOut = true
				
	ScoreBoardMain:Update()
	ScoreBoardMain:SetVisible(true)
	ScoreBoardMain:SetPos(x, y)
	ScoreBoardMain:SetAlpha(0)
	ScoreBoardMain:AlphaTo(255, 0.5, 0, function()
		movingOut = false
		movedOut = true
		movedIn = false
	end)
end
