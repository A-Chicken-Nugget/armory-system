AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local pos_
local ang_

timer.Simple(1,function()
	if file.Exists("armory-system/entities/"..string.lower(game.GetMap()),"DATA") then
		local tbl = util.JSONToTable(file.Read("armory-system/entities/"..string.lower(game.GetMap()).."/armory_entities.txt"))
		for k,v in pairs(tbl) do
			local locker = ents.Create("armory_entity")
			pos_ = Vector(v.pos)
			ang_ = Angle(v.ang)
			locker:SetPos(pos_)
			locker:SetAngles(ang_)
			locker:Spawn()
		end
	end
end)

concommand.Add(ARMORY.SPAWNENTITY,function(ply)
	if table.HasValue(ARMORY.SPAWNCHECK,ply:GetUserGroup()) then
		local pos = ply:GetEyeTrace().HitPos
		local ang = ply:GetAngles()+Angle(0, -180, 0)
		local locker = ents.Create("armory_entity")
		pos_ = Vector(pos[1],pos[2],pos[3])
		ang_ = Angle(ang[1],ang[2],ang[3])
		locker:SetPos(pos_)
		locker:SetAngles(ang_)
		locker:Spawn()
		if file.Exists("armory-system/entities/"..string.lower(game.GetMap()),"DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/entities/"..string.lower(game.GetMap()).."/armory_entities.txt"))
			table.insert(tbl,{
				pos = pos_,
				ang = ang_
			})
			file.Write("armory-system/entities/"..string.lower(game.GetMap()).."/armory_entities.txt",util.TableToJSON(tbl))
		else
			local tbl = {{
				pos = pos_,
				ang = ang_
			}}
			file.CreateDir("armory-system/entities/"..string.lower(game.GetMap()))
			file.Write("armory-system/entities/"..string.lower(game.GetMap()).."/armory_entities.txt",util.TableToJSON(tbl))
		end
	end
end)

function ENT:Initialize()
	self:SetModel("models/starwars/syphadias/props/sw_tor/bioware_ea/props/city/city_market_stand_03.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(a,c)
	local i = {}
	net.Start("armory_panel")
	if file.Exists("armory-system/players/"..a:SteamID64().."/weapons.txt","DATA") then
		local tbl = util.JSONToTable(file.Read("armory-system/players/"..a:SteamID64().."/weapons.txt"))
		i["weapons"] = tbl
	end
	if file.Exists("armory-system/players/"..a:SteamID64().."/perks.txt","DATA") then
		local tbl = util.JSONToTable(file.Read("armory-system/players/"..a:SteamID64().."/perks.txt"))
		i["perks"] = tbl
	end
	if file.Exists("armory-system/players/"..a:SteamID64().."/kills.txt","DATA") then
		local tbl = util.JSONToTable(file.Read("armory-system/players/"..a:SteamID64().."/kills.txt"))
		i["kills"] = tbl
	end
	if file.Exists("armory-system/players/"..a:SteamID64().."/levels.txt","DATA") then
		local tbl = util.JSONToTable(file.Read("armory-system/players/"..a:SteamID64().."/levels.txt"))
		i["levels"] = tbl
	end
	net.WriteTable(i)
	net.Send(a)
end

function ENT:Think()
end