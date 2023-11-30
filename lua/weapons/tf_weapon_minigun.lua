if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID( "backpack/weapons/w_models/w_minigun" )
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicon.Add( "tf_weapon_minigun", "lambdaplayers/killicons/icon_tf2_minigun", Color( 255, 255, 255, 255 ) )
	end
	
	SWEP.PrintName = "Minigun"
	SWEP.Category = "Team Fortress 2"
	SWEP.Spawnable= true
	SWEP.AdminSpawnable= true
	SWEP.AdminOnly = false
	
	SWEP.ViewModelFOV = 65
	SWEP.ViewModel = "models/weapons/c_arms.mdl"
	SWEP.WorldModel = "models/lambdaplayers/tf2/weapons/w_minigun.mdl"
	SWEP.ViewModelFlip = false
	SWEP.BobScale = 1
	SWEP.SwayScale = 0
	
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
	SWEP.Weight = 3
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	
	SWEP.UseHands = false
	SWEP.HoldType = "shotgun"
	SWEP.FiresUnderwater = true
	SWEP.DrawCrosshair = false
	SWEP.DrawAmmo = true
	SWEP.CSMuzzleFlashes = 1
	SWEP.Base = "weapon_base"
	
	SWEP.WalkSpeed = 200
	SWEP.RunSpeed = 400
	
	SWEP.Sound = 0
	SWEP.Spin = 0
	SWEP.SpinTimer = CurTime()
	SWEP.Idle = 0
	SWEP.IdleTimer = CurTime()
	
	SWEP.Primary.Sound = Sound( "Weapon_Minigun.Fire" )
	SWEP.Primary.ClipSize = -1
	SWEP.Primary.DefaultClip = 200
	SWEP.Primary.MaxAmmo = 200
	SWEP.Primary.Automatic = true
	SWEP.Primary.Ammo = "AR2"
	SWEP.Primary.Damage = 9
	SWEP.Primary.Spread = 0.08
	SWEP.Primary.TakeAmmo = 1
	SWEP.Primary.NumberofShots = 4
	SWEP.Primary.Delay = 0.1
	SWEP.Primary.Force = 1
	
	SWEP.Secondary.Sound = Sound( "Weapon_Minigun.Spin" )
	SWEP.Secondary.ClipSize = -1
	SWEP.Secondary.DefaultClip = -1
	SWEP.Secondary.Automatic = true
	SWEP.Secondary.Ammo = "none"
	
	function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.Idle = 0
	self.IdleTimer = CurTime() + 1
	end
	
	function SWEP:DrawHUD()
	if CLIENT then
	local x, y
	if ( self.Owner == LocalPlayer() and self.Owner:ShouldDrawLocalPlayer() ) then
	local tr = util.GetPlayerTrace( self.Owner )
	local trace = util.TraceLine( tr )
	local coords = trace.HitPos:ToScreen()
	x, y = coords.x, coords.y
	else
	x, y = ScrW() / 2, ScrH() / 2
	end
	surface.SetTexture( surface.GetTextureID( "sprites/crosshair_5" ) )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( x - 32, y - 32, 64, 64 )
	end
	end
	
	function SWEP:Deploy()
	self:SetWeaponHoldType( self.HoldType )
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:SetNextSecondaryFire( CurTime() + 0.5 )
	self.Sound = 0
	self.Spin = 0
	self.SpinTimer = CurTime() + 0.5
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Owner:SetWalkSpeed( self.WalkSpeed )
	self.Owner:SetRunSpeed( self.RunSpeed )
	return true
	end
	
	function SWEP:Holster()
	if SERVER then
	self.Owner:StopSound( self.Primary.Sound )
	self.Owner:StopSound( self.Secondary.Sound )
	self.Owner:StopSound( "Weapon_Minigun.WindUp" )
	self.Owner:StopSound( "Weapon_Minigun.ClipEmpty" )
	end
	self.Sound = 0
	self.Spin = 0
	self.SpinTimer = CurTime()
	self.Idle = 0
	self.IdleTimer = CurTime()
	self.Owner:SetWalkSpeed( 200 )
	self.Owner:SetRunSpeed( 400 )
	return true
	end
	
	function SWEP:PrimaryAttack()
	if self.Spin == 0 and self.SpinTimer <= CurTime() and self.Owner:KeyDown( IN_ATTACK ) then
	if SERVER then
	self.Owner:EmitSound( "Weapon_Minigun.WindUp" )
	end
	self.Weapon:SendWeaponAnim( ACT_DEPLOY )
	self.Spin = 1
	self.SpinTimer = CurTime() + 0.9
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Owner:SetWalkSpeed( 74 )
	self.Owner:SetRunSpeed( 148 )
	end
	if !( self.Spin == 2 ) then return end
	if self.Weapon:Ammo1() <= 0 and !( self.Owner:WaterLevel() == 3 and self.FireUnderwater == false ) then
	if SERVER then
	self.Owner:StopSound( self.Primary.Sound )
	self.Owner:StopSound( self.Secondary.Sound )
	end
	if SERVER then
	self.Owner:StopSound( "Weapon_Minigun.ClipEmpty" )
	self.Owner:EmitSound( "Weapon_Minigun.ClipEmpty" )
	end
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 0.2 )
	end
	if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then
	if SERVER then
	self.Owner:StopSound( self.Primary.Sound )
	self.Owner:StopSound( self.Secondary.Sound )
	end
	if SERVER then
	self.Owner:StopSound( "Weapon_Minigun.ClipEmpty" )
	self.Owner:EmitSound( "Weapon_Minigun.ClipEmpty" )
	end
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 0.2 )
	end
	if self.Weapon:Ammo1() <= 0 then return end
	if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then return end
	local bullet = {}
	bullet.Num = self.Primary.NumberofShots
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector( 1 * self.Primary.Spread, 1 * self.Primary.Spread, 0 )
	bullet.TracerName = "tf2_bullettracer"
	bullet.Force = self.Primary.Force
	bullet.Damage = self.Primary.Damage
	bullet.AmmoType = self.Primary.Ammo
	self.Owner:FireBullets( bullet )
	ParticleEffectAttach("muzzle_minigun", PATTACH_POINT_FOLLOW, self.Weapon, 1)
	if self.Sound == 0 then
	if SERVER then
	self.Owner:StopSound( "Weapon_Minigun.ClipEmpty" )
	self.Owner:EmitSound( self.Primary.Sound )
	end
	self.Sound = 1
	end
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:DoAnimationEvent( ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2 )
	self.Owner:MuzzleFlash()
	self:TakePrimaryAmmo( self.Primary.TakeAmmo )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Idle = 1
	end
	
	function SWEP:SecondaryAttack()
	if self.Owner:KeyDown( IN_ATTACK ) then return end
	if self.Spin == 0 and self.SpinTimer <= CurTime() and self.Owner:KeyDown( IN_ATTACK2 ) then
	if SERVER then
	self.Owner:EmitSound( "Weapon_Minigun.WindUp" )
	end
	self.Weapon:SendWeaponAnim( ACT_DEPLOY )
	self.Spin = 1
	self.SpinTimer = CurTime() + 0.9
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Owner:SetWalkSpeed( 74 )
	self.Owner:SetRunSpeed( 148 )
	end
	if self.Spin == 2 then
	if SERVER then
	self.Owner:StopSound( self.Secondary.Sound )
	self.Owner:EmitSound( self.Secondary.Sound )
	end
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self.Idle = 1
	end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	end
	
	function SWEP:Reload()
	end
	
	function SWEP:Think()
	if self.Spin == 1 and self.SpinTimer <= CurTime() then
	self.Spin = 2
	end
	if !self.Owner:KeyDown( IN_ATTACK ) then
	if SERVER then
	self.Owner:StopSound( self.Primary.Sound )
	self.Owner:StopSound( "Weapon_Minigun.ClipEmpty" )
	end
	self.Sound = 0
	end
	if self.Spin == 2 and !self.Owner:KeyDown( IN_ATTACK ) and !self.Owner:KeyDown( IN_ATTACK2 ) then
	if SERVER then
	self.Owner:StopSound( self.Primary.Sound )
	self.Owner:StopSound( self.Secondary.Sound )
	self.Owner:StopSound( "Weapon_Minigun.ClipEmpty" )
	self.Owner:EmitSound( "Weapon_Minigun.WindDown" )
	end
	self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
	self.Sound = 0
	self.Spin = 0
	self.SpinTimer = CurTime() + 0.9
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Owner:SetWalkSpeed( self.WalkSpeed )
	self.Owner:SetRunSpeed( self.RunSpeed )
	end
	if self.Idle == 0 and self.IdleTimer <= CurTime() then
	if SERVER then
	if self.Spin == 0 then
	self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
	end
	if !( self.Spin == 0 ) then
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	end
	end
	self.Idle = 1
	end
	if self.Weapon:Ammo1() > self.Primary.MaxAmmo then
	self.Owner:SetAmmo( self.Primary.MaxAmmo, self.Primary.Ammo )
	end
	end