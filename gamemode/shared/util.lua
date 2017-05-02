
local player = FindMetaTable("Player")

function printtab(t)
	print(util.TableToKeyValues(t))
end

function TLen(t)

	local l = 0

	for k,v in pairs(t) do
		l = l + 1
	end

	return l

end

function comma_value(amount)
	if !amount then return 0 end

	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end
