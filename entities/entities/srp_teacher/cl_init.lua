
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

surface.CreateFont( "npcs_teacher_name", {
	font 		= "Arial",
	size 		= 36,
	weight 		= 700,
})

surface.CreateFont( "npcs_teacher_title", {
	font 		= "Arial",
	size 		= 22,
	weight 		= 700,
})

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function ENT:Post()
	local dist = self:GetPos():Distance(LocalPlayer():GetPos())

	if dist > 400 then return end

	local angles = self:GetAngles();
	local position = self:GetPos();
	local aboveoffset = angles:Up() * -0 + angles:Forward() * 0 + angles:Right() * 0;

	local alphaStrength = 1 - (dist) / 400
	if alphaStrength < 0 then
		alphaStrength = 0
	end

	angles:RotateAroundAxis(angles:Forward(), 90);
	-- angles:RotateAroundAxis(angles:Right(), LocalPlayer():GetAngles().yaw);
	local eyeang = LocalPlayer():EyeAngles().y - 90 -- Face upwards
	local SpinAng = Angle( 0, eyeang, 90 )

	cam.Start3D2D(position + aboveoffset, SpinAng, 0.2);
		draw.SimpleText(
			self:GetNWString("Name"),
			"npcs_teacher_name",
			-0,
			-410,
			Color(255, 255, 255, 255 * alphaStrength),
			1,
			1
		)

		draw.SimpleText(
			self:GetNWString("Title"),
			"npcs_teacher_title",
			-0,
			-375,
			Color(192, 57, 43, 255 * alphaStrength),
			1,
			1
		)
	cam.End3D2D();

	if IsCurfew() then
		cam.Start3D2D(position + Vector(0,0,2), Angle(0,0,0), 1);
			surface.SetDrawColor(231, 76, 60, 50 * alphaStrength )
			draw.NoTexture()
			draw.Circle(0, 0, 200, 10)
		cam.End3D2D()
	end
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:DrawTranslucent()
    self:Post()
end
