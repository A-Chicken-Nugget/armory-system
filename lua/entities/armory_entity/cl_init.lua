include('shared.lua')
if CLIENT then
	surface.CreateFont("locker_font",{font="",extended=false,size=50,weight=500})
end

function ENT:Initialize()
end

function ENT:Draw()
	-- local eye = LocalPlayer():GetEyeTrace()
	-- local offset = Vector( 0, -50, 85 )
	-- local ang = LocalPlayer():EyeAngles()
	-- local ang_ent = self:GetLocalAngles()
	-- local pos = self:GetPos() + offset + ang:Up()
	
	-- ang:RotateAroundAxis( ang:Forward(), 90 )
	-- ang:RotateAroundAxis( ang:Right(), 90 )
	-- if eye.Entity:GetClass() == self:GetClass()   then
	-- 	cam.Start3D2D( pos+Vector(48,10,30), Angle( ang_ent.x, ang_ent.y + 90, ang_ent.z + 90), 0.2 )
	-- 		draw.DrawText( "ARMORY", "locker_font", 2, 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	-- 	cam.End3D2D()
	-- end

	self:DrawModel()
end

function ENT:OnRemove()
end	
