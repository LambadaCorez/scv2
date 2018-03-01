--GM:SC CL_INIT

include ("shared.lua")
include("sth/ct.lua")
include("sth/sh_stealth.lua")
include("sth/cl_stealth.lua")
include("ss/sh_silentstep.lua")
include("ss/cl_silentstep.lua")
include("nv/nvscript.lua")


local side = false

local click = false

local bandage = false

function toggleOn()
  side = true
  end
  function toggleOff()
  side = false
  end
  
  function clickAimDown()
	if input.IsMouseDown( MOUSE_RIGHT ) then
	click = true
	else
	click = false
	end
	if !bandage then
		if input.IsKeyDown( KEY_Q ) then
			bandage = true
			bandageSelf()
		
		end
	end
  end
  
  
  
  hook.Add("Think", "aimView", clickAimDown)
  
  function bandageSelf()
  
  net.Start("bandage")
  net.SendToServer()
  
  timer.Simple(5, function()
  bandage = false
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

  
  
  