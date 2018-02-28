
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sth/ct.lua")
AddCSLuaFile("ss/cl_silentstep.lua")
AddCSLuaFile("ss/sh_silentstep.lua")
AddCSLuaFile("sth/sh_stealth.lua")
AddCSLuaFile("sth/cl_stealth.lua")


include("sth/sh_stealth.lua")
include("sth/stealth.lua")
include("ss/silentstep.lua")
include("ss/sh_silentstep.lua")
include("shared.lua")


util.AddNetworkString("roll")
util.AddNetworkString("prone")
util.AddNetworkString("on_join")
util.AddNetworkString("view_normal_send")
util.AddNetworkString("view_normal")


net.Receive("view_normal_send", function(len, ply)

	net.Start("view_normal")
	net.Send(ply)

end)
playermodels = {}

playermodels[0] = "models/player/Group03/male_04.mdl"
playermodels[1] = "models/player/Group03/male_05.mdl"
playermodels[2] = "models/player/Group03/male_07.mdl"
playermodels[3] = "models/player/Group03/male_03.mdl"
playermodels[4] = "models/player/Group03/male_08.mdl"
playermodels[5] = "models/player/Group03/male_09.mdl"

weapon = {}

weapon[0] = "tfcss_fiveseven_sh"

ammo = {}

ammo[0] = "item_ammo_pistol"
ammo[1] = "item_ammo_pistol"

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
			
			net.Start("on_join")
			net.Send(ply)
			
	end
		
function GM:PlayerSpawn( ply )
			
			giveWeaponsAmmo( ply )
			--Crosshair Commands
			ply:ConCommand("wos_roll_cameramode 4")
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
			ply:ConCommand("cl_tfa_viewbob_reloading 0")
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
			--wOS Commands
			ply:ConCommand("prone_bindkey_enabled 0")
			ply:AllowFlashlight( false )
			
			ply:ConCommand("wos_roll_doubletap 0")
			ply:ConCommand("stealth_drawbar 1")
			ply:SetJumpPower(200)
											

	end

