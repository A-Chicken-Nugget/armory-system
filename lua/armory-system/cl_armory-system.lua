if CLIENT then
	surface.CreateFont("armory_1",{font="Roboto Black",extended=false,size=17,weight=500})
	surface.CreateFont("armory_2",{font="Roboto Black",extended=false,size=30,weight=500})
	surface.CreateFont("armory_3",{font="",extended=false,size=15,weight=500})

	local white = Color(255,255,255)
	local grey = Color(192,192,192)
	local dim_white = Color(150,150,150)
	local yellow = Color(255,165,0)

	net.Receive("armory_panel",function()
		net.Start("armory_quereyInformation")
		net.SendToServer()
		net.Receive("armory_returnInformation",function()
			local tbl = net.ReadTable()
			for k,v in pairs(tbl) do
				if k == "weapons" then
					ARMORY.plyweapons = v
				elseif k == "perks" then
					ARMORY.plyperks = v
				elseif k == "kills" then
					ARMORY.plykills = v
				elseif k == "levels" then
					ARMORY.plylevels = v
				end
			end
			armory_panel()
		end)
		function armory_panel()
			local box = {}
			local cat = {}
			local icon = {}
			local boxclick = {}
			local equiptWeapon = {}
			local categoryNames = {}
			local selected = 1
			local categorySelected = 1

			for k,v in pairs(ARMORY.categories) do
				table.insert(categoryNames,ARMORY.categories[k].name)
			end
			if table.Count(ARMORY.plyweapons) > 0 then
				for k,v in pairs(categoryNames) do
					if ARMORY.plyweapons[v] != nil then
						for k2,v2 in pairs(ARMORY.plyweapons[v]) do
							if v2.isEquip then
								equiptWeapon[v] = v2.weapon
							end
						end
					end
				end
			end
			function armory_weaponMatch(wep)
				local i = false
				if ARMORY.plyweapons[ARMORY.categories[categorySelected].name] != nil then
					for k,v in pairs(ARMORY.plyweapons[ARMORY.categories[categorySelected].name]) do
						if v.weapon == wep then
							i = true
						end
					end
				end
				return i
			end
			function armory_setEquipt(wep)
				equiptWeapon[ARMORY.categories[categorySelected].name] = wep
				for k,v in pairs(ARMORY.categories[categorySelected].items) do
					if armory_weaponMatch(v.class) then
						if v.class == equiptWeapon[ARMORY.categories[categorySelected].name] then
							icon[k]:SetVisible(true)
							icon[k]:SetImage("materials/armory-system/check.png")
						else
							icon[k]:SetVisible(false)
						end
					else
						icon[k]:SetImage("materials/armory-system/lock.png")
					end
				end
			end
			function armory_weaponLevel(wep)
				local i = 0
				if table.Count(ARMORY.plylevels) > 0 then
					for k,v in pairs(ARMORY.plylevels) do
						if v.weapon == wep then
							i = v.level
						end
					end
				end
				return tonumber(i)
			end
			local curlevel = armory_weaponLevel(ARMORY.categories[categorySelected].items[selected].class)
			function armory_checkKills(wep)
				local i = 0
				for k,v in pairs(ARMORY.plykills) do
					if k == wep then
						i = v
					end
				end
				return i
			end
			function armory_getPercentage(stat,curlevel)
				local default = ARMORY.categories[categorySelected].items[selected][stat]
				if curlevel >= 1 then
					if stat == "default_damage" then
						return ARMORY.UPGRADELEVELS[curlevel].damageUpgrade+default
					elseif stat == "default_recoil" then
						return ARMORY.UPGRADELEVELS[curlevel].recoilUpgrade+default
					elseif stat == "default_clipsize" then
						return ARMORY.UPGRADELEVELS[curlevel].clipsizeUpgrade+default
					end
				else
					return ARMORY.categories[categorySelected].items[selected][stat]
				end
			end
			function armory_checkBlacklist(wep)
				local i = false
				for k,v in pairs(ARMORY.BLACKLIST) do
					if wep == k then
						if team.GetName(LocalPlayer():Team()) == v[1] then
							i = true
						end
					end
				end
				return i
			end
			local frame = vgui.Create("DFrame")
			frame:SetSize(ScrW(),ScrH())
			frame:MakePopup()
			frame:SetTitle("")
			frame:SetDraggable(false)
			frame:ShowCloseButton(false)
			function frame:Paint() end
			local blur = vgui.Create("DFrame",frame)
			blur:SetSize(1,1)
			blur:SetBackgroundBlur(true)
			local close = vgui.Create("DButton",frame)
			close:SetSize(75,30)
			close:SetText("")
			close:SetPos(frame:GetWide()-close:GetWide()-10,10)
			function close:DoClick() frame:Close() end
			function close:Paint(w,h)
				surface.SetDrawColor(white)
				surface.DrawOutlinedRect(0,0,w,h)
			end
			local lbl = vgui.Create("DLabel",close)
			lbl:SetText("X")
			lbl:SetFont("armory_3")
			lbl:SetColor(white)
			lbl:SizeToContents()
			lbl:Center()
			local scrollpanel = vgui.Create("DScrollPanel",frame)
			scrollpanel:SetSize(300,600)
			scrollpanel:SetPos(ScrW()/12,ScrH()/2-265)
			local sbar = scrollpanel:GetVBar()
			function sbar:Paint( w, h )
				surface.SetDrawColor(white)
				surface.DrawOutlinedRect(0,0,w,h)
			end
			function sbar.btnUp:Paint( w, h )
				surface.SetDrawColor(white)
				surface.DrawOutlinedRect(0,0,w,h)
			end
			function sbar.btnDown:Paint( w, h )
				surface.SetDrawColor(white)
				surface.DrawOutlinedRect(0,0,w,h)
			end
			function sbar.btnGrip:Paint( w, h )
				surface.SetDrawColor(white)
				surface.DrawOutlinedRect(0,0,w,h)
			end
			local layout = vgui.Create("DIconLayout",scrollpanel)
			layout:Dock(FILL)
			local err = vgui.Create("DLabel",frame)
			err:SetVisible(false)
			err:SetFont("armory_3")
			err:SetColor(white)
			function armory_errorMsg(i,num)
				err:SetText(i)
				err:SizeToContents()
				err:Center()
				err:SetVisible(true)
				if num == 1 then
					err:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/2-175)
				else
					err:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/1.3)
				end
				if timer.Exists("armoy_errorMsg") then
					timer.Destroy("armoy_errorMsg")
					timer.Create("armoy_errorMsg",5,1,function()
						if frame:IsValid() then
							err:SetVisible(false)
						end
					end)
				else
					timer.Create("armoy_errorMsg",5,1,function()
						if frame:IsValid() then
							err:SetVisible(false)
						end
					end)
				end
			end
			local categoryLayout = vgui.Create("DIconLayout",frame)
			categoryLayout:SetSize(300,65)
			categoryLayout:SetPos(ScrW()/12,ScrH()/2-335)
			categoryLayout:SetSpaceX(5)
			categoryLayout:SetSpaceY(5)
			for k,v in pairs(ARMORY.categories) do
				cat[k] = categoryLayout:Add("DButton",frame)
				cat[k]:SetSize(147,30)
				cat[k]:SetText("")
				cat[k].Paint = function(_,w,h)
					surface.SetDrawColor(dim_white)
					surface.DrawOutlinedRect(0,0,w,h)
					if cat[k]:IsHovered() then
						cat[k]:SetAlpha(175)
					else
						cat[k]:SetAlpha(255)
					end
				end
				cat[1].Paint = function(_,w,h)
					surface.SetDrawColor(white)
					surface.DrawOutlinedRect(0,0,w,h)
					if cat[1]:IsHovered() then
						cat[1]:SetAlpha(175)
					else
						cat[1]:SetAlpha(255)
					end
				end
				local lbl = vgui.Create("DLabel",cat[k])
				lbl:SetText(v.name)
				lbl:SetFont("armory_3")
				lbl:SetColor(white)
				lbl:SizeToContents()
				lbl:Center()
				cat[k].DoClick = function()
					if table.Count(ARMORY.categories[k].items) > 0 then
						selected = 1
						categorySelected = k
						curlevel = armory_weaponLevel(ARMORY.categories[categorySelected].items[selected].class)
						layout:Clear()
						armory_layout()
						armory_refreshVgui()
						for k,v in pairs(ARMORY.categories) do
							cat[k].Paint = function(_,w,h)
								surface.SetDrawColor(dim_white)
								surface.DrawOutlinedRect(0,0,w,h)
								if cat[k]:IsHovered() then
									cat[k]:SetAlpha(175)
								else
									cat[k]:SetAlpha(255)
								end
							end
						end
						cat[k].Paint = function(_,w,h)
							surface.SetDrawColor(white)
							surface.DrawOutlinedRect(0,0,w,h)
							if cat[k]:IsHovered() then
								cat[k]:SetAlpha(175)
							else
								cat[k]:SetAlpha(255)
							end
						end
					end
				end
			end
			local name = vgui.Create("DLabel",frame)
			name:SetText(ARMORY.categories[categorySelected].items[selected].name)
			name:SetFont("armory_2")
			name:SetColor(white)
			name:SizeToContents()
			name:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/2-275)
			local purchase = vgui.Create("DButton",frame)
			purchase:SetSize(200,50)
			purchase:SetText("")
			purchase:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/2-235)
			local pur = vgui.Create("DLabel",purchase)
			pur:SetText("Purchase Weapon")
			if armory_weaponMatch(ARMORY.categories[categorySelected].items[selected].class) then
				pur:SetText("Click to")
			else
				pur:SetText("Purchase Weapon")
			end
			pur:SetFont("armory_1")
			pur:SetColor(white)
			pur:SizeToContents()
			pur:SetPos(0,5)
			pur:CenterHorizontal()
			local price = vgui.Create("DLabel",purchase)
			if armory_weaponMatch(ARMORY.categories[categorySelected].items[selected].class) then
				price:SetText("equip weapon")
			else
				price:SetText("($"..ARMORY.categories[categorySelected].items[selected].price..")")
			end
			price:SetFont("armory_3")
			price:SetColor(white)
			price:SizeToContents()
			price:SetPos(0,25)
			price:CenterHorizontal()
			function purchase:Paint(w,h)
				surface.SetDrawColor(white)
				surface.DrawOutlinedRect(0,0,w,h)
				if purchase:IsHovered() then
					purchase:SetAlpha(175)
				else
					purchase:SetAlpha(255)
				end
			end
			function purchase:DoClick()
				if ARMORY.categories[categorySelected].items[selected].class != equiptWeapon[ARMORY.categories[categorySelected].name] then
					if armory_weaponMatch(ARMORY.categories[categorySelected].items[selected].class) then
						armory_setEquipt(ARMORY.categories[categorySelected].items[selected].class)
						net.Start("armory_equipItem")
							net.WriteString(ARMORY.categories[categorySelected].items[selected].class)
							net.WriteString(ARMORY.categories[categorySelected].name)
						net.SendToServer()
					else
						if ARMORY.categories[categorySelected].isGrenade then
							if LocalPlayer():getDarkRPVar("money") >= ARMORY.categories[categorySelected].items[selected].price then
								net.Start("armory_buySpecialItem")
									net.WriteString(ARMORY.categories[categorySelected].items[selected].price)
									net.WriteString(ARMORY.categories[categorySelected].items[selected].class)
								net.SendToServer()
							else
								armory_errorMsg("You do not have enough money to purchase this weapon!",1)
							end
						else
							if LocalPlayer():getDarkRPVar("money") >= ARMORY.categories[categorySelected].items[selected].price then
								net.Start("armory_buyItem")
									net.WriteString(ARMORY.categories[categorySelected].items[selected].price)
									net.WriteString(ARMORY.categories[categorySelected].name)
									net.WriteString(ARMORY.categories[categorySelected].items[selected].class)
								net.SendToServer()
							else
								armory_errorMsg("You do not have enough money to purchase this weapon!",1)
							end
							frame:Close()
						end
					end
				end
			end
			local lbl = vgui.Create("DLabel",frame)
			lbl:SetText("Damage")
			lbl:SetFont("armory_1")
			lbl:SetColor(white)
			lbl:SizeToContents()
			lbl:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/2-100)
			local lblre = vgui.Create("DLabel",frame)
			lblre:SetText("Recoil")
			lblre:SetFont("armory_1")
			lblre:SetColor(white)
			lblre:SizeToContents()
			lblre:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/2-75)
			local lblc = vgui.Create("DLabel",frame)
			lblc:SetText("Clip Size")
			lblc:SetFont("armory_1")
			lblc:SetColor(white)
			lblc:SizeToContents()
			lblc:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/2-50)
			local blayout = vgui.Create("DPanel",frame)
			blayout:SetSize(300,100)
			blayout:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+150,ScrH()/2-100)
			function blayout:Paint() end
			local dmg
			local recoil
			local clip
			function armory_refreshBars()
				blayout:Clear()
				if ARMORY.categories[categorySelected].showDamage then
					local gdmg = armory_getPercentage("default_damage",curlevel)
					dmg = vgui.Create("DProgress",blayout)
					dmg:SetSize( 240, 20 )
					dmg:SetPos(0,0)
					dmg:SetFraction(ARMORY.categories[categorySelected].items[selected].default_damage/100)
					function dmg:Paint(w,h)
						draw.RoundedBox(8,0,0,w,h,dim_white)
						draw.RoundedBoxEx(8,0,0,gdmg/100*240,h,yellow,true,false,true,false)
						draw.RoundedBoxEx(8,0,0,dmg:GetFraction()*240,h,white,true,false,true,false)
					end
				end
				if ARMORY.categories[categorySelected].showRecoil then
					local grecoil = armory_getPercentage("default_recoil",curlevel)
					recoil = vgui.Create("DProgress",blayout)
					recoil:SetSize( 240, 20 )
					recoil:SetPos(0,25)
					recoil:SetFraction(ARMORY.categories[categorySelected].items[selected].default_recoil/100)
					function recoil:Paint(w,h)
						draw.RoundedBox(8,0,0,w,h,dim_white)
						draw.RoundedBoxEx(8,0,0,recoil:GetFraction()*240,h,white,true,false,true,false)
						if grecoil/100*240 != recoil:GetFraction()*240 then
							draw.RoundedBoxEx(8,0,0,grecoil/100*240,h,grey,true,false,true,false)
						end
					end
				end
				if ARMORY.categories[categorySelected].showClipsize then
					local gclip = armory_getPercentage("default_clipsize",curlevel)
					clip = vgui.Create("DProgress",blayout)
					clip:SetSize( 240, 20 )
					clip:SetPos(0,50)
					clip:SetFraction(ARMORY.categories[categorySelected].items[selected].default_clipsize/100)
					function clip:Paint(w,h)
						draw.RoundedBox(8,0,0,w,h,dim_white)
						draw.RoundedBoxEx(8,0,0,gclip/100*240,h,yellow,true,false,true,false)
						draw.RoundedBoxEx(8,0,0,clip:GetFraction()*240,h,white,true,false,true,false)
					end
				end
			end
			local model = vgui.Create("DModelPanel",frame)
			model:SetSize(400,400)
			model:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+450,ScrH()/2-250)
			model:SetModel(ARMORY.categories[categorySelected].items[selected].model)
			local PrevMins, PrevMaxs = model.Entity:GetRenderBounds()
			model:SetCamPos(PrevMins:Distance(PrevMaxs)*Vector(0.75, 0.75, 0.5))
			model:SetLookAt((PrevMaxs + PrevMins)/2)
			model:SetFOV(80)
			local plbl = vgui.Create("DLabel",frame)
			plbl:SetText("Weapon Upgrade")
			plbl:SetFont("armory_1")
			plbl:SetColor(white)
			plbl:SizeToContents()
			plbl:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/1.75)
			local upgradep = vgui.Create("DPanel",frame)
			upgradep:SetSize(105,95)
			upgradep:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/1.65)
			function upgradep:Paint() end
			local levelp = vgui.Create("DLabel",frame)
			function armory_refreshUpgrade()
				local nextlevel = curlevel+1
				upgradep:Clear()
				local isMax
				if nextlevel >= table.Count(ARMORY.UPGRADELEVELS) then
					isMax = true
				else
					isMax = false
				end
				local button = vgui.Create("DButton",upgradep)
				button:SetText("")
				button:SetSize(105,95)
				function button:Paint(w,h)
					surface.SetDrawColor(dim_white)
					surface.DrawOutlinedRect(0,0,w,h)
				end
				local img = vgui.Create("DImage",button)
				if isMax then
					img:SetImage("materials/armory-system/lock.png")
					button:SetAlpha(100)
				else
					if armory_checkKills(ARMORY.categories[categorySelected].items[selected].class) >= ARMORY.UPGRADELEVELS[nextlevel].killsRequired then
						img:SetImage("materials/armory-system/arrow_upgrade.png")
					else
						img:SetImage("materials/armory-system/lock.png")
						button:SetAlpha(100)
					end
				end
				img:SetSize(25,30)
				img:SetPos(0,5)
				img:CenterHorizontal()
				local lblname = vgui.Create("DLabel",button)
				if isMax then
					lblname:SetText("MAX LEVEL")
				else
					lblname:SetText(ARMORY.UPGRADELEVELS[nextlevel].name)
				end
				lblname:SetFont("armory_3")
				lblname:SetColor(white)
				lblname:SizeToContents()
				lblname:SetPos(0,35)
				lblname:CenterHorizontal()
				local kills = vgui.Create("DLabel",button)
				if isMax then
					kills:SetText("")
				else
					kills:SetText(armory_checkKills(ARMORY.categories[categorySelected].items[selected].class).." out of "..ARMORY.UPGRADELEVELS[nextlevel].killsRequired)
				end
				kills:SetFont("armory_3")
				kills:SetColor(white)
				kills:SizeToContents()
				kills:SetPos(0,52)
				kills:CenterHorizontal()
				local icon = vgui.Create("DImage",button)
				icon:SetImage("materials/armory-system/points.png")
				icon:SetSize(20,20)
				icon:SetPos(button:GetWide()/2-25,70)
				local lblprice = vgui.Create("DLabel",button)
				if isMax then
					lblprice:SetText("-----")
				else
					lblprice:SetText(ARMORY.UPGRADELEVELS[nextlevel].price)
				end
				lblprice:SetFont("armory_3")
				lblprice:SetColor(white)
				lblprice:SizeToContents()
				lblprice:SetPos(icon:GetPos()+25,72)
				if isMax then
					levelp:SetText("You are max level for this weapon.")
				else
					levelp:SetText("* Get "..ARMORY.UPGRADELEVELS[nextlevel].killsRequired.." kills with this weapon to unlock the upgrade.")
				end
				levelp:SetFont("armory_3")
				levelp:SetColor(white)
				levelp:SizeToContents()
				levelp:SetPos(scrollpanel:GetPos()+scrollpanel:GetWide()+20,ScrH()/1.35)
				function button:DoClick()
					if armory_checkKills(ARMORY.categories[categorySelected].items[selected].class) >= ARMORY.UPGRADELEVELS[nextlevel].killsRequired then
						if LocalPlayer():ARMORY_GETPOINTS() >= ARMORY.UPGRADELEVELS[nextlevel].price then
							net.Start("armory_upgradeWeapon")
								net.WriteString(nextlevel)
								net.WriteString(ARMORY.categories[categorySelected].items[selected].class)
								net.WriteString(ARMORY.UPGRADELEVELS[nextlevel].price)
							net.SendToServer()
							curlevel = nextlevel
							armory_refreshBars()
							armory_refreshUpgrade()
							if nextlevel >= table.Count(ARMORY.UPGRADELEVELS) then
								isMax = true
							else
								isMax = false
							end
							if isMax then
								lblname:SetText("MAX LEVEL")
								lblprice:SetText("-----")
								levelp:SetText("You are max level for this weapon.")
								button:SetAlpha(100)
							else
								lblname:SetText(ARMORY.UPGRADELEVELS[nextlevel].name)
								lblprice:SetText(ARMORY.UPGRADELEVELS[nextlevel].price)
								levelp:SetText("* Get "..ARMORY.UPGRADELEVELS[nextlevel].killsRequired.." kills with this weapon to unlock the upgrade.")
								if LocalPlayer():ARMORY_GETPOINTS() < ARMORY.UPGRADELEVELS[nextlevel].price then
									button:SetAlpha(100)
								end
							end
							lblname:SizeToContents()
							lblname:CenterHorizontal()
							lblprice:SizeToContents()
							levelp:SizeToContents()
						else
							armory_errorMsg("You do not have enough upgrade points to upgrade this weapon!",2)
						end
					end
				end
			end
			local pointimg = vgui.Create("DImage",frame)
			pointimg:SetImage("materials/armory-system/points.png")
			pointimg:SetSize(20,20)
			pointimg:SetPos(ScrW()-224,50)
			local pointslbl = vgui.Create("DLabel",frame)
			pointslbl:SetFont("armory_1")
			pointslbl:SetColor(white)
			function pointslbl:Paint()
				pointslbl:SetText(LocalPlayer():ARMORY_GETPOINTS())
				pointslbl:SizeToContents()
			end
			pointslbl:SetPos(pointimg:GetPos()+25,52)
			function armory_refreshVgui()
				armory_refreshUpgrade()
				armory_refreshBars()
				name:SetText(ARMORY.categories[categorySelected].items[selected].name)
				name:SizeToContents()
				if armory_weaponMatch(ARMORY.categories[categorySelected].items[selected].class) and (not ARMORY.categories[categorySelected].isGrenade) then
					pur:SetText("Click to")
					price:SetText("equip weapon")
				else
					pur:SetText("Purchase Weapon")
					price:SetText("($"..ARMORY.categories[categorySelected].items[selected].price..")")
				end
				pur:SizeToContents()
				pur:CenterHorizontal()
				price:SizeToContents()
				price:CenterHorizontal()
				model:SetModel(ARMORY.categories[categorySelected].items[selected].model)
				if ARMORY.categories[categorySelected].showDamage then
					dmg:SetFraction(ARMORY.categories[categorySelected].items[selected].default_damage/100)
				end
				if ARMORY.categories[categorySelected].showRecoil then
					lblre:SetVisible(true)
					recoil:SetVisible(true)
					recoil:SetFraction(ARMORY.categories[categorySelected].items[selected].default_recoil/100)
				else
					lblre:SetVisible(false)
				end
				if ARMORY.categories[categorySelected].showClipsize then
					lblc:SetVisible(true)
					clip:SetVisible(true)
					clip:SetFraction(ARMORY.categories[categorySelected].items[selected].default_clipsize/100)
				else
					lblc:SetVisible(false)
				end
			end
			function armory_layout()
				selected = 1
				for k,v in pairs(ARMORY.categories[categorySelected].items) do
					box[k] = layout:Add("DPanel",frame)
					box[k]:SetSize(scrollpanel:GetWide(),100)
					box[k]:SetText("")
					if armory_checkBlacklist(v.class) then 
						box[k]:SetVisible(false)
					end
					box[k].Paint = function(_,w,h)
						surface.SetDrawColor(dim_white)
						surface.DrawOutlinedRect(0,0,w,h)
					end
					box[1].Paint = function(_,w,h)
						surface.SetDrawColor(white)
						surface.DrawOutlinedRect(0,0,w,h)
					end
					local lbl = vgui.Create("DLabel",box[k])
					lbl:SetText(v.name)
					lbl:SetFont("armory_1")
					lbl:SetColor(white)
					lbl:SizeToContents()
					lbl:SetPos(10,10)
					local img = vgui.Create("DModelPanel",box[k])
					img:SetModel(v.model)
					img:SetSize(240,65)
					img:SetPos(0,30)
					img:CenterHorizontal()
					img:SetColor(white)
					local PrevMins, PrevMaxs = img.Entity:GetRenderBounds()
					img:SetCamPos(PrevMins:Distance(PrevMaxs)*Vector(0.75, 0.75, 0.5))
					img:SetLookAt((PrevMaxs + PrevMins)/2)
					function img:LayoutEntity() end
					icon[k] = vgui.Create("DImage",box[k])
					icon[k]:SetSize(16,16)
					icon[k]:SetPos(box[k]:GetWide()-34,10)
					if armory_weaponMatch(v.class) then
						if v.class == equiptWeapon[ARMORY.categories[categorySelected].name] then
							icon[k]:SetImage("materials/armory-system/check.png")
						else
							icon[k]:SetVisible(false)
						end
					else
						if ARMORY.categories[categorySelected].isGrenade then
							icon[k]:SetVisible(false)
						else
							icon[k]:SetImage("materials/armory-system/lock.png")
						end
					end
					boxclick[k] = vgui.Create("DButton",box[k])
					boxclick[k]:SetSize(box[k]:GetWide(),box[k]:GetTall())
					boxclick[k]:SetText("")
					boxclick[k].Paint = function() end
					boxclick[k].DoClick = function()
						selected = k
						curlevel = armory_weaponLevel(ARMORY.categories[categorySelected].items[selected].class)
						for k2,v2 in pairs(ARMORY.categories[categorySelected].items) do
							box[k2].Paint = function(_,w,h)
								surface.SetDrawColor(dim_white)
								surface.DrawOutlinedRect(0,0,w,h)
							end
						end
						box[k].Paint = function(_,w,h)
							surface.SetDrawColor(white)
							surface.DrawOutlinedRect(0,0,w,h)
						end
						armory_refreshVgui()
						armory_refreshBars()
					end
				end
			end
			local logo = vgui.Create("DImage",frame)
			logo:SetSize(200,200)
			logo:SetImage(ARMORY.LOGO)
			logo:SetPos(frame:GetWide()-logo:GetWide(),frame:GetTall()-logo:GetTall())

			armory_layout()
			armory_refreshUpgrade()
			armory_refreshBars()
		end
	end)
	concommand.Add(ARMORY.ENTITYEDIT,function()
		if table.HasValue(ARMORY.SPAWNCHECK,LocalPlayer():GetUserGroup()) then
			net.Start("armory_getEntities")
			net.SendToServer()
			net.Receive("armory_returnEntites",function()
				local tbl = net.ReadTable()
				local selected
				local frame = vgui.Create("DFrame")
				frame:SetSize(200,140)
				frame:Center()
				frame:SetTitle("Edit Armory Entities")
				frame:MakePopup()
				local lbl = vgui.Create("DLabel",frame)
				lbl:SetText("Selected Entity:")
				lbl:SizeToContents()
				lbl:SetPos(0,30)
				lbl:CenterHorizontal()
				local entp = vgui.Create("DComboBox",frame)
				entp:SetSize(50,20)
				entp:SetPos(0,50)
				entp:CenterHorizontal()
				local entt = vgui.Create("DButton",frame)
				entt:SetSize(150,20)
				entt:SetPos(0,80)
				entt:SetText("Go to selected entity")
				entt:SetDisabled(true)
				entt:CenterHorizontal()
				function entt:DoClick()
					RunConsoleCommand("armory_setPlyPos",tostring(tbl[selected].pos))
				end
				local entd = vgui.Create("DButton",frame)
				entd:SetSize(150,20)
				entd:SetPos(0,105)
				entd:SetDisabled(true)
				entd:SetText("Delete Selected Entity")
				entd:CenterHorizontal()
				local function refreshPnl()
					for k,v in pairs(tbl) do
						entp:AddChoice(k)
					end
				end
				function entd:DoClick()
					LocalPlayer():ChatPrint("Entity removed! Please delete the entity or update the map.")
					table.remove(tbl,selected)
					net.Start("armory_saveEntites")
						net.WriteTable(tbl)
					net.SendToServer()
					entp:Clear()
					refreshPnl()
				end
				function entp:OnSelect(i)
					entt:SetDisabled(false)
					entd:SetDisabled(false)
					selected = i
				end
				refreshPnl()
			end)
		end
	end)
	concommand.Add(ARMORY.GIVEPOINTS,function()
		local plys = {}
		local selected
		local frame = vgui.Create("DFrame")
		frame:SetSize(300,180)
		frame:SetTitle("Give Upgrade Points")
		frame:Center()
		frame:MakePopup()
		local lbl = vgui.Create("DLabel",frame)
		lbl:SetText("Select player:")
		lbl:SizeToContents()
		lbl:SetPos(0,30)
		lbl:CenterHorizontal()
		local players = vgui.Create("DComboBox",frame)
		players:SetSize(150,25)
		players:SetPos(0,50)
		players:CenterHorizontal()
		local ply = vgui.Create("DComboBox",frame)
		ply:SetSize(75,25)
		ply:SetPos(40,90)
		ply:AddChoice("Give")
		ply:AddChoice("Take")
		local points = vgui.Create("DTextEntry",frame)
		points:SetSize(100,25)
		points:SetPos(125,90)
		local lbl = vgui.Create("DLabel",frame)
		lbl:SetText("points")
		lbl:SizeToContents()
		lbl:SetPos(230,95)
		local submit = vgui.Create("DButton",frame)
		submit:SetSize(125,30)
		submit:SetText("Submit")
		submit:SetPos(0,130)
		submit:SetDisabled(true)
		submit:CenterHorizontal()
		for k,v in pairs(player.GetAll()) do
			players:AddChoice(v:Nick())
			table.insert(plys,v)
		end
		function submit:DoClick()
			if ply:GetValue() == "" then
				LocalPlayer():ChatPrint("Please select 'Give' or 'Take'!")
			elseif points:GetValue() == "" then
				LocalPlayer():ChatPrint("Please enter an amount of points.")
			elseif not isnumber(tonumber(points:GetValue())) then
				LocalPlayer():ChatPrint("Invalid characters detected in point amount. Please use numbers only.")
			else
				net.Start("armory_managePoints")
					net.WriteTable({
						amount = points:GetValue(),
						ply = plys[players:GetSelectedID()],
						action = ply:GetValue()
					})
				net.SendToServer()
			end
		end
		function players:OnSelect()
			submit:SetDisabled(false)
		end
	end)
end