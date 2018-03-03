
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sth/ct.lua")
AddCSLuaFile("ss/cl_silentstep.lua")
AddCSLuaFile("ss/sh_silentstep.lua")
AddCSLuaFile("sth/sh_stealth.lua")
AddCSLuaFile("sth/cl_stealth.lua")
AddCSLuaFile("nv/nvscript.lua")
AddCSLuaFile("stwp2/ststealth2-sounds.lua")

include("sth/sh_stealth.lua")
include("sth/stealth.lua")
include("ss/silentstep.lua")
include("ss/sh_silentstep.lua")
include("shared.lua")
include("stwp2/ststealth2-sounds.lua")

util.AddNetworkString("bandage")
util.AddNetworkString("nvg")
util.AddNetworkString("swapcam")
util.AddNetworkString("cameraCheck")
util.AddNetworkString("bandageOther")
util.AddNetworkString("attachCLModel")

local clothRip = Sound( "items/cloth_rip.wav" )

local plymeta = FindMetaTable("Player")

net.Receive("bandage", function(len, ply)
	local bandages = tonumber(ply:GetNWInt("bandages"))
	if bandages > 0 then
		ply:SetHealth(math.Clamp(ply:Health() + 15,0,100))
		ply:SetNWInt("bandages", (ply:GetNWInt("bandages") - 1 ))
		ply:EmitSound( "items/cloth_rip.wav", 25, 100, .7, CHAN_AUTO )
	end

end)

net.Receive("bandageOther", function(len, ply)
	local bandages = tonumber(ply:GetNWInt("bandages"))
	local ent = net.ReadEntity()
	if bandages > 0 then
			if ent:Health() < 100 then
				ent:SetHealth(math.Clamp(ent:Health() + 15,0,100))
				ply:SetNWInt("bandages", (ply:GetNWInt("bandages") - 1 ))
				ply:EmitSound( "items/cloth_rip.wav", 25, 100, .7, CHAN_AUTO )
			end
	end

end)

function GM:ShowSpare2( ply )

	net.Start("swapcam")
	net.Send(ply)

end

net.Receive("nvg", function(len, ply)
	
	ply:ConCommand("nv_togg")

end)


local pickup = false

playermodels = {}

playermodels[0] = "models/player/Group03/male_04.mdl"
playermodels[1] = "models/player/Group03/male_05.mdl"
playermodels[2] = "models/player/Group03/male_07.mdl"
playermodels[3] = "models/player/Group03/male_08.mdl"
playermodels[4] = "models/player/Group03/male_09.mdl"

weapon = {}

weapon[0] = "tfcss_fiveseven_sh"
weapon[1] = "weapon_scknife"

weaponDisabled = {}

weaponDisabled["ar2"] = 1
weaponDisabled["rpg"] = 1
weaponDisabled["smg"] = 1
weaponDisabled["shotgun"] = 1
weaponDisabled["pistol"] = 1
weaponDisabled["crossbow"] = 1
weaponDisabled["physgun"] = 1
weaponDisabled["revolver"] = 1
weaponDisabled["slam"] = 1
weaponDisabled["melee"] = 1
weaponDisabled["melee2"] = 1
weaponDisabled["grenade"] = 1

ammo = {}

ammo[0] = "item_ammo_pistol"
ammo[1] = "item_ammo_pistol"


function GM:PlayerCanPickupWeapon( ply, wep )
	local pickup = true
	local totalWep = ply:GetWeapons()
	
        for k, v in pairs(totalWep) do

			local ht = v:GetHoldType()
			
            if ( weaponDisabled[ht] ) then
			if ( weaponDisabled[ht] == 1 ) then
				hasPrimary = true
			end
		end
		end
		
		local ht = wep:GetHoldType()
	
		if ( not weaponDisabled[ht] ) then
			return true
		end
        
		if ( weaponDisabled[ht] == 1 and hasPrimary ) then
		return false
		end
		
		
end

