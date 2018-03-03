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

local hudDrawName = false

local drawNVG = true

function GM:HUDDrawTargetID()
end
	


net.Receive("attachCLModel", function(len, ply)
	
end)

surface.CreateFont( "plyFont", {
	font 		= "Prototype",
	size 		= 25, 
	weight 		= 700,
	blursize 	= 0.6,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= true,
	additive 	= false,
	outline 	= false
} )

function GM:DrawDeathNotice( x, y )
end

	net.Receive("swapcam", function(len, ply)
		if !side then
			side = true
		else
			side = false
		end
	end)
	
	net.Receive("cameraCheck", function(len, ply)
		netBool = net.ReadBool()
	end)


function toggleOn()
  side = true
  end
  function toggleOff()
  side = false
  end

  function buttonInputs()
	LocalPlayer():SetCanZoom(false)
	LocalPlayer():SetCanZoom( false )
	if LocalPlayer():Alive() then
	if netBool then
		if input.IsMouseDown( MOUSE_RIGHT ) then
			click = true
		else
			click = false
		end
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
			nvg = true
			anim = true
			NVGActivate()
		end
	end

	
	
	local trace = {}
	trace.start = LocalPlayer():EyePos()
	trace.endpos = trace.start + LocalPlayer():GetAimVector() * 85
	trace.filter = LocalPlayer()
	
	local tr = util.TraceLine(trace)
	
	local trace = {}
	trace.start = LocalPlayer():EyePos()
	trace.endpos = trace.start + LocalPlayer():GetAimVector() * 85
	trace.filter = LocalPlayer()
	
	local tr = util.TraceLine(trace)
	
	if (tr.HitWorld) then return false end
	
	if !tr.Entity:IsValid() then hudDrawName = false return end
	
	if tr.Entity:IsPlayer() then
		
		hudDrawName = true
		ent = tr.Entity
		stringName = tr.Entity:GetName()
		
		if !bandage then
		if input.IsKeyDown( KEY_F ) then
			bandage = true
			bandageOther(tr.Entity)
		end
		end	
		
	else
		hudDrawName = false
	end

	 end

function drawName()
	if hudDrawName and ent:Alive() then
		local zOffset = 50
		local x = ent:GetPos().x			//Get the X position of our player
		local y = ent:GetPos().y			//Get the Y position of our player
		local z = ent:GetPos().z
		local pos = Vector(x,y,z+zOffset)
		local pos2d = pos:ToScreen()
		
		draw.DrawText(stringName .. ": " .. ent:Health() .. "% Health \n   [F] Bandage Player [" .. tostring(LocalPlayer():GetNWInt("bandages")) .. "x]","plyFont",pos2d.x,pos2d.y,Color(255,255,255,160),TEXT_ALIGN_LEFT)
		
	end
end
 
hook.Add("HUDPaint", "paintName", drawName)
 
function bandageOther(ent)

	if ent:IsValid() then
			net.Start("bandageOther")
			net.WriteEntity(ent)
			net.SendToServer()
end
timer.Simple(5, function()
  bandage = false
  end)
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
  ply:SetPlaybackRate( 2 )
  ply:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_IN_CHAT, true )
  
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
		endpos = view.origin + Vector(0,-7,0),
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

  
  
  