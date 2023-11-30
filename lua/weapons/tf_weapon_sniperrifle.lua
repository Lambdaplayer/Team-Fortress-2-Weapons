if CLIENT then
SWEP.WepSelectIcon = surface.GetTextureID( "sprites/bucket_sniper" )
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false
killicon.Add( "tf_weapon_sniperrifle", "lambdaplayers/killicons/icon_tf2_sniperrifle", Color( 255, 255, 255, 255 ) )
end

SWEP.PrintName = "Sniper Rifle"
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_models/v_sniperrifle_sniper.mdl"
SWEP.WorldModel = "models/lambdaplayers/tf2/weapons/w_sniper_rifle.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 3
SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.UseHands = false
SWEP.HoldType = "rpg"
SWEP.FiresUnderwater = false
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"

SWEP.WalkSpeed = 200
SWEP.RunSpeed = 400

SWEP.Scope = 0
SWEP.ScopeTimer = CurTime()
SWEP.Reloading = 0
SWEP.ReloadingTimer = CurTime()
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()

SWEP.Primary.Sound = Sound( "weapons/sniper_shoot.wav" )
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 25
SWEP.Primary.MaxAmmo = 25
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SniperRound"
SWEP.Primary.Damage = 50
SWEP.Primary.Spread = 0
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Delay = 1.5
SWEP.Primary.Force = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 0.25

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
surface.SetDrawColor( 255, 255, 255, self.Weapon:GetNWString( "ScopeAlpha", 0 ) )
surface.SetTexture( surface.GetTextureID( "hud/scope_sniper_ll" ) )
surface.DrawTexturedRect( x - ScrH() / 1.5, y - 0, ScrH() / 1.5, ScrH() / 2 )
surface.SetTexture( surface.GetTextureID( "hud/scope_sniper_lr" ) )
surface.DrawTexturedRect( x - 0, y - 0, ScrH() / 1.5, ScrH() / 2 )
surface.SetTexture( surface.GetTextureID( "hud/scope_sniper_ul" ) )
surface.DrawTexturedRect( x - ScrH() / 1.5, y - ScrH() / 2, ScrH() / 1.5, ScrH() / 2 )
surface.SetTexture( surface.GetTextureID( "hud/scope_sniper_ur" ) )
surface.DrawTexturedRect( x - 0, y - ScrH() / 2, ScrH() / 1.5, ScrH() / 2 )
surface.SetTexture( surface.GetTextureID( "hud/black" ) )
surface.DrawTexturedRect( x - ScrW() / 2, y - ScrH() / 2, ScrW() / 2 - ScrH() / 2, ScrH() )
surface.SetTexture( surface.GetTextureID( "hud/black" ) )
surface.DrawTexturedRect( x - -ScrH() / 2, y - ScrH() / 2, ScrW() / 2 - ScrH() / 2, ScrH() )
surface.SetTexture( surface.GetTextureID( "sprites/crosshair_2" ) )
surface.SetDrawColor( 255, 255, 255, self.Weapon:GetNWString( "CrosshairAlpha" ) )
surface.DrawTexturedRect( x - 16, y - 16, 32, 32 )
surface.SetTexture( surface.GetTextureID( "sprites/redglow1" ) )
surface.SetDrawColor( 255, 255, 255, self.Weapon:GetNWString( "ScopeLaserAlpha", 0 ) )
surface.DrawTexturedRect( x - 32, y - 32, 64, 64 )
end
end

function SWEP:AdjustMouseSensitivity()
return self.Weapon:GetNWString( "MouseSensitivity", 1 )
end

function SWEP:Deploy()
self:SetWeaponHoldType( self.HoldType )
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
self:SetNextPrimaryFire( CurTime() + 0.5 )
self:SetNextSecondaryFire( CurTime() + 0.5 )
self.Scope = 0
self.Reloading = 0
self.ReloadingTimer = CurTime()
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
self.Owner:SetWalkSpeed( self.WalkSpeed )
self.Owner:SetRunSpeed( self.RunSpeed )
self.Weapon:SetNWString( "CrosshairAlpha", 255 )
self.Weapon:SetNWString( "ScopeLaserAlpha", 0 )
self.Weapon:SetNWString( "ScopeAlpha", 0 )
self.Weapon:SetNWString( "MouseSensitivity", 1 )
return true
end

