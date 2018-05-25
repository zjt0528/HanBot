local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
if not avada_lib then
	print("")
	console.set_color(79)
	print("                                                                                        ")
	print("----------- Master Yi by Kornis -------------                                         ")
	print("You need to have Avada Lib in your community_libs folder to run this script!            ")
	print("You can find it here:                                                                   ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                               ")
	console.set_color(79)
	print("                                                                                        ")
	console.set_color(12)
	local menuerror = menu("MasterYiKornis", "Master Yi By Kornis")
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
elseif avada_lib.version < 1 then
	print("")
	console.set_color(79)
	print("                                                                                        ")
	print("----------- Master Yi by Kornis -------------                                         ")
	print("You need to have Avada Lib in your community_libs folder to run this script!            ")
	print("You can find it here:                                                                   ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                               ")
	console.set_color(79)
	print("                                                                                        ")
	console.set_color(12)
	local menuerror = menu("MasterYiKornis", "Master Yi By Kornis")
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
end

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = avada_lib.common
local dmglib = avada_lib.damageLib

local spellQ = {
	range = 600
}

local spellW = {}

local spellE = {
	range = 900,
	delay = 0.25,
	speed = 1800,
	width = 120,
	boundingRadiusMod = 1
}

local spellR = {
	range = 900,
	delay = 0.4,
	speed = 2000,
	width = 100,
	boundingRadiusMod = 1
}
local SmiteSlot = nil
local SmiteDamage = {390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000}
if player:spellSlot(5).name:find("Smite") then
	SmiteSlot = 4
end
if player:spellSlot(5).name:find("Smite") then
	SmiteSlot = 5
