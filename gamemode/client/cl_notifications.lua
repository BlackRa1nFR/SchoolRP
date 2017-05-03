
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
			chat.AddText(unpack(v))
		end
	end
end

net.Receive("notification", function(len)
	print("Got notification")
	local tab = net.ReadTable()
	notificationReceive(tab)
	PrintTable(tab)
end)
