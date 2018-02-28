include( "sh_stealth.lua" )
AddCSLuaFile( "sh_stealth.lua" )
resource.AddFile("sound/stealth/alert.mp3");
resource.AddFile("sound/stealth/alertmusic.wav");

util.AddNetworkString("stealth_enabled")
util.AddNetworkString("stealth_alerttime")
util.AddNetworkString("stealth_override")
util.AddNetworkString("stealth_keepcorpses")
util.AddNetworkString("stealth_alertondamage")
util.AddNetworkString("stealth_multiplier")
util.AddNetworkString("stealth_minsight")
util.AddNetworkString("stealth_maxsight")
util.AddNetworkString("stealth_movebonus")
util.AddNetworkString("stealth_minhearing")
util.AddNetworkString("stealth_shotrange")
util.AddNetworkString("stealth_suppmultiplier")
util.AddNetworkString("stealth_backuptime")
util.AddNetworkString("stealth_backuprange")
util.AddNetworkString("stealth_maxcorpses")
util.AddNetworkString("stealth_sensortime")
util.AddNetworkString("stealth_sensorrange")
util.AddNetworkString("stealth_sleeptime")
util.AddNetworkString("stealth_reloadsettings")
util.AddNetworkString("stealth_defaultsettings")
util.AddNetworkString("stealth_clientinitialized")

local npctable = {}
local corpsetable = {}
local npcdied = false

local silent_list = {}
local npc_list = {}
local suppressed_list = {}

--Add silent stuff here
local silent_default = 
{
"weapon_physgun",
"gmod_tool",
"weapon_crossbow",
"novoice",
"weapon_gascan_limited",
"weapon_gascan",
"blink_swep",
"climb_swep2",
"weapon_fists",
"weapon_m24sd",
"spiderman's_swep",
"weapon_medkit",
"weapon_minecraft_torch",
"laserpointer",
"remotecontroller",
"m9k_honeybadger",
"m9k_mp7",
"m9k_harpoon",
"m9k_knife",
"m9k_machete",
"m9k_fists",
"m9k_damascus",
"m9k_svu",
"gdcw_lr300ironsupp",
"gdcw_lr300scopesupp",
"gdcw_mk14ebr_supp",
"weapon_crowbar",
"weapon_bugbait",
"weapon_frag",
"weapon_physcannon",
"weapon_slam",
"weapon_stunstick",
"weapon_chumtoad",
"weapon_crossbow_hl",
"weapon_crowbar_hl",
"weapon_handgrenade",
"weapon_tripmine",
"weapon_satchel",
"weapon_snark",
"weapon_barnacle",
"weapon_knife",
"weapon_penguin",
"weapon_pipewrench",
"tfa_nmrih_bat",
"tfa_nmrih_bcd",
"tfa_nmrih_cleaver",
"tfa_nmrih_crowbar",
"tfa_nmrih_bow",
"tfa_nmrih_zippo",
"tfa_nmrih_etool",
"tfa_nmrih_fireaxe",
"tfa_nmrih_fext",
"tfa_nmrih_fists",
"tfa_nmrih_frag",
"tfa_nmrih_fubar",
"tfa_nmrih_hatchet",
"tfa_nmrih_kknife",
"tfa_nmrih_lpipe",
"tfa_nmrih_machete",
"tfa_nmrih_maglite",
"tfa_nmrih_molotov",
"tfa_nmrih_pickaxe",
"tfa_nmrih_sledge",
"tfa_nmrih_spade",
"tfa_nmrih_tnt",
"tfa_nmrih_welder",
"tfa_nmrih_wrench",
"tfcss_css_knife",
"tfcss_cssfrag",
"tfcss_css_c4",
"tfcss_css_smoke",
"tfcss_css_c4_alt",
"tfcss_cssfrag_alt",
"tfcss_css_knife_alt",
"tfcss_css_smoke_alt",
"tfa_csgo_bayonet",
"tfa_csgo_butfly",
"tfa_csgo_decoy",
"tfa_csgo_falch",
"tfa_csgo_flash",
"tfa_csgo_flip",
"tfa_csgo_frag",
"tfa_csgo_gut",
"tfa_csgo_tackni",
"tfa_csgo_incen",
"tfa_csgo_karam",
"tfa_csgo_ctknife",
"tfa_csgo_tknife",
"tfa_csgo_m9",
"tfa_csgo_molly",
"tfa_csgo_pushkn",
"tfa_csgo_smoke",
"wpn_proxsensor",
"wpn_soundgrenade",
"wpn_stealthfists",
"gmod_flashbang",
"weapon_wt_cerebralbore",
"realistic_hook",
"weapon_fulton"


}

