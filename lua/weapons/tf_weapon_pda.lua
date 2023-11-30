
AddCSLuaFile()

SWEP.Author			= ""
SWEP.Instructions	= "PDA"
SWEP.Category 		= "Team-Fortress 2"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= false

SWEP.ViewModel			= "models/weapons/v_models/v_builder_engineer.mdl"
SWEP.ViewBox 			=  "models/weapons/v_models/v_toolbox_engineer.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_builder.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.PrintName			= "PDA"
SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false

SWEP.CanBuild = false
SWEP.Spawning = false

SWEP.Cmdl = nil
SWEP.ExAngle = 0
SWEP.NAng = 0

if SERVER then

util.AddNetworkString("SetOwner")
util.AddNetworkString("CreateConstruct")
util.AddNetworkString("setBuildType")

end

function SWEP:Holster()

	if CLIENT then

		if(self.Cmdl != nil) then

			self.Cmdl:Remove()

		end

	end

	return true

end

function SWEP:Deploy()

	self:CallOnClient("Deploy",0)
	local seq = self:LookupSequence("draw")
	self:ResetSequence(seq)
	self:SetPlaybackRate(1)
	self:SetSequence(seq)

	if CLIENT then
		self.Object = 0
		self.ExAngle = 0
		self.Spawning = false
	end

	if(game.SinglePlayer()) then
		self.Object = 0
		self.ExAngle = 0
		self.Spawning = false
	end

	self.Spawning = false
	self.ExAngle = 0
	self:CallOnClient("Deploy",0)

	return true

end

function SWEP:PrimaryAttack()
	

	MsgN(self.CanBuild)

	if(game.SinglePlayer()) then

		local pos,bol = self:CanBuild()
		if((!self.Spawning && self.Object != nil || self.Object != 0) && bol) then

			self:createBuilding({pos,self.Object,self.ExAngle})

			self.Owner:ConCommand("lastinv")

		end

	end

	if(CLIENT) then

		if((!self.Spawning && self.Object != nil || self.Object != 0) && self.CanBuild) then
			
			self.Spawning = true
			net.Start("CreateConstruct")
			net.WriteTable({self.Cmdl:GetPos(),self.Object,self.ExAngle})
			net.SendToServer()

			RunConsoleCommand("lastinv")

			self.Cmdl:Remove()

		end


	end

end

SWEP.FixClient = false

function SWEP:SecondaryAttack()
	
	self:SetNextSecondaryFire(0.5)

	if(!self.FixClient) then


	self.FixClient = true

	timer.Simple(0.01,function() self.FixClient = false end)


	self.ExAngle = self.ExAngle + 90

	end

end

local entS = {"sent_sentry","sent_dispenser","sent_teleport","sent_teleport"}

net.Receive("CreateConstruct",function(len,ply)

	local tbl = net.ReadTable()
	ply:GetActiveWeapon():createBuilding(tbl)
	

end)

function SWEP:createBuilding(tbl)

	local ply = self.Owner
	local ent = ents.Create(entS[tbl[2]])
	ent:SetPos(tbl[1])
	ent:SetAngles(Angle(0,self.Owner:EyeAngles().y + tbl[3],0))
	ent.Owner = self.Owner
	ent:Spawn()

	net.Start("SetBuildLevel")
	net.WriteEntity(ent)
	net.WriteFloat(0)
	net.Broadcast()

	if(tbl[2]==1) then
		if(ply.Sentry != nil && ply.Sentry:IsValid()) then
			ply.Sentry:Remove()
		end
		ply.Sentry = ent
	end
	if(tbl[2]==2) then
		if(ply.Dispenser != nil && ply.Dispenser:IsValid()) then
			ply.Dispenser:Remove()
		end
		ply.Dispenser = ent
	end
	if(tbl[2]==3) then
		if(ply.TeleportIn != nil && ply.TeleportIn:IsValid()) then
			ply.TeleportIn:Remove()
		end
		ply.TeleportIn = ent
	end
	if(tbl[2]==4) then
		if(ply.TeleportOut != nil && ply.TeleportOut:IsValid()) then
			ply.TeleportOut:Remove()
		end
		ply.TeleportOut = ent
	end

	if(tbl[2] == 4) then

		ent.Exit = true
		ply.telB = ent

	elseif(tbl[2] == 3) then

		ply.telA = ent

	end

	timer.Simple(0.05,function()

		net.Start("SetOwner")
		net.WriteTable({ply,ent,ent.Exit})
		net.Broadcast()

	end)

