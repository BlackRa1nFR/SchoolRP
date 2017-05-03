
GM.Name = "SchoolRP"
GM.Author = "Fifteen"
GM.Email = "NA"
GM.Website = "NA"

-- In seconds
LengthOfDay = 2160.0 --2160.0
-- There are 5 periods.
NumberOfPeriods = 5

SecondsInDay = 86400.0
SecondsInHalfDay = 86400.0 / 2

CalcSecond = 1.0 / SecondsInDay * LengthOfDay
CalcMinute = CalcSecond * 60.0
CalcHour = CalcMinute * 60.0

-- In ingame minutes
LengthOfPeriodInGame = 60
PeriodIntermissionInGame = 30

-- Start school at 7:00 AM
SchoolStarts = 7 * 60
-- Start Day 1 at 6:50 AM
StartAtTime = 60 * 7 - 10
-- Start Day 1 at 12:00 AM
-- StartAtTime = 0

LengthOfPeriod = CalcMinute * LengthOfPeriodInGame
PeriodIntermission = CalcMinute * PeriodIntermissionInGame

function IsCurfew()
	return CurrentDayHour > 22 or CurrentDayHour < 5.5
end
