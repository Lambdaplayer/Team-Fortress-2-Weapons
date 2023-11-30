if CLIENT then
SWEP.WepSelectIcon = surface.GetTextureID( "sprites/bucket_grenlaunch" )
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false
killicon.Add( "tf_weapon_ironbomber", "lambdaplayers/killicons/icon_tf2_iron_bomber", Color( 255, 255, 255, 255 ) )
killicon.Add( "tf_projectile_pipe_ironbomber", "lambdaplayers/killicons/icon_tf2_iron_bomber", Color( 255, 255, 255, 255 ) )
end

SWEP.PrintName = "Iron Bomber"
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/c_models/c_demo_arms.mdl"
SWEP.WorldModel = "models/lambdaplayers/tf2/weapons/w_iron_bomber.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 4
SWEP.Slot = 4
SWEP.SlotPos = 0

SWEP.UseHands = false
SWEP.HoldType = "crossbow"
SWEP.FiresUnderwater = false
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"

SWEP.WalkSpeed = 200
SWEP.RunSpeed = 400

SWEP.Reloading = 0
SWEP.ReloadingTimer = CurTime()
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()
SWEP.Recoil = 0
SWEP.RecoilTimer = CurTime()

SWEP.Primary.Sound = Sound( "weapons/tacky_grenadier_shoot.wav" )
SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 20
SWEP.Primary.MaxAmmo = 16
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1_Grenade"
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Delay = 0.6
SWEP.Primary.Force = 1200

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
self:SetWeaponHoldType( self.HoldType )
self.Idle = 0
self.IdleTimer = CurTime() + 1
end

function SWEP:DrawHands()
if (CLIENT) then
self.Hands = ClientsideModel("models/workshop/weapons/c_models/c_quadball/c_quadball.mdl", RENDERGROUP_VIEWMODEL)
local vm = self.Owner:GetViewModel()
self.Hands:SetPos(vm:GetPos())
self.Hands:SetAngles(vm:GetAngles())
self.Hands:AddEffects(EF_BONEMERGE)
self.Hands:SetNoDraw(true)
self.Hands:SetParent(vm)
self.Hands:DrawModel()
end
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
surface.SetTexture( surface.GetTextureID( "sprites/crosshair_3" ) )
surface.SetDrawColor( 255, 255, 255, 255 )
surface.DrawTexturedRect( x - 16, y - 16, 32, 32 )
end
end

function SWEP:Deploy()
self:SetWeaponHoldType( self.HoldType )
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
self:SetNextPrimaryFire( CurTime() + 0.5 )
self:SetNextSecondaryFire( CurTime() + 0.5 )
self.Reloading = 0
self.ReloadingTimer = CurTime()
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
self.Recoil = 0
self.RecoilTimer = CurTime()
self.Owner:SetWalkSpeed( self.WalkSpeed )
self.Owner:SetRunSpeed( self.RunSpeed )
return true
end

function SWEP:Holster()
self.Reloading = 0
self.ReloadingTimer = CurTime()
self.Idle = 0
self.IdleTimer = CurTime()
self.Recoil = 0
self.RecoilTimer = CurTime()
self.Owner:SetWalkSpeed( 200 )
self.Owner:SetRunSpeed( 400 )
return true
end