local suppressed_default = 
{
"tfa_svu",
"tfa_wa2000",
"tfa_honeybadger",
"tfa_mp7",
"tfa_mp5sd",
"tfa_mp9",
"tfcss_tmp",
"tfcss_tmp_alt",
"tfa_val",
"tfa_smg_mp9",
"mwr_m4a1",
"mwr_mp5sd",
"cod4_m21sd",
"wpn_stealthtranquilizer",
"weapon_silenced_usp"
}

local npc_default = 
{
"npc_metropolice",
"npc_combine_s"
}

local function load_files()
	silent_list = table.Copy(silent_default)
	suppressed_list = table.Copy(suppressed_default)
	local s = file.Read("stealth/silent.txt", "DATA")
	if s then
		silent_list2 = string.Explode("\r\n", s)
		for k,v in pairs(silent_list2) do
			if !table.HasValue(silent_list,v) then table.insert(silent_list,v) end
		end
	else
		local output = "weapon_example1\r\nweapon_example2"
		if !file.IsDir("stealth", "DATA") then
			file.CreateDir("stealth")
		end
		file.Write("stealth/silent.txt", output)
	end
	local s = file.Read("stealth/npc.txt", "DATA")
	if s then
		npc_list = string.Explode("\r\n", s)
		-- PrintTable(npc_list)
	else
		npc_list = npc_default
		local output = string.Implode("\r\n", npc_list)
		if !file.IsDir("stealth", "DATA") then
			file.CreateDir("stealth")
		end
		file.Write("stealth/npc.txt", output)
	end
	local s = file.Read("stealth/suppressed.txt", "DATA")
	if s then
		suppressed_list2 = string.Explode("\r\n", s)
		for k,v in pairs(suppressed_list2) do
			if !table.HasValue(suppressed_list,v) then table.insert(suppressed_list,v) end
		end
	else
		local output = "weapon_example3\r\nweapon_example4"
		if !file.IsDir("stealth", "DATA") then
			file.CreateDir("stealth")
		end
		file.Write("stealth/suppressed.txt", output)
	end
	print ("Stealth Mod files loaded")
end

concommand.Add("stealth_reloadsettings", function ()
	load_files()
end)

hook.Add("Initialize", "initializing_stealth", function()
	load_files()
end)

local function IsVisible(ply,npc)
	local tr = util.TraceLine{
		start = npc:EyePos(),
		endpos = ply:EyePos(),
		filter = {ply,npc},
		mask = MASK_VISIBLE_AND_NPCS
	}
	
	return not tr.Hit
end

local function IsEntVisible(ent,npc)
	local tr = util.TraceLine{
		start = npc:EyePos(),
		endpos = ent:GetPos(),
		filter = {ent,npc},
		mask = MASK_VISIBLE_AND_NPCS
	}
	
	return not tr.Hit
end

