if SERVER then
	util.AddNetworkString("armory_panel")
	util.AddNetworkString("armory_buyItem")
	util.AddNetworkString("armory_returnInformation")
	util.AddNetworkString("armory_quereyInformation")
	util.AddNetworkString("armory_equipItem")
	util.AddNetworkString("armory_upgradeWeapon")
	util.AddNetworkString("armory_getEntities")
	util.AddNetworkString("armory_returnEntites")
	util.AddNetworkString("armory_saveEntites")
	util.AddNetworkString("armory_buySpecialItem")
	util.AddNetworkString("armory_managePoints")

	resource.AddFile("resource/fonts/Roboto-Black.ttf")
	resource.AddFile("materials/armory-system/logo.png")
	resource.AddFile("materials/armory-system/check.png")
	resource.AddFile("materials/armory-system/lock.png")
	resource.AddFile("materials/armory-system/points.png")
	resource.AddFile("materials/armory-system/arrow_upgrade.png")

	local armory_trackedWeapons = {}

	function armory_checkMatch(ply,wep)
		i = true
		if armory_trackedWeapons[ply:SteamID()] != nil then
			for k,v in pairs(armory_trackedWeapons[ply:SteamID()]) do
				if v == wep then
					i = false
				end
			end
		end
		return i
	end
	function armory_setPerks(ply)
		local wep = ply:GetActiveWeapon():GetClass()
		local wpn = ply:GetWeapon(wep)
		if file.Exists("armory-system/players/"..ply:SteamID64().."/levels.txt","DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/levels.txt"))
			for k,v in pairs(tbl) do
				if v.weapon == wep then
					if wpn.Primary != nil then
						wpn.Primary["Damage"] = wpn.Primary["Damage"]+ARMORY.UPGRADELEVELS[tonumber(v.level)].damageUpgrade
						wpn.Primary["Recoil"] = wpn.Primary["Recoil"]+ARMORY.UPGRADELEVELS[tonumber(v.level)].recoilUpgrade
						wpn.Primary["ClipSize"] = wpn.Primary["ClipSize"]+ARMORY.UPGRADELEVELS[tonumber(v.level)].clipsizeUpgrade
					end
				end
			end
		end
	end
	function armory_addKill(ply,wep)
		if file.Exists("armory-system/players/"..ply:SteamID64().."/kills.txt","DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/kills.txt"))
			local i = false
			for k,v in pairs(tbl) do
				if k == wep then
					i = true
				end
			end
			if i then
				for k,v in pairs(tbl) do
					if k == wep then
						if tbl[wep] != nil then
							tbl[wep] = tbl[wep]+1
						else
							tbl[wep] = 1
						end
					end
				end
			else
				tbl[wep] = 1
			end
			if tbl[wep] % ARMORY.KILLINTERVAL == 0 then
				ply:ARMORY_GIVEPOINTS(ARMORY.KILLREWARD)
				ply:ChatPrint("You have received "..ARMORY.KILLREWARD.." upgrade points for getting kills.")
			end
			file.Write("armory-system/players/"..ply:SteamID64().."/kills.txt",util.TableToJSON(tbl))
		else
			local tbl = {}
			tbl[wep] = 1
			file.Write("armory-system/players/"..ply:SteamID64().."/kills.txt",util.TableToJSON(tbl))
		end
	end
	function armory_trackKills(ply,category)
		local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/weapons.txt"))
		local i = true
		for k,v in pairs(tbl[category]) do
			if armory_checkMatch(ply,v.weapon) then
				if armory_trackedWeapons[ply:SteamID()] != nil then
					table.insert(armory_trackedWeapons[ply:SteamID()],v.weapon)
				else
					armory_trackedWeapons[ply:SteamID()] = {v.weapon}
				end
			end
		end
		hook.Add("PlayerDeath","TrackKills",function(victim,inflictor,killer)
			if table.HasValue(armory_trackedWeapons[ply:SteamID()],killer:GetActiveWeapon():GetClass()) then
				armory_addKill(killer,killer:GetActiveWeapon():GetClass())
			end
		end)
	end
	function armory_giveWeapon(ply,wep,category)
		local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/weapons.txt"))
		for k,v in pairs(tbl[category]) do
			if ply:HasWeapon(v.weapon) then
				ply:StripWeapon(v.weapon)
			end
		end
		for k,v in pairs(tbl[category]) do
			if v.isEquip then
				v.isEquip = false
			end
		end
		for k,v in pairs(tbl[category]) do
			if v.weapon == wep then
				v.isEquip = true
			end
		end
		file.Write("armory-system/players/"..ply:SteamID64().."/weapons.txt",util.TableToJSON(tbl))
		ply:Give(wep)
		ply:SelectWeapon(wep)
		armory_trackKills(ply,category)
		armory_setPerks(ply)
	end
	hook.Add("PlayerSpawn","GiveWeapon",function(ply)
		if file.Exists("armory-system/players/"..ply:SteamID64().."/weapons.txt","DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/weapons.txt"))
			for k,v in pairs(ARMORY.categories) do
				if tbl[ARMORY.categories[k].name] != nil then
					for k2,v2 in pairs(tbl[ARMORY.categories[k].name]) do
						if v2.isEquip then
							armory_giveWeapon(ply,v2.weapon,ARMORY.categories[k].name)
						end
					end
				end
			end
		end
	end)
	hook.Add("PlayerSay","loadDatText",function(ply,msg)
		if ARMORY.CHATCOMMAND != false then
			if ARMORY.CHATCOMMAND == string.lower(msg) then
				net.Start("armory_panel")
				net.Send(ply)
				return ""
			end
		end
	end)
	hook.Add("PlayInitialSpawn","weaponCount",function(ply)
		if file.Exists("armory-system/players/"..ply:SteamID64().."/weapons.txt","DATA") then
			armory_trackKills(ply)
			timer.Simple(3,function()
				local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/weapons.txt"))
				local i = 0
				for k,v in pairs(tbl) do
					i = i+1
					for k2,v2 in pairs(tbl[ARMORY.categories[i].name]) do
						if v2.isEquip then
							armory_giveWeapon(ply,v2.weapon,ARMORY.categories[i].name)
						end
					end
				end
			end)
		end
	end)

	concommand.Add("armory_setPlyPos",function(ply,_,_,i)
		if table.HasValue(ARMORY.SPAWNCHECK,ply:GetUserGroup()) then
			local pos = string.Explode('"',i)
			ply:SetPos(Vector(pos[2])+Vector(0,0,125))
		end
	end)

	net.Receive("armory_managePoints",function(_,ply)
		if table.HasValue(ARMORY.SPAWNCHECK,ply:GetUserGroup()) then
			local tbl = net.ReadTable()
			local amount = tonumber(tbl.amount)
			local ply2 = tbl.ply
			local action = tbl.action
			if action == "Give" then
				ply2:ARMORY_GIVEPOINTS(amount)
				ply:ChatPrint("You have successfully given "..amount.." points to "..ply2:Nick())
			elseif action == "Take" then
				ply2:ARMORY_TAKEPOINTS(amount)
				ply:ChatPrint("You have successfully taken "..amount.." points from "..ply2:Nick())
			end
		end
	end)
	net.Receive("armory_buySpecialItem",function(_,ply)
		local price = net.ReadString()
		local weapon = net.ReadString()
		if ply:HasWeapon(weapon) then
			ply:StripWeapon(weapon)
		end
		ply:addMoney(-price)
		ply:Give(weapon)
		ply:SelectWeapon(weapon)
	end)
	net.Receive("armory_getEntities",function(_,ply)
		if file.Exists("armory-system/entities/"..string.lower(game.GetMap()),"DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/entities/"..string.lower(game.GetMap()).."/armory_entities.txt"))
			net.Start("armory_returnEntites")
				net.WriteTable(tbl)
			net.Send(ply)
		end
	end)
	net.Receive("armory_saveEntites",function(_,ply)
		local tbl = net.ReadTable()
		file.Write("armory-system/entities/"..string.lower(game.GetMap()).."/armory_entities.txt",util.TableToJSON(tbl))
	end)
	net.Receive("armory_upgradeWeapon",function(_,ply)
		local nextlevel = net.ReadString()
		local wep = net.ReadString()
		local cost = net.ReadString()
		if file.Exists("armory-system/players/"..ply:SteamID64().."/levels.txt","DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/levels.txt"))
			local i = false
			for k,v in pairs(tbl) do
				if v.weapon == wep then
					i = true
				end
			end
			if i then
				for k,v in pairs(tbl) do
					if v.weapon == wep then
						v.level = nextlevel
					end
				end
			else
				table.insert(tbl,{
					weapon = wep,
					level = nextlevel
				})
			end
			ARMORY.plylevels = tbl
			file.Write("armory-system/players/"..ply:SteamID64().."/levels.txt",util.TableToJSON(ARMORY.plylevels))
		else
			ARMORY.plylevels = {{weapon = wep,level = nextlevel}}
			file.Write("armory-system/players/"..ply:SteamID64().."/levels.txt",util.TableToJSON(ARMORY.plylevels))
		end
		ply:ARMORY_TAKEPOINTS(cost)
	end)
	net.Receive("armory_equipItem",function(_,ply)
		local wep = net.ReadString()
		local category = net.ReadString()
		armory_giveWeapon(ply,wep,category)
	end)
	net.Receive("armory_quereyInformation",function(_,ply)
		local i = {}
		net.Start("armory_returnInformation")
		if file.Exists("armory-system/players/"..ply:SteamID64().."/weapons.txt","DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/weapons.txt"))
			i["weapons"] = tbl
		end
		if file.Exists("armory-system/players/"..ply:SteamID64().."/perks.txt","DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/perks.txt"))
			i["perks"] = tbl
		end
		if file.Exists("armory-system/players/"..ply:SteamID64().."/kills.txt","DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/kills.txt"))
			i["kills"] = tbl
		end
		if file.Exists("armory-system/players/"..ply:SteamID64().."/levels.txt","DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/levels.txt"))
			i["levels"] = tbl
		end
		net.WriteTable(i)
		net.Send(ply)
	end)
	net.Receive("armory_buyItem",function(_,ply)
		local price = net.ReadString()
		local category = net.ReadString()
		local weapon = net.ReadString()
		if file.Exists("armory-system/players/"..ply:SteamID64().."/weapons.txt","DATA") then
			local tbl = util.JSONToTable(file.Read("armory-system/players/"..ply:SteamID64().."/weapons.txt"))
			if tbl[category] != nil then
				for k,v in pairs(tbl[category]) do
					if v.isEquip then
						v.isEquip = false
					end
				end
				table.insert(tbl[category],{
					weapon = weapon,
					isEquip = true
				})
			else
				tbl[category] = {{weapon = weapon,isEquip = true}}
			end
			ARMORY.plyweapons = tbl
			file.Write("armory-system/players/"..ply:SteamID64().."/weapons.txt",util.TableToJSON(ARMORY.plyweapons))

			hook.Remove("PlayerDeath","TrackKills")
		else
			ARMORY.plyweapons[category] = {{weapon = weapon,isEquip = true}}
		
			file.CreateDir("armory-system/players/"..ply:SteamID64())
			file.Write("armory-system/players/"..ply:SteamID64().."/weapons.txt",util.TableToJSON(ARMORY.plyweapons))
		end
		ply:addMoney(-price)
		armory_giveWeapon(ply,weapon,category)
	end)
end