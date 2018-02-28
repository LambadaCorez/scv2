SStep = {}

SStep.silent = {}
SStep.rlysilent = {}
SStep.jumping = {}
SStep.jumped = {}

CreateConVar( "ss_silence_all_footsteps", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY } )
CreateConVar( "ss_silence_slow_footsteps", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY } )
CreateConVar( "ss_silence_eluded_footsteps", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY } )
CreateConVar( "ss_silent_jumps", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY } )

SStep.silence_all = GetConVar( "ss_silence_all_footsteps" ):GetBool()
SStep.silence_slow = GetConVar( "ss_silence_slow_footsteps" ):GetBool()
SStep.silence_eluded = GetConVar( "ss_silence_eluded_footsteps" ):GetBool()
SStep.silence_jumps = GetConVar( "ss_silent_jumps" ):GetBool()

if SERVER then
	util.AddNetworkString( "SILENT_STEP_CVARS" )
	
	local function UpdateClientConVars()
		net.Start( "SILENT_STEP_CVARS" )
		net.Broadcast()
	end
	
	cvars.AddChangeCallback( "ss_silence_all_footsteps", function( convar_name, value_old, value_new )
		SStep.silence_all = tobool( value_new )
		UpdateClientConVars()
	end )
	
	cvars.AddChangeCallback( "ss_silence_slow_footsteps", function( convar_name, value_old, value_new )
		SStep.silence_slow = tobool( value_new )
		UpdateClientConVars()
	end )
	
	cvars.AddChangeCallback( "ss_silence_eluded_footsteps", function( convar_name, value_old, value_new )
		SStep.silence_eluded = tobool( value_new )
		UpdateClientConVars()
	end )
	
	cvars.AddChangeCallback( "ss_silent_jumps", function( convar_name, value_old, value_new )
		SStep.silence_jumps = tobool( value_new )
		UpdateClientConVars()
	end )
end

if CLIENT then
	-- For some reason, cvars.AddChangeCallback doesn't get called clientside whenever FCVAR_REPLICATED is in place.
	net.Receive( "SILENT_STEP_CVARS", function( len )
		SStep.silence_all = GetConVar( "ss_silence_all_footsteps" ):GetBool()
		SStep.silence_slow = GetConVar( "ss_silence_slow_footsteps" ):GetBool()
		SStep.silence_eluded = GetConVar( "ss_silence_eluded_footsteps" ):GetBool()
		SStep.silence_jumps = GetConVar( "ss_silent_jumps" ):GetBool()
	end )
end

if SERVER and not game.SinglePlayer() then
	return
end

hook.Add( "PlayerTick", "CyberScriptz_SilentStep_PlayerTick", function( ply, mv )
	local steamid = ply:SteamID()
	if not SStep.silence_jumps and SStep.silent[steamid] then
		if mv:KeyDown( IN_JUMP ) then
			if not SStep.jumping[steamid] and ply:OnGround() then
				SStep.jumping[steamid] = true
			end
		elseif ply:OnGround() then
			SStep.jumping[steamid] = false
			SStep.jumped[steamid] = false
		end
	end
end )

hook.Add( "PlayerFootstep", "CyberScriptz_SilentStep_PlayerFootstep", function( ply, pos, foot, sound, volume, filter )
	local steamid = ply:SteamID()
	if SStep.silence_all or ( SStep.silence_slow and SStep.silent[steamid] ) or ( SStep.silence_eluded and SStep.rlysilent[steamid] ) then
		if SStep.jumping[steamid] and not SStep.jumped[steamid] then
			SStep.jumped[steamid] = true
			if not SStep.silence_all then
				return
			end
		end
		return true
	end
end )