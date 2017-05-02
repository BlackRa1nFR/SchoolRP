
GM.Name = "SchoolRP"
GM.Author = "Fifteen"
GM.Email = "NA"
GM.Website = "NA"

DeriveGamemode( "sandbox" )

-- In seconds
LengthOfDay = 2160.0 --2160.0
NumberOfPeriods = 6

SecondsInDay = 86400.0
SecondsInHalfDay = 86400.0 / 2

CalcSecond = 1.0 / SecondsInDay * LengthOfDay
CalcMinute = CalcSecond * 60.0
CalcHour = CalcMinute * 60.0

LengthOfPeriodInGame = 60
PeriodIntermissionInGame = 30

LengthOfPeriod = CalcMinute * LengthOfPeriodInGame
PeriodIntermission = CalcMinute * PeriodIntermissionInGame
