-- Flare

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

PrecacheParticleSystem("flaregun_trail_red")
PrecacheParticleSystem("flaregun_trail_blue")
PrecacheParticleSystem("flaregun_crit_red")
PrecacheParticleSystem("flaregun_crit_blue")
PrecacheParticleSystem("flaregun_destroyed")

ENT.IsTFWeapon = false

function ENT:InitEffects()
	ParticleEffectAttach("flaregun_trail_red", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end

if CLIENT then

function ENT:Initialize()
	self:InitEffects()
end

function ENT:Draw()
	self:DrawModel()
end

end

if SERVER then

AddCSLuaFile( "shared.lua" )

ENT.Model = "models/weapons/w_models/w_flaregun_shell.mdl"

ENT.BaseDamage = 30
ENT.DamageRandomize = 0.1
ENT.MaxDamageRampUp = 0
ENT.MaxDamageFalloff = 0
ENT.DamageModifier = 1

ENT.HitboxSize = 0.5

ENT.CritDamageMultiplier = 3

ENT.HitSound = Sound("Default.FlareImpact")


/*function ENT:CalculateDamage(ownerpos)
	return tf_util.CalculateDamage(self, self:GetPos(), ownerpos)
end*/

function ENT:Initialize()
	local min = Vector(-self.HitboxSize, -self.HitboxSize, -self.HitboxSize)
	local max = Vector( self.HitboxSize,  self.HitboxSize,  self.HitboxSize)
	
	self:SetModel(self.ModelOverride or self.Model)
	
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_CUSTOM)
	self:SetCollisionBounds(min, max)
	self:SetSolid(SOLID_BBOX)
	
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	self:SetLocalVelocity(self:GetForward() * (self.Force or 1650))
	self:SetGravity(0.5)
	
	
	self:InitEffects()
end

function ENT:Think()
	self:SetAngles(self:GetVelocity():Angle())
end

function ENT:Hit(ent)
	self.Touch = nil
	
	self:EmitSound(self.HitSound)
	
	local range, damage
    local expd = DamageInfo()

    ParticleEffect("flaregun_destroyed", self:GetPos(), self:GetAngles())
	self:Remove()

	
	local owner = self:GetOwner()
	if not owner or not owner:IsValid() then owner = self end
	
	--local damage = self:CalculateDamage(owner:GetPos())
	local dir = self:GetVelocity():GetNormal()
	
	
	self:FireBullets{
		Src=self:GetPos(),
		Attacker=owner,
		Dir=dir,
		Spread=Vector(0,0,0),
		Num=1,
		Damage=damage,
		Tracer=0,
		HullSize=self.HitboxSize*2,
	}
	
	expd:SetAttacker( owner )
    expd:SetInflictor(self)
	expd:SetDamage(30)
	expd:SetDamageCustom( TF_DMG_CUSTOM_BURNING + TF_DMG_CUSTOM_IGNITE )
	--expd:SetDamageType(DMG_BURN)
	expd:SetDamagePosition(self:GetPos())

    ent:TakeDamageInfo(expd)
	--ent:Ignite(10)

	self:SetLocalVelocity(Vector(0,0,0))
	self:SetMoveType(MOVETYPE_NONE)
	self:SetNotSolid(true)
	self:SetNoDraw(true)
	self:Fire("kill", "", 0.1)
    self:EmitSound("player/pl_impact_flare1.wav", nil, nil, 0.7 )
end

function ENT:Touch(ent)
	--if not ent:IsTrigger() then
	self:Hit(ent)
end

end
