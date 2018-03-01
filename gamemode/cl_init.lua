--GM:SC CL_INIT

include ("shared.lua")
include("sth/ct.lua")
include("sth/sh_stealth.lua")
include("sth/cl_stealth.lua")
include("ss/sh_silentstep.lua")
include("ss/cl_silentstep.lua")
include("nv/nvscript.lua")
include("stwp2/ststealth2-sounds.lua")


local side = false

local click = false

local bandage = false

local anim = true

local nvg = false

	net.Receive("swapcam", function(len, ply)
	
		if !side then
			side = true
		else
			side = false
		end
	
	end)

function toggleOn()
  side = true
  end
  function toggleOff()
  side = false
  end
  

  
  function buttonInputs()
	if (LocalPlayer():GetActiveWeapon():GetClass() != "weapon_scknife") then
	if input.IsMouseDown( MOUSE_RIGHT ) then
	click = true
	else
	click = false
	end
	end
	if !bandage then
		if input.IsKeyDown( KEY_Q ) then
			bandage = true
			
			bandageSelf()
		
		end
	end
	if !nvg then
		if input.IsKeyDown( KEY_N ) then
			print(nvg)
			nvg = true
			anim = true
			NVGActivate()
		end
	end
	
  end
  
  
  
  hook.Add("Think", "aimView", buttonInputs)
  
  function bandageSelf()
  
  if ply:Health() < 100 then
	net.Start("bandage")
	net.SendToServer()
  
	if tonumber(ply:GetNWInt("bandages") > 0) then
		surface.PlaySound( clothRip )
	end
  end
  timer.Simple(5, function()
  bandage = false
  end)
  
  end
  
  function NVGActivate()
  
  net.Start("nvg")
  net.SendToServer()
  
	hook.Add("Think", "playAnim", function()
	if anim then
	ply:DoAnimationEvent( ACT_GMOD_IN_CHAT )
	else
	ply:DoAnimationEvent( ACT_RESET )
	end
	end)
	
  timer.Simple(.2, function()
	anim = false
	hook.Remove("playAnim")
  end)
  
  timer.Simple(1, function()
  nvg = false
  end)
  
  end
  
  concommand.Add("toggle_on", toggleOn)
  concommand.Add("toggle_off", toggleOff)

function MyCalcView( ply, pos, angles, fov )
	
--TRYING TO GET OFFSET_RIGHT TO SMOOTHLY TRANSITION OVER TO 17 FOR A SMOOTH LOOOKING CAMERA TRANSITION
	
	
	-- OFFSET AIMING //////////
	tget = ( click and -.5 or -1)
	funcClick = funcClick and Lerp(FrameTime()*7, funcClick, tget) or tget
	offset_forward = funcClick * 40
	
	
	local offset_up = 10
	--OFFSET SIDE ////////////
	target = ( side and -1 or 1)
	variable = variable and Lerp(FrameTime()*7, variable, target) or target
	offset_right = variable * 17
	local pullout = 4
	
	local view = {
	origin = pos + angles:Forward() * offset_forward + angles:Up() * offset_up + angles:Right() * offset_right,
	}

		local trace = util.TraceLine({
		start = pos,
		endpos = view.origin,
		filter = ply
	})
	
	if (trace.Hit) then
		-- Change the position to be in front of the surface
		-- By pulling out of the hit position in the direction of the trace
		view.origin = trace.HitPos + trace.HitNormal * pullout
	end;
	
	view.drawviewer= true 
	
	return view
    	
  end

  hook.Add("CalcView", "normalView", MyCalcView)

  
  
  