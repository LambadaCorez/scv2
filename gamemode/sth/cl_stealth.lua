include( "sh_stealth.lua" )
resource.AddFile( "materials/hud/light_meter.vtf" )
resource.AddFile( "materials/hud/light_meter.vmt" )
resource.AddFile( "materials/hud/sound_meter.vtf" )
resource.AddFile( "materials/hud/sound_meter.vmt" )
resource.AddFile( "materials/hud/undetected.vtf" )
resource.AddFile( "materials/hud/undetected.vmt" )
resource.AddFile( "materials/hud/search.vtf" )
resource.AddFile( "materials/hud/search.vmt" )
resource.AddFile( "materials/hud/detected.vtf" )
resource.AddFile( "materials/hud/detected.vmt" )

surface.CreateFont( "Prototype", {
	font 		= "Prototype",
	size 		= 17,
	weight 		= 700,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
} )



local light_meter = "hud/light_meter.vtf"
local sound_meter = "hud/sound_meter.vtf"
local icon = "hud/undetected.vtf"
local detected = "hud/detected.vtf"
local search = "hud/search.vtf"
local lastsend = 0
local luminocity = 0
local alertdanger = 0
local talking = false
local dangernpc = nil
local isnpc = false
local hunters = {}
local npctable = {}
local sensorlist = {}
local insight = 0
local alertmusic = nil
local playingmusic = 0
local fadingmusic = 0
local currenteffect = nil
local sounddelay = CurTime()


local dlight = DynamicLight( LocalPlayer():EntIndex() ) // Darkness vision light
local darkvisionbrightness = 0 // Used to fade in/out the darkness vision light.

stealthmod = {enablehud = 1, luminocity = 0, alertdanger = 0}

CreateClientConVar( "stealth_drawbar", 1) 
CreateClientConVar( "stealth_enablefx", 1) 
CreateClientConVar( "stealth_enablesound", 1) 
CreateClientConVar( "stealth_enablemusic", 1) 
CreateClientConVar( "stealth_enabledarkvision", 0)
CreateClientConVar( "stealth_hudx", 29) 
CreateClientConVar( "stealth_hudy", 220) 

hook.Add( "InitPostEntity", "some_unique_name", function()
	alertmusic = CreateSound( LocalPlayer() , "stealth/alertmusic.wav") 
	util.PrecacheSound("stealth/alert.mp3")
	util.PrecacheSound("stealth/alertmusic.wav")
	net.Start("stealth_clientinitialized")
	net.SendToServer()
end )

local function AddNPCtoTable( data )
	local npc = data:ReadEntity()
	if IsValid( npc ) and !table.HasValue(npctable, npc) then
		table.insert(npctable, npc)
	end
end

usermessage.Hook( "AddNPCtoTable", AddNPCtoTable )

local function RemoveNPCfromTable( data )
	local npc = data:ReadEntity()
	if IsValid( npc ) and table.HasValue(npctable, npc) then
		table.RemoveByValue(npctable, npc)
	end
end

usermessage.Hook( "RemoveNPCfromTable", RemoveNPCfromTable )

cvars.AddChangeCallback( "stealth_enablemusic", function( convar_name, value_old, value_new )
	if (tonumber(value_new) == 0 and alertmusic:IsPlaying()) then alertmusic:Stop()
	elseif (tonumber(value_new)) != 0 and !alertmusic:IsPlaying() and playingmusic == 1 then alertmusic:Play() end
end)

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is need for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function AddSensor( data )
	local ent = data:ReadEntity()
	if IsValid( ent ) and !table.HasValue(sensorlist, ent) then
		table.insert(sensorlist, ent)
	end
end

usermessage.Hook( "AddSensor", AddSensor )

