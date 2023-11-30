if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID( "sprites/bucket_bat_red" )
    SWEP.DrawWeaponInfoBox = false
    SWEP.BounceWeaponIcon = false
    killicon.Add( "tf_weapon_sandman", "lambdaplayers/killicons/icon_tf2_sandman", Color( 255, 255, 255, 255 ) )
    killicon.Add( "tf_projectile_ball", "lambdaplayers/killicons/icon_tf2_sandman_ball", Color( 255, 255, 255 ) )
    end
    
    SWEP.PrintName = "Sandman"
    SWEP.Category = "Team Fortress 2"
    SWEP.Spawnable= true
    SWEP.AdminSpawnable= true
    SWEP.AdminOnly = false
    
    SWEP.ViewModelFOV = 65
    SWEP.ViewModel = "models/weapons/c_arms.mdl"
    SWEP.WorldModel = "models/lambdaplayers/tf2/weapons/w_wooden_bat.mdl"
    SWEP.ViewModelFlip = false
    SWEP.BobScale = 1
    SWEP.SwayScale = 0
    
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false
    SWEP.Weight = 1
    SWEP.Slot = 0
    SWEP.SlotPos = 0
    
    SWEP.UseHands = false
    SWEP.HoldType = "melee"
    SWEP.FiresUnderwater = true
    SWEP.DrawCrosshair = false
    SWEP.DrawAmmo = true
    SWEP.CSMuzzleFlashes = 1
    SWEP.Base = "weapon_base"
    
    SWEP.WalkSpeed = 200
    SWEP.RunSpeed = 400
    
    SWEP.Attack = 0
    SWEP.AttackTimer = CurTime()
    SWEP.Idle = 0
    SWEP.IdleTimer = CurTime()
    
    SWEP.Primary.Sound = Sound( "Weapon_Bat.Miss" )
    SWEP.Primary.ClipSize = -1
    SWEP.Primary.DefaultClip = -1
    SWEP.Primary.Automatic = true
    SWEP.Primary.Ammo = "none"
    SWEP.Primary.Damage = 35
    SWEP.Primary.Delay = 0.5
    SWEP.Primary.Force = 2000
    
    SWEP.Secondary.Sound = Sound( "weapons/bat_baseball_hit2.wav" )
    SWEP.Secondary.ClipSize = 1
    SWEP.Secondary.DefaultClip = 0
    SWEP.Secondary.MaxAmmo = 1
    SWEP.Secondary.TakeAmmo = 1
    SWEP.Secondary.Ammo = "none"
    SWEP.Secondary.Delay = 1
    SWEP.Secondary.Force = 1250
    
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
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
    self.Owner:SetWalkSpeed( self.WalkSpeed )
    self.Owner:SetRunSpeed( self.RunSpeed )
    return true
    end
    
    function SWEP:Holster()
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime()
    self.Owner:SetWalkSpeed( 200 )
    self.Owner:SetRunSpeed( 400 )
    return true
    end
    
    function SWEP:PrimaryAttack()
    self:EmitSound( self.Primary.Sound )
    self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
    self.Attack = 1
    self.AttackTimer = CurTime() + 0.2
    self.Idle = 0
    self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
    end
    
    function SWEP:SecondaryAttack()
        if SERVER then
        local entity = ents.Create( "tf_projectile_ball" )
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
        self:EmitSound( self.Secondary.Sound )
        self:TakeSecondaryAmmo( self.Secondary.TakeAmmo )
        self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
        self.Owner:DoAnimationEvent( "scout_range_ball" )
        self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
        self.Idle = 0
        self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
        self.Recoil = 1
        self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
        self.RecoilTimer = CurTime() + 1.9
        self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( -3, 0, 0 ) )
        end
        
    
    function SWEP:Reload()
    end
    
    function SWEP:Think()
    if self.Attack == 1 and self.AttackTimer <= CurTime() then
    local tr = util.TraceLine( {
    start = self.Owner:GetShootPos(),
    endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64,
    filter = self.Owner,
    mask = MASK_SHOT_HULL,
    } )
    if !IsValid( tr.Entity ) then
    tr = util.TraceHull( {
    start = self.Owner:GetShootPos(),
    endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64,
    filter = self.Owner,
    mins = Vector( -16, -16, 0 ),
    maxs = Vector( 16, 16, 0 ),
    mask = MASK_SHOT_HULL,
    } )
    end
    if SERVER and IsValid( tr.Entity ) then
    local dmg = DamageInfo()
    local attacker = self.Owner
    if !IsValid( attacker ) then
    attacker = self
    end
    dmg:SetAttacker( attacker )
    dmg:SetInflictor( self )
    dmg:SetDamage( self.Primary.Damage )
    dmg:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
    tr.Entity:TakeDamageInfo( dmg )
    end
    if tr.Hit then
    if SERVER then
    if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
    self.Owner:EmitSound( "Weapon_Bat.HitFlesh" )
    end
    if !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() ) then
    self.Owner:EmitSound( "Weapon_Bat.HitWorld" )
    end
    end
    end
    self.Attack = 0
    end
    if self.Idle == 0 and self.IdleTimer <= CurTime() then
    if SERVER then
    self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
    end
    self.Idle = 1
    end
    end