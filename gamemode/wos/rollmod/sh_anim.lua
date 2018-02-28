
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

local meta = FindMetaTable( "Player" )

function meta:wOSIsRolling()

	return ( self:GetRollTime() >= CurTime() )

end

function meta:GetRollTime()

	return ( self:GetNW2Float( "wOS.RollTime", 0 ) )

end

function meta:GetRollDir()

	return ( self:GetNW2Int( "wOS.RollDir", 1 ) )

end

function wOS.RollMod:ResetAnimation( ply )

	ply:AnimRestartMainSequence()
	if SERVER then
		net.Start( "wOS.RollMod.CallRestart" )
			net.WriteEntity( ply )
		net.Broadcast()
	end
	
end

hook.Add( "UpdateAnimation", "wOS.RollMod.SlowDownAnim", function(ply, velocity, maxSeqGroundSpeed)
	if ply:wOSIsRolling() then
		if ply:GetRollDir() == 2 then
			ply:SetPlaybackRate( 0.95 )
		elseif ply:GetRollDir() == 4 then
			ply:SetPlaybackRate( 0.95 )
		else
			ply:SetPlaybackRate( 0.95)
		end
		return true
	end
end )

hook.Add( "CalcMainActivity", "wOS.RollMod.Animations", function( ply, velocity )

	if !IsValid( ply ) or !ply:wOSIsRolling() then return end
	
	local seq = wOS.RollMod.Animations[ ply:GetRollDir() ]
	local seqid = ply:LookupSequence( seq or "" )
	if seqid < 0 then return end
	if ply:GetRollDir() == 2 then
		ply:SetPlaybackRate( 0.95 )
	end
	return -1, seqid or nil

end )

hook.Add( "Move", "wOS.RollMod.MoveDir", function( ply, mv ) 
	if not ply:wOSIsRolling() then return end
	if ply:GetRollDir() == 3 then return end
	
	local ang = mv:GetMoveAngles()
	local vel = mv:GetVelocity()
	
	if ply:GetRollDir() == 2 then
		vel = ang:Forward()*wOS.RollMod.RollSpeed	
	elseif ply:GetRollDir() == 4 then
		vel = ang:Right()*-wOS.RollMod.RollSpeed*(4/3)
	elseif ply:GetRollDir() == 5 then
		vel = ang:Right()*wOS.RollMod.RollSpeed*(4/3)
	end
	
	mv:SetVelocity( vel )
	
end )


