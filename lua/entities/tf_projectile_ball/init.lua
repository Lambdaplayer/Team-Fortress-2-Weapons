AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	local Trail = ents.Create("info_particle_system")
	Trail:SetPos(self:GetPos())
	Trail:SetKeyValue( "effect_name", "stunballtrail_red" )
	Trail:SetParent( self )
	Trail:SetKeyValue( "start_active", "1" )
	Trail:Spawn()
	Trail:Activate()
	util.SpriteTrail(self, 0, Color(255,100,100), false, 8, 1, 0.28, 1/(8+1)*0.5, "Effects/baseballtrail_red.vmt")

	self:SetModel("models/weapons/w_models/w_baseball.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( true )
	
	-- Don't collide with the player
	self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
	self:SetNetworkedString("Owner", "World")
	
	local phys = self:GetPhysicsObject()
	
	phys:SetMass(1.4)
	
	self.AllowHit = CurTime() + 0.085
	self.HomeRun = CurTime() + 0.6
	self.NextHit = CurTime()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	timer.Simple(9,function()
	if self:IsValid() then
	self:Remove()
	end
	end)
end

local exp

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function ENT:Think()
	for k,v in pairs (ents.FindInSphere( self:GetPos(), 25)) do
	if v:IsPlayer() and v:HasWeapon("tf_weapon_sandman") then
	if v:GetWeapon("tf_weapon_sandman"):GetNWBool("BallGot") then return end
	v:GetWeapon("tf_weapon_sandman"):SetNWBool("BallGot",true)
	v:GetWeapon("tf_weapon_sandman"):EmitSound("player/recharged.wav")
	self:Remove()
	if SERVER then
	if v:GetWeapon("tf_weapon_sandman") then return end
	if v:GetWeapon("tf_weapon_sandman") then
	v:GetWeapon("tf_weapon_sandman"):sendWeaponAnim("Ballgrab",1)
	end
	end
	end
end
end

function ENT:Use(activator)
end

function ENT:Touch(ent)
if self.AllowHit and CurTime()>=self.AllowHit and self.NextHit and CurTime()>=self.NextHit then

if not ent:IsNPC() or not ent:IsPlayer() then
self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
end

if self:GetVelocity():Length() >= 500 and ent:IsPlayer() then
if self.HomeRun and CurTime()<= self.HomeRun then
self.NextHit = CurTime() + 0.1
ent:EmitSound("player/pl_impact_stun.wav")
ent:Freeze(true)
ent:TakeDamage(6, self.Owner, self)
self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
local ExplodeEffect = ents.Create("info_particle_system")
	ExplodeEffect:SetPos(ent:GetPos() + ent:GetUp() * 60)
	ExplodeEffect:SetKeyValue( "effect_name", "conc_stars" )
	ExplodeEffect:SetKeyValue( "start_active", "1" )
	ExplodeEffect:Spawn()
	ExplodeEffect:Activate()
timer.Create("unlockme"..tostring(ent:Nick()), 1.55, 1, function()
ExplodeEffect:Remove()
if ent:IsValid() then
ent:Freeze(false)
end
end)
else
self.HomeRun = nil
self.NextHit = CurTime() + 0.1
ent:EmitSound("player/pl_impact_stun_range.wav")
ent:Freeze(true)
ent:TakeDamage(12, self.Owner, self)
self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
local ExplodeEffect = ents.Create("info_particle_system")
	ExplodeEffect:SetPos(ent:GetPos() + ent:GetUp() * 60)
	ExplodeEffect:SetKeyValue( "effect_name", "conc_stars" )
	ExplodeEffect:SetKeyValue( "start_active", "1" )
	ExplodeEffect:Spawn()
	ExplodeEffect:Activate()
timer.Create("unlockme"..tostring(ent:Nick()), 2.2, 1, function()
ExplodeEffect:Remove()
if ent:IsValid() then
ent:Freeze(false)
end
end)
end
end

if self:GetVelocity():Length() >= 350 and ent:IsNPC() then
self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
self.NextHit = CurTime() + 0.1
if self.HomeRun and CurTime()<= self.HomeRun then
ent:TakeDamage(self:GetVelocity():Length()/100,self.Owner)
ent:EmitSound("player/pl_impact_stun.wav")
self.Owner:EmitSound("player/pl_impact_stun.wav")
else
ent:TakeDamage(self:GetVelocity():Length()/100,self.Owner)
self.HomeRun = nil
ent:EmitSound("player/pl_impact_stun_range.wav")
self.Owner:EmitSound("player/pl_impact_stun_range.wav")
end
end
end
end