end
player:spellSlot(5).name:find("Smite")
local aaaaaaaaaa = 0
local dodgeWs = {
	["garen"] = {
		{menuslot = "R", slot = 3}
	},
	["darius"] = {
		{menuslot = "R", slot = 3}
	},
	["karthus"] = {
		{menuslot = "R", slot = 3}
	},
	["zed"] = {
		{menuslot = "R", slot = 3}
	},
	["vladimir"] = {
		{menuslot = "R", slot = 3}
	},
	["syndra"] = {
		{menuslot = "R", slot = 3}
	},
	["veigar"] = {
		{menuslot = "R", slot = 3}
	},
	["leesin"] = {
		{menuslot = "R", slot = 3}
	},
	["malzahar"] = {
		{menuslot = "R", slot = 3}
	},
	["tristana"] = {
		{menuslot = "R", slot = 3}
	},
	["chogath"] = {
		{menuslot = "R", slot = 3}
	},
	["lissandra"] = {
		{menuslot = "R", slot = 3}
	},
	["jarvaniv"] = {
		{menuslot = "R", slot = 3}
	},
	["skarner"] = {
		{menuslot = "R", slot = 3}
	},
	["kalista"] = {
		{menuslot = "E", slot = 2}
	},
	["brand"] = {
		{menuslot = "R", slot = 3}
	},
	["akali"] = {
		{menuslot = "R", slot = 3}
	},
	["diana"] = {
		{menuslot = "R", slot = 3}
	},
	["khazix"] = {
		{menuslot = "Q", slot = 0}
	},
	["nocturne"] = {
		{menuslot = "R", slot = 3}
	},
	["volibear"] = {
		{menuslot = "W", slot = 1}
	},
	["singed"] = {
		{menuslot = "E", slot = 2}
	},
	["nautilus"] = {
		{menuslot = "R", slot = 3}
	},
	["morgana"] = {
		{menuslot = "R", slot = 3}
	},
	["nocturne"] = {
		{menuslot = "R", slot = 3}
	},
	["vayne"] = {
		{menuslot = "E", slot = 2}
	},
	["warwick"] = {
		{menuslot = "Q", slot = 0}
	},
	["vayne"] = {
		{menuslot = "E", slot = 2}
	},
	["caitlyn"] = {
		{menuslot = "R", slot = 3}
	},
	["fiddlesticks"] = {
		{menuslot = "E", slot = 2}
	},
	["fiddlesticks"] = {
		{menuslot = "Q", slot = 0}
	},
	["kayle"] = {
		{menuslot = "Q", slot = 0}
	},
	["pantheon"] = {
		{menuslot = "W", slot = 1}
	},
	["ryze"] = {
		{menuslot = "W", slot = 1}
	},
	["teemo"] = {
		{menuslot = "Q", slot = 0}
	},
	["twistedfate"] = {
		{menuslot = "W", slot = 1}
	},
	["alistar"] = {
		{menuslot = "W", slot = 1}
	},
	["camille"] = {
		{menuslot = "R", slot = 3}
	},
	["lulu"] = {
		{menuslot = "W", slot = 1}
	},
	["poppy"] = {
		{menuslot = "E", slot = 2}
	},
	["rammus"] = {
		{menuslot = "E", slot = 2}
	},
	["tahmkench"] = {
		{menuslot = "W", slot = 1}
	},
	["vi"] = {
		{menuslot = "R", slot = 3}
	}
}
local Spells = {
	["Pulverize"] = {
		charName = "Alistar",
		slot = 0,
		type = "circular",
		speed = math.huge,
		range = 0,
		delay = 0.25,
		radius = 365,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = false
	},
	["InfernalGuardian"] = {
		charName = "Annie",
		slot = 3,
		type = "circular",
		speed = math.huge,
		range = 600,
		delay = 0.25,
		radius = 290,
		hitbox = true,
		aoe = true,
		cc = false,
		collision = false
	},
	["EkkoR"] = {
		charName = "Ekko",
		slot = 3,
		type = "circular",
		speed = 1650,
		range = 1600,
		delay = 0.25,
		radius = 375,
		hitbox = false,
		aoe = true,
		cc = false,
		collision = false
	},
	["ZoeQ"] = {
		charName = "Zoe",
		slot = 0,
		type = "linear",
		speed = 1280,
		range = 800,
		delay = 0.25,
		radius = 40,
		hitbox = true,
		aoe = false,
		cc = false,
		collision = true
	},
	["ZoeQRecast"] = {
		charName = "Zoe",
		slot = 0,
		type = "linear",
		speed = 2370,
		range = 1600,
		delay = 0,
		radius = 40,
		hitbox = true,
		aoe = false,
		cc = false,
		collision = true
	},
	["CurseoftheSadMummy"] = {
		charName = "Amumu",
		slot = 3,
		type = "circular",
		speed = math.huge,
		range = 0,
		delay = 0.25,
		radius = 550,
		hitbox = false,
		aoe = true,
		cc = true,
		collision = false
	},
	["AurelionSolR"] = {
		charName = "AurelionSol",
		slot = 3,
		type = "linear",
		speed = 4285,
		range = 1500,
		delay = 0.35,
		radius = 120,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = false
	},
	["StaticField"] = {
		charName = "Blitzcrank",
		slot = 3,
		type = "circular",
		speed = math.huge,
		range = 0,
		delay = 0.25,
		radius = 600,
		hitbox = false,
		aoe = true,
		cc = true,
		collision = false
	},
	["GalioE"] = {
		charName = "Galio",
		slot = 2,
		type = "linear",
		speeds = 1400,
		range = 650,
		delay = 0.45,
		radius = 160,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = false
	},
	["EvelynnR"] = {
		charName = "Evelynn",
		slot = 3,
		type = "conic",
		speed = math.huge,
		range = 450,
		delay = 0.35,
		angle = 180,
		hitbox = false,
		aoe = true,
		cc = false,
		collision = false
	},
	["ZacE"] = {
		charName = "Zac",
		slot = 2,
		type = "circular",
		speeds = 1330,
		range = 1800,
		delay = 0,
		radius = 300,
		hitbox = false,
		aoe = true,
		cc = true,
		collision = false
	},
	["ZacR"] = {
		charName = "Zac",
		slot = 3,
		type = "circular",
		speeds = math.huge,
		range = 1000,
		delay = 0,
		radius = 300,
		hitbox = false,
		aoe = true,
		cc = true,
		collision = false
	},
	["GnarR"] = {
		charName = "Gnar",
		slot = 3,
		type = "linear",
		speed = math.huge,
		range = 475,
		delay = 0.25,
		radius = 475,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = false
	},
	["UFSlash"] = {
		charName = "Malphite",
		slot = 3,
		type = "circular",
		speed = 2170,
		range = 1000,
		delay = 0,
		radius = 300,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = false
	},
	["RivenIzunaBlade"] = {
		charName = "Riven",
		slot = 3,
		type = "conic",
		speed = 1600,
		range = 900,
		delay = 0.25,
		angle = 50,
		hitbox = true,
		aoe = true,
		cc = false,
		collision = false
	},
	["LuxLightBinding"] = {
		charName = "Lux",
		slot = 0,
		type = "linear",
		speeds = 1200,
		range = 1175,
		delay = 0.25,
		radius = 60,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = true
	},
	["NautilusAnchorDrag"] = {
		charName = "Nautilus",
		slot = 0,
		type = "linear",
		speeds = 2000,
		range = 1100,
		delay = 0.25,
		radius = 75,
		hitbox = true,
		aoe = false,
		cc = true,
		collision = true
	},
	["GnarBigW"] = {
		charName = "Gnar",
		slot = 1,
		type = "linear",
		speeds = math.huge,
		range = 550,
		delay = 0.6,
		radius = 100,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = false
	},
	["CamilleE"] = {
		charName = "Camille",
		slot = 2,
		type = "linear",
		speeds = 1350,
		range = 800,
		delay = 0.25,
		radius = 45,
		hitbox = true,
		aoe = false,
		cc = true,
		collision = false
	},
	["SonaR"] = {
		charName = "Sona",
		slot = 3,
		type = "linear",
		speed = 2250,
		range = 900,
		delay = 0.25,
		radius = 120,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = false
	},
	["GravesChargeShot"] = {
		charName = "Graves",
		slot = 3,
		type = "linear",
		speed = 1950,
		range = 1000,
		delay = 0.25,
		radius = 100,
		hitbox = true,
		aoe = true,
		cc = false,
		collision = false
	},
	["CassiopeiaR"] = {
		charName = "Cassiopeia",
		slot = 3,
		type = "conic",
		speed = math.huge,
		range = 825,
		delay = 0.5,
		angle = 80,
		hitbox = false,
		aoe = true,
		cc = true,
		collision = false
	},
	["GravesChargeShotFxMissile"] = {
		charName = "Graves",
		slot = 3,
		type = "conic",
		speed = math.huge,
		range = 800,
		delay = 0.3,
		angle = 80,
		hitbox = true,
		aoe = true,
		cc = false,
		collision = false
	},
	["GragasR"] = {
		charName = "Gragas",
		slot = 3,
		type = "circular",
		speed = 1800,
		range = 1000,
		delay = 0.25,
		radius = 400,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = false
	},
	["TalonR"] = {
		charName = "Talon",
		slot = 3,
		type = "circular",
		speed = math.huge,
		range = 0,
		delay = 0.25,
		radius = 550,
		hitbox = false,
		aoe = true,
		cc = false,
		collision = false
	},
	["ZiggsR"] = {
		charName = "Ziggs",
		slot = 3,
		type = "circular",
		speed = 1500,
		range = 5300,
		delay = 0.375,
		radius = 550,
		hitbox = true,
		aoe = true,
		cc = false,
		collision = false
	},
	["OrianaDetonateCommand"] = {
		charName = "Orianna",
		slot = 3,
		type = "circular",
		speed = math.huge,
		range = 0,
		delay = 0.5,
		radius = 325,
		hitbox = false,
		aoe = true,
		cc = true,
		collision = false
	},
	["VarusR"] = {
		charName = "Varus",
		slot = 3,
		type = "linear",
		speed = 1850,
		range = 1075,
		delay = 0.242,
		radius = 120,
		hitbox = true,
		aoe = true,
		cc = true,
		collision = false
	}
}

