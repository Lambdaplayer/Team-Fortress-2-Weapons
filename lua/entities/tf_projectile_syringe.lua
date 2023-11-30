AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false

function ENT:Draw()
self.Entity:DrawModel()
end

function ENT:Initialize()
if SERVER then
self.Entity:SetModel( "models/weapons/w_models/w_syringe_proj.mdl" )
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
self.Entity:SetSolid( SOLID_VPHYSICS )
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
self.Entity:DrawShadow( false )
end
end

function ENT:PhysicsCollide( data )
if SERVER then
self.Entity:SetMoveType( MOVETYPE_NONE )
self.Entity:SetSolid( SOLID_NONE )
self.Entity:PhysicsInit( SOLID_NONE )
self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE )
end
local dmg = DamageInfo()
local owner = self:GetOwner()
if !IsValid( self ) then
owner = self
end
dmg:SetAttacker( owner )
dmg:SetInflictor( self )
dmg:SetDamage( 10 )
dmg:SetDamageType( DMG_BULLET )
data.HitEntity:TakeDamageInfo( dmg )
if SERVER and ( data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() ) then
self.Entity:Remove()
end
end