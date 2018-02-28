include( "sh_silentstep.lua" )

CreateClientConVar( "ss_walk_override_sprint", "1", true, true )

net.Receive( "SILENT_STEP_DATA", function( len )
	local steamid = net.ReadString()
	SStep.silent[steamid] = net.ReadBool()
	SStep.rlysilent[steamid] = net.ReadBool()
end )

hook.Add( "CreateMove", "ss_walk_override_sprint", function( cmd )
	local buttons = cmd:GetButtons()
	if bit.band( buttons, IN_WALK ) > 0 and bit.band( buttons, IN_SPEED ) > 0 then
		if GetConVar( "ss_walk_override_sprint" ):GetBool() then
			cmd:SetButtons( bit.band( buttons, bit.bnot( IN_SPEED ) ) )
		end
	end
end )