local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local tSelector = avada_lib.targetSelector
local menu = menu("MasterYiKornis", "Master Yi By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
menu.combo:dropdown("qusage", "Q Usage", 2, {"Always", "Smart", "Never"})
menu.combo:boolean("wcombo", "Use W for AA Reset", true)
menu.combo:keybind("wtoggle", " ^- Toggle", "G", nil)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("rcombo", "Use R in Combo", false)
menu.combo:boolean("items", "Use Items", true)

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("wcombo", "Use W for AA Reset", true)
menu.harass:boolean("ecombo", "Use E in Harass", true)

menu:menu("farming", "Farming")
menu.farming:menu("laneclear", "Lane Clear")
menu.farming.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.farming.laneclear:slider("hitq", " ^- if Hits X", 3, 1, 6, 1)
menu.farming.laneclear:boolean("farme", "Use E in Lane Clear", true)
menu.farming:menu("jungleclear", "Jungle Clear")
menu.farming.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.farming.jungleclear:boolean("usee", "Use E in Jungle Clear", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)

menu:menu("smite", "Smite Settings")
menu.smite:boolean("smitemob", "Use Smite on Monsters", true)
menu.smite:boolean("smitechampion", "Use Smite on Champions", true)
menu.smite:boolean("savestacks", " ^- Only if 2 Stacks", true)
menu.smite:keybind("toggle", "Smite Toggle", "T", nil)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawtoggle", "Draw Toggles", true)
menu.draws:boolean("damage", "Draw Damage", true)
menu.draws:slider("includeaa", " ^- Include X AA Damage", 3, 1, 10, 1)

menu:menu("dodgew", "Q / W Dodge")
menu.dodgew:boolean("enableq", "Enable Q for Dodge", true)
menu.dodgew:boolean("enablew", "Enable W on Targeted Spells", true)

menu.dodgew:header("hello", " -- Enemy Skillshots -- ")
for _, i in pairs(Spells) do
	for l, k in pairs(common.GetEnemyHeroes()) do
		-- k = myHero
		if not Spells[_] then
			return
		end
		if i.charName == k.charName then
			if i.displayname == "" then
				i.displayname = _
			end
			if i.danger == 0 then
				i.danger = 1
			end
			if (menu.dodgew[i.charName] == nil) then
				menu.dodgew:menu(i.charName, i.charName)
			end
			menu.dodgew[i.charName]:menu(_, "" .. i.charName .. " | " .. (str[i.slot] or "?") .. " " .. _)

			menu.dodgew[i.charName][_]:boolean("Dodge", "Dodge", true)

			menu.dodgew[i.charName][_]:slider("hp", "HP to Dodge", 100, 1, 100, 5)
		end
	end
end
for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and dodgeWs[name] then
		for v = 1, #dodgeWs[name] do
			local spell = dodgeWs[name][v]
			menu.dodgew:boolean(
				string.format(tostring(enemy.charName) .. tostring(spell.menuslot)),
				"Dodge: " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
				true
			)
		end
	end
end

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)

TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist < 1200 then
		res.obj = obj
		return true
	end
end

local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end

local uhh = false
local something = 0
local uhh2 = false
local something2 = 0
local function Toggle()
	if menu.smite.toggle:get() then
		if (uhh == false and os.clock() > something) then
			uhh = true
			something = os.clock() + 0.3
		end
		if (uhh == true and os.clock() > something) then
			uhh = false
			something = os.clock() + 0.3
		end
	end
	if menu.combo.wtoggle:get() then
		if (uhh2 == false and os.clock() > something2) then
			uhh2 = true
			something2 = os.clock() + 0.3
		end
		if (uhh2 == true and os.clock() > something2) then
			uhh2 = false
			something2 = os.clock() + 0.3
		end
	end
end
local delayyyyyyy = 0
-- Thanks to asdf. ♡

local function count_enemies_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.enemies_n - 1 do
		local enemy = objManager.enemies[i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end

local QLevelDamage = {25, 60, 95, 130, 165}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculatePhysicalDamage(target, (QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAD() * 1)), player)
	end
	return damage
end
local function Smiting()
	if not uhh then
		if not player.isDead and SmiteSlot and player:spellSlot(SmiteSlot).state == 0 then
			if menu.smite.smitemob:get() then
				for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
					local minion = objManager.minions[TEAM_NEUTRAL][i]
					if
						minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
							minion.pos:dist(player.pos) <= 600 and
							minion.health <= SmiteDamage[player.levelRef]
					 then
						if minion.charName == "SRU_Baron" then
							player:castSpell("obj", SmiteSlot, minion)
						elseif
							minion.charName == "SRU_Dragon_Water" or minion.charName == "SRU_Dragon_Fire" or
								minion.charName == "SRU_Dragon_Earth" or
								minion.charName == "SRU_Dragon_Air" or
								minion.charName == "SRU_Dragon_Elder"
						 then
							player:castSpell("obj", SmiteSlot, minion)
						elseif minion.charName == "SRU_RiftHerald" then
							player:castSpell("obj", SmiteSlot, minion)
						elseif minion.charName == "SRU_Blue" then
							player:castSpell("obj", SmiteSlot, minion)
						elseif minion.charName == "SRU_Red" then
							player:castSpell("obj", SmiteSlot, minion)
						end
					end
				end
			end
		end
	end
