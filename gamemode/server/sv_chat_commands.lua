
function chatCommand( ply, text, public )
    if (string.starts(text, "!sch")) then
		net.Start("notification")
			net.WriteTable({
				["openschedule"] = true
			})
		net.Send(ply)
		return(false)
    end
end

hook.Add( "PlayerSay", "schedule", chatCommand)
