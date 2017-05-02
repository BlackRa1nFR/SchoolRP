
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
