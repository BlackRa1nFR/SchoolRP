
DayTime = 0
CurPeriod = -1

local Students = {}

local function PutEveryoneRoam()
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
end

function StartNewDay(timeStart)
	if not timeStart then
		timeStart = 0
	end

	CurPeriod = 0
	print ("Creating a new day!")
	-- Clean up if refreshing
	timer.Remove("DayTimeTimer")
	timer.Remove("StartClasses")
	timer.Remove("PeriodTimer")
	PutEveryoneRoam()

	DayTime = CurTime() - timeStart * CalcMinute
	SetGlobalInt("DayTime", DayTime)
	SetGlobalInt("ClassPeriod", CurPeriod)
	SetGlobalInt("ClassPeriodEnds", -1)

	timer.Create(
		"DayTimeTimer",
		LengthOfDay - timeStart * CalcMinute,
		0,
		function()
			StartNewDay()
		end
	)

	-- Start classes at 7:00 AM
	-- CalcHour == 1 in-game hour
	if CalcMinute * SchoolStarts - timeStart * CalcMinute > 0 then
		timer.Create(
			"StartClasses",
			CalcMinute * SchoolStarts - timeStart * CalcMinute,
			1,
			function()
				CreatePeriods()
			end
		)
	end
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
		PutEveryoneRoam()
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
							v.ent:Roam(SCHOOL_POINTS)
						end
					end
				end

				for k,v in pairs(Students) do
					if v.ent then
						print (v.Schedule[period])
						local c = CLASSES[v.Schedule[period]]
						local d = 's_' .. c.Room

						v.ent:SetDestination(d)
					else
						v.ent:Roam(SCHOOL_POINTS)
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
	2,
	function()
		-- Spawn all teachers
		for k,v in pairs(TEACHERS) do
			v.ent = SpawnTeacher(v)
		end

		local principal = {
			["Name"] = "Principal Skinner",
			["Title"] = "Principal",
			["Model"] = "models/monk.mdl"
		}
		principal.ent = SpawnTeacher(principal)
		principal.ent:Roam(SCHOOL_POINTS)

		local detentionTeacher = {
			["Name"] = "Mr. " .. TEACHER_NAMES[math.random(#TEACHER_NAMES)],
			["Title"] = "Detention Teacher",
			["Model"] = TEACHER_MODELS[1][math.random(#TEACHER_MODELS[1])]
		}
		detentionTeacher.ent = SpawnTeacher(detentionTeacher)
		detentionTeacher.ent:SetPos(POINTS['t_StudyingRoom1'][1])
		detentionTeacher.ent:SetDestination('t_StudyingRoom1')

		local schs = {
			[9] = {
				[1] = {"AlgerbraI"},
				[2] = {"BiologyI", "EarthScience"},
				[3] = {"Lunch"},
				[4] = {"English9"},
				[5] = {"WorldHistory", "Government"},
			},
			[10] = {
				[1] = {"PhysicsI", "ChemistryI"},
				[2] = {"AlgerbraII"},
				[3] = {"Lunch"},
				[4] = {"AmericanHistory", "Sociology"},
				[5] = {"English10"},
			},
			[11] = {
				[1] = {"Geometry"},
				[2] = {"BiologyI", "EarthScienceI"},
				[3] = {"Lunch"},
				[4] = {"English11"},
				[5] = {"WorldHistory", "Government"},
			},
			[12] = {
				[1] = {"PhysicsI", "ChemistryI"},
				[2] = {"PreCalculus"},
				[3] = {"Lunch"},
				[4] = {"AmericanHistory", "Sociology"},
				[5] = {"English12"},
			},
		}

		for i=1,20 do
			local gender = math.random(1,2)
			local grade = math.random(9,12)
			local sch = GenerateSchedule(grade)

			local s = {
				["Name"] = TEACHER_NAMES[math.random(#TEACHER_NAMES)],
				["Title"] = grade .. "th Grader",
				["Model"] = STUDENT_MODELS[gender][math.random(#STUDENT_MODELS[gender])],
				["Schedule"] = sch,
			}
			s.ent = SpawnStudent(s)
			s.ent:SetGender(gender)
			table.insert(Students, s)
		end
	end
)

-- Start a new day.
StartNewDay(StartAtTime)