end
local waiting = 0
local chargingW = 0
local uhhh = 0
local enemy = nil
local attacked = 0
local function AutoInterrupt(spell) -- Thank you Dew for this <3
	if
		spell and spell.owner.type == TYPE_HERO and spell.owner == player and spell.owner.team == TEAM_ALLY and
			not (spell.name:find("BasicAttack") or spell.name:find("crit"))
	 then
		if (spell.name == "Meditate") then
		end
	end
	if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == player then
		if spell.owner.charName == "TwistedFate" then
			local enemyName = string.lower(spell.owner.charName)
			if dodgeWs[enemyName] then
				for i = 1, #dodgeWs[enemyName] do
					local spellCheck = dodgeWs[enemyName][i]

					if menu.dodgew[spell.owner.charName .. spellCheck.menuslot]:get() then
						if spell.name == "GoldCardPreAttack" then
							for i = 0, objManager.enemies_n - 1 do
								local enemies = objManager.enemies[i]
								if
									enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
										player.pos:dist(enemies) < spellQ.range
								 then
									if menu.dodgew.enableq:get() then
										player:castSpell("obj", 0, enemies)
									end
								end
							end
							if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
								for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
									local minion = objManager.minions[TEAM_ENEMY][i]
									if
										minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
											minion.pos:dist(player.pos) < spellQ.range
									 then
										if menu.dodgew.enableq:get() then
											player:castSpell("obj", 0, minion)
										end
									end
								end
							end
							if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
								if menu.dodgew.enablew:get() then
									player:castSpell("self", 1)
								end
							end
						end
					end
				end
			end
		end
	end
	if
		spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == player and
			not (spell.name:find("BasicAttack") or spell.name:find("crit") and not spell.owner.charName == "Karthus")
	 then
		if not player.buff["meditate"] then
			local enemyName = string.lower(spell.owner.charName)
			if dodgeWs[enemyName] then
				for i = 1, #dodgeWs[enemyName] do
					local spellCheck = dodgeWs[enemyName][i]

					if
						menu.dodgew[spell.owner.charName .. spellCheck.menuslot]:get() and spell.slot == spellCheck.slot and
							spell.owner.charName ~= "Vladimir" and
							spell.owner.charName ~= "Karthus" and
							spell.owner.charName ~= "Zed"
					 then
						for i = 0, objManager.enemies_n - 1 do
							local enemies = objManager.enemies[i]
							if
								enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
									player.pos:dist(enemies) < spellQ.range
							 then
								if menu.dodgew.enableq:get() then
									player:castSpell("obj", 0, enemies)
								end
							end
						end
						if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
							for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
								local minion = objManager.minions[TEAM_ENEMY][i]
								if
									minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
										minion.pos:dist(player.pos) < spellQ.range
								 then
									if menu.dodgew.enableq:get() then
										player:castSpell("obj", 0, minion)
									end
								end
							end
						end
						if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
							if menu.dodgew.enablew:get() then
								player:castSpell("self", 1)
							end
						end
					end
				end
			end
		end
	end
end

local function updatebuff(buff)
	if buff.name == "Meditate" then
		if orb.combat.target then
			if
				orb.combat.target and common.IsValidTarget(orb.combat.target) and
					player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
			 then
				orb.core.set_server_pause()
				player:attack(orb.combat.target)
			end
		end
	end
end

local uhhmeow = 0
orb.combat.register_f_after_attack(
	function()
		if not orb.core.can_attack() and menu.keys.combokey:get() then
			if orb.combat.target then
				if
					orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					if menu.combo.wcombo:get() and not uhh2 and player:spellSlot(1).state == 0 then
						player:castSpell("self", 1)
						orb.combat.set_invoke_after_attack(false)
						return "waa"
					end
				end
			end
		end
		if not orb.core.can_attack() and menu.keys.harasskey:get() then
			if orb.combat.target then
				if
					orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					if menu.harass.wcombo:get() and not uhh2 and player:spellSlot(1).state == 0 then
						player:castSpell("self", 1)
						orb.combat.set_invoke_after_attack(false)
						return "waa"
					end
				end
			end
		end
	end
)

