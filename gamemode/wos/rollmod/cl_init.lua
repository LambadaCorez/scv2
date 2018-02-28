
--[[-------------------------------------------------------------------
	Roll Mod:
		Dodge, duck, dip, dive and... roll!
			Powered by
						  _ _ _    ___  ____  
				__      _(_) | |_ / _ \/ ___| 
				\ \ /\ / / | | __| | | \___ \ 
				 \ V  V /| | | |_| |_| |___) |
				  \_/\_/ |_|_|\__|\___/|____/ 
											  
 _____         _                 _             _           
|_   _|__  ___| |__  _ __   ___ | | ___   __ _(_) ___  ___ 
  | |/ _ \/ __| '_ \| '_ \ / _ \| |/ _ \ / _` | |/ _ \/ __|
  | |  __/ (__| | | | | | | (_) | | (_) | (_| | |  __/\__ \
  |_|\___|\___|_| |_|_| |_|\___/|_|\___/ \__, |_|\___||___/
                                         |___/             
----------------------------------------------------------------------[[
							  
	Lua Developer: King David
	Contact: http://steamcommunity.com/groups/wiltostech
		
-------------------------- Copyright 2017, David "King David" Wiltos ]]--


hook.Add( "CalcView", "wOS.RollMod.FirstPerson", function( ply, pos, ang )

	if ( !IsValid( ply ) or !ply:Alive() or ply:InVehicle() or ply:GetViewEntity() != ply ) then return end
	if !ply:wOSIsRolling() then return end
	local cam_mode = GetGlobalInt( "wos_roll_cameramode" ) or 0	
	if cam_mode < 1 then return end
	if cam_mode <= 2 then
		local angs = ang
		local eyes = ply:GetAttachment( ply:LookupAttachment( "eyes" ) );
		if cam_mode == 2 then
			angs = eyes.Ang
		end
		return {
			origin = eyes.Pos + Vector( 0, 0, 1.5 ),
			angles = angs,
			fov = GetConVar( "fov_desired" ):GetInt(), 
			drawviewer = false
		}
	elseif cam_mode == 3 then
		local trace = util.TraceHull( {
			start = pos,
			endpos = pos - ang:Forward() * 100,
			filter = { ply:GetActiveWeapon(), ply },
			mins = Vector( -4, -4, -4 ),
			maxs = Vector( 4, 4, 4 ),
		} )

		if ( trace.Hit ) then pos = trace.HitPos else pos = pos - ang:Forward() * 100 end

		return {
			origin = pos,
			angles = ang,
			drawviewer = true
		}
	end
	
end )

hook.Add( "CalcViewModelView", "wOS.RollMod.RotateGun", function(wep, viewmodel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)

	if !IsValid( wep ) then return end
	
	local ply = LocalPlayer()
	
	if !ply:wOSIsRolling() then return end
	local cam_mode = GetGlobalInt( "wos_roll_cameramode" ) or 0	
	if cam_mode < 1 then return end	
	local eyes = ply:GetAttachment( ply:LookupAttachment( "eyes" ) );	
	
	return eyes.Pos, ( cam_mode > 1 and eyes.Ang ) or eyeAngles
	
end )


hook.Add( "CreateMove", "wOS.RollMod.PreventMovement", function( cmd )
	if LocalPlayer():wOSIsRolling() then
		cmd:ClearButtons()
		cmd:ClearMovement()
		if LocalPlayer():GetRollDir() != 3 and LocalPlayer():GetRollTime() >= CurTime() + 0.1 then
			cmd:SetButtons( IN_DUCK )
		end
	end
end )

--Credit to Stalker for this thing, super handy.
net.Receive( "wOS.RollMod.CallRestart", function()

	local ply = net.ReadEntity()
	
	if IsValid( ply ) then
	
		ply:AnimRestartMainSequence()
		
	end
	
end )