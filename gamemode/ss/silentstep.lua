AddCSLuaFile( "sh_silentstep.lua" )
AddCSLuaFile( "cl_silentstep.lua" )

include( "sh_silentstep.lua" )

CreateConVar( "ss_silent_walking", "1", { FCVAR_ARCHIVE } )
CreateConVar( "ss_silent_elude_npcs", "1", { FCVAR_ARCHIVE } )
CreateConVar( "ss_silent_elude_timeout", "5", { FCVAR_ARCHIVE } )

local silent_walking = GetConVar( "ss_silent_walking" ):GetBool()
local silent_elude_npcs = GetConVar( "ss_silent_elude_npcs" ):GetBool()
local silent_elude_timeout = GetConVar( "ss_silent_elude_timeout" ):GetInt()

cvars.AddChangeCallback( "ss_silent_walking", function( convar_name, value_old, value_new )
	silent_walking = tobool( value_new )
end )

cvars.AddChangeCallback( "ss_silent_elude_npcs", function( convar_name, value_old, value_new )
	silent_elude_npcs = tobool( value_new )
end )

cvars.AddChangeCallback( "ss_silent_elude_timeout", function( convar_name, value_old, value_new )
	silent_elude_timeout = tonumber( value_new )
end )

util.AddNetworkString( "SILENT_STEP_DATA" )

local function SendSilentData( steamid )
	net.Start( "SILENT_STEP_DATA" )
	net.WriteString( steamid )
	net.WriteBool( SStep.silent[steamid] )
	net.WriteBool( SStep.rlysilent[steamid] )
	net.Broadcast()
end

hook.Add( "Move", "CyberScriptz_SilentStep_Move", function( ply, mv )
	local steamid = ply:SteamID()
	if mv:KeyDown( IN_FORWARD ) or mv:KeyDown( IN_BACK ) or mv:KeyDown( IN_MOVELEFT ) or mv:KeyDown( IN_MOVERIGHT ) then
		if not ( ( SStep.silence_slow or SStep.silence_eluded ) and not mv:KeyDown( IN_SPEED ) and ( ( silent_walking and mv:KeyDown( IN_WALK ) ) or ply:Crouching() ) ) then
			if SStep.silent[steamid] then
				timer.Stop( "silent-" .. steamid )
				SStep.silent[steamid] = false
				SStep.rlysilent[steamid] = false
				SendSilentData( steamid )
			end
			return
		end
	end
	if not SStep.silent[steamid] then
		SStep.silent[steamid] = true
		timer.Create( "silent-" .. steamid, silent_elude_timeout, 1, function()
			SStep.rlysilent[steamid] = true
			SendSilentData( steamid )
		end )
		SendSilentData( steamid )
	end
end )

hook.Add( "Think", "CyberScriptz_SilentStep_Think", function()
	if silent_elude_npcs then
		for i, npc in pairs( ents.FindByClass( "npc_*" ) ) do
			if IsValid( npc ) and npc:IsNPC() then
				local enemy = npc:GetEnemy()
				if enemy and enemy:IsPlayer() and ( SStep.silence_all or SStep.rlysilent[enemy:SteamID()] ) then
					npc:MarkEnemyAsEluded()
				end
			end
		end
	end
end )