end

net.Receive("SetOwner",function()

	local tbl = net.ReadTable()

	if(tbl[2] != nil && tbl[2]:IsValid()) then

	if(tbl[2]:GetClass() == "sent_sentry") then
		tbl[1].Sentry = tbl[2]
	end
	if(tbl[2]:GetClass() == "sent_dispenser") then
		tbl[1].Dispenser = tbl[2]
	end
	if(tbl[2]:GetClass() == "sent_teleport" && tbl[3] == false) then
		tbl[1].TeleportIn = tbl[2]
	end
	if(tbl[2]:GetClass() == "sent_teleport" && tbl[3]) then
		tbl[1].TeleportOut = tbl[2]
	end

	tbl[2].Owner = tbl[1]
	tbl[2].Exit = tbl[3]

	end

end)

SWEP.Object = 0

net.Receive("setBuildType",function(len,ply)

	ply:GetActiveWeapon().Object = net.ReadFloat()

end)

function SWEP:CanBuild()

	local pl = self.Owner
	local tr = util.QuickTrace(pl:GetShootPos(),pl:GetAimVector()*96,{self})
	if(tr.HitWorld) then
		local p = tr.HitNormal:Angle().p
		if(p != 270) then
			self.CanBuild = false
		else
			self.CanBuild = true
		end

		return tr.HitPos,self.CanBuild

	else
		local trB = util.QuickTrace(pl:GetShootPos()+pl:GetAimVector()*96,-pl:GetUp()*96,{self})
		if(trB.HitWorld) then

			local p = trB.HitNormal:Angle().p
			if(p != 270) then
				if(self.CanBuild) then
					self.CanBuild = false
				else
					self.CanBuild = true
				end
			end
		end

		return trB.HitPos,self.CanBuild

	end
		
end

function SWEP:Think()

	if CLIENT then

		if(self.Object == 0) then

			if(input.IsKeyDown(KEY_1)) then
				self.Object = 1
			end
			if(input.IsKeyDown(KEY_2)) then
				self.Object = 2
			end
			if(input.IsKeyDown(KEY_3)) then
				self.Object = 3
			end
			if(input.IsKeyDown(KEY_4)) then
				self.Object = 4
			end

			if(self.Object != 0) then
				net.Start("setBuildType")
				net.WriteFloat(self.Object)
				net.SendToServer()
			end

		end


	end

end

if CLIENT then
surface.CreateFont( "BigTF2", {
	font = "TF2 Build",
	size = ScrW()/22,
	weight = 500,
} )

surface.CreateFont( "MiniTF2", {
	font = "TF2 Build",
	size = ScrW()/74,
	weight = 500,
} )

surface.CreateFont( "TinyTF2", {
	font = "TF2 Build",
	size = ScrW()/96,
	weight = 500,
} )

local build = surface.GetTextureID("hud/ico_build")
local corner = surface.GetTextureID("vgui/common/panel_grey_corner")
local edge = surface.GetTextureID("vgui/common/panel_grey_edge")
local fill = surface.GetTextureID("vgui/common/panel_grey_fill")

local sentry = surface.GetTextureID("hud/eng_build_sentry_blueprint")
local disp = surface.GetTextureID("hud/eng_build_dispenser_blueprint")
local teli = surface.GetTextureID("hud/eng_build_tele_entrance_blueprint")
local telo = surface.GetTextureID("hud/eng_build_tele_exit_blueprint")

local key = surface.GetTextureID("hud/ico_key_blank")