orb.combat.register_f_after_attack(
	function()
		if not orb.core.can_attack() and menu.keys.combokey:get() then
			if orb.combat.target then
				if
					orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					if menu.combo.items:get() then
						if (player.buff["doublestrike"]) then
							for i = 6, 11 do
								local item = player:spellSlot(i).name
								if item and (item == "ItemTitanicHydraCleave" or item == "ItemTiamatCleave") and player:spellSlot(i).state == 0 then
									player:castSpell("obj", i, player)
									player:attack(orb.combat.target)
									return "on_after_attack_hydra"
								end
							end
						end
						orb.combat.set_invoke_after_attack(false)
					end
				end
			end
		end
	end
)

local function Combo()
	local target = GetTarget()
	if menu.smite.smitechampion:get() and not uhh then
		if SmiteSlot then
			if menu.smite.savestacks:get() and player:spellSlot(SmiteSlot).stacks == 2 then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) < 600 then
						player:castSpell("obj", SmiteSlot, target)
					end
				end
			end
		end

		if SmiteSlot then
			if common.IsValidTarget(target) then
				player:castSpell("obj", SmiteSlot, target)
			end
		end
	end
	if common.IsValidTarget(target) then
		if menu.combo.items:get() then
			if (target.pos:dist(player) <= 650) then
				for i = 6, 11 do
					local item = player:spellSlot(i).name

					if item and (item == "ItemSwordOfFeastAndFamine") then
						player:castSpell("obj", i, target)
					end
					if item and (item == "BilgewaterCutlass") then
						player:castSpell("obj", i, target)
					end
				end
			end
		end
	end
	if menu.combo.qusage:get() == 1 then
		if common.IsValidTarget(target) then
			if (target.pos:dist(player) <= spellQ.range) then
				player:castSpell("obj", 0, target)
			end
		end
	end

	if menu.combo.qusage:get() == 2 then
		if common.IsValidTarget(target) then
			if (target.pos:dist(player) <= spellQ.range) then
				if target.path.isActive and target.path.isDashing then
					player:castSpell("obj", 0, target)
				end
				if (target.health / target.maxHealth) * 100 <= 30 then
					player:castSpell("obj", 0, target)
				end
				if (player.health / player.maxHealth) * 100 <= 30 then
					player:castSpell("obj", 0, target)
				end

				if QDamage(target) > target.health and not common.HasBuffType(target, 17) then
					player:castSpell("obj", 0, target)
				end
				if target.pos:dist(player.pos) > 400 then
					player:castSpell("obj", 0, target)
				end
			end
		end
	end
	if menu.combo.ecombo:get() then
		if orb.combat.target then
			if
				common.IsValidTarget(orb.combat.target) and
					player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
			 then
				player:castSpell("self", 2)
			end
		end
	end
	if menu.combo.rcombo:get() then
		if common.IsValidTarget(target) then
			if (target.pos:dist(player) <= 1200) then
				player:castSpell("self", 3)
			end
		end
	end
end
-- Credits to Avada's Kalista. <3
function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		local pos = graphics.world_to_screen(target.pos)
		if
			(math.floor((QDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get()) / target.health * 100) <
				100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get())) ..
					" (" ..
						tostring(
							math.floor(
								(QDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get()) / target.health * 100
							)
						) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if
			(math.floor((QDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get()) / target.health * 100) >=
				100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get())) ..
					" (" ..
						tostring(
							math.floor(
								(QDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get()) / target.health * 100
							)
						) ..
							"%)" .. "Kilable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 150, 255, 200)
			)
		end
	end
end

local function JungleClear()
	if menu.farming.jungleclear.useq:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellQ.range
			 then
				player:castSpell("obj", 0, minion)
			end
		end
	end
	if menu.farming.jungleclear.usee:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < common.GetAARange(minion)
			 then
				player:castSpell("self", 2)
			end
		end
	end
end

local function Harass()
	local target = GetTarget()
	if menu.harass.qcombo:get() then
		if common.IsValidTarget(target) then
			if (target.pos:dist(player) <= spellQ.range) then
				player:castSpell("obj", 0, target)
			end
		end
	end

	if menu.harass.ecombo:get() then
		if orb.combat.target then
			if
				common.IsValidTarget(orb.combat.target) and
					player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
			 then
				player:castSpell("self", 2)
			end
		end
	end
end
local function KillSteal()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("AD", enemies)
			if menu.killsteal.ksq:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range and
						QDamage(enemies) >= hp
				 then
					player:castSpell("obj", 0, enemies)
				end
			end
		end
	end
