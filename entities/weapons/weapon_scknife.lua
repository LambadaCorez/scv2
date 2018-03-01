sound.Add( 
{
 name = "Weapon_SCKnife.Hitwall",
 channel = CHAN_WEAPON,
 volume = 0.55,
 level = SNDLVL_GUNFIRE,
 pitch = { 90, 110 },
 sound = "weapons/sc_knife/knife_hitwall1.wav"
} )

sound.Add( 
{
 name = "Weapon_SCKnife.Hit",
 channel = CHAN_WEAPON,
 volume = 0.5,
 level = SNDLVL_GUNFIRE,
 pitch = { 90, 110 },
 sound =  "weapons/sc_knife/knife_slash.wav" 
} )

sound.Add( 
{
 name = "Weapon_SCKnife.Stab",
 channel = CHAN_WEAPON,
 volume = 0.85,
 level = SNDLVL_GUNFIRE,
 pitch = { 90, 110 },
 sound =  "weapons/sc_knife/knife_stab.wav" 
} )


SWEP.Base = "weapon_base"

SWEP.PrintName			= "SC Protector"			
SWEP.Author			    = ""
SWEP.Purpose            = "Doing the dirty work quietly."
SWEP.Instructions		= ""
SWEP.Category           = "Splinter Cell"

SWEP.Spawnable = true

SWEP.Primary.Delay	 = 0.75
SWEP.Primary.Damage	 = 65
SWEP.Primary.Force	 = 2

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Damage = 100
SWEP.Secondary.Delay = 1
SWEP.Secondary.Force = 4

SWEP.Weight			= 1
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.HoldType           = "knife"

SWEP.Slot			= 0
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel = "models/weapons/csczds/v_knife.mdl"
SWEP.WorldModel = "models/weapons/csczds/w_knife.mdl"

SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {}

SWEP.SwingMissSound = Sound("weapons/sc_knife/knife_slash2.wav")
SWEP.SwingSound = Sound("weapons/sc_knife/knife_slash.wav")

SWEP.UseHands = false

if CLIENT then
killicon.Add(  "weapon_scprotector","hud/hud_weapon/sc_knife", Color( 255, 255, 255, 255 ))
SWEP.BounceWeaponIcon   = true
SWEP.WepSelectIcon	= surface.GetTextureID( "hud/hud_weapon/sc_knife_select" )
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end 

function SWEP:Reload()
end

function SWEP:Think()
end

function SWEP:Deploy()
self:SetWeaponHoldType( self.HoldType )
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
if SERVER then
self.Owner:EmitSound( "weapons/sc_knife/knife_equip.wav" )
end
end

function SWEP:Holster()
if SERVER then
self.Owner:EmitSound( "weapons/sc_knife/knife_holster.wav" )
end
return true
end

function SWEP:PrimaryAttack()
self.Owner:EmitSound( "weapons/sc_knife/knife_slash2.wav" )
self.Owner:LagCompensation( true )
local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 75,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 75,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if SERVER and tr.Hit and !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) then
self.Owner:EmitSound( "Weapon_SCKnife.Hitwall" )
end
if SERVER and IsValid( tr.Entity ) then
local dmginfo = DamageInfo()
local attacker = self.Owner
if !IsValid( attacker ) then
attacker = self
end
dmginfo:SetAttacker( attacker )
dmginfo:SetInflictor( self )
dmginfo:SetDamage( self.Primary.Damage )
dmginfo:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
tr.Entity:TakeDamageInfo( dmginfo )
if tr.Hit then
if tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 then
self.Owner:EmitSound( "Weapon_SCKnife.Hit" )
end
if !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) then
self.Owner:EmitSound( "Weapon_SCKnife.Hitwall" )
end
end
end
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
self.Owner:SetAnimation( PLAYER_ATTACK1 )
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:SecondaryAttack()
self.Owner:EmitSound( "weapons/sc_knife/knife_equip.wav" )
self.Owner:LagCompensation( true )
local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 56,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 56,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if SERVER and tr.Hit and !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) then
self.Owner:EmitSound( "Weapon_SCKnife.HitWall" )
end
if SERVER and IsValid( tr.Entity ) then
local dmginfo = DamageInfo()
local attacker = self.Owner
if !IsValid( attacker ) then
attacker = self
end
dmginfo:SetAttacker( attacker )
dmginfo:SetInflictor( self )
local angle = self.Owner:GetAngles().y - tr.Entity:GetAngles().y
if angle < -180 then angle = 360 + angle end
if angle <= 90 and angle >= -90 then
dmginfo:SetDamage( 195 )
else
dmginfo:SetDamage( self.Secondary.Damage )
end
dmginfo:SetDamageForce( self.Owner:GetForward() * self.Secondary.Force )
tr.Entity:TakeDamageInfo( dmginfo )
if tr.Hit then
if tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 then
self.Owner:EmitSound( "Weapon_SCKnife.Stab" )
end
if !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) then
self.Owner:EmitSound( "Weapon_SCKnife.HitWall" )
end
end
end
if tr.Hit then
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
if !tr.Hit then
self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
end
self.Owner:SetAnimation( PLAYER_ATTACK1 )
self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
end