local function alert(ply, npc, silent)
	if !ply:Alive() or not npc.sm_MEnemies then return end
	if table.HasValue(npc.sm_MEnemies, ply) then return end
	npc:SetSchedule(0)
	table.insert(npc.sm_MEnemies,ply)
	npc:AddEntityRelationship(ply, D_HT, 1)
	if silent == true and npc:GetNPCState() <= NPC_STATE_ALERT then
		npc:SetLastPosition(ply:GetPos())
		npc:SetEnemy(ply)
		npc:UpdateEnemyMemory( ply, ply:GetPos() ) 
		npc:SetSchedule( SCHED_CHASE_ENEMY  )
	end
	-- Attack player as soon as he's detected (this is old)
	--[[
	local plypos = ply:GetPos()
	npc:SetLastPosition(plypos)
	npc:SetEnemy(ply)
	npc:UpdateEnemyMemory( ply, plypos ) 
	]]--
	npc.sm_investigating = 0
	npc.sm_targetpos = nil
	npc.sm_running = false
	npc:SetNWBool("sm_alerted",true)
	
	-- Little delay, so it doesn't display anything if the enemy died intantly
	timer.Simple(0.1, function()
		if IsValid(npc) and IsValid(ply) and npc:Health() > 0 then
			-- Tell player that he alerted someone
			umsg.Start( "NPCAlerted", ply )
				umsg.Entity( npc )
				umsg.Bool( silent )
			umsg.End();	
			-- Broadcast alert effect
			umsg.Start( "NPCEffect" )
				umsg.Entity( npc )
				umsg.String( "alert" )
			umsg.End();	
		end
	end)
	if silent == false then
		timer.Simple(GetConVarNumber("stealth_backuptime"), function() 
			if IsValid(npc) and IsValid(ply) then
				for k, v in pairs(npctable) do
					if IsValid(v) and v != npc and npc:GetPos():Distance(v:GetPos()) <= GetConVarNumber("stealth_backuprange") then alert(ply, v, true)	end
				end
			end
		end) 
	end
end

function sendinvestigate(npc, pos, run)
	investigate(npc, pos, run, false)
end

local function investigate(npc, pos, run, nearest)
	-- If nearest is true, then only change target if its closer than the last one
	-- If its false, then always change target
	-- This prevents the NPC from changing target constantly if he see more than one player at the same time
	if #npc.sm_MEnemies != 0 then return end
	if npc.invdelay > CurTime() then return end
	npc.invdelay = CurTime() + 3
	if npc.sm_investigating == 0 then
		-- Little delay, so it doesn't display anything if the enemy died intantly
		timer.Simple(0.1, function()
			if IsValid(npc) and npc:Health() > 0 then
				-- Broadcast alert effect
				umsg.Start( "NPCEffect" )
					umsg.Entity( npc )
					umsg.String( "caution" )
				umsg.End();
			end
		end)
	end
	npc.sm_investigating = 1
	--if nearest == false or (nearest == true and (npc.sm_targetpos == nil or npc:GetPos():Distance(npc.sm_targetpos) >= npc:GetPos():Distance(pos))) then
	npc.sm_targetpos = pos
	npc:SetLastPosition(pos)
	if run == false and npc.sm_running == false then
		npc:SetSchedule( SCHED_FORCED_GO )
	else
		npc:SetSchedule( SCHED_FORCED_GO_RUN )
		npc.sm_running = true
	end
	--end
end

local function calm(ply, npc)
	-- Always calm him down, don't wait until he loses track of the player
	-- if ply==npc:GetEnemy() then return end
	for k = #npc.sm_MEnemies, 1, -1 do
		local v = npc.sm_MEnemies[k]
		if v==ply then
			npc:AddEntityRelationship(ply, D_NU, 1)
			table.remove(npc.sm_MEnemies,k)
			-- Make npc forget the player
			npc:SetTarget(npc)
			
			-- Tell player that an npc is not looking for him anymore
			umsg.Start( "NPCCalmed", ply );
				umsg.Entity( npc );
			umsg.End();	
			-- Broadcast alert effect
			umsg.Start( "NPCEffect" )
				umsg.Entity( npc )
				umsg.String( "caution" )
			umsg.End();	
			return
		end
	end
	if #npc.sm_MEnemies < 1 then npc:SetNWBool("sm_alerted",false) end
end

function GetNPCSchedule( npc )
	if ( !IsValid( npc ) ) then return end
	for s = 0, LAST_SHARED_SCHEDULE-1 do
		if ( npc:IsCurrentSchedule( s ) ) then return s end
	end
	return 0
end