end
local function count_minions_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
		local enemy = objManager.minions[TEAM_ENEMY][i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end
local function LaneClear()
	if menu.farming.laneclear.farmq:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellQ.range
			 then
				if #count_minions_in_range(minion.pos, spellQ.range) >= menu.farming.laneclear.hitq:get() then
					player:castSpell("obj", 0, minion)
				end
			end
		end
	end
	if menu.farming.laneclear.farme:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < common.GetAARange(minion)
			 then
				player:castSpell("self", 2)
			end
		end
	end
end

local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 50)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, 1200, 2, menu.draws.colorr:get(), 50)
		end
	end
	if menu.draws.drawtoggle:get() then
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))

		if uhh == true then
			graphics.draw_text_2D("Smite: OFF", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 218, 34, 34))
		else
			graphics.draw_text_2D("Smite: ON", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 128, 255, 0))
		end

		if uhh2 == true then
			graphics.draw_text_2D("W AA: OFF", 18, pos.x - 20, pos.y + 20, graphics.argb(255, 218, 34, 34))
		else
			graphics.draw_text_2D("W AA: ON", 18, pos.x - 20, pos.y + 20, graphics.argb(255, 128, 255, 0))
		end
	end

	if menu.draws.damage:get() then
		for i = 0, objManager.enemies_n - 1 do
			local enemies = objManager.enemies[i]
			if enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and player.pos:dist(enemies) < 2000 then
				DrawDamagesE(enemies)
			end
		end
	end
end

