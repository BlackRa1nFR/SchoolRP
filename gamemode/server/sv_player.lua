
local player = FindMetaTable("Player")

local teams = {
	[1] = {
		name = "Blue",
		color = Vector(.2, .2, 1.0),
		weapons = {"weapon_pistol"}
	},
	[2] = {
		name = "Red",
		color = Vector(1.0, .2, .2),
		weapons = {"weapon_pistol"}
	}
}

function player:GetRPName()
	local firstName = self:dbGetValue("firstName")
	local lastName = self:dbGetValue("lastName")

	if not firstName or firstName == "" then
		firstName = "Barack"
	end

	if not lastName or lastName == "" then
		lastName = "Obama"
	end

	return firstName .. " " .. lastName
end

function player:SetGamemodeTeam(n)
	if not teams[n] then return end

	self:SetTeam(n)

	self:SetPlayerColor(teams[n].color)

	self:GiveGamemodeWeapons()

	return true
end

function player:GiveGamemodeWeapons()
	local n = self:Team()

	if not teams[n] then return end

	print("On team: " .. n)
	self:StripWeapons()

	for k, weapon in pairs(teams[n].weapons) do
		self:Give(weapon)
	end
end

function player:GiveDetention(time)
	if not self.inDetention then
		local p = POINTS[DETENTION_POINTS[math.random(#DETENTION_POINTS)]]
		self:SetPos(p[1])
		self:SetAngles(p[2])

		self.inDetention = true

		net.Start("notification")
			net.WriteTable({
				["detention"] = CurTime() + time
			})
		net.Send(self)

		timer.Simple(
			time,
			function()
				self.inDetention = false
				local g = math.random(1, 2)
				local p = POINTS[DORM_POINTS[g][math.random(#DORM_POINTS[g])]]
				self:SetPos(p[1])
				self:SetAngles(p[2])
			end
		)
	end
end
