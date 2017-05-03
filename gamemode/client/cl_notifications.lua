
IsInDetention = false

local function notificationReceive(tab)
	for k,v in pairs(tab) do
		if k == "detention" then
			if v > CurTime() then
				IsInDetention = v
			end
		elseif k == "openschedule" then
			OpenSchedule(nil, "gm_showhelp")
		elseif k == "opencharactercreation" then
			OpenCharacterCreation()
		elseif k == "specialchatmsg" then
			local c = v.Color

			if not c then
				c = Color(255,255,255)
			end

			chat.AddText(c, v.msg)
		end
	end
end

net.Receive("notification", function(len)
	print("Got notification")
	local tab = net.ReadTable()
	notificationReceive(tab)
	PrintTable(tab)
end)
