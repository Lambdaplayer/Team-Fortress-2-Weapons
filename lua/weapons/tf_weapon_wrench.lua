
AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID( "sprites/bucket_wrench" )
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicon.Add( "tf_weapon_wrench", "lambdaplayers/killicons/icon_tf2_wrench", Color( 255, 255, 255, 255 ) )
	end

SWEP.Author			= ""
SWEP.Instructions	= "Wrench"
SWEP.Category 		= "Team-Fortress 2"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= false

SWEP.ViewModel			= "models/weapons/v_models/v_wrench_engineer.mdl"
SWEP.WorldModel			= "models/lambdaplayers/tf2/weapons/w_wrench.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.PrintName			= "Wrench"
SWEP.Slot				= 2
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false


SWEP.NextSwing = 0
SWEP.UpgradableEnts = {"sent_sentry","sent_dispenser","sent_teleport"}

function SWEP:Holster()

	return true

end

if SERVER then

	util.AddNetworkString("SetBuildLevel")
	util.AddNetworkString("StuffTeleported")
	util.AddNetworkString("ScoreTeleported")

end

function SWEP:Deploy()

	local seq = self.Owner:GetViewModel():LookupSequence("draw")
	self.Owner:GetViewModel():ResetSequence("draw")
	self.Owner:GetViewModel():SetSequence(seq)

	local golden = math.random(1,10)

	if(golden == 1) then
		self.Owner:GetViewModel():SetSkin(8)
	else
		self.Owner:GetViewModel():SetSkin(1)
	end

	return true

end


function SWEP:SecondaryAttack()

	return false

end

local nm = 1

function SWEP:PrimaryAttack()

	if(self.NextSwing < CurTime()) then
		
		self.NextSwing = CurTime() + 0.5

		nm = nm + 1
		if(nm == 4) then
			nm = 1
		end
		local str = "swing_a"

		if(nm == 1) then
			str = "swing_a"
		elseif(nm == 2) then
			str = "swing_b"
		else
			str = "swing_c"
		end

		local seq = self.Owner:GetViewModel():LookupSequence(str)
		self.Owner:GetViewModel():ResetSequence(seq)
		self.Owner:GetViewModel():SetCycle(0)
		self.Owner:GetViewModel():SetSequence(seq)
		

		local tr = util.QuickTrace(self.Owner:GetShootPos(),self.Owner:GetAimVector()*64,{self.Owner})

		if(tr.Entity != nil && tr.Entity:IsValid()) then

			if(table.HasValue(self.UpgradableEnts,tr.Entity:GetClass())) then

				if(tr.Entity:Health() < tr.Entity.MaxHealth[math.Clamp(tr.Entity.Level,1,3)]) then

					tr.Entity:SetHealth(tr.Entity:Health() + math.random(10,20))

					tr.Entity:ShowDamage()

					if(tr.Entity:Health() > tr.Entity.MaxHealth[math.Clamp(tr.Entity.Level,1,3)]) then
						tr.Entity:SetHealth(tr.Entity.MaxHealth[math.Clamp(tr.Entity.Level,1,3)])
					end

				end
				if(tr.Entity.Level != 3) then
				
					if(tr.Entity.Level == 0) then
						tr.Entity.Hit = true

						timer.Simple(0.5,function()
							if(tr.Entity:IsValid()) then
								tr.Entity.Hit = false
							end
						end)

					else

						if SERVER then
							local qd = math.random(5,20)
							self:Upgrade(tr.Entity,qd)
						end
					end	

				end
				
				self:EmitSound("weapons/wrench_hit_build_success"..math.random(1,2)..".wav")

			end

		end
	end

end


function SWEP:Upgrade(ent,q)	

	if(ent.Level <= 3 && ent.Upgrading == false) then

		ent.Progress = ent.Progress + q

		if(ent.Owner.TeleportOut != nil && ent.Owner.TeleportOut:IsValid() && ent.Owner.TeleportIn != nil && ent.Owner.TeleportIn:IsValid()) then
			if(ent == ent.Owner.TeleportOut) then
				ent.Owner.TeleportIn.Progress = ent.Progress
				if(ent.Owner.TeleportIn.Progress >= 100) then
					ent.Owner.TeleportIn.Progress = 0
					ent.Owner.TeleportOut.Progress = 0
					ent.Owner.TeleportIn:LevelUp()
				end
				net.Start("UpgradeBuild")
				net.WriteEntity(ent.Owner.TeleportIn)
				net.WriteFloat(q)
				net.Broadcast()

			elseif(ent == ent.Owner.TeleportIn) then
				ent.Owner.TeleportOut.Progress = ent.Progress
				if(ent.Owner.TeleportOut.Progress >= 100) then
					ent.Owner.TeleportOut.Progress = 0
					ent.Owner.TeleportIn.Progress = 0
					ent.Owner.TeleportOut:LevelUp()
				end
				net.Start("UpgradeBuild")
				net.WriteEntity(ent.Owner.TeleportOut)
				net.WriteFloat(q)
				net.Broadcast()

			end
		end

		if(ent.Progress >= 100) then
			ent.Progress = 0
			ent:LevelUp()
		end

		net.Start("UpgradeBuild")
		net.WriteEntity(ent)
		net.WriteFloat(q)
		net.Broadcast()

	end

end