local function checkLOS(ply, npc)
	-- Variables
	local minsight = GetConVarNumber("stealth_minsight")
	local maxsight = GetConVarNumber("stealth_maxsight")
	local movementbonus = GetConVarNumber("stealth_movebonus")
	local minhearing = GetConVarNumber("stealth_minhearing")
	local shotrange = GetConVarNumber("stealth_shotrange")
	local multiplier = GetConVarNumber("stealth_multiplier")
	if minsight < 0 then minsight = 0 end
	if maxsight < 0 then maxsight = 0 end
	if movementbonus < 0 then movementbonus = 0 end
	if minhearing < 0 then minhearing = 0 end
	if shotrange < 0 then shotrange = 0 end
	if multiplier < 0 then multiplier = 0 end
	--
	
	if not ply:Alive() then return end
	if not ply then return end
	if not ply.sm_Luminocity then return end
	if not ply.sm_shooting then ply.sm_shooting = 0 end

	local isvisible = IsVisible(ply,npc)
		
	-- ConVar to number
	local alerttime = 0
	if GetConVarNumber("stealth_alerttime") >= 0 then alerttime = GetConVarNumber("stealth_alerttime") end
	--
	
	if not isvisible then 
		if not timer.Exists(npc:EntIndex().."Cooldown") then
			-- Use ConVar as timer duration
			timer.Create(npc:EntIndex().."Cooldown",alerttime,1,function() if IsValid(npc) then npc:SetTarget(npc) calm(ply, npc) end end)
			--
		end 
	elseif timer.Exists(npc:EntIndex().."Cooldown") then
		-- Use ConVar as timer duration
		timer.Adjust(npc:EntIndex().."Cooldown",alerttime,1, function() if IsValid(npc) then npc:SetTarget(npc) calm(ply, npc) end end)
		--
	end

	if ply.sm_shooting != 0 then ply.sm_Luminocity = math.Clamp(ply.sm_Luminocity + 100,0,255) end
	local eyesang = nil
	local yawdiff = 0
	local eyesobj = npc:LookupAttachment( "eyes" )
	if eyesobj then eyesang = npc:GetAttachment( eyesobj ) end
	if eyesang then yawdiff = math.abs(math.AngleDifference(eyesang["Ang"].y,(ply:GetPos()-npc:GetPos()):Angle().y))
	else yawdiff = math.abs(math.AngleDifference(npc:GetAngles().y,(ply:GetPos()-npc:GetPos()):Angle().y)) end
	local lightbonus = ((maxsight - minsight) * (ply.sm_Luminocity/255))
	local playerspeed = ply:GetVelocity():Length()
	local playerdist = ply:GetPos():Distance(npc:GetPos())
	-- Sight and hearing are different variables
	local sightrange = ( minsight + lightbonus * (1+(movementbonus*(playerspeed/200))) ) * multiplier
	local hearrange = ( minhearing * (playerspeed/200) ) * multiplier
	local shotrange = shotrange * multiplier
	--
	
	-- If ai_disabled == 1 or ai_ignoreplayers == 1, ignore players
	if GetConVar("ai_disabled"):GetInt() == 1 or GetConVar("ai_ignoreplayers"):GetInt() == 1 or ply.notarget == true then
		sightrange = 0
		hearrange = 0
		ply.sm_shooting = 0
	else
		-- Enemies can't see what's behind them or behind walls
		if yawdiff>60 or not isvisible then
			sightrange = 0
		end
				
		-- If player is walking or crouching, enemies can't hear him. They can't hear behind walls either
		if ply:GetVelocity():Length() < 110 or not isvisible then
			hearrange = 0
		end
		
		-- If player is hiding under a cardboard box, and is not moving, ignore him
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) then
			if wep:GetClass() == "weapon_cbox" and ply:Crouching() and ply:GetVelocity():Length() == 0 then
				sightrange = 0
				hearrange = 0
			end
		end
	end
	--
	
	if ply:Crouching() then sightrange = sightrange/2 end
	if not isvisible then ply.sm_shooting = ply.sm_shooting/2 end
	
	--[[ DEBUG
	print("-------------------------")
	print("SightRange: "..sightrange)
	print("HearRange: "..hearrange)
	print("Shooting: ".. ply.sm_shooting*shotrange)
	print("Player distance: ".. playerdist)
	]]--
	
	if (sightrange*0.75)>=playerdist then
		alert(ply, npc, false)
	elseif (sightrange>=playerdist or hearrange>=playerdist) then
		investigate(npc, ply:GetPos(), false, true)
	elseif (ply.sm_shooting*shotrange)>=playerdist then
		investigate(npc, ply:GetPos(), true, false)
	end

	ply.sm_shooting = 0
