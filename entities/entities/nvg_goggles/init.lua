AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self.Entity:SetModel( "models/nvg/nv_goggles.mdl" )
	
end
	
	function ENT:Use( activator, caller )
	end
	
	function ENT:Touch( ent )
	end
	
	function ENT:OnRemove()
	end
	
	function ENT:Think()
	end