
DayTime = 0
CurPeriod = -1

local Students = {}

function StartNewDay()
	CurPeriod = 0
	print ("Creating a new day!")
	-- Clean up if refreshing
	timer.Remove("DayTimeTimer")
	timer.Remove("StartClasses")
	timer.Remove("PeriodTimer")

	DayTime = CurTime()
	SetGlobalInt("DayTime", DayTime)
	SetGlobalInt("ClassPeriod", CurPeriod)
	SetGlobalInt("ClassPeriodEnds", -1)

	timer.Create(
		"DayTimeTimer",
		LengthOfDay,
		0,
		function()
			StartNewDay()
		end
	)

	-- Start classes at 7:00 AM
	-- CalcHour == 1 in-game hour
	timer.Create(
		"StartClasses",
		CalcHour * 7,
		1,
		function()
			CreatePeriods()
		end
	)
end

function CreatePeriods()
	CurPeriod = 0
	print("Creating new periods!")

	-- Start the initial period.
	CurPeriod = CurPeriod + 1
	StartPeriod(CurPeriod)

	timer.Create(
		"PeriodTimer",
		LengthOfPeriod + PeriodIntermission,
		NumberOfPeriods,
		function()
			CurPeriod = CurPeriod + 1
			StartPeriod(CurPeriod)
		end
	)
end

function StartPeriod(period)
	if period > NumberOfPeriods then
		SetGlobalInt("ClassPeriod", 0)
		SetGlobalInt("ClassPeriodEnds", -1)

		for k,v in pairs(TEACHERS) do
			if v.ent then
				v.ent:Roam()
			end
		end

		for k,v in pairs(Students) do
			if v.ent then
				v.ent:Roam()
			end
		end
	else
		SetGlobalInt("ClassPeriod", period)
		SetGlobalInt("ClassPeriodEnds", CurTime() + LengthOfPeriod + PeriodIntermission)

		if SCHEDULE[period] then
			if SCHEDULE[period][-1] then
				for k,v in pairs(TEACHERS) do
					if v.ent then
						local d = 't_Cafe' .. math.random(1, 6)

						v.ent:SetDestination(d)
					end
				end

				for k,v in pairs(Students) do
					if v.ent then
						local d = 's_Cafe' .. math.random(1, 3)

						v.ent:SetDestination(d)
					end
				end
			else
				for k,v in pairs(TEACHERS) do
					if v.ent then
						if SCHEDULE[period][k] then
							local c = SCHEDULE[period][k]
							local r = CLASSES[c].Room
							local d = 't_' .. r

							v.ent:SetDestination(d)
						else
							v.ent:Roam()
						end
					end
				end

				for k,v in pairs(Students) do
					if v.ent then
						local c = CLASSES[v.Schedule[period]]
						local d = 's_' .. c.Room

						v.ent:SetDestination(d)
					else
						v.ent:Roam()
					end
				end
			end
		end
	end
	print ("Starting new Period " .. period)
	
end

local function SpawnTeacher(meta)
	local entTable = nil

	local SpawnableEntities = list.Get( "SpawnableEntities" )
	entTable = SpawnableEntities["srp_teacher"]
	local entClass = entTable.ClassName

	local ent = ents.Create(entClass)

	if entTable then
		if (entTable.KeyValues) then
			for k, v in pairs(entTable.KeyValues) do
				ent:SetKeyValue(k, v)
			end
		end

		local p = POINTS[ROAMING_POINTS[math.random(#ROAMING_POINTS)]]
		ent:SetPos(p[1] + Vector(math.random(-50, 50), math.random(-50, 50), 0))
		ent:SetAngles(p[2])
		ent:Spawn()
		ent:Activate()
		ent:SetNWName(meta.Name)
		ent:AltModel(meta.Model)
		ent:SetTitle(meta.Title)

		print ("spawning " .. meta.Name)

		return ent
	end

	print ("Not spawning")
end

local function SpawnStudent(meta)
	local entTable = nil

	local SpawnableEntities = list.Get( "SpawnableEntities" )
	entTable = SpawnableEntities["srp_student"]
	local entClass = entTable.ClassName

	local ent = ents.Create(entClass)

	if entTable then
		if (entTable.KeyValues) then
			for k, v in pairs(entTable.KeyValues) do
				ent:SetKeyValue(k, v)
			end
		end

		local p = POINTS[ROAMING_POINTS[math.random(#ROAMING_POINTS)]]
		ent:SetPos(p[1] + Vector(math.random(-50, 50), math.random(-50, 50), 0))
		ent:SetAngles(p[2])
		ent:Spawn()
		ent:Activate()
		ent:SetNWName(meta.Name)
		ent:AltModel(meta.Model)
		ent:SetTitle(meta.Title)

		print ("spawning " .. meta.Name)

		return ent
	end

	print ("Not spawning")
end

-- Clean up all teachers
for k,v in pairs(ents.GetAll()) do
	if v:GetClass() == "srp_teacher" or v:GetClass() == "srp_student" then
		v:Remove()
	end
end

timer.Simple(
	70,
	function()
		-- Spawn all teachers
		for k,v in pairs(TEACHERS) do
			v.ent = SpawnTeacher(v)
		end

		local schs = {
			{
				 "AlgerbraI",
				 "BiologyI",
				 "Lunch",
				 "English9",
				 "WorldHistory"
			},
			{
				 "AlgerbraII",
				 "BiologyI",
				 "Lunch",
				 "English9",
				 "WorldHistory"
			},
			{
				 "AlgerbraI",
				 "BiologyI",
				 "Lunch",
				 "English9",
				 "EarthScienceI"
			},
			{
				 "AlgerbraI",
				 "BiologyI",
				 "Lunch",
				 "English9",
				 "Sociology"
			},
		}

		for i=1,10 do
			local gender = math.random(1,2)

			local s = {
				["Name"] = TEACHER_NAMES[math.random(#TEACHER_NAMES)],
				["Title"] = "9th Grader",
				["Model"] = TEACHER_MODELS[gender][math.random(#TEACHER_MODELS[gender])],
				["Schedule"] = schs[math.random(#schs)],
			}
			s.ent = SpawnStudent(s)
			table.insert(Students, s)
		end
	end
)

-- Start a new day.
StartNewDay()
