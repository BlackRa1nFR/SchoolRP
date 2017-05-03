
function split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function join(inputstr, sep)
	if sep == nil then
		sep = " "
	end

	local s = ""

	if #inputstr > 0 then
		s = table.remove(inputstr, 1)
	end

	if #inputstr > 0 then
		for k, v in ipairs(inputstr) do
			s = s .. sep .. v
		end
	end

	return s
end

local function MessageAll(msg, color)
	net.Start("notification")
		net.WriteTable({
			["specialchatmsg"] = {
				["msg"] = msg,
				["Color"] = color
			}
		})
	net.Broadcast()
end

ChatCommands = {
	["/me"] = function(ply, msg, isTeam)
		msg[1] = ply:GetRPName()
		MessageAll(join(msg), Color(142, 68, 173))
		return ""
	end
}

-- Custom Chat commands
hook.Add("PlayerSay", "textCommands", function(ply, text, isTeam)
	local s = split(text, sep)

	if s[1] and ChatCommands[s[1]] then
		local x = ChatCommands[s[1]](ply, s, isTeam)
		if x then
			return x
		end
	end
end)

local function ScheduleChatCommand( ply, text, public )
    if (string.starts(text, "!sch")) then
		net.Start("notification")
			net.WriteTable({
				["openschedule"] = true
			})
		net.Send(ply)
		return (false)
    end
end

hook.Add( "PlayerSay", "schedule", ScheduleChatCommand)

local function CharacterCreationChatCommand( ply, text, public )
    if (string.starts(text, "!name")) then
		net.Start("notification")
			net.WriteTable({
				["opencharactercreation"] = true
			})
		net.Send(ply)
		return (false)
    end
end

hook.Add( "PlayerSay", "characterCreation", CharacterCreationChatCommand)
