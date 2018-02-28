if !ConVarExists("stealth_enabled") then
	CreateConVar("stealth_enabled","1",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 1. Can take values from 0 to 1. Changes HUD mode (0 is disabled).")
end

if !ConVarExists("stealth_alerttime") then
	CreateConVar("stealth_alerttime","15",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 15. Time until the NPCs leave their alerted state.")
end

if !ConVarExists("stealth_override") then
	CreateConVar("stealth_override","1",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 1. This will make any npc your enemy as long as it's included in npc.txt")
end

if !ConVarExists("stealth_keepcorpses") then
	CreateConVar("stealth_keepcorpses","0",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 0. This will spawn server corpses even if ai_servercorpses is 0. It doesn't look good tho.")
end

if !ConVarExists("stealth_alertondamage") then
	CreateConVar("stealth_alertondamage","1",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 1. This will make NPCs spot the player immediately after receiving damage, instead of investigating his position.")
end

if !ConVarExists("stealth_maxcorpses") then
	CreateConVar("stealth_maxcorpses","10",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 10. Limits the maximum amount of enemy ragdolls (only for NPCs affected by this mod)")
end

if !ConVarExists("stealth_multiplier") then
	CreateConVar("stealth_multiplier","1",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 1. This increases or decreases all stealth settings.")
end

if !ConVarExists("stealth_minsight") then
	CreateConVar("stealth_minsight","200",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 200. Range at which an NPC can detect a standing player with minimum light level.")
end

if !ConVarExists("stealth_maxsight") then
	CreateConVar("stealth_maxsight","1500",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 1500. Range at which an NPC can detect a standing player with maximum light level.")
end

if !ConVarExists("stealth_movebonus") then
	CreateConVar("stealth_movebonus","0.3",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 0.3. Sight range will be increased this much when a player is running.")
end

if !ConVarExists("stealth_minhearing") then
	CreateConVar("stealth_minhearing","200",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 200. Range at which an NPC can hear a running player footsteps.")
end

if !ConVarExists("stealth_shotrange") then
	CreateConVar("stealth_shotrange","1000",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 1000. Range at which an NPC can hear a gunshot.")
end

if !ConVarExists("stealth_suppmultiplier") then
	CreateConVar("stealth_suppmultiplier","0.3",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 0.3. Hearing range multiplier for suppressed weapons.")
end

if !ConVarExists("stealth_backuptime") then
	CreateConVar("stealth_backuptime","2",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 2. Time in seconds until an enemy alerts nearby npcs after detecting a player.")
end

if !ConVarExists("stealth_backuprange") then
	CreateConVar("stealth_backuprange","800",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 800. When an enemy detects you, he will alert all enemies inside this range after a few seconds.")
end

if !ConVarExists("stealth_sensortime") then
	CreateConVar("stealth_sensortime","10",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 10. Time until the Proximity Sensor deactivates.")
end

if !ConVarExists("stealth_sensorrange") then
	CreateConVar("stealth_sensorrange","500",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 500. Detection range for the Proximity Sensor.")
end

if !ConVarExists("stealth_sleeptime") then
	CreateConVar("stealth_sleeptime","60",{FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY},"Default is 60. Time in seconds until an unconcious enemy wakes up.")
end


if !SERVER then return end

net.Receive("stealth_enabled", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_enabled", net.ReadFloat())
	end
end)

net.Receive("stealth_alerttime", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_alerttime", net.ReadFloat())
	end
end)

net.Receive("stealth_multiplier", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_multiplier", net.ReadFloat())
	end
end)

net.Receive("stealth_keepcorpses", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_keepcorpses", net.ReadFloat())
	end
end)

net.Receive("stealth_alertondamage", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_alertondamage", net.ReadFloat())
	end
end)

net.Receive("stealth_maxcorpses", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_maxcorpses", net.ReadFloat())
	end
end)

net.Receive("stealth_minsight", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_minsight", net.ReadFloat())
	end
end)

net.Receive("stealth_maxsight", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_maxsight", net.ReadFloat())
	end
end)

net.Receive("stealth_movebonus", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_movebonus", net.ReadFloat())
	end
end)

net.Receive("stealth_minhearing", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_minhearing", net.ReadFloat())
	end
end)

net.Receive("stealth_shotrange", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_shotrange", net.ReadFloat())
	end
end)

net.Receive("stealth_suppmultiplier", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_suppmultiplier", net.ReadFloat())
	end
end)

net.Receive("stealth_override", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_override", net.ReadFloat())
	end
end)

net.Receive("stealth_backuptime", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_backuptime", net.ReadFloat())
	end
end)

net.Receive("stealth_backuprange", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_backuprange", net.ReadFloat())
	end
end)

net.Receive("stealth_sensortime", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_sensortime", net.ReadFloat())
	end
end)

net.Receive("stealth_sensorrange", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_sensorrange", net.ReadFloat())
	end
end)

net.Receive("stealth_sleeptime", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_sleeptime", net.ReadFloat())
	end
end)

net.Receive("stealth_reloadsettings", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_reloadsettings")
	end
end)

--[[
net.Receive("stealth_defaultsettings", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("stealth_enabled", 1)
		RunConsoleCommand("stealth_alerttime", 15)
		RunConsoleCommand("stealth_override", 1)
		RunConsoleCommand("stealth_multiplier", 1)
		RunConsoleCommand("stealth_minsight", 200)
		RunConsoleCommand("stealth_maxsight", 1500)
		RunConsoleCommand("stealth_movebonus", 0.3)
		RunConsoleCommand("stealth_minhearing", 200)
		RunConsoleCommand("stealth_shotrange", 800)
		RunConsoleCommand("stealth_suppmultiplier", 0.3)
		RunConsoleCommand("stealth_backuptime", 1)
		RunConsoleCommand("stealth_backuprange", 800)
		print ("The settings have been reset")
	end
end)]]--