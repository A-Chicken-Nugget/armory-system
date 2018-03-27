AddCSLuaFile("armory-system/config_armory-system.lua")
AddCSLuaFile("point-system/sh_point-system.lua")

include("armory-system/config_armory-system.lua")
include("point-system/sh_point-system.lua")

if SERVER then
	AddCSLuaFile("armory-system/cl_armory-system.lua")
	include("armory-system/sv_armory-system.lua")
	include("point-system/sv_point-system.lua")
else
	include("armory-system/cl_armory-system.lua")
end	