--[[
I use an extra table to avoid calculating the NPCs under
sensor range in the PostDrawOpaqueRenderables event.
That should increase performance.
]]--
timer.Create("CheckNearSensor",.5,0,function() --Keep checking what alerted npcs are visible
	local range = GetConVarNumber("stealth_sensorrange")
	if #sensorlist > 0 then
		local allnpc = ents.FindByClass("npc_*")
		for k = #allnpc, 1, -1 do
			local v = allnpc[k]
			if IsValid(v) then
				local nearest = nil
				local neardist = -1
				for o = #sensorlist, 1, -1 do
					local p = sensorlist[o]
					if IsValid(p) then
						local dist = p:GetPos():Distance(v:GetPos())
						if dist < range and (neardist == -1 or (dist < neardist)) then
							nearest = p
							neardist = dist
						end
					else
						table.remove(sensorlist,o)
					end
				end
			if IsValid(nearest) then v.sm_NPCinsensor = neardist
			else v.sm_NPCinsensor = -1 end
			end
		end
	end
	-- Here I copy a networked variable to a client global one. That should
	-- reduce network transit.
	for k,v in ipairs( ents.FindByClass("prop_ragdoll") ) do
		v.sm_sleeping = v:GetNWBool("sm_sleepingNPC")
		v.sm_sleepinit = v:GetNWFloat("sm_sleepinit")
		v.sm_sleeptime = v:GetNWFloat("sm_sleeptime")
		v.sm_sleephealth = v:GetNWInt("sm_NPChealth")
	end
end)

hook.Add("PostDrawOpaqueRenderables","SensorWallhack",function()
	if #sensorlist < 1 then return end
	local range = GetConVarNumber("stealth_sensorrange")
	local allents = ents.FindByClass("npc_*")
	for k = #allents, 1, -1 do
		local v = allents[k]
		render.ClearStencil()
		if IsValid(v) and v:Health() > 0 and v.sm_NPCinsensor and v.sm_NPCinsensor != -1 then
			cam.Start3D()
				render.SetStencilEnable( true )
					cam.IgnoreZ( true )

						render.SetStencilWriteMask( 1 )
						render.SetStencilTestMask( 1 )
						render.SetStencilReferenceValue( 1 )

						render.SetStencilCompareFunction( STENCIL_ALWAYS )
						render.SetStencilPassOperation( STENCIL_REPLACE )
						render.SetStencilFailOperation( STENCIL_KEEP )
						render.SetStencilZFailOperation( STENCIL_KEEP )
						
						render.SetBlend(0)
						v:DrawModel()
						render.SetBlend(1)

						render.SetStencilCompareFunction( STENCIL_EQUAL )
						render.SetStencilPassOperation( STENCIL_KEEP )
							cam.Start2D()
								surface.SetAlphaMultiplier( math.Clamp(range-v.sm_NPCinsensor,0,range)/range ) 
								surface.SetDrawColor( Color( 248, 118, 22 ) )
								surface.DrawRect( 0, 0, ScrW(), ScrH() )
								surface.SetAlphaMultiplier( 1 ) 
							cam.End2D()
					cam.IgnoreZ( false )
					v:DrawModel()
				render.SetStencilEnable( false )
			cam.End3D()
		end
	end
end)

-- Drawing stars over heads. Credits to Olivia for the formula.
hook.Add( "PostDrawOpaqueRenderables", "SleepStars", function()
	for k,v in ipairs( ents.FindByClass("prop_ragdoll") ) do
		if (v.sm_sleeping == true and v.sm_sleepinit and v.sm_sleeptime and v.sm_sleephealth > 0) then
			local attpoint = v:GetAttachment(v:LookupAttachment("eyes"))
			
			if ( attpoint ) then
				local stars = math.ceil((1-((CurTime() - v.sm_sleepinit)/v.sm_sleeptime)) * 5)
				
				for i = 1, stars do
					local time = CurTime() * 3 + ( math.pi * 2 / stars * i )
					local offset = Vector( math.sin( time ) * 5, math.cos( time ) * 5, 15 )
					
					render.SetMaterial( Material( "stealth/star.png", "noclamp smooth" ) )
					render.DrawSprite( attpoint.Pos + offset, 3, 3, white )
				end
			end
		end
	end
end)

