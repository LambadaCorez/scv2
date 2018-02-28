
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

util.AddNetworkString( "wOS.RollMod.CallRestart" )

resource.AddWorkshop( "757604550" )
resource.AddWorkshop( "848953359" )
resource.AddFile( "sound/wos/roll/dive.wav" )
resource.AddFile( "sound/wos/roll/land.wav" )

CreateConVar( "wos_roll_doubletap", "1", { FCVAR_ARCHIVE } )
CreateConVar( "wos_roll_cameramode", "2", { FCVAR_ARCHIVE } )
CreateConVar( "wos_roll_dodgedamage", "1", { FCVAR_ARCHIVE } )

cvars.AddChangeCallback( "wos_roll_cameramode", function( cvar, old, new )
	SetGlobalInt( "wos_roll_cameramode", tonumber( new ) )
end, "wos_roll_cameramode" )

hook.Add( "PlayerInitialSpawn", "wOS.RollMod.SyncCameraMode", function()
	SetGlobalInt( "wos_roll_cameramode", GetConVarNumber( "wos_roll_cameramode" ) )
end )

concommand.Add( "wos_roll_use", function( ply, cmd, args )
	if !IsValid( ply ) or !ply:Alive() or ply:wOSIsRolling() or !ply:OnGround() then return end
	ply:StartRolling()
end )

hook.Add( "OnPlayerHitGround", "wOS.RollMod.PlayLandNoise", function( ply, inWater, onFloater, speed )
	if ply.wOS.Landed then return end
	ply:EmitSound( "wos/roll/land.wav" )
	ply.wOS.Landed = true
end )

hook.Add( "ScalePlayerDamage", "wOS.RollMod.DodgeHook", function( ent, hitgroup, dmginfo )
	if !GetConVar( "wos_roll_dodgedamage" ):GetBool() then return end
	if !IsValid( ent ) or !ent:Alive() or !ent:wOSIsRolling() then return end
	if not ent:IsPlayer() then return end
	
	local dmgtype = dmginfo:GetDamageType()
	
	if wOS.RollMod.Dodgeables[ dmgtype ] then
		ent:EmitSound( "weapons/fx/nearmiss/bulletLtoR0" .. math.random( 3, 7 ) .. ".wav", 75, math.random( 90, 110 ) )
		dmginfo:ScaleDamage( 0 )
		hook.Call( "wOS.RollMod.DodgedDamage", nil, ent, hitgroup, dmginfo )
		return true
	end
	
end )

hook.Add( "PlayerSpawn", "wOS.RollMod.Reset", function( ply )

	ply:SetNW2Float( "wOS.RollTime", 0 )
	ply:SetNW2Int( "wOS.RollDir", 0 )
	ply.wOS = {}
	ply.wOS.LastRoll = 0
	ply.wOS.LastKey = 0
	ply.wOS.Landed = true
	
end )

local meta = FindMetaTable( "Player" )

function meta:OnLadder()

	return self:GetMoveType() == MOVETYPE_LADDER

end

function meta:CanRoll()

	if self:KeyDown( IN_WALK ) then return false end

	local hookcheck = hook.Call( "wOS.RollMod.ShouldRoll", nil, self )
	if hookcheck then return hookcheck end
	
	return ( !self:wOSIsRolling() and self:OnGround() and !self:OnLadder() )
	
end

function meta:StartRolling()
	if not self:CanRoll() then return end
	hook.Call( "wOS.RollMod.OnRoll", nil, self )
	local time = 0.75
	if self:KeyDown( IN_BACK ) then
		self:SetNW2Int( "wOS.RollDir", 3 )
		self:SetVelocity( self:GetForward() * -4*wOS.RollMod.RollSpeed )
		self:ViewPunch( Angle( -5, 0, 0 ) )
		self:SetNW2Float( "wOS.RollTime", CurTime() + 1 )	
	elseif self:KeyDown( IN_MOVELEFT ) then
		self:SetNW2Int( "wOS.RollDir", 4 )
		self:SetLocalVelocity( self:GetRight() * -800  )
		self:ViewPunch( Angle( 0, 0, -10 ) )
		self:SetNW2Float( "wOS.RollTime", CurTime() + 0.62 )	
		time = 0.47
	elseif self:KeyDown( IN_MOVERIGHT ) then
		self:SetNW2Int( "wOS.RollDir", 5 )	
		self:SetLocalVelocity( self:GetRight() * 800 )
		self:ViewPunch( Angle( 0, 0, 10 ) )
		self:SetNW2Float( "wOS.RollTime", CurTime() + 0.78 )	
		time = 0.47
	else
		self:SetNW2Int( "wOS.RollDir", 2 )
		self:SetLocalVelocity( self:GetForward() * 800 )
		self:ViewPunch( Angle( 5, 0, 0 ) )
		self:SetNW2Float( "wOS.RollTime", CurTime() + 0.85 )	
		time = 0.2
	end
	wOS.RollMod:ResetAnimation( self )
	self:EmitSound( "wos/roll/dive.wav" )
	self.wOS.LastRoll = 0
	timer.Simple( time*0.63, function()
		if not IsValid( self ) then return end
		if not self:Alive() then return end
		if not self:wOSIsRolling() then return end
		if not self:OnGround() then self.wOS.Landed = false return end
		self:EmitSound( "wos/roll/land.wav" )		
	end )
end

hook.Add( "KeyPress", "wOS.RollMod.CheckDoubleTap", function( ply, key )
	if !GetConVar( "wos_roll_doubletap" ):GetBool() then return end
	if ply:InVehicle() then return end
	if ( !IsValid( ply) or !ply:Alive() ) then return end
	if ( key != IN_BACK and key != IN_FORWARD and key != IN_MOVELEFT and key != IN_MOVERIGHT ) then return end
	if ply:wOSIsRolling() then return end
	if !ply:OnGround() then return end
	
	if ply.wOS.LastRoll + wOS.RollMod.Sensitivity > CurTime() and ply.wOS.LastKey == key then
		ply:StartRolling()
	else
		ply.wOS.LastRoll = CurTime() 
		ply.wOS.LastKey = key
	end

end )