end

local function checkEntityLOS(ent, npc)
	-- Variables
	local minsight = GetConVarNumber("stealth_minsight")
	local maxsight = GetConVarNumber("stealth_maxsight")
	local multiplier = GetConVarNumber("stealth_multiplier")
	if minsight < 0 then minsight = 0 end
	if maxsight < 0 then maxsight = 0 end
	if multiplier < 0 then multiplier = 0 end
	--
	
	local isvisible = IsEntVisible(ent,npc)
	local eyesang = nil
	local yawdiff = 0
	local eyesobj = npc:LookupAttachment( "eyes" )
	if eyesobj then eyesang = npc:GetAttachment( eyesobj ) end
	if eyesang then yawdiff = math.abs(math.AngleDifference(eyesang["Ang"].y,(ent:GetPos()-npc:GetPos()):Angle().y))
	else yawdiff = math.abs(math.AngleDifference(npc:GetAngles().y,(ent:GetPos()-npc:GetPos()):Angle().y)) end
	local entdist = ent:GetPos():Distance(npc:GetPos())
	local sightrange = maxsight * multiplier
	--
	
	if yawdiff>60 or not isvisible then
			return -1
	end
	
	if (sightrange*0.75)>=entdist then
		--investigate(npc, ent:GetPos(), false, false)
		-- Return distance to target
		return entdist
	end
	return -1
end

function GetAllConditions ( npc )
	for i=0, 70 do
		if npc:HasCondition( i ) then print (npc:ConditionName( i ) ) end
	end
	print("-----------")
end

