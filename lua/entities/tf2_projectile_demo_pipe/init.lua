
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	if self.Loch then
	self:SetModel("models/weapons/w_models/w_grenade_grenadelauncher.mdl")
	self.SelfDamage = 38
	self.Damage = 72
	elseif self.Cannon then
	self:SetModel("models/weapons/w_models/w_cannonball.mdl")
	self.SelfDamage = 38
	self.Damage = 60
	elseif self.IronBomb then
	self:SetModel("models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl")
	self.SelfDamage = 38
	self.Damage = 60
	else
	self:SetModel("models/weapons/w_models/w_grenade_grenadelauncher.mdl")
	self.SelfDamage = 38
	self.Damage = 60
	end
	if not self.Loch then
	self:DoTimer()
	end
	if self.Blue then
	self:SetSkin(1)
	end
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.trail = ents.Create("info_particle_system")
	self.trail:SetPos(self:GetPos())
	self.trail:SetParent(self)
	if self.Blue then
	self.trail:SetKeyValue("effect_name","pipebombtrail_blue")
	else
	self.trail:SetKeyValue("effect_name","pipebombtrail_red")
	end
	self.trail:SetKeyValue("start_active", "1")
	self.trail:Spawn()
	self.trail:Activate()
end

function ENT:OnRemove()
	if self.trail and IsValid(self.trail) then self.trail:Remove() end
end

function ENT:Think()
end

function ENT:DoTimer()
if self.Timer then
if self.Timer <= 0 then
self.Timer = 0.1
end
timer.Simple(self.Timer * 0.1, function()
if self and IsValid(self) then
self.Exploding = true
end
end)
timer.Simple(self.Timer, function()
if self and IsValid(self) then
self:Explode()
end
end)
end
end

function ENT:Explode()
if self.Cannon then
self:EmitSound("Weapon_LooseCannon.Explode")
else
self:EmitSound("Weapon_Grenade_Pipebomb.Explode")
end
	local ExplodeEffect = ents.Create("info_particle_system")
	ExplodeEffect:SetPos(self:GetPos())
	ExplodeEffect:SetKeyValue( "effect_name", "ExplosionCore_MidAir" )
	ExplodeEffect:SetKeyValue( "start_active", "1" )
	ExplodeEffect:Spawn()
	ExplodeEffect:Activate()
	self:Remove()
	if self.Loch then
	self.ExplosionRange = 109.5
	else
	self.ExplosionRange = 146
	end
	for k,v in pairs(ents.FindInSphere(self:GetPos(), self.ExplosionRange)) do
	if v:GetClass() == self:GetClass() or v.Explosive then return end
	if v:EntIndex() == self.Owner:EntIndex() then
	local d = DamageInfo()
	d:SetDamage( self.SelfDamage )
	d:SetAttacker( self:GetOwner() )
	d:SetDamageType( DMG_BLAST )
	v:TakeDamageInfo( d )
	else
	local d = DamageInfo()
	d:SetDamage( self.Damage )
	d:SetAttacker( self:GetOwner() )
	d:SetDamageType( DMG_BLAST )
	v:TakeDamageInfo( d )
	end
	v:SetVelocity( 1000 * (v:LocalToWorld(v:OBBCenter()) - self:GetPos()):GetNormalized() )
	if v:GetPhysicsObject():IsValid() then
	v:GetPhysicsObject():SetVelocity( 1000 * (v:LocalToWorld(v:OBBCenter()) - self:GetPos()):GetNormalized() )
	end
	end
end


function ENT:PhysicsCollide( data, physobj )
	
	if self.Cannon and data.Speed > 100 and data.HitEntity:IsValid() and (data.HitEntity:IsNPC() or data.HitEntity:IsPlayer()) and data.HitEntity:Health() > 0 then
	data.HitEntity:SetVelocity(data.HitEntity:GetVelocity() + Vector(data.HitEntity:GetVelocity().x,data.HitEntity:GetVelocity().y,300))
	data.HitEntity:SetVelocity( 1000 * (data.HitEntity:LocalToWorld(data.HitEntity:OBBCenter()) - self:GetPos()):GetNormalized() )
	if data.HitEntity:GetPhysicsObject():IsValid() then
	data.HitEntity:GetPhysicsObject():SetVelocity( 1000 * (data.HitEntity:LocalToWorld(data.HitEntity:OBBCenter()) - self:GetPos()):GetNormalized() )
	end
	if SERVER then
	local d = DamageInfo()
	d:SetDamage( 5 )
	d:SetAttacker( self:GetOwner() )
	d:SetDamageType( DMG_BLAST )
	data.HitEntity:TakeDamageInfo( d )
	end
	self:EmitSound("weapons/loose_cannon_ball_impact.wav")
	self:SetVelocity(self:GetVelocity()/2)
	if self.Exploding then
	data.HitEntity:EmitSound("player/doubledonk.wav")
	self.Owner:EmitSound("player/doubledonk.wav")
	end
	end
	
	if self.IronBomb and self:GetPhysicsObject():IsValid() then
	self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()*.5)
	end

	if not self.Cannon and data.HitEntity:IsValid() and (data.HitEntity:IsNPC() or data.HitEntity:IsPlayer()) and data.HitEntity:Health() > 0 then
		self:Explode()
	else
	if self.Loch then
	self:EmitSound("weapons/loch_n_load_dud.wav")
	self:Remove()
	else
	if ( data.Speed > 100 ) then
		self:EmitSound( "Weapon_Grenade_Pipebomb.Bounce" )
	end
	end
	end
	return true
end


