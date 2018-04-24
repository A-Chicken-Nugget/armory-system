ARMORY = {}
ARMORY.categories = {}
ARMORY.plyweapons = {}
ARMORY.plyperks = {}
ARMORY.plylevels = {}
ARMORY.plykills = {}

function armory_addCategory(category,showDamage,showRecoil,showClipsize,isGrenade)
	if table.Count(ARMORY.categories) < 4 then
		table.insert(ARMORY.categories,{
			name = category,
			showDamage = showDamage,
			showRecoil = showRecoil,
			showClipsize = showClipsize,
			isGrenade = isGrenade,
			items = {}
		})
	end
end
function armory_addItem(category,name,class,model,price,defDamage,defRecoil,defClipsize)
	for k,v in pairs(ARMORY.categories) do
		if v.name == category then
			table.insert(ARMORY.categories[k].items,{
				name = name,
				class = class,
				model = model,
				price = price,
				default_damage = defDamage,
				default_recoil = defRecoil,
				default_clipsize = defClipsize
			})
		end
	end
end
-- Do not edit anything above

----------------------
//CONFIG STARTS HERE\\
----------------------

--Logo path that shows in the bottom right corner
ARMORY.LOGO = "materials/armory-system/logo.png"

--Console command to spawn a armory entity
ARMORY.SPAWNENTITY = "armory_spawnArmory"

--Console command to open the entity edit menu
ARMORY.ENTITYEDIT = "armory_editEntities"

--Model that the armory entity will use
ARMORY.ENTITYMODEL = "models/props_wasteland/kitchen_fridge001a.mdl"

--Console command to give upgrade points
ARMORY.GIVEPOINTS = "armory_giveUpgradePoints"

--Chat command to open the menu (change to false to disable)
ARMORY.CHATCOMMAND = "!armory"

--Every time a player gets this many kills, they will be rewarded with upgrade points
ARMORY.KILLINTERVAL = 5

--This will be the amount of points the players receive every kill interval
ARMORY.KILLREWARD = 25

--ULX groups that can spawn/edit entities as well as give upgrade points
ARMORY.SPAWNCHECK = {
	"superadmin",
	"admin"
}

--Blacklist the prevents certain jobs from seeing weapon options
ARMORY.BLACKLIST = {
	["weapon_smg1"] = { --weapon class
		"Mayor", --name of job that cannot see the weapon
	}
}

--This is where you add your weapons/categories:
--EXAMPLE: armory_addCategory("Weapon Name",Show Damage Bar?,Show Recoil Bar?,Show Clipsize Bar?,Can you buy multiple?)
--EXAMPLE: armory_addItem("Category to add item to","Item name","Item class","Item world model",Price,Default damage stat,Default recoil stat,Default clipsize stat)
--NOTE: the default stat values do not matter and aren't actully replaced with the weapons values, they are only used in the menu progress bars
--NOTE: only use 4 categories max, any category created after 4 will not be used
armory_addCategory("Primary Weapons",true,true,true,false)
armory_addItem("Primary Weapons","Magnum","weapon_357","models/weapons/w_357.mdl",5000,50,20,5)
armory_addItem("Primary Weapons","AR2","weapon_ar2","models/weapons/w_IRifle.mdl",4000,35,30,25)
armory_addItem("Primary Weapons","SMG","weapon_smg1","models/weapons/w_smg1.mdl",4500,25,30,30)
armory_addCategory("Grenades",true,false,false,true)
armory_addItem("Grenades","Frag Grenade","weapon_frag","models/weapons/w_grenade.mdl",1500,90,20,5)
armory_addCategory("Secondary Weapons",true,true,true,false)
armory_addItem("Secondary Weapons","RPG","weapon_rpg","models/weapons/w_rocket_launcher.mdl",6000,50,10,10)
armory_addItem("Secondary Weapons","Crossbow","weapon_crossbow","models/weapons/w_crossbow.mdl",2000,50,5,10)

--This is where you tweak each level and how it upgrades each perks
--NOTE: if a upgrade perk value is less than any default weapon perk value it will show as an orange bar
--NOTE: the damage, recoil, and clipsize upgrades do not seem to work with the default gmod weapons
ARMORY.UPGRADELEVELS = {
	{
		name = "Level 1", --name
		price = 100, --price
		killsRequired = 10, --kills required to purchase perk
		damageUpgrade = 15, --amount of damage added to weapons default damage
		recoilUpgrade = -1, --amount of recoil reduced from weapons default recoil (note: if the weapon recoil is already low, you can go negative recoil which has the opposite effect)
		clipsizeUpgrade = 5 --clipsize added to weapons default
	},
	{
		name = "Level 2",
		price = 125,
		killsRequired = 15,
		damageUpgrade = 35,
		recoilUpgrade = -5,
		clipsizeUpgrade = 7
	},
	{
		name = "Level 3",
		price = 150,
		killsRequired = 25,
		damageUpgrade = 45,
		recoilUpgrade = -9,
		clipsizeUpgrade = 10
	},
	{
		name = "Level 4",
		price = 175,
		killsRequired = 55,
		damageUpgrade = 35,
		recoilUpgrade = -15,
		clipsizeUpgrade = 15
	}, --you can add as many as you would like, just remember to put the , at the closing table tag. Just like on this line
}