function SWEP:PrimaryAttack()
if self.Reloading == 1 then
self.Reloading = 2
else
if !( self.Reloading == 0 ) then return end
if self.Weapon:Clip1() <= 0 and self.Weapon:Ammo1() <= 0 then
self.Weapon:EmitSound( "Weapon_Shotgun.Empty" )
self:SetNextPrimaryFire( CurTime() + 0.2 )
self:SetNextSecondaryFire( CurTime() + 0.2 )
end
if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then
self.Weapon:EmitSound( "Weapon_Shotgun.Empty" )
self:SetNextPrimaryFire( CurTime() + 0.2 )
self:SetNextSecondaryFire( CurTime() + 0.2 )
end
if self.Weapon:Clip1() <= 0 then
self:Reload()
end
if self.Weapon:Clip1() <= 0 then return end
if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then return end
if SERVER then
local entity = ents.Create( "tf_projectile_pipe_ironbomber" )
entity:SetOwner( self.Owner )
if IsValid( entity ) then
local Forward = self.Owner:EyeAngles():Forward()
local Right = self.Owner:EyeAngles():Right()
local Up = self.Owner:EyeAngles():Up()
entity:SetPos( self.Owner:GetShootPos() + Forward * 8 + Right * 4 + Up * -4 )
entity:SetAngles( self.Owner:EyeAngles() )
entity:Spawn()
local phys = entity:GetPhysicsObject()
phys:SetVelocity( self.Owner:GetAimVector() * self.Primary.Force )
phys:AddAngleVelocity( Vector( math.Rand( -500, 500 ), math.Rand( -500, 500 ), math.Rand( -500, 500 ) ) )
end
end
self:EmitSound( self.Primary.Sound )
timer.Simple( 0.366667, function() self:EmitSound("weapons/grenade_launcher_drum_start.wav") end)
timer.Simple( 0.533333, function() self:EmitSound("weapons/grenade_launcher_drum_start.wav") end)
ParticleEffectAttach("muzzle_grenadelauncher", PATTACH_POINT_FOLLOW, self.Weapon, 1)
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
self.Owner:DoAnimationEvent( ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )
self:TakePrimaryAmmo( self.Primary.TakeAmmo )
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
self.Recoil = 1
self.RecoilTimer = CurTime() + 0.2
self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( -3, 0, 0 ) )
end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
if self.Reloading == 0 and self.Weapon:Clip1() < self.Primary.ClipSize and self.Weapon:Ammo1() > 0 then
self.Weapon:SendWeaponAnim( ACT_RELOAD_START )
self.Owner:DoAnimationEvent( ACT_HL2MP_GESTURE_RELOAD_AR2 )
timer.Simple( 0., function() self:EmitSound("zetaplayer/weapon/tf2/grenade_launcher_drum_open.wav") end)
timer.Simple( 0.7, function() self:EmitSound("zetaplayer/weapon/tf2/grenade_launcher_worldreload.wav") end)
timer.Simple( 1.3, function() self:EmitSound("zetaplayer/weapon/tf2/grenade_launcher_worldreload.wav") end)
timer.Simple( 1.6, function() self:EmitSound("zetaplayer/weapon/tf2/grenade_launcher_drum_close.wav") end)


self:SetNextPrimaryFire( CurTime() + 0.7 )
self:SetNextSecondaryFire( CurTime() + 0.7 )
self.Reloading = 1
self.ReloadingTimer = CurTime() + 0.6
self.Idle = 1
end
end

function SWEP:Think()
if self.Recoil == 1 and self.RecoilTimer <= CurTime() then
self.Recoil = 0
end
if self.Recoil == 1 then
self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( 0.23, 0, 0 ) )
end
if self.Reloading == 1 and self.ReloadingTimer <= CurTime() and self.Weapon:Clip1() < self.Primary.ClipSize and self.Weapon:Ammo1() > 0 then
self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
self.Weapon:SetClip1( self.Weapon:Clip1() + 1 )
self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
self.Reloading = 1
self.ReloadingTimer = CurTime() + 0.6
self.Idle = 1
end
if self.Reloading == 1 and self.ReloadingTimer <= CurTime() and self.Weapon:Clip1() == self.Primary.ClipSize then
self.Weapon:SendWeaponAnim( ACT_RELOAD_FINISH )
self:SetNextPrimaryFire( CurTime() + 0.5 )
self:SetNextSecondaryFire( CurTime() + 0.5 )
self.Reloading = 0
self.ReloadingTimer = CurTime() + 0.5
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Reloading == 1 and self.ReloadingTimer <= CurTime() and self.Weapon:Clip1() > 0 and self.Weapon:Ammo1() <= 0 then
self.Weapon:SendWeaponAnim( ACT_RELOAD_FINISH )
self:SetNextPrimaryFire( CurTime() + 0.5 )
self:SetNextSecondaryFire( CurTime() + 0.5 )
self.Reloading = 0
self.ReloadingTimer = CurTime() + 0.5
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Reloading == 2 and self.ReloadingTimer <= CurTime() then
self.Weapon:SendWeaponAnim( ACT_RELOAD_FINISH )
self:SetNextPrimaryFire( CurTime() + 0.5 )
self:SetNextSecondaryFire( CurTime() + 0.5 )
self.Reloading = 3
self.ReloadingTimer = CurTime() + 0.5
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Reloading == 3 and self.ReloadingTimer <= CurTime() then
self.Reloading = 0
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