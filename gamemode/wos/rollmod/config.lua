
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

-- How many seconds does the player have to put that second tap in for double-tap rolling
wOS.RollMod.Sensitivity = 0.3

--Speed you go when you are rolling
wOS.RollMod.RollSpeed = 200

--These are the damage types you can dodge while rolling. 
--Set them to true so they are dodgeable, false for the opposite
wOS.RollMod.Dodgeables = {}
wOS.RollMod.Dodgeables[ DMG_GENERIC ] = false
wOS.RollMod.Dodgeables[ DMG_CRUSH ] = false
wOS.RollMod.Dodgeables[ DMG_BULLET ] = true
wOS.RollMod.Dodgeables[ DMG_SLASH ] = true
wOS.RollMod.Dodgeables[ DMG_BURN ] = false
wOS.RollMod.Dodgeables[ DMG_BLAST ] = false
wOS.RollMod.Dodgeables[ DMG_SHOCK ] = true
wOS.RollMod.Dodgeables[ DMG_SONIC ] = false
wOS.RollMod.Dodgeables[ DMG_ENERGYBEAM ] = false
wOS.RollMod.Dodgeables[ DMG_BUCKSHOT ] = true

wOS.RollMod.Animations = {}
wOS.RollMod.Animations[2] = "wos_bs_shared_roll_forward"
wOS.RollMod.Animations[3] = "wos_bs_shared_roll_back"
wOS.RollMod.Animations[4] = "wos_bs_shared_roll_left"
wOS.RollMod.Animations[5] = "wos_bs_shared_roll_right"