hook.Add("HUDPaint","DrawSplinterCellThing",function()
	if GetConVarNumber("stealth_drawbar")==0 or GetConVarNumber("cl_drawhud")==0 or stealthmod.enablehud == 0 then return end
	local hudxpos = GetConVarNumber("stealth_hudx")
	local hudypos = ScrH()-GetConVarNumber("stealth_hudy")
	local down = ScrH()-200
	local width = 100
	local section = width/6
	
	-- HUD BASE
	if GetConVarNumber("stealth_drawbar")==1 then
		draw.RoundedBox(6,hudxpos,hudypos,200,100,Color(20,20,20,0))
		
		
		-- CIRCLE
		
		-- Outer 
		
	
	else
		surface.SetDrawColor(0,0,0,255)
		
	end
	
	-- Inner circ
	
	if GetConVarNumber("stealth_drawbar")==1 or GetConVarNumber("stealth_drawbar")==2 then draw.Circle( ScrW()/10, ScrH()/1.22, 38, 38 )
	elseif GetConVarNumber("stealth_drawbar")==3 then draw.Circle( ScrW()/10, ScrH()/1.22, 38, 38 )
	elseif GetConVarNumber("stealth_drawbar")==4 then draw.Circle( ScrW()/10, ScrH()/1.22, 38, 38 ) end
	
	
	--surface.DrawRect(35,down+5,10,10)
	
	
	if GetConVarNumber("stealth_drawbar") >= 1 and GetConVarNumber("stealth_drawbar") <= 3 then
		if LocalPlayer():Health()<=0 then return end
		-- Base
		surface.SetDrawColor(80, 95, 60,65)
		surface.DrawRect(ScrW()/23, ScrH()/1.133, (ScrW()/7.75), ScrH()/75)

		-- Blocks
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetTexture( surface.GetTextureID( light_meter ) );
		surface.DrawTexturedRect(ScrW()/22, ScrH()/1.13, ScrW()/8, ScrH()/125);
		
		-- Slider
		local bar1 = luminocity*0.61
		draw.RoundedBox(4,ScrW()/22-2+bar1, ScrH()/1.13-2,8,11,Color(245,255,240,255))
	end
	
	if GetConVarNumber("stealth_drawbar") == 1 or GetConVarNumber("stealth_drawbar") == 2 or GetConVarNumber("stealth_drawbar") == 4 then
		-- Base
		surface.SetDrawColor(80, 95, 60,65)
		surface.DrawRect(ScrW()/23, ScrH()/1.113, (ScrW()/7.75), ScrH()/75)

		-- Blocks
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetTexture( surface.GetTextureID( sound_meter ) );
		surface.DrawTexturedRect(ScrW()/22, ScrH()/1.11, ScrW()/8, ScrH()/125);
		
		-- Slider
		--local bar2 = alertdanger*0.9
		local bar2 = alertdanger*0.61
		draw.RoundedBox(4,ScrW()/22-2+bar2, ScrH()/1.11-2,8,11,Color(235,255,150,100))
	end
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

local function CLcheckLOS(npc)
	-- Variables
	local minsight = GetConVarNumber("stealth_minsight")
	local maxsight = GetConVarNumber("stealth_maxsight")
	local movementbonus = GetConVarNumber("stealth_movebonus")
	local multiplier = GetConVarNumber("stealth_multiplier")
	if minsight < 0 then minsight = 0 end
	if maxsight < 0 then maxsight = 0 end
	if movementbonus < 0 then movementbonus = 0 end
	if multiplier < 0 then multiplier = 0 end
	--
	
	local sightrange = 0

	local isvisible = IsVisible(LocalPlayer(),npc)
	local eyesang = nil
	local yawdiff = 0
	local eyesobj = npc:LookupAttachment( "eyes" )
	if eyesobj then eyesang = npc:GetAttachment( eyesobj ) end
	if eyesang then yawdiff = math.abs(math.AngleDifference(eyesang["Ang"].y,(LocalPlayer():GetPos()-npc:GetPos()):Angle().y))
	else yawdiff = math.abs(math.AngleDifference(npc:GetAngles().y,(LocalPlayer():GetPos()-npc:GetPos()):Angle().y)) end
	local lightbonus = ((maxsight - minsight) * (luminocity/255))
	local playerspeed = LocalPlayer():GetVelocity():Length()
	local playerdist = LocalPlayer():GetPos():Distance(npc:GetPos())
	sightrange = ( minsight + lightbonus * (1+(movementbonus*(playerspeed/200))) ) * multiplier
	
	if GetConVar("ai_disabled"):GetInt() == 1 or GetConVar("ai_ignoreplayers"):GetInt() == 1 then
		return -1
	else
		if yawdiff>60 or not isvisible then
			return -1
		end
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) then
			if wep:GetClass() == "weapon_cbox" and LocalPlayer():Crouching() and LocalPlayer():GetVelocity():Length() == 0 then
				return -1
			end
		end
	end
	--
	
	if LocalPlayer():Crouching() then sightrange = sightrange/2 end
	--if not isvisible then LocalPlayer().shooting = LocalPlayer().shooting/2 end
	
	return math.Clamp((  255 - math.Clamp(255 * ((LocalPlayer():GetPos():Distance(npc:GetPos())-(sightrange * 0.75)) / math.Max((sightrange * 0.75),1000)),0,255))  , 0 , 255)
