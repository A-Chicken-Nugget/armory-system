if SERVER then
	local plyMeta = FindMetaTable("Player")
	
	function plyMeta:ARMORY_GIVEPOINTS(amount)
		local curpoints = self:ARMORY_GETPOINTS()
		self:SetNWInt("armory_points",self:GetNWInt("armory_points")+amount)
		self:SetPData("armory_points",self:GetNWInt("armory_points")+amount)
	end
	function plyMeta:ARMORY_TAKEPOINTS(amount)
		local curpoints = self:ARMORY_GETPOINTS()
		self:SetNWInt("armory_points",self:GetNWInt("armory_points")-amount)
		self:SetPData("armory_points",self:GetNWInt("armory_points")-amount)
	end

	hook.Add("PlayerAuthed","PointsSetup",function(ply)
		local points = ply:GetPData("armory_points",-1)
		if points == -1 then
			ply:SetPData("armory_points",0)
			ply:SetNWInt("armory_points",0)
		else
			ply:SetNWInt("armory_points",points)
		end
	end)
end