include( "cl_stealth.lua" )
resource.AddFile( "materials/hud/energy_icon.vmt" )
resource.AddFile( "materials/hud/hp_icon.vmt" )

local HudColor = Color(134,164,131,155)


/* Dont mess these up! */
/* -- */ local rightx = ScrW()
/* -- */ local centerx = rightx*0.5
/* -- */ local bottomy = ScrH()
/* -- */ local centery = bottomy*0.5
/* -- */ local ply = LocalPlayer();
/* -- */ local Alphacolor = Color(0,255,55,255)
/* ^^^^^^^^^^^^^^^^^^^ */

surface.CreateFont( "Prototype45", {
	font 		= "Prototype",
	size 		= rightx/12, 
	size 		= bottomy/72,
	weight 		= 700,
	blursize 	= 0.6,
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

surface.CreateFont( "Prototype60", {
	font 		= "Bodoni MT Condensed",
	size 		= rightx/18,
	size 		= bottomy/11,
	weight 		= 0,
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



function DrawHUD()

	local ply = LocalPlayer()
	
	if ply:Health()<=0 then return end
	if(ply:GetActiveWeapon() == NULL or ply:GetActiveWeapon() == "Camera") then return end

	local weapon = ply:GetActiveWeapon()
	if !IsValid( weapon ) or !weapon:GetPrimaryAmmoType() then return end
	local wpnname = weapon:GetPrintName()
	wpnname = wpnname or '<UNKNOWN WEAPON>'
	local magleft = ply:GetActiveWeapon():Clip1()
	local magextra = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType())
	local secondary_ammo = ply:GetAmmoCount(ply:GetActiveWeapon():GetSecondaryAmmoType())
	local hp_icon = "materials/hud/hp_icon.vmt"
	local energy_icon = "materials/hud/energy_icon.vmt"
	
	if magleft < 0 then magleft = 0 end
	if magextra < 0 then magextra = 0 end
	
	
	
	
	--Bars BACKGROUND--
	surface.SetDrawColor( 80, 95, 60, 65 );
	surface.DrawRect(rightx/23, bottomy/1.1625, (rightx/7.75), bottomy/50);
	

	
		--HP BACKGROUND--
	surface.SetDrawColor( 20, 20, 20, 175 );
	surface.DrawRect(rightx/22.25, bottomy/1.16, (rightx/8), bottomy/145);
	
	--HP BAR--
	if (ply:Health()<25) then // -- 25 is fixed number, you will need to get player max health fraction if you want to get procentual value (for overheal or max health increase)
		local brate = math.sin(CurTime());// you can multiply Curtime()*N to modify blink speed
		surface.SetDrawColor( (brate*51)+225, (brate*49)+245, (brate*13)+175, 500); 
	else
		surface.SetDrawColor( 169, 196, 162, 175 );
	end
	surface.DrawRect( rightx/22.25, bottomy/1.16,(rightx/(15)/53.2)*ply:Health(),bottomy/145);
	
	--Armor BACKGROUND--
	surface.SetDrawColor( 20, 20, 20, 175 );
	surface.DrawRect(rightx/22.25, bottomy/1.15, (rightx/8), bottomy/100);
	
	--Armor BAR--
	surface.SetDrawColor( 115, 165, 235, 175 );
	surface.DrawRect( rightx/21.25, bottomy/1.15,(rightx/(15)/53.2)*ply:Armor(),bottomy/100);
	

	
	
	--Equipment OUTLINE--
	surface.SetDrawColor( 80, 95, 60, 65 );
	surface.DrawRect(rightx/4.92, bottomy/1.1615, (rightx/14.25), bottomy/21);
	
	--Equipment BACKGROUND--
	surface.SetDrawColor( 20, 20, 20, 175 );
	surface.DrawRect(rightx/4.86, bottomy/1.16, (rightx/15), bottomy/22);
	
	

	

	
	
	draw.SimpleText(wpnname, "Prototype45", rightx/4.2, bottomy/1.115, Color(255,255,255,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.SimpleText(magleft, "Prototype45", rightx/3.85, bottomy/1.14, Color(255,255,255,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.SimpleText(magextra, "Prototype45", rightx/4.55, bottomy/1.14, Color(255,255,255,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.DrawText( "[", "Prototype60", rightx/29.25, bottomy/1.203, Color( 160, 175, 140, 70 ), TEXT_ALIGN_CENTER )
	
	draw.DrawText( "]", "Prototype60", rightx/5.6, bottomy/1.203, Color( 160, 175, 140, 70 ), TEXT_ALIGN_CENTER )
	

end





hook.Add("HUDPaint","DrawHUD:Draw",DrawHUD)

local function HideThings( name )
	if(name == "CHudHealth") or (name == "CHudBattery") or(name=="CHudAmmo") or(name=="CHudSecondaryAmmo")then
		return false
	end
end
hook.Add( "HUDShouldDraw", "HideThings", HideThings )