end

hook.Add("Think","SendLuminocity",function() --Keep checking what npcs are alert to
	if CurTime()+.5>lastsend then
		lastsend=CurTime()
		isnpc = GetGlobalBool("BadNPCOnMap", false)
		local complight = math.max((render.ComputeLighting(LocalPlayer():GetPos()+Vector(0,0,40),Vector(0,0,-1))*Vector(255,255,255)):Length(),(render.ComputeLighting(LocalPlayer():GetPos()+Vector(0,0,40),Vector(0,0,1))*Vector(255,255,255)):Length(),(render.ComputeLighting(LocalPlayer():GetPos()+Vector(0,0,40),Vector(0,1,0))*Vector(255,255,255)):Length(),(render.ComputeLighting(LocalPlayer():GetPos()+Vector(0,0,40),Vector(0,-1,0))*Vector(255,255,255)):Length(),(render.ComputeLighting(LocalPlayer():GetPos()+Vector(0,0,40),Vector(1,0,0))*Vector(255,255,255)):Length(),(render.ComputeLighting(LocalPlayer():GetPos()+Vector(0,0,40),Vector(-1,0,0))*Vector(255,255,255)):Length())
		local complight = math.max((render.ComputeLighting(LocalPlayer():GetPos(),Vector(0,0,-1))*Vector(255,255,255)):Length(),(render.ComputeLighting(LocalPlayer():GetPos(),Vector(0,0,1))*Vector(255,255,255)):Length())
		luminocity = math.Clamp(complight/2.8 + ((LocalPlayer():FlashlightIsOn() and 1 or 0)*100),0,255)
		-- Back to the old method
		luminocity = math.Clamp((render.GetLightColor(LocalPlayer():GetPos())*Vector(255,255,255)):Length()+ ((LocalPlayer():FlashlightIsOn() and 1 or 0)*100),0,255)
		RunConsoleCommand("p_sendluminocity",tostring(luminocity))
		stealthmod.luminocity = luminocity
		
		-- Sight Range Calculation
		if #npctable != 0 then
			alertdanger = 0
			dangernpc = nil
			for k,v in pairs(npctable) do
				if IsValid(v) then 
					local aux = CLcheckLOS(v)
					if aux >= alertdanger then
						alertdanger = aux
						dangernpc = v
					end
				else
					table.RemoveByValue(npctable,v)
				end
			end
			stealthmod.alertdanger = alertdanger
		end
	end
	-- Music
	if !alertmusic then alertmusic = CreateSound( LocalPlayer() , "stealth/alertmusic.wav") end
	if alertmusic:IsPlaying() then
		if insight == 1 and LocalPlayer():Alive() then
			if timer.Exists("musicturnoff") then timer.Remove("musicturnoff") end
			alertmusic:ChangeVolume( 1 , 0 ) 
			if GetConVarNumber("stealth_alerttime") > 2 then
				timer.Create( "musicturnoff", GetConVarNumber("stealth_alerttime")-2, 1, function() alertmusic:ChangeVolume( 0.01, 2 ) end) 
			end
		elseif #hunters == 0 and fadingmusic == 0 then
			fadingmusic = 1
			alertmusic:ChangeVolume( 0.01, 2 )
			timer.Simple( 2, function()
				if (#hunters == 0) then
					alertmusic:Stop()
					playingmusic = 0
				else
					alertmusic:ChangeVolume( 1 , 0 )
				end
				fadingmusic = 0
			end) 
		end
	end
	
	-- Amnesia-like dark vision, made by AaronTheSnob
	-- Cool stuff, but not related to this mod
	
	if GetConVar("stealth_enabledarkvision"):GetInt() != 0 then
		-- Check if the player is in darkness.
		if (luminocity < 10) and (!LocalPlayer():FlashlightIsOn()) then
			-- Make the light fade in.
			darkvisionbrightness = darkvisionbrightness + 0.3 * FrameTime()
			if darkvisionbrightness >= 1 then
				darkvisionbrightness = 1
			end
		else
			-- Make the light fade out
			darkvisionbrightness = darkvisionbrightness - 1 * FrameTime()
			if darkvisionbrightness <= 0 then
				darkvisionbrightness = 0
			end
		end
	else
		-- Turn off the light
		darkvisionbrightness = 0
	end
	
	-- Apply the light settings
	if ( dlight ) then
		dlight.pos = LocalPlayer():GetShootPos()
		-- Toned down the brightness a bit
		dlight.r = 5 * darkvisionbrightness
		dlight.g = 5 * darkvisionbrightness
		dlight.b = 15 * darkvisionbrightness
		dlight.brightness = 1
		dlight.Decay = 1000
		dlight.Size = 512
		dlight.DieTime = CurTime() + 1
	end

end)

local function NPCAlerted( data )
 	local npc = data:ReadEntity()
	local silent = data:ReadBool()
	if IsValid( npc ) and !table.HasValue(hunters, npc) then
		table.insert(hunters, npc)
		insight = 1
		
		if GetConVar("stealth_enablesound"):GetInt() != 0 and silent == false and sounddelay < CurTime() then
				LocalPlayer():EmitSound( "stealth/detected.wav", 100, 100, 1, CHAN_AUTO )
			
			sounddelay = CurTime() + 1
		end
		timer.Simple(0.5, function() if !alertmusic:IsPlaying() and #hunters > 0 and GetConVarNumber("stealth_enablemusic")==1 then
			alertmusic:Play()
			playingmusic = 1
		end
		end)
	end
end

usermessage.Hook( "NPCAlerted", NPCAlerted )

local function NPCCalmed( data )
	local npc = data:ReadEntity()
	if IsValid( npc ) and table.HasValue(hunters, npc) then
		table.RemoveByValue(hunters, npc)
	end
end

usermessage.Hook( "NPCCalmed", NPCCalmed )

local function NPCCreateEffect(npc, effectname)
	if !IsValid(npc) then return end
	local allents = ents.GetAll()
	if GetConVar("stealth_enablefx"):GetInt() != 0 then
		local effect = EffectData()
		effect:SetOrigin(npc:GetPos())
		effect:SetEntity(npc)
		util.Effect( effectname, effect, true, true )
		LocalPlayer():EmitSound( "stealth/tension.wav", 100, 100, 1, CHAN_AUTO )
	end
	local e = ents.GetAll()[#allents +1]
	if e then return e end
end

local function NPCEffect( data )
	local npc = data:ReadEntity()
	local effectname = data:ReadString()
	if IsValid(npc.currenteffect) then 
		npc.currenteffect:DoRemove()
	end
	npc.currenteffect = NPCCreateEffect(npc,effectname)
end

usermessage.Hook( "NPCEffect", NPCEffect )

timer.Create("CheckVisible",.5,0,function() --Keep checking what alerted npcs are visible
	if #hunters == 0 then return end
	insight = 0
	for k = #hunters, 1, -1 do
		if IsValid(hunters[k]) then
			if insight == 0 and IsVisible(LocalPlayer(),hunters[k]) then
				insight = 1
			end
		else
			table.remove(hunters, k)
		end
	end
end)

hook.Add("PopulateToolMenu", "stealthmenu", function()
	spawnmenu.AddToolMenuOption("Options", "Stealth Mod", "stealthmodclient", "Client Settings", "", "", SettingsPanelClient)
	spawnmenu.AddToolMenuOption("Options", "Stealth Mod", "stealthmodserver", "Server Settings", "", "", SettingsPanelServer)
end)

function SettingsPanelClient(panel)

	local pan = {}
	
	local p = panel:AddControl("Slider", {
		Label = "HUD Mode",
		Min = "0",
		Max = "4"
	})
	p:SetValue( GetConVarNumber( "stealth_drawbar" ) )
	p.OnValueChanged = function(self)
		RunConsoleCommand("stealth_drawbar", math.Round(self:GetValue(),0))
	end
	table.insert(pan,{"stealth_drawbar",p,1})
		
	
	
	local p = panel:AddControl("CheckBox", {
		Label = "Enable Effects"
	})
	p:SetValue( GetConVarNumber( "stealth_enablefx" ) )
	p.OnChange = function(self)
		RunConsoleCommand("stealth_enablefx", self:GetChecked()==true and 1 or 0)
	end
	table.insert(pan,{"stealth_enablefx",p,1})
	
	
	
	local p = panel:AddControl("CheckBox", {
		Label = "Enable Sound"
	})
	p:SetValue( GetConVarNumber( "stealth_enablesound" ) )
	p.OnChange = function(self)
		RunConsoleCommand("stealth_enablesound", self:GetChecked()==true and 1 or 0)
	end
	table.insert(pan,{"stealth_enablesound",p,1})
	
	
	
	local p = panel:AddControl("CheckBox", {
		Label = "Enable Music"
	})
	p:SetValue( GetConVarNumber( "stealth_enablemusic" ) )
	p.OnChange = function(self)
		RunConsoleCommand("stealth_enablemusic", self:GetChecked()==true and 1 or 0)
	end
	table.insert(pan,{"stealth_enablemusic",p,1})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Hud X Pos",
		Min = "0",
		Max = "4000"
	})
	p:SetValue( GetConVarNumber( "stealth_hudx" ) )
	p.OnValueChanged = function(self)
		RunConsoleCommand("stealth_hudx", math.Round(self:GetValue()))	
	end
	table.insert(pan,{"stealth_hudx",p,29})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Hud Y Pos",
		Min = "0",
		Max = "3000"
	})
	p:SetValue( GetConVarNumber( "stealth_hudy" ) )
	p.OnValueChanged = function(self)
		RunConsoleCommand("stealth_hudy", math.Round(self:GetValue()))	
	end
	table.insert(pan,{"stealth_hudy",p,220})
	
	
	
	local p = panel:AddControl("Button", {
		Label = "Default settings",
		Command = ""
	})
	p.DoClick = function()
		for k,v in pairs(pan) do
			v[2]:SetValue(v[3])
		end
		--[[
		pan[1][2]:SetValue(1)
		pan[2][2]:SetValue(1)
		pan[3][2]:SetValue(1)
		pan[4][2]:SetValue(1)
		pan[5][2]:SetValue(29)
		pan[6][2]:SetValue(220)	
		]]--
	end
	
