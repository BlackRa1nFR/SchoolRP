
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local TravelPoints = {
	Vector(-143.133133, -1456.099243, 72.031250),
	Vector(1097.671387, -489.795532, 144.031250),
}

-- models/Zombie/Fast.mdl
-- models/Humans/Group03m/male_03.mdl -- black health guy
-- models/Humans/Group03/male_06.mdl -- white guy
-- models/Humans/Group02/Male_05.mdl -- other white guy

function ENT:GoToRespawn()
	local p = POINTS[ROAMING_POINTS[math.random(#ROAMING_POINTS)]]
	print ( p[1])
	self:SetPos(p[1] + Vector(math.random(-50, 50), math.random(-50, 50), 0))
	self:SetAngles(p[2])
end

function ENT:Initialize()
	self.Posted = false
	self:SetModel( "models/monk.mdl" )
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self.stuckCount = 0
	self.Cancel = false
	self:SetCustomCollisionCheck( true )
end

function ENT:SetNWName(name)
	self:SetNWString("Name", name)
end

function ENT:SetTitle(title)
	self:SetNWString("Title", title)
end

function ENT:AltModel(model)
	self:SetModel(model)
end

function ENT:SetGender(gender)
	self.gender = gender
end

function ENT:MoveToPos( pos, options )
	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end

	while ( not self.Cancel and path:IsValid() ) do
		path:Update( self )

		-- Draw the path (only visible on listen servers or single player)
		if ( options.draw ) then
			path:Draw()
		end

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then

			self:HandleStuck()

			if self:GetPos():Distance(pos) < 75 then
				return "stuck"
			else
				self:GoToRespawn()
			end
		end

		--
		-- If they set maxage on options then make sure the path is younger than it
		--
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		--
		-- If they set repath then rebuild the path every x seconds
		--
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end
		coroutine.yield()
	end
	return "ok"
end

function ENT:GetRandom()
	if IsCurfew() then
		return DORM_POINTS[self.gender][math.random(#DORM_POINTS[self.gender])]
	else
		points = ROAMING_POINTS

		if self.RoamPoints then
			points = self.RoamPoints
		end
		
		return points[math.random(#points)]
	end
end

function ENT:RunBehaviour()
	while (true) do
		self:StartActivity( ACT_WALK )			-- Walk animation

		local point = nil

		if self.Posted then
			point = POINTS[self.distination]
			point[1] = point[1] + Vector(math.random(-50, 50), math.random(-50, 50), 0)
			point[2].yaw = point[2].yaw + 0
			self.loco:SetDesiredSpeed( 200 )		-- Walk speed
		else
			local d = self:GetRandom()
			point = POINTS[d]
			self.loco:SetDesiredSpeed( 75 )		-- Walk speed
		end

		local travelto = point[1]

		self.Cancel = false

		self:MoveToPos( travelto, {
			lookahead = 100,
			draw = false,
			repath = 3
		})

		self:SetAngles(point[2])
		self:StartActivity( ACT_IDLE )			-- Idle animation

		local pos = 0
		local dir = 3
		local a = self:GetAngles()

		if not self.Cancel then
			coroutine.wait( 5 )
		end

		while (not self.Cancel and self.Posted) do
			coroutine.wait( 0.1 )
			if pos > 30 or pos < -30 then
				dir = -dir
			end

			a.pitch = 0
			a.yaw = a.yaw + dir
			pos = pos + dir

			self:SetAngles(a)
		end

		coroutine.yield()
		-- The function is done here, but will start back at the top of the loop and make the bot walk somewhere else
	end
end

function ENT:SetDestination(point)
	self.distination = point
	self.Posted = true
	self.Cancel = true
end

function ENT:Roam(points)
	self.Posted = false
	self.Cancel = true
	self.RoamPoints = points
end

function ENT:Use( activator, caller, type, value )
end

function ENT:Touch( activator, caller, type, value )
end