function GM:PlayerSwitchWeapon( ply, oldWep, newWep )

	
	if newWep:GetClass() == ( "weapon_scknife" ) then
		boolin = false
	else
		boolin = true
	end
	
	net.Start("cameraCheck")
	net.WriteBool( boolin )
	net.Send(ply)

end

function giveWeaponsAmmo( ply )

	for k, wep in pairs(weapon) do
	
		ply:Give(wep)
	
	end

	for k, amm in pairs(ammo) do
	
		ply:Give(amm)
	
	end

end

function GM:PlayerInitialSpawn( ply )
			
			ply:ConCommand("sv_tfa_ironsights_enabled 0")
			ply:SetModel(table.Random(playermodels)) 
			print("WOWOAWE")
			ply:SetCanZoom(false)
			
	end
	
function nvgGoggles(ply)

	local bone_id = ply:GetAttachment(ply:LookupAttachment("head"))
		local nvg = ents.Create( "nvg_goggles" )
	
	nvg:SetPos( Vector( 0, 0, 0 ) )
	nvg:SetModelScale( 1.2 )
	nvg:SetAngles( Angle( 0, 0, 90 ) )
	nvg:FollowBone( ply, ply:LookupBone("ValveBiped.Bip01_Head1") )
	nvg:SetLocalPos( Vector( -12.3, -.1, 0 ) )
	nvg:SetLocalAngles( Angle( 0, -90, 270 ) )
	nvg:Spawn()
	if !ply:Alive() then
	nvg:Remove()
	end

end
	
function GM:PlayerSpawn( ply )
			
			nvgGoggles(ply)
			
			
			net.Start("attachCLModel")
			net.Send(ply)
			
			timer.Simple(.1, function()
			ply:SetNWInt("bandages", 5)
			end)
			
			ply:SetWalkSpeed(175)
			ply:SetRunSpeed(230)
			giveWeaponsAmmo( ply )
		
			--Crosshair Commands
			ply:SetCanZoom( true )
			ply:ConCommand("sv_tfa_spread_multiplier .8")
			ply:ConCommand("cl_tfa_hud_crosshair_color_a 225")
			ply:ConCommand("cl_tfa_hud_crosshair_color_r 255")
			ply:ConCommand("cl_tfa_hud_crosshair_color_g 225")
			ply:ConCommand("cl_tfa_hud_crosshair_color_b 225")
			ply:ConCommand("cl_tfa_hud_crosshair_gap_scale 0")
			ply:ConCommand("cl_tfa_hud_crosshair_length 0")
			ply:ConCommand("cl_tfa_hud_hitmarker_enabled 0")
			ply:ConCommand("cl_tfa_hud_crosshair_width 2")
			ply:ConCommand("cl_tfa_hud_enabled 0")
			ply:ConCommand("cl_tfa_hud_crosshair_dot 1")
			ply:ConCommand("sv_tfa_cmenu 0")
			ply:ConCommand("sv_tfa_default_clip 1")
			ply:ConCommand("sv_tfa_sprint_enabled 0")
			ply:ConCommand("cl_tfa_gunbob_intensity 0")
			--Nightvision Commands
			ply:ConCommand("nv_aim_status 0")
			ply:ConCommand("nv_toggspeed 0.10")
			ply:ConCommand("nv_id_status 0")
			ply:ConCommand("nv_fx_colormod_status 1")
			ply:ConCommand("nv_fx_goggle_status 1")
			ply:ConCommand("nv_fx_goggle_overlay_status 0")
			ply:ConCommand("nv_fx_distort_status 0")
			ply:ConCommand("nv_fx_noise_status 0")
			ply:ConCommand("nv_fx_alphapass 5")
			ply:ConCommand("nv_etisd_status 0")
			ply:ConCommand("nv_fx_blur_status 0")
			ply:ConCommand("nv_illum_bright .1")
			ply:ConCommand("nv_illum_area 256")

			--wOS Commands
			ply:AllowFlashlight( false )
			ply:ConCommand("stealth_drawbar 1")
			ply:SetJumpPower(200)
											

	end
	
	function GM:PlayerDeath( ply, inflict, attack )
	
		nvgGoggles(ply)
		
	end