end

function SettingsPanelServer(panel)

	local pan = {}

	local p = panel:AddControl("CheckBox", {
		Label = "Enable Stealth"
	})
	p:SetValue( GetConVarNumber( "stealth_enabled" ) )
	p.OnChange = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_enabled")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_enabled",p,1})
	
	
	
	local p = panel:AddControl("CheckBox", {
		Label = "Relationship Override"
	})
	p:SetValue( GetConVarNumber( "stealth_override" ) )
	p.OnChange = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_override")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_override",p,1})
	
	
	
	local p = panel:AddControl("CheckBox", {
		Label = "Keep Corpses Override"
	})
	p:SetValue( GetConVarNumber( "stealth_keepcorpses" ) )
	p.OnChange = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_keepcorpses")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_keepcorpses",p,0})
	
	
	
	local p = panel:AddControl("CheckBox", {
		Label = "Alert on damage"
	})
	p:SetValue( GetConVarNumber( "stealth_alertondamage" ) )
	p.OnChange = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_alertondamage")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_alertondamage",p,1})

	
	
	local p = panel:AddControl("Slider", {
		Label = "Alert Time",
		Type = "Float",
		Min = "0",
		Max = "100"
	})
	p:SetValue( GetConVarNumber( "stealth_alerttime" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_alerttime")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_alerttime",p,15})

	panel:AddControl("Label", {
		Text = "Time until NPCs leave their alerted state."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Difficulty Multiplier",
		Type = "Float",
		Min = "0",
		Max = "5"
	})
	p:SetValue( GetConVarNumber( "stealth_multiplier" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_multiplier")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_multiplier",p,1})

	
	
	panel:AddControl("Label", {
		Text = "This increases or decreases all stealth settings."
	})
	
	local p = panel:AddControl("Slider", {
		Label = "Min Sight Range",
		Type = "Float",
		Min = "0",
		Max = "5000"
	})
	p:SetValue( GetConVarNumber( "stealth_minsight" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_minsight")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_minsight",p,200})

	
	
	panel:AddControl("Label", {
		Text = "Range at which an NPC can detect a standing player with minimum light level."
	})
	
	local p = panel:AddControl("Slider", {
		Label = "Max Sight Range",
		Type = "Float",
		Min = "0",
		Max = "5000"
	})
	p:SetValue( GetConVarNumber( "stealth_maxsight" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_maxsight")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_maxsight",p,1500})

	panel:AddControl("Label", {
		Text = "Range at which an NPC can detect a standing player with maximum light level."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Movement Bonus",
		Type = "Float",
		Min = "0",
		Max = "5"
	})
	p:SetValue( GetConVarNumber( "stealth_movebonus" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_movebonus")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_movebonus",p,0.3})

	panel:AddControl("Label", {
		Text = "Sight range will be increased this much when a player is running (double if sprinting)."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Min Hearing Range",
		Type = "Float",
		Min = "0",
		Max = "5000"
	})
	p:SetValue( GetConVarNumber( "stealth_minhearing" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_minhearing")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_minhearing",p,200})

	panel:AddControl("Label", {
		Text = "Range at which an NPC can hear a running player (double if sprinting)."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Shot Range",
		Type = "Float",
		Min = "0",
		Max = "5000"
	})
	p:SetValue( GetConVarNumber( "stealth_shotrange" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_shotrange")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_shotrange",p,1000})

	panel:AddControl("Label", {
		Text = "Range at which an NPC can hear a gunshot."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Suppression Multiplier",
		Type = "Float",
		Min = "0",
		Max = "1"
	})
	p:SetValue( GetConVarNumber( "stealth_suppmultiplier" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_suppmultiplier")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_suppmultiplier",p,0.3})

	panel:AddControl("Label", {
		Text = "Hearing range multiplier for suppressed weapons."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Backup time",
		Type = "Float",
		Min = "0",
		Max = "100"
	})
	p:SetValue( GetConVarNumber( "stealth_backuptime" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_backuptime")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_backuptime",p,0.2})

	panel:AddControl("Label", {
		Text = "Time in seconds until an enemy alerts nearby npcs after detecting a player."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Backup range",
		Type = "Float",
		Min = "0",
		Max = "5000"
	})
	p:SetValue( GetConVarNumber( "stealth_backuprange" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_backuprange")
			net.WriteFloat(self:GetValue())
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_backuprange",p,800})

	panel:AddControl("Label", {
		Text = "When an enemy detects you, he will alert all enemies inside this range."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Max corpses",
		Min = "0",
		Max = "100"
	})
	p:SetValue( GetConVarNumber( "stealth_maxcorpses" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_maxcorpses")
			net.WriteFloat(math.Round(self:GetValue()))
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_maxcorpses",p,10})

	panel:AddControl("Label", {
		Text = "Limits the maximum amount of enemy corpses (only for NPCs affected by this mod)."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Sensor Time",
		Min = "0",
		Max = "100"
	})
	p:SetValue( GetConVarNumber( "stealth_sensortime" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_sensortime")
			net.WriteFloat(math.Round(self:GetValue()))
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_sensortime",p,10})

	panel:AddControl("Label", {
		Text = "Time until the Proximity Sensor deactivates."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Sensor Range",
		Min = "0",
		Max = "5000"
	})
	p:SetValue( GetConVarNumber( "stealth_sensorrange" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_sensorrange")
			net.WriteFloat(math.Round(self:GetValue()))
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_sensorrange",p,500})

	panel:AddControl("Label", {
		Text = "Detection range for the Proximity Sensor."
	})
	
	
	
	local p = panel:AddControl("Slider", {
		Label = "Sleep Time",
		Min = "0",
		Max = "1000"
	})
	p:SetValue( GetConVarNumber( "stealth_sleeptime" ) )
	p.OnValueChanged = function(self)
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_sleeptime")
			net.WriteFloat(math.Round(self:GetValue()))
			net.SendToServer()
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to change this option.")
			chat.PlaySound()
		end			
	end
	table.insert(pan,{"stealth_sleeptime",p,60})

	panel:AddControl("Label", {
		Text = "Time in seconds until an unconcious enemy wakes up."
	})
	
	
	
	local p = panel:AddControl("Button", {
		Label = "Reload lists",
		Command = ""
	})
	p.DoClick = function() 
		if LocalPlayer():IsSuperAdmin() then
			net.Start("stealth_reloadsettings")
			net.SendToServer() 
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to do this.")
			chat.PlaySound()
		end			
	end
	
	local p = panel:AddControl("Button", {
		Label = "Default settings",
		Command = ""
	})
	p.DoClick = function() 
		if LocalPlayer():IsSuperAdmin() then
			-- Reset panel
			-- GetDefault() doesn't work for some reason, so...
			for k,v in pairs(pan) do
				v[2]:SetValue(v[3])
			end
			--[[
			pan[1][2]:SetValue(1)
			pan[2][2]:SetValue(1)
			pan[3][2]:SetValue(0)
			pan[4][2]:SetValue(1)
			pan[5][2]:SetValue(15)
			pan[6][2]:SetValue(1)
			pan[7][2]:SetValue(200)
			pan[8][2]:SetValue(1500)
			pan[9][2]:SetValue(0.3)
			pan[10][2]:SetValue(200)
			pan[11][2]:SetValue(1000)
			pan[12][2]:SetValue(0.3)
			pan[13][2]:SetValue(2)
			pan[14][2]:SetValue(800)
			pan[15][2]:SetValue(10)
			pan[16][2]:SetValue(10)
			pan[17][2]:SetValue(10)
			pan[18][2]:SetValue(10)
			]]--
		else
			chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be a super-admin to do this.")
			chat.PlaySound()
		end			
	end
end