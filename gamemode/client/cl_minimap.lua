
local W,H = ScrW(), ScrH()
local w,h = W * 0.6, H * 0.6
local x,y = W * 0.4 / 2, H * 0.4 / 2

local dMiniMap = nil
local dMenu = nil

--------

-- The mini-map needs a crap load of work lmao.
-- It's very bad for performance.

--------

local function DrawMiniMap()

	if not dMiniMap or not IsValid(dMiniMap) then
		dMiniMap = vgui.Create("DPanel", dMenu)
		dMiniMap:SetSize(w, h)
		dMiniMap:SetPos(x, y)
		dMiniMap.Paint = function(s,w,h) 
			draw.RoundedBox(
				2,
				0,0,
				w,h,
				Color(33,33,33,150)
			)
		end

		local dMiniMapMap = vgui.Create("DPanel", dMiniMap)
		dMiniMapMap:SetSize(dMiniMap:GetWide(), dMiniMap:GetTall() - 30)
		dMiniMapMap:SetPos(0, 30)
		dMiniMapMap.Paint = function(s,w,h)
			local p = LocalPlayer():GetPos()
			local a = LocalPlayer():GetAngles().yaw + 90

			p.z = 2200

			render.RenderView( {
				origin = p,
				angles = Angle(90, a, 90),
				x = x,
				y = y+30,
				w = w,
				h = h,
				fov = 100,
			 } )
		end
	end

end

local function DrawQMenu()
	if not dMenu and not IsValid(dMenu) then
		local W,H = ScrW(), ScrH()
		local w,h = W * 0.6, H * 0.6
		local x,y = W * 0.4 / 2, H * 0.4 / 2
		local topHeight = 50

		dMenu = vgui.Create("DFrame")
		dMenu:SetPos(x, y)
		dMenu:SetSize(w, h)
		dMenu:SetTitle("")
		dMenu:SetDraggable(false)
		dMenu:MakePopup()
		dMenu:ShowCloseButton(true)
		dMenu:SetKeyboardInputEnabled(false)

		dMenu.Paint = function(s,w,h)
			draw.RoundedBox(
				4,
				0,0,
				w,h,
				Color(33,33,33,200)
			)
		end

		DrawMiniMap()
	end
end

-- DrawQMenu()

-- DrawMiniMap()