function SWEP:Holster()
self.Scope = 0
self.Reloading = 0
self.ReloadingTimer = CurTime()
self.Idle = 0
self.IdleTimer = CurTime()
self.Owner:SetWalkSpeed( 200 )
self.Owner:SetRunSpeed( 400 )
self.Weapon:SetNWString( "CrosshairAlpha", 255 )
self.Weapon:SetNWString( "ScopeLaserAlpha", 0 )
self.Weapon:SetNWString( "ScopeAlpha", 0 )
self.Weapon:SetNWString( "MouseSensitivity", 1 )
return true
end

function SWEP:PrimaryAttack()
if self.Weapon:Ammo1() <= 0 then
self.Weapon:EmitSound( "Weapon_SniperRifle.ClipEmpty" )
self:SetNextPrimaryFire( CurTime() + 0.2 )
self:SetNextSecondaryFire( CurTime() + 0.2 )
end
if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then
self.Weapon:EmitSound( "Weapon_SniperRifle.ClipEmpty" )
self:SetNextPrimaryFire( CurTime() + 0.2 )
self:SetNextSecondaryFire( CurTime() + 0.2 )
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
if ScopeTimer
self.Owner:FireBullets( bullet )
if SERVER then
self.Owner:EmitSound( self.Primary.Sound, SNDLVL_94dB, PITCH_NORM, VOL_NORM, CHAN_WEAPON )
end
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
self.Owner:SetAnimation( PLAYER_ATTACK1 )
self.Owner:MuzzleFlash()
self:TakePrimaryAmmo( self.Primary.TakeAmmo )
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
self.Scope = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
self.Weapon:SetNWString( "CrosshairAlpha", 255 )
self.Weapon:SetNWString( "ScopeLaserAlpha", 0 )
self.Weapon:SetNWString( "ScopeAlpha", 0 )
self.Weapon:SetNWString( "MouseSensitivity", 1 )
self.Owner:SetFOV( 0, 0.1 )
self.Owner:SetWalkSpeed( self.WalkSpeed )
self.Owner:SetRunSpeed( self.RunSpeed )
end

function SWEP:SecondaryAttack()
if self.Scope == 0 then
self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
self.Scope = 1
self.ScopeTimer = CurTime() + 3
self.Weapon:SetNWString( "CrosshairAlpha", 0 )
self.Weapon:SetNWString( "ScopeLaserAlpha", 0 )
self.Weapon:SetNWString( "ScopeAlpha", 255 )
self.Weapon:SetNWString( "MouseSensitivity", 0.2 )
self.Owner:SetFOV( self.Owner:GetFOV() / 5, 0.1 )
self.Owner:SetWalkSpeed( 54 )
self.Owner:SetRunSpeed( 108 )
else
if self.Scope == 1 then
self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
self.Scope = 0
self.ScopeTimer = CurTime()
self.Weapon:SetNWString( "CrosshairAlpha", 255 )
self.Weapon:SetNWString( "ScopeLaserAlpha", 0 )
self.Weapon:SetNWString( "ScopeAlpha", 0 )
self.Weapon:SetNWString( "MouseSensitivity", 1 )
self.Owner:SetFOV( 0, 0.1 )
self.Owner:SetWalkSpeed( self.WalkSpeed )
self.Owner:SetRunSpeed( self.RunSpeed )
end
end
end

function SWEP:Reload()
end

function SWEP:Think()
if self.Scope == 0 then
self.Primary.Damage = 50
end
if self.Scope == 1 then
if self.ScopeTimer > CurTime() then
self.Primary.Damage = ( 1.5 / ( self.ScopeTimer - CurTime() + 1.5 ) ) * 150
if SERVER then
self.Weapon:SetNWString( "ScopeLaserAlpha", ( 1 / ( self.ScopeTimer - CurTime() + 1 ) ) * 255 )
end
end
if SERVER and self.ScopeTimer < CurTime() + 0.025 and self.ScopeTimer > CurTime() then
self.Owner:EmitSound( "player/recharged.wav", SNDLVL_75dB, PITCH_NORM, VOL_NORM, CHAN_STATIC )
end
if self.ScopeTimer <= CurTime() then
self.Primary.Damage = 150
self.Weapon:SetNWString( "ScopeLaserAlpha", 255 )
end
end
if self.Idle == 0 and self.IdleTimer <= CurTime() then
if SERVER then
self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
end
self.Idle = 1
end
if self.Weapon:Ammo1() > self.Primary.MaxAmmo then
self.Owner:SetAmmo( self.Primary.MaxAmmo, self.Primary.Ammo )
end
end