local function OnTick()
	Smiting()
	for i = 1, #evade.core.active_spells do
		local spell = evade.core.active_spells[i]

		if
			spell.polygon and spell.polygon:Contains(player.path.serverPos) ~= 0 and
				(not spell.data.collision or #spell.data.collision == 0)
		 then
			for _, k in pairs(Spells) do
				if menu.dodgew[k.charName] then
					if
						spell.name:find(_:lower()) and menu.dodgew[k.charName][_].Dodge:get() and
							menu.dodgew[k.charName][_].hp:get() >= (player.health / player.maxHealth) * 100
					 then
						if spell.missile then
							if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
								for i = 0, objManager.enemies_n - 1 do
									local enemies = objManager.enemies[i]
									if
										enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
											player.pos:dist(enemies) < spellQ.range
									 then
										if menu.dodgew.enableq:get() then
											player:castSpell("obj", 0, enemies)
										end
									end
								end
								if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
									for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
										local minion = objManager.minions[TEAM_ENEMY][i]
										if
											minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
												minion.pos:dist(player.pos) < spellQ.range
										 then
											if menu.dodgew.enableq:get() then
												player:castSpell("obj", 0, minion)
											end
										end
									end
								end
								if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
									if menu.dodgew.enablew:get() then
										player:castSpell("self", 1)
									end
								end
							end
						end
						if spell.name:find(_:lower()) then
							if k.speeds == math.huge or spell.data.spell_type == "Circular" then
								for i = 0, objManager.enemies_n - 1 do
									local enemies = objManager.enemies[i]
									if
										enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
											player.pos:dist(enemies) < spellQ.range
									 then
										if menu.dodgew.enableq:get() then
											player:castSpell("obj", 0, enemies)
										end
									end
								end
								if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
									for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
										local minion = objManager.minions[TEAM_ENEMY][i]
										if
											minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
												minion.pos:dist(player.pos) < spellQ.range
										 then
											if menu.dodgew.enableq:get() then
												player:castSpell("obj", 0, minion)
											end
										end
									end
								end
								if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
									if menu.dodgew.enablew:get() then
										player:castSpell("self", 1)
									end
								end
							end
						end
						if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
							for i = 0, objManager.enemies_n - 1 do
								local enemies = objManager.enemies[i]
								if
									enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
										player.pos:dist(enemies) < spellQ.range
								 then
									if menu.dodgew.enableq:get() then
										player:castSpell("obj", 0, enemies)
									end
								end
							end
							if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
								for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
									local minion = objManager.minions[TEAM_ENEMY][i]
									if
										minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
											minion.pos:dist(player.pos) < spellQ.range
									 then
										if menu.dodgew.enableq:get() then
											player:castSpell("obj", 0, minion)
										end
									end
								end
							end
							if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
								if menu.dodgew.enablew:get() then
									player:castSpell("self", 1)
								end
							end
						end
					end
				end
			end
		end
	end

	if not player.buff["meditate"] then
		if
			menu.dodgew["Karthus" .. "R"] and menu.dodgew["Karthus" .. "R"]:get() and player.buff["karthusfallenonetarget"] and
				(player.buff["karthusfallenonetarget"].endTime - game.time) * 1000 <= 300
		 then
			for i = 0, objManager.enemies_n - 1 do
				local enemies = objManager.enemies[i]
				if
					enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
						player.pos:dist(enemies) < spellQ.range
				 then
					if menu.dodgew.enableq:get() then
						player:castSpell("obj", 0, enemies)
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if
						minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
							minion.pos:dist(player.pos) < spellQ.range
					 then
						if menu.dodgew.enableq:get() then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
				if menu.dodgew.enablew:get() then
					player:castSpell("self", 1)
				end
			end
		end
		if
			menu.dodgew["Zed" .. "R"] and menu.dodgew["Zed" .. "R"]:get() and player.buff["zedrdeathmark"] and
				(player.buff["zedrdeathmark"].endTime - game.time) * 1000 <= 300
		 then
			for i = 0, objManager.enemies_n - 1 do
				local enemies = objManager.enemies[i]
				if
					enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
						player.pos:dist(enemies) < spellQ.range
				 then
					if menu.dodgew.enableq:get() then
						player:castSpell("obj", 0, enemies)
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if
						minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
							minion.pos:dist(player.pos) < spellQ.range
					 then
						if menu.dodgew.enableq:get() then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
				if menu.dodgew.enablew:get() then
					player:castSpell("self", 1)
				end
			end
		end
		if
			menu.dodgew["Vladimir" .. "R"] and menu.dodgew["Vladimir" .. "R"]:get() and player.buff["vladimirhemoplaguedebuff"] and
				(player.buff["vladimirhemoplaguedebuff"].endTime - game.time) * 1000 <= 300
		 then
			for i = 0, objManager.enemies_n - 1 do
				local enemies = objManager.enemies[i]
				if
					enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
						player.pos:dist(enemies) < spellQ.range
				 then
					if menu.dodgew.enableq:get() then
						player:castSpell("obj", 0, enemies)
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if
						minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
							minion.pos:dist(player.pos) < spellQ.range
					 then
						if menu.dodgew.enableq:get() then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
				if menu.dodgew.enablew:get() then
					player:castSpell("self", 1)
				end
			end
		end
		if
			menu.dodgew["Nautilus" .. "R"] and menu.dodgew["Nautilus" .. "R"]:get() and player.buff["nautilusgrandlinetarget"] and
				(player.buff["nautilusgrandlinetarget"].endTime - game.time) * 1000 <= 300
		 then
			for i = 0, objManager.enemies_n - 1 do
				local enemies = objManager.enemies[i]
				if
					enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
						player.pos:dist(enemies) < spellQ.range
				 then
					if menu.dodgew.enableq:get() then
						player:castSpell("obj", 0, enemies)
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if
						minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
							minion.pos:dist(player.pos) < spellQ.range
					 then
						if menu.dodgew.enableq:get() then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
				if menu.dodgew.enablew:get() then
					player:castSpell("self", 1)
				end
			end
		end

		if
			menu.dodgew["Nocturne" .. "R"] and menu.dodgew["Nocturne" .. "R"]:get() and player.buff["nocturneparanoiadash"] and
				(player.buff["nocturneparanoiadash"].endTime - game.time) * 1000 <= 300
		 then
			for i = 0, objManager.enemies_n - 1 do
				local enemies = objManager.enemies[i]
				if
					enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
						player.pos:dist(enemies) < spellQ.range
				 then
					if menu.dodgew.enableq:get() then
						player:castSpell("obj", 0, enemies)
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if
						minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
							minion.pos:dist(player.pos) < spellQ.range
					 then
						if menu.dodgew.enableq:get() then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
			if #count_enemies_in_range(player.pos, spellQ.range) == 0 or player:spellSlot(0).state ~= 0 then
				if menu.dodgew.enablew:get() then
					player:castSpell("self", 1)
				end
			end
		end
	end

	Toggle()

	KillSteal()
	if menu.keys.clearkey:get() then
		LaneClear()
		JungleClear()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
end

cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
orb.combat.register_f_pre_tick(OnTick)
cb.add(cb.updatebuff, updatebuff)

--cb.add(cb.tick, OnTick)
