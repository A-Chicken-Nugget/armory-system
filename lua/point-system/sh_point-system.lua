local plyMeta = FindMetaTable("Player")

function plyMeta:ARMORY_GETPOINTS()
	return tonumber(self:GetNWInt("armory_points"))
end