local metal = surface.GetTextureID("hud/ico_metal")
local back = surface.GetTextureID("hud/tournament_panel_tan")

local obj = { sentry,disp,teli,telo}

local Mpri = {130,100,125,125}

local sPri = {"Sentry Gun" ,"Dispenser","Entrance","Exit"}

function vgui.PanelBasic(x,y,w,h)

	surface.SetDrawColor(255,255,255,255)

	surface.SetTexture(corner)

	surface.DrawTexturedRectRotated(x,y,32,32,0)
	surface.DrawTexturedRectRotated(x + w,y,32,32,270)
	surface.DrawTexturedRectRotated(x + w,y + h,32,32,180)
	surface.DrawTexturedRectRotated(x,y + h,32,32,90)

	surface.SetTexture(edge)
	surface.DrawTexturedRectRotated(x+w/2,y,w-32,32,0)
	surface.DrawTexturedRectRotated(x+w/2,y+h,w-32,32,180)
	surface.DrawTexturedRectRotated(x,y+h/2,h-32,32,90)
	surface.DrawTexturedRectRotated(x+w,y+h/2,h-32,32,270)

	surface.SetTexture(fill)
	surface.DrawTexturedRectRotated(x+w/2,y+h/2,h-32,w-32,270)

end

function SWEP:DrawHUD()

	if(self.Object == 0) then

	vgui.PanelBasic(ScrW()/2-ScrW()/(2.65*2),ScrH()/2.2,ScrW()/2.65,ScrH()/4)
	draw.SimpleText("BUILD", "BigTF2", ScrW()/2-ScrW()/7.5+2, ScrH()/2.4+2,Color(25,25,25,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText("BUILD", "BigTF2", ScrW()/2-ScrW()/7.5, ScrH()/2.4,Color(225,225,200,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

	surface.SetTexture(build)
	surface.SetDrawColor(25,25,20,255)
	surface.DrawTexturedRect(ScrW()/2-ScrW()/(2.65*2)+2,ScrH()/2.4+2,ScrW()/22,ScrW()/22)
	surface.SetDrawColor(225,225,225,255)
	surface.DrawTexturedRect(ScrW()/2-ScrW()/(2.65*2),ScrH()/2.4,ScrW()/22,ScrW()/22)

	for k,v in pairs(obj) do

		surface.SetDrawColor(255,255,255,255)
		surface.SetTexture(back)
		surface.DrawTexturedRect(ScrW()/2-ScrW()/5.9 + ScrW()/14*(k-1)*1.25,ScrH()/1.9,ScrW()/14,ScrW()/14)		

		surface.SetTexture(v)
		surface.DrawTexturedRect(ScrW()/2-ScrW()/5.9 + ScrW()/14*(k-1)*1.25 + ScrW()/64,ScrH()/1.78,ScrW()/24,ScrW()/24)		

		surface.SetTexture(key)
		surface.DrawTexturedRect(ScrW()/2-ScrW()/6.3 + ScrW()/14*(k-1)*1.25 + ScrW()/64,ScrH()/1.525,ScrW()/48,ScrW()/48)		

		surface.SetTexture(metal)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawTexturedRect(ScrW()/2-ScrW()/5.75 + ScrW()/14*(k-1)*1.25 + ScrW()/64,ScrH()/1.865,ScrW()/86,ScrW()/86)		

		draw.SimpleText(k, "MiniTF2",ScrW()/2-ScrW()/6.3 + ScrW()/14*(k-1)*1.25 + ScrW()/64+ScrW()/48/2,ScrH()/1.525+ScrW()/48/2.5,Color(25,25,20,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(Mpri[k], "MiniTF2",ScrW()/2-ScrW()/6.15 + ScrW()/14*(k-1)*1.25 + ScrW()/64+ScrW()/48/2,ScrH()/1.89+ScrW()/48/2.5,Color(25,25,20,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(sPri[k], "TinyTF2",ScrW()/2-ScrW()/5.25 + ScrW()/14*(k-1)*1.25 + ScrW()/64+ScrW()/48/2,ScrH()/1.95,Color(225,225,200,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	end

end

local SBPS = "models/buildables/sentry1_blueprint.mdl"
local DBPS = "models/buildables/dispenser_blueprint.mdl"
local TEBP = "models/buildables/teleporter_blueprint_enter.mdl"
local TSBP = "models/buildables/teleporter_blueprint_exit.mdl"

local modelNames = {SBPS,DBPS,TEBP,TSBP}

hook.Add("PlayerBindPress","DisableSomeKeys",function( ply, bind, pressed )
	
	if(ply:GetActiveWeapon() != nil && ply:GetActiveWeapon():IsValid() && ply:GetActiveWeapon():GetClass() == "weapon_pda") then

		if ( string.find( bind, "slot*" ) ) then return true end
	end
end)


function SWEP:CalcView( pl, Origin, an, FOV )

	if (self.Object != 0) then

		self.Owner:GetViewModel():SetModel(self.ViewBox)
		self.Owner:GetViewModel():SetSkin(2)

		if(self.Cmdl == nil || !self.Cmdl:IsValid()) then

			self.Cmdl = ClientsideModel(modelNames[self.Object])
			self.Cmdl:SetAngles(pl:EyeAngles())
			self.Cmdl:SetPos(pl:GetPos() + pl:GetForward()*96)

		end

		if(self.Cmdl != nil && self.Cmdl:IsValid()) then

			local tr = util.QuickTrace(pl:GetShootPos(),pl:GetAimVector()*96,{self,self.Cmdl})

			if(tr.HitWorld) then

				local p = tr.HitNormal:Angle().p
				if(p != 270) then
					if(self.CanBuild) then
						local seq = self.Cmdl:LookupSequence("reject")
						if(self.Object == 3) then
							seq = self.Cmdl:LookupSequence("enter_reject")
						elseif(self.Object == 4) then
							seq = self.Cmdl:LookupSequence("exit_reject")
						end
						self.Cmdl:ResetSequence(seq)
						self.Cmdl:SetSequence(seq)
					end
					self.CanBuild = false
				else
					local seq = self.Cmdl:LookupSequence("idle")
					if(self.Object == 3) then
						seq = self.Cmdl:LookupSequence("enter_idle")
					elseif(self.Object == 4) then
						seq = self.Cmdl:LookupSequence("exit_idle")
					end
					self.Cmdl:ResetSequence(seq)
					self.Cmdl:SetSequence(seq)
					self.CanBuild = true
				end

				self.Cmdl:SetPos(tr.HitPos)

			else

				local trB = util.QuickTrace(pl:GetShootPos()+pl:GetAimVector()*96,-pl:GetUp()*96,{self,self.Cmdl})

				if(trB.HitWorld) then

					local p = trB.HitNormal:Angle().p
					if(p != 270) then
						if(self.CanBuild) then
							local seq = self.Cmdl:LookupSequence("reject")
							if(self.Object == 3) then
								seq = self.Cmdl:LookupSequence("enter_reject")
							elseif(self.Object == 4) then
								seq = self.Cmdl:LookupSequence("exit_reject")
							end
							self:ResetSequence(seq)
							self:SetSequence(seq)
						end
						
						self.CanBuild = false
					else
						local seq = self.Cmdl:LookupSequence("idle")
						if(self.Object == 3) then
							seq = self.Cmdl:LookupSequence("enter_idle")
						elseif(self.Object == 4) then
							seq = self.Cmdl:LookupSequence("exit_idle")
						end
						self.Cmdl:ResetSequence(seq)
						self.Cmdl:SetSequence(seq)
						self.CanBuild = true
					end

					self.Cmdl:SetPos(trB.HitPos)

				end

			end

			if(self.NAng != self.ExAngle) then

				self.NAng = Lerp(FrameTime()*8,self.NAng,self.ExAngle)

			end

			self.Cmdl:SetAngles(Angle(0,pl:EyeAngles().y + self.NAng,0))
			

		end

	end

end

end
