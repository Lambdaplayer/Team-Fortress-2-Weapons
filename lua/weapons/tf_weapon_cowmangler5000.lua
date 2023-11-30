if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID( "sprites/bucket_rl" )
    SWEP.DrawWeaponInfoBox = false
    SWEP.BounceWeaponIcon = false
    killicon.Add( "tf_weapon_cowmanlger5000", "lambdaplayers/killicons/icon_tf2_cowmangler5000", Color( 255, 255, 255, 255 ) )
    killicon.Add( "tf_projectile_rocket_light", "lambdaplayers/killicons/icon_tf2_cowmangler5000", Color( 255, 255, 255, 255 ) )
    end
    
    SWEP.PrintName = "Cow Mangler 50000"
    SWEP.Category = "Team Fortress 2"
    SWEP.Spawnable= true
    SWEP.AdminSpawnable= true
    SWEP.AdminOnly = false
    
    SWEP.ViewModelFOV = 65
    SWEP.ViewModel = "models/weapons/c_arms.mdl"
    SWEP.WorldModel = "models/lambdaplayers/tf2/weapons/w_cowmangler.mdl"
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
    
    SWEP.Reloading = 0
    SWEP.ReloadingTimer = CurTime()
    SWEP.Idle = 0
    SWEP.IdleTimer = CurTime()
    
    SWEP.Primary.Sound = Sound( "weapons/cow_mangler_main_shot.wav" )
    SWEP.Primary.ClipSize = 4
    SWEP.Primary.DefaultClip = 24
    SWEP.Primary.MaxAmmo = 20
    SWEP.Primary.Automatic = true
    SWEP.Primary.Ammo = "RPG_Round"
    SWEP.Primary.TakeAmmo = 1
    SWEP.Primary.Delay = 0.8
    SWEP.Primary.Force = 500
    
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
        self.Owner:SetWalkSpeed( self.WalkSpeed )
        self.Owner:SetRunSpeed( self.RunSpeed )
        return true
        end
        
        function SWEP:Holster()
        self.Reloading = 0
        self.ReloadingTimer = CurTime()
        self.Idle = 0
        self.IdleTimer = CurTime()
        self.Owner:SetWalkSpeed( 200 )
        self.Owner:SetRunSpeed( 400 )
        return true
        end
        
        function SWEP:PrimaryAttack()
            if self.Owner:WaterLevel() == -1 then
            if (!self:CanPrimaryAttack()) then return end
            self:SetNextPrimaryFire(CurTime() + 0.2) return end
            if (!self:CanPrimaryAttack()) then return end
            if(self.Weapon:Clip1() > 0) then
                if (not(self.Owner:KeyDown(IN_ATTACK2))) then
                self.Weapon:EmitSound("weapons/cow_mangler_main_shot.wav")
                timer.Simple(0.5, function() 
                if IsValid(self.Weapon) then
                end
                end)
                self.Weapon:SetNextPrimaryFire(CurTime() + 0.8)
                self.Owner:SetAnimation(PLAYER_ATTACK1)
                self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
                self:FireRocket()
                self:TakePrimaryAmmo(1)
                self.StartReload = false
                self.Weapon:SetNetworkedBool("reloading",false)
                self.Owner:ViewPunch(Angle(0,0,0))
                local bullet = {}
        bullet.Num = self.Primary.NumberofShots 
        bullet.Src = self.Owner:GetShootPos() 
        bullet.Dir = self.Owner:GetAimVector() 
        --bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
        bullet.Tracer = 0 
        bullet.Force = self.Primary.Force 
        bullet.Damage = 0
        bullet.AmmoType = self.Primary.Ammo 
                end
            end
        end
    
        function SWEP:SecondaryAttack()
        end
        
        function SWEP:FireRocket()
        if SERVER then
        local aim = self.Owner:GetAimVector()
        local side = aim:Cross(Vector(0,0,0))
        local up = side:Cross(aim)
        local pos = self.Owner:GetShootPos() +  aim * 0 + side * 0 + up * 0
        local rocket = ents.Create("tf_projectile_rocket_light")
        if !rocket:IsValid() then return false end
        rocket:SetAngles(aim:Angle())
        rocket:SetPos(pos)
        rocket:SetOwner(self.Owner)
        rocket:Spawn()
        rocket:Activate()
            --rocket:SetVelocity(rocket:GetForward()*1000)
        end
        end
        
        function SWEP:SecondaryAttack()
        end
        
        function SWEP:Reload()
        if self.Reloading == 0 and self.Weapon:Clip1() < self.Primary.ClipSize and self.Weapon:Ammo1() > 0 then
        self.Weapon:SendWeaponAnim( ACT_RELOAD_START )
        self.Owner:SetAnimation( PLAYER_RELOAD )
        self:SetNextPrimaryFire( CurTime() + 0.6 )
        self:SetNextSecondaryFire( CurTime() + 0.6 )
        self.Reloading = 1
        self.ReloadingTimer = CurTime() + 0.5
        self.Idle = 1
        end
        end
        
        function SWEP:Think()
        if self.Reloading == 1 and self.ReloadingTimer <= CurTime() and self.Weapon:Clip1() < self.Primary.ClipSize and self.Weapon:Ammo1() > 0 then
        self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
        self.Weapon:SetClip1( self.Weapon:Clip1() + 1 )
        self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
        self.Reloading = 1
        self.ReloadingTimer = CurTime() + 0.85
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