timer.Create("NPCStealthThink",.2,0,function() --Keep checking what npcs are alert to
	if GetConVarNumber("stealth_enabled") == 0 then return end
	-- Check Player LOS
	for k = #npctable, 1, -1 do
		local v = npctable[k]
		if IsValid(v) then
			if v.sm_initpos == nil then v.sm_initpos = v:GetPos() end
			if v.sm_initangles == nil then v.sm_initangles = v:GetAngles() end
			-- GetAllConditions ( v )
			for o,p in pairs(player.GetAll()) do
				checkLOS(p,v)
			end
			-- Check corpse LOS
			if GetConVarNumber("stealth_enabled") != 0 then
				local nearestcorpse = nil
				local nearestdistance = -1
				for o = #corpsetable, 1, -1 do
					local p = corpsetable[o]
					if IsValid(p) then
						if !table.HasValue(v.sm_seencorpses,p) then
							local dist = checkEntityLOS(p,v)
							if dist != -1 then
								table.insert(v.sm_seencorpses,p)
								if nearestdistance == -1 or dist < nearestdistance then
									nearestdistance = dist
									nearestcorpse = p
								end
							end
						end
					else
						table.remove(corpsetable,o)
					end
				end
				if IsValid(nearestcorpse) then investigate(v, nearestcorpse:GetPos(), true, false) end
			end
			--
			for o = #v.sm_MEnemies, 1, -1 do
				local p = v.sm_MEnemies[o]
				if !IsValid(p) then table.remove(v.sm_MEnemies,o) end
			end
			if #v.sm_MEnemies < 1 then v:SetNWBool("sm_alerted",false) end
		else
			table.remove(npctable,k)
			-- Send Clients the signal to remove NPC
			umsg.Start( "RemoveNPCfromTable" )
				umsg.Entity( v )
			umsg.End();	
		end
	end
	-- Check corpses LOS
	
	-- Check if enemies have arrived their investigation target point
	if #npctable > 0 then
		SetGlobalBool("BadNPCOnMap", true)
		for k, v in pairs(npctable) do
			if v.sm_investigating == 1 and v.sm_targetpos != nil and v:GetPos():Distance(v.sm_targetpos)<100 then
				v.sm_targetpos = nil
				v.sm_running = false
				v:SetSchedule( 1 )
				timer.Simple(1, function()
					if IsValid(v) then
						v:SetSchedule( SCHED_ALERT_SCAN  )
					end
				end)
				timer.Simple(4, function()
					if IsValid(v) then
						if v.sm_initpos!=nil and v.pr_prcontroller then
							v.sm_investigating = 0
						else
							v.sm_investigating = 2
							v:SetLastPosition(v.sm_initpos)
							v:SetSchedule( SCHED_FORCED_GO_RUN )
						end
					end
				end)
				-- Broadcast alert effect
				--umsg.Start( "NPCEffect" )
				--	umsg.Entity( v )
				--	umsg.String( "caution" )
				--umsg.End();	
			end
			if v.sm_investigating == 2 and v.sm_initangles != nil and v:GetPos():Distance(v.sm_initpos)<50 then
				v.sm_running = false
				v:SetSchedule( 1 )
				v.sm_investigating = 0
				v.sm_targetpos = nil
				timer.Simple(1, function()
					if IsValid(v) then
						v:SetAngles(v.sm_initangles)
					end
				end)
			end
		end
	else
		SetGlobalBool("BadNPCOnMap", false)
	end
	-- Delete corpses
	if #corpsetable > GetConVarNumber("stealth_maxcorpses") then
		for k = (#corpsetable - GetConVarNumber("stealth_maxcorpses")), 1, -1 do
			corpsetable[1]:Remove() 
			table.remove(corpsetable,1)
		end
	end
	
	-- DEBUG STUFF
	for k,v in pairs(ents.FindByClass("npc_*")) do
		if v:GetNWBool("sm_sleepingNPC") == true then print(timer.Exists("wake_time_"..v:EntIndex())) end
	end
	
end)

function CorpseCreate(ent,ragdoll)
	if GetConVarNumber("stealth_enabled") != 0 and (table.HasValue(npctable,ent)) and (!TFA_BGO) then
		table.insert(corpsetable,ragdoll)
	end
end

hook.Add("CreateEntityRagdoll","AddCorpseToTable",CorpseCreate)

hook.Add("PlayerDeath","StopChase",function(ply,item,attacker)
	for o = #npctable, 1, -1 do
		local p = npctable[o]
		for k = #p.sm_MEnemies, 1, -1 do
			local v = p.sm_MEnemies[k]
			if v==ply then
				p:AddEntityRelationship(ply, D_NU, 1)
				table.remove(p.sm_MEnemies,k)
				-- Make npc forget the player
				--p:SetTarget(p)
				
				-- Tell player that an npc is not looking for him anymore
				umsg.Start( "NPCCalmed", ply );
					umsg.Entity( p );
				umsg.End();	
			end
		end
		if #p.sm_MEnemies < 1 then p:SetNWBool("sm_alerted",false) end
	end
end)

hook.Add("OnNPCKilled", "ZDeathHappen", function(npc, attacker, inflictor )
	-- Blood and Gore Overhaul compatibility
	if TFA_BGO and GetConVarNumber("sv_bgo_enabled") != 0 and table.HasValue(npctable,npc) then	
		local bgocorpses = ents.FindByClass("bgo_ragdoll")
		--print(bgocorpses[#bgocorpses])
		table.insert(corpsetable,bgocorpses[#bgocorpses].targent)
	end
	local corpses = ents.FindByClass("prop_ragdoll")
	-- Gibmod Compatibility
	if corpses[#corpses] and corpses[#corpses].GibMod_DeathRag and corpses[#corpses].GibMod_DeathRag == true then
		table.insert(corpsetable,corpses[#corpses])
	end
end)

hook.Add("AddCorpse", "AddToCorpseList", function(ent) 
	table.insert(corpsetable,ent)
end)

hook.Add("EntityTakeDamage","AlertAttackedNpc",function(attacked,damage)
	local attacker = nil
	if damage:GetAttacker() then attacker = damage:GetAttacker() end
	if IsValid(attacked) and attacked:IsNPC() and table.HasValue(npctable,attacked) and IsValid(attacker) and attacker:IsPlayer() and !table.HasValue(attacked.sm_MEnemies,attacker)then
		if GetConVar("ai_disabled"):GetInt() == 1 or GetConVar("ai_ignoreplayers"):GetInt() == 1 or attacker.notarget == true then return
		elseif GetConVarNumber("stealth_alertondamage") == 1 then alert(attacker, attacked, false)
		else investigate(attacked,attacker:GetPos(),true,false) end
	end
end)

hook.Add("KeyPress","AlertShootingNPC",function(ply,key)
	if IsValid(ply) and key==IN_ATTACK and #npctable>0 and GetConVarNumber("stealth_enabled") == 1 then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) then
		
			if table.HasValue(silent_list, wep:GetClass()) or wep:Clip1()<=0 or (CurTime() < wep:GetNextPrimaryFire()) then return end
			
			if (wep.dt and wep.dt.Suppressed) or ( type(wep.GetSilenced) == "function" and wep:GetSilenced()) or table.HasValue(suppressed_list, wep:GetClass()) then
				ply.sm_shooting = GetConVarNumber("stealth_suppmultiplier")
			else
				ply.sm_shooting = 1
			end
			
			for k = #npctable, 1, -1 do
				local v = npctable[k]
				if IsValid(v) then
					checkLOS(ply,v)
				else
					table.remove(npctable,k)
					-- Send Clients the signal to remove NPC
					umsg.Start( "RemoveNPCfromTable" )
						umsg.Entity( ent )
					umsg.End();	
				end
			end
		end
	end
end)

local potentialenemies = {}
hook.Add("OnEntityCreated","GiveHearing",function(ent) --Startnpcs
	if GetConVarNumber("stealth_enabled") == 0 then return end
	local playerlist = player.GetAll()
	-- Only add npcs if they are in the list
	if ent:IsNPC() and table.HasValue(npc_list, ent:GetClass()) then
		if playerlist[1] then
			if ent:Disposition(playerlist[1])==1 or GetConVarNumber("stealth_override") != 0 then
				table.insert(npctable,ent)
				ent.sm_MEnemies = {}
				if GetConVarNumber("stealth_keepcorpses") != 0 and !TFA_BGO then ent:SetShouldServerRagdoll( true ) end
				for k, v in pairs(playerlist) do
					ent:AddEntityRelationship(v, D_NU, 1)
				end
				-- Send Clientes the new NPC
				umsg.Start( "AddNPCtoTable" )
					umsg.Entity( ent )
				umsg.End();	
			end
		else
			table.insert(potentialenemies, ent)
		end
		-- Variables initialization
		ent.sm_investigating = 0
		ent.invdelay = CurTime()
		ent.sm_running = false
		ent.sm_targetpos = nil
		ent.sm_initpos = nil
		ent.sm_initangles = nil
		ent.sm_seencorpses = {}
		ent:SetNWBool("sm_stealthNPC",true)
		ent:SetNWBool("sm_alerted",false)
		--
	elseif ent:IsPlayer() then
		for k, v in pairs(potentialenemies) do
			if IsValid(v) and v:Disposition(ent)==1 then
				table.insert(npctable,v)
				v.sm_MEnemies = {}
				-- Send Clients the new NPC
				umsg.Start( "AddNPCtoTable" )
					umsg.Entity( ent )
				umsg.End();	
			end
		end
		potentialenemies = {}
		for k, v in pairs(npctable) do
			v:AddEntityRelationship(ent, D_NU, 1)
		end
	end
end)

-- Dragging stuff
local function dropbody(ply)
	local wep = ply:GetActiveWeapon()
	if (IsValid(wep)) then
		wep:SetNextPrimaryFire(CurTime())
		wep:SetNextSecondaryFire(CurTime())
	end
	ply.holdEnt = NULL
	--if (!ply.visibleGun) then
		ply:DrawViewModel(true)
		ply:DrawWorldModel(true)
	--end
	ply.hasDropped = true
end

local function dragbody(ply)
	ply.hasDropped = false;
	if (IsValid(ply.holdEnt)) then
		dropbody(ply)
		return
	else
		local tr = {}
		tr.start = ply:GetShootPos()
		tr.endpos = tr.start + ply:GetAimVector() * 70
		tr.filter = ply
		tr = util.TraceLine(tr)
		if (!IsValid(ply:GetVehicle()) && IsValid(tr.Entity) && (table.HasValue(corpsetable,tr.Entity) or tr.Entity:GetNWString("sm_sleepingNPC")==true)) then
			ply.holdEnt = tr.Entity
			ply.holdPhys = tr.PhysicsBone
			if (IsValid(ply:GetActiveWeapon())) then
				ply.visibleGun = !ply:GetActiveWeapon():IsWeaponVisible()
				ply.weapon = ply:GetActiveWeapon():GetClass()
			end											
		end
	end
end

hook.Add("KeyPress","startdrag",function(ply,key) 
	if (key==IN_USE) then
		dragbody(ply)
	end
end)

local function dragThink()
	for _, v in pairs(player.GetAll()) do
		if (IsValid(v.holdEnt)) then
			local wep = v:GetActiveWeapon()
			if (IsValid(wep)) then
				wep:SetNextPrimaryFire(CurTime()+10)
				wep:SetNextSecondaryFire(CurTime()+10)
				v:DrawViewModel(false)
				v:DrawWorldModel(false)
				
				if (wep:GetClass() != v.weapon) then
					v:SelectWeapon(v.weapon)
				end
			end
			
			if (v:GetGroundEntity() == v.holdEnt || IsValid(v:GetVehicle())) then
				dropbody(v)
				return
			end
			
			local physobj = v.holdEnt:GetPhysicsObjectNum(v.holdPhys)
			local pos1 = v:GetShootPos() + v:GetAimVector() * 60
			local pos2 = physobj:GetPos()
						
			if (pos1:Distance(pos2) > 100) then
				dropbody(v)
				return
			else	
				v:SetLocalVelocity(v:GetVelocity()/2)
				local pos3=-(pos2 - pos1)
				pos3.z=0
				physobj:SetVelocity(pos3*8)
			end
			
		elseif (!v.hasDropped) then
			dropbody(v)
		end
	end
end

hook.Add("Think","dragthink",dragThink)

hook.Add( "MakeNoiseDistraction", "MakeNoise", function( pos, run )
	if #npctable>0 and GetConVarNumber("stealth_enabled") == 1 then
		local soundrange = GetConVarNumber("stealth_shotrange") * GetConVarNumber("stealth_multiplier")
		for k = #npctable, 1, -1 do
			local v = npctable[k]
			if IsValid(v) then
				local distance = pos:Distance(v:GetPos())
				local tr = util.TraceLine{
					start = v:EyePos(),
					endpos = pos,
					filter = {v},
					mask = MASK_VISIBLE_AND_NPCS
				}
				if (tr.Hit and soundrange/2 > distance) or (!tr.Hit and soundrange > distance) then
					investigate(v, pos, run, false)
				end
			else
				table.remove(npctable,k)
				-- Send Clients the signal to remove NPC
				umsg.Start( "RemoveNPCfromTable" )
					umsg.Entity( ent )
				umsg.End();	
			end
		end
	end
end )

hook.Add( "TurnOnSensor", "AddSensor", function( ent )
	if IsValid(ent) and IsValid(ent:GetOwner()) then
		umsg.Start( "AddSensor", ent:GetOwner() )
			umsg.Entity( ent )
		umsg.End();	
	end
end )

net.Receive("stealth_clientinitialized", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() then
		for k,v in pairs(npctable) do
			if IsValid(v) then
				umsg.Start( "AddNPCtoTable" )
					umsg.Entity( ent )
				umsg.End()
			end
		end
	end
end)

concommand.Add("p_sendluminocity",function(ply,com,arg)
	if arg[1] then
		ply.sm_Luminocity = tonumber(arg[1])
	end
end)