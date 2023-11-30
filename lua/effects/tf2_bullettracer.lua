function EFFECT:Init( data )

	PrecacheParticleSystem( "bullet_tracer01_red" )

	self.Position = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	
	util.ParticleTracerEx("bullet_tracer01_red", self.StartPos, self.EndPos, 0, 0, -1)

end

function EFFECT:Render()

	return false

end