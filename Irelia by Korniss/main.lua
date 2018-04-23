local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Irelia by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Irelia by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip")
	console.set_color(15)
	return
end

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = avada_lib.common
local dmglib = avada_lib.damageLib

local spellQ = {
	range = 625
}

local spellW = {
	range = 825,
	width = 120,
	speed = 2300,
	boundingRadiusMod = 1,
	delay = 0.25
}

local spellE = {
	range = 900,
	delay = 0.25,
	speed = 1800,
	width = 120,
	boundingRadiusMod = 1
}
local spellEA = {
	range = 900,
	delay = 0.25,
	speed = 3100,
	width = 120,
	boundingRadiusMod = 1
}
local spellES = {
	range = 900,
	delay = 0.25,
	speed = 100000,
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
	["MonkeyKingSpinToWin"] = {
		charName = "MonkeyKing",
		slot = 3,
		type = "circular",
		speed = math.huge,
		range = 0,
		delay = 0,
		radius = 325,
		hitbox = false,
		aoe = true,
		cc = true,
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
local interruptableSpells = {
	["anivia"] = {
		{menuslot = "R", slot = 3, spellname = "glacialstorm", channelduration = 6}
	},
	["caitlyn"] = {
		{menuslot = "R", slot = 3, spellname = "caitlynaceinthehole", channelduration = 1}
	},
	["ezreal"] = {
		{menuslot = "R", slot = 3, spellname = "ezrealtrueshotbarrage", channelduration = 1}
	},
	["fiddlesticks"] = {
		{menuslot = "W", slot = 1, spellname = "drain", channelduration = 5},
		{menuslot = "R", slot = 3, spellname = "crowstorm", channelduration = 1.5}
	},
	["gragas"] = {
		{menuslot = "W", slot = 1, spellname = "gragasw", channelduration = 0.75}
	},
	["janna"] = {
		{menuslot = "R", slot = 3, spellname = "reapthewhirlwind", channelduration = 3}
	},
	["karthus"] = {
		{menuslot = "R", slot = 3, spellname = "karthusfallenone", channelduration = 3}
	}, --common.IsValidTargetTarget will prevent from casting @ karthus while he's zombie
	["katarina"] = {
		{menuslot = "R", slot = 3, spellname = "katarinar", channelduration = 2.5}
	},
	["lucian"] = {
		{menuslot = "R", slot = 3, spellname = "lucianr", channelduration = 2}
	},
	["lux"] = {
		{menuslot = "R", slot = 3, spellname = "luxmalicecannon", channelduration = 0.5}
	},
	["malzahar"] = {
		{menuslot = "R", slot = 3, spellname = "malzaharr", channelduration = 2.5}
	},
	["masteryi"] = {
		{menuslot = "W", slot = 1, spellname = "meditate", channelduration = 4}
	},
	["missfortune"] = {
		{menuslot = "R", slot = 3, spellname = "missfortunebullettime", channelduration = 3}
	},
	["nunu"] = {
		{menuslot = "R", slot = 3, spellname = "absolutezero", channelduration = 3}
	},
	--excluding Orn's Forge Channel since it can be cancelled just by attacking him
	["pantheon"] = {
		{menuslot = "R", slot = 3, spellname = "pantheonrjump", channelduration = 2}
	},
	["shen"] = {
		{menuslot = "R", slot = 3, spellname = "shenr", channelduration = 3}
	},
	["twistedfate"] = {
		{menuslot = "R", slot = 3, spellname = "gate", channelduration = 1.5}
	},
	["varus"] = {
		{menuslot = "Q", slot = 0, spellname = "varusq", channelduration = 4}
	},
	["warwick"] = {
		{menuslot = "R", slot = 3, spellname = "warwickr", channelduration = 1.5}
	},
	["xerath"] = {
		{menuslot = "R", slot = 3, spellname = "xerathlocusofpower2", channelduration = 3}
	}
}
local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local tSelector = avada_lib.targetSelector
local menu = menu("IreliaKornis", "Irelia By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
menu.combo:header("uhhh", "-- Q Settings --")
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:slider("minq", " ^- Min. Q Range", 300, 0, 500, 1)
menu.combo:boolean("markedq", "Q only if Marked / Killable", false)
menu.combo:boolean("gapq", "Use Q for Gapclose on Minion", true)
menu.combo:boolean("outofq", " ^-Only if out of Q Range", false)
menu.combo:boolean("jumparound", "Use Q to Jump-Around Enemy on Minions", false)
menu.combo:slider("jumpmana", " ^- Mana Manager", 50, 0, 100, 1)
--menu.combo:boolean("waitq", "Wait for Mark", true)
menu.combo:header("uhhh", "-- W Settings --")
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:slider("chargew", " ^- Charge Timer", 100, 1, 1500, 1)
menu.combo:boolean("forcew", " ^- Force W if Enemy leaving range", true)
menu.combo.forcew:set("tooltip", "Forces charged W if Enemy is Leaving Range")
menu.combo:header("uhhh", "-- E Settings --")
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:dropdown("emode", "E Mode", 2, {"First", "Second"})
menu.combo.emode:set("tooltip", "Different E1 position")
menu.combo:header("uhhh", "-- R Settings --")
menu.combo:dropdown("rusage", "R Usage", 2, {"Always", "Only if Killable", "Never"})
menu.combo:slider("hitr", " ^- If Hits X Enemies", 2, 1, 5, 1)
menu.combo.hitr:set("tooltip", "Only if Usage is 'Always'")
menu.combo:slider("saver", "Don't waste R if Enemy Health Percent <=", 10, 1, 100, 1)
menu.combo:keybind("semir", "Semi-R", "T", nil)
menu.combo:boolean("items", "Use Items", true)

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:slider("minq", " ^- Min. Q Range", 220, 0, 400, 1)
menu.harass:boolean("markedq", "Q only if Marked / Killable", false)
menu.harass:boolean("gapq", "Use Q for Gapclose on Minion", true)
menu.harass:boolean("outofq", " ^-Only if out of Q Range", false)
--menu.combo:boolean("waitq", "Wait for Mark", true)
menu.harass:boolean("wcombo", "Use W in Harass", true)
menu.harass:slider("chargew", " ^- Charge Timer", 100, 1, 1500, 1)
menu.harass:boolean("forcew", " ^- Force W if Enemy leaving range", true)
menu.harass.forcew:set("tooltip", "Forces charged W if Enemy is Leaving Range")
menu.harass:boolean("ecombo", "Use E in Harass", true)

menu:menu("farming", "Farming")
menu.farming:menu("laneclear", "Lane Clear")
menu.farming.laneclear:keybind("toggle", "Farm Toggle", "Z", nil)
menu.farming.laneclear:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.farming.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.farming.laneclear:boolean("lastq", " ^-Only for Last Hit", true)
menu.farming.laneclear:boolean("turret", " ^-Don't use Q Under the Turret", true)
menu.farming.laneclear:boolean("qaa", " ^-Don't use Q in AA Range", true)
menu.farming.laneclear:boolean("farme", "Use E in Lane Clear", true)
menu.farming:menu("jungleclear", "Jungle Clear")
menu.farming.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.farming.jungleclear:boolean("markedq", " ^- Only if Marked", true)

menu.farming.jungleclear:boolean("usee", "Use E in Jungle Clear", true)
menu:menu("lasthit", "Last Hit")
menu.lasthit:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.lasthit:boolean("useq", "Use Q to Last Hit", true)
menu.lasthit:boolean("qaa", " ^-Don't use Q in AA Range", true)
menu.lasthit:boolean("turret", " ^-Don't use Q Under the Turret", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)
menu.killsteal:boolean("kse", "Killsteal with E", true)
menu.killsteal:boolean("ksr", "Killsteal with R", true)
menu.killsteal:boolean("gapq", "Use Smart Q Gapclose", true)
menu.killsteal:header("uhhh", "Q on Killable Minion > Enemy", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawtoggle", "Draw Farm Toggle", true)
menu.draws:boolean("drawkill", "Draw Minions Killable with Q", true)
menu.draws:boolean("drawgapclose", "Draw Gapclose Lines", true)
menu.draws:boolean("drawdamage", "Draw Damage", true)
menu.draws:boolean("mouse", "Draw Flee Range on Cursor", true)

menu:menu("Gap", "Gapcloser Settings")
menu.Gap:boolean("GapA", "Use E for Anti-Gapclose", true)
menu:menu("interrupt", "Interrupt Settings")
menu.interrupt:boolean("inte", "Use E to Interrupt if Possible", true)
menu.interrupt:menu("interruptmenu", "Interrupt Settings")
for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.interrupt.interruptmenu:boolean(
				string.format(tostring(enemy.charName) .. tostring(spell.menuslot)),
				"Interrupt " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
				true
			)
		end
	end
end

menu:menu("dodgew", "W Dodge")
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

			menu.dodgew[i.charName][_]:boolean("Dodge", "Enable Block", true)

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
				"Reduce Damage: " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
				true
			)
		end
	end
end

menu:menu("flee", "Flee")
menu.flee:boolean("fleeq", "Use Q to Flee", true)
menu.flee:boolean("fleekill", " ^- Only if Minion is Killable/Marked", true)
menu.flee:keybind("fleekey", "Flee Key", "G", nil)
menu.flee:boolean("fleee", "Use E in Flee", true)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end

local blade = {}
function size()
	local count = 0
	for _ in pairs(blade) do
		count = count + 1
	end
	return count
end
local first = 0
local function DeleteObj(object)
	if object then
		blade[object.ptr] = nil
	end
end
local function CreateObj(object)
	if object and object.name == "Blade" then
		blade[object.ptr] = object
		if (first == 0) then
			first = 1
			return
		end
		if first == 1 then
			common.DelayAction(
				function()
					first = 0
				end,
				0.36
			)
		end
	end
end
local TargetSelectionGap = function(res, obj, dist)
	if dist < (spellQ.range * 2) - 70 then
		res.obj = obj
		return true
	end
end

local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end
local GetTargetGap = function()
	return TS.get_result(TargetSelectionGap).obj
end
local uhh = false
local something = 0
local function Toggle()
	if menu.farming.laneclear.toggle:get() then
		if (uhh == false and os.clock() > something) then
			uhh = true
			something = os.clock() + 0.3
		end
		if (uhh == true and os.clock() > something) then
			uhh = false
			something = os.clock() + 0.3
		end
	end
end
local delayyyyyyy = 0
-- Thanks to asdf. ♡
passiveBaseScale = {
	4
}
passiveADScale = {2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4}
sheenTimer = os.clock()
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

local last_item_update = 0
local hasSheen = false
local hasTF = false
local hasBOTRK = false
local hasTitanic = false
local hasWitsEnd = false
local hasRecurve = false
local hasGuinsoo = false
function GetQDamage(target)
	local totalPhysical = 0
	local totalMagical = 0

	local flat = -10 + 20 * player:spellSlot(0).level
	local ratio = common.GetTotalAD() * 0.7
	local total = flat + ratio
	if target.type == TYPE_MINION and target.team ~= TEAM_NEUTRAL then
		total = total * 1.7
	end
	totalPhysical = total + totalPhysical
	if os.clock() > last_item_update then
		hasSheen = false
		hasTF = false
		hasBOTRK = false
		hasTitanic = false
		hasWitsEnd = false
		hasRecurve = false
		hasGuinsoo = false
		for i = 0, 5 do
			if player:itemID(i) == 3078 then
				hasTF = true
			end
			if player:itemID(i) == 3057 then
				hasSheen = true
			end
			if player:itemID(i) == 3153 then
				hasBOTRK = true
			end
			if player:itemID(i) == 3748 then
				hasTitanic = true
			end
			if player:itemID(i) == 3748 then
				hasTitanic = true
			end
			if player:itemID(i) == 3091 then
				hasWitsEnd = true
			end
			if player:itemID(i) == 1043 then
				hasRecurve = true
			end
			if player:itemID(i) == 3124 then
				hasGuinsoo = true
			end
		end
		last_item_update = os.clock() + 5
	end

	local onhitPhysical = 0
	local onhitMagical = 0

	if hasTF and (os.clock() >= sheenTimer or player.buff[sheen]) then
		onhitPhysical = onhitPhysical + 1.95 * player.baseAttackDamage
	end
	if hasSheen and not hasTF and (os.clock() >= sheenTimer or player.buff[sheen]) then
		onhitPhysical = onhitPhysical + player.baseAttackDamage
	end
	if hasBOTRK then
		if target.type == TYPE_MINION then
			onhitPhysical = onhitPhysical + math.min(math.max(15, target.health * 0.08), 60)
		else
			onhitPhysical = onhitPhysical + math.max(15, target.health * 0.08)
		end
	end
	if hasTitanic then
		if player.buff["itemtitanichydracleavebuff"] then
			onhitPhysical = onhitPhysical + 40 + player.maxHealth / 10
		else
			onhitPhysical = onhitPhysical + 5 + player.maxHealth / 100
		end
	end
	if hasRecurve then
		onhitPhysical = onhitPhysical + 10
	end
	if hasWitsEnd then
		onhitMagical = onhitMagical + 42
	end

	--passive
	if player.buff["ireliapassivestacks"] then
		local passiveTotalDmg = 1.5 + (common.GetTotalAD() - 10) * passiveADScale[player.levelRef] / 100
		passiveTotalDmg = (player.buff["ireliapassivestacks"].stacks2 + 1) * passiveTotalDmg - 10
		onhitMagical = onhitMagical + passiveTotalDmg
	end

	if hasGuinsoo then
		onhitPhysical = onhitPhysical + 5 + common.GetBonusAD(player) / 10
		onhitMagical = onhitMagical + 5 + common.GetTotalAP(player) / 10
	end

	totalPhysical = totalPhysical + onhitPhysical
	totalMagical = totalMagical + onhitMagical

	if target.type == TYPE_HERO then
		--Conqueror
		--Other Reductions
		totalPhysical = totalPhysical
		totalMagical = totalMagical
	end
	return (totalPhysical * common.PhysicalReduction(target) + totalMagical * common.MagicReduction(target)) - 20
end
local RLevelDamage = {125, 225, 325}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage = CalcADmg(target, (RLevelDamage[player:spellSlot(3).level] + (common.GetTotalAP() * .7)))
	end
	return damage
end
local ELevelDamage = {80, 120, 160, 200, 240}
function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage = CalcADmg(target, (ELevelDamage[player:spellSlot(2).level] + (common.GetTotalAP() * .8)))
	end
	return damage
end
function CalcMagicDmg(target, amount, from)
	local from = from or player
	local target = target or orb.combat.target
	local amount = amount or 0
	local targetMR = target.spellBlock * math.ceil(from.percentMagicPenetration) - from.flatMagicPenetration
	local dmgMul = 100 / (100 + targetMR)
	if dmgMul < 0 then
		dmgMul = 2 - (100 / (100 - magicResist))
	end
	amount = amount * dmgMul
	return math.floor(amount)
end
function CalcADmg(target, amount, from)
	local from = from or player or objmanager.player
	local target = target or orb.combat.target
	local amount = amount or 0
	local targetD = target.armor * math.ceil(from.percentBonusArmorPenetration)
	local dmgMul = 100 / (100 + targetD)
	amount = amount * dmgMul
	return math.floor(amount)
end

local function GetClosestMobToEnemyForGap()
	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < spellQ.range and
						minion.type == TYPE_MINION
				 then
					if minion.health < GetQDamage(minion) or minion.buff["ireliamark"] then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(enemies) < spellQ.range then
							local minionDistanceToMouse = minionPos:dist(enemies)

							if minionDistanceToMouse < closestMinionDistance then
								closestMinion = minion
								closestMinionDistance = minionDistanceToMouse
							end
						end
					end
				end
			end
		end
	end

	return closestMinion
end

local function GetClosestJungleEnemy()
	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ad", enemies)

			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < spellQ.range and
						(minion.health < GetQDamage(minion) or minion.buff["ireliamark"])
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(enemies) < spellQ.range then
						local minionDistanceToMouse = minionPos:dist(enemies)

						if minionDistanceToMouse < closestMinionDistance then
							closestMinion = minion
							closestMinionDistance = minionDistanceToMouse
						end
					end
				end
			end
		end
	end

	return closestMinion
end
local function GetClosestJungleEnemyToGap()
	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ad", enemies)
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < spellQ.range and
						(minion.health < GetQDamage(minion) or minion.buff["ireliamark"]) and
						minion.type == TYPE_MINION
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(enemies) < spellQ.range then
						local minionDistanceToMouse = minionPos:dist(enemies)

						if minionDistanceToMouse < closestMinionDistance then
							closestMinion = minion
							closestMinionDistance = minionDistanceToMouse
						end
					end
				end
			end
		end
	end

	return closestMinion
end
local waiting = 0
local chargingW = 0
local uhhh = 0
local enemy = nil
local function AutoInterrupt(spell) -- Thank you Dew for this <3
	if
		spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == player and
			not (spell.name:find("BasicAttack") or spell.name:find("crit") and not spell.owner.charName == "Karthus")
	 then
		if not player.buff["ireliawdefense"] then
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
						player:castSpell("pos", 1, player.pos)
					end
				end
			end
		end
	end

	if menu.interrupt.inte:get() then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if
						menu.interrupt.interruptmenu[spell.owner.charName .. spellCheck.menuslot]:get() and
							string.lower(spell.name) == spellCheck.spellname
					 then
						if player.pos2D:dist(spell.owner.pos2D) < spellE.range and common.IsValidTarget(spell.owner) then
							common.DelayAction(
								function()
									for _, objsq in pairs(blade) do
										if objsq and objsq.x and objsq.z and enemy then
											local pos = preds.linear.get_prediction(spellE, enemy, vec2(objsq.x, objsq.z))
											if pos and player:spellSlot(2).name == "IreliaE2" then
												local EPOS =
													objsq.pos +
													(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
														(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 300)
												if (enemy.pos:dist(objsq.pos) > 300) then
													spellE.speed = EPOS:dist(objsq.pos)
												end

												local pos2 = preds.linear.get_prediction(spellE, enemy, vec2(objsq.x, objsq.z))
												if pos2 and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 930 then
													local EPOS2 =
														objsq.pos +
														(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y) - objsq.pos):norm() *
															(objsq.pos:dist(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y)) + 300)
													player:castSpell("pos", 2, EPOS2)

													enemy = nil
												end
											end
										end
									end
								end,
								0.35
							)

							if aaaaaaaaaa < os.clock() and player:spellSlot(2).name == "IreliaE" then
								local pos2 = preds.linear.get_prediction(spellEA, spell.owner)
								if (pos2) and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 900 then
									local EPOS2 =
										spell.owner.path.serverPos +
										(((player.pos:dist(spell.owner.pos)) * -0.5 + 200 + spell.owner.path.serverPos:dist(player.path.serverPos)) /
											spell.owner.path.serverPos:dist(player.path.serverPos)) *
											(player.path.serverPos - spell.owner.path.serverPos)
									player:castSpell("pos", 2, EPOS2)
									enemy = spell.owner
								end
							end
						end
					end
				end
			end
		end
	end
	if spell.owner.charName == "Irelia" then
		if spell.name == "IreliaE" then
			aaaaaaaaaa = os.clock() + 1
			waiting = os.clock() + 1
			uhhh = os.clock() + 0.8
		end
		if spell.name == "IreliaW" then
			chargingW = os.clock()
		end
		if spell.name == "IreliaR" then
			waiting = os.clock() + 1
		end
	end
end

local function WGapcloser()
	if menu.Gap.GapA:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < spellE.range
				 then
					if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
						common.DelayAction(
							function()
								for _, objsq in pairs(blade) do
									if objsq and objsq.x and objsq.z and enemy then
										local pos = preds.linear.get_prediction(spellE, enemy, vec2(objsq.x, objsq.z))
										if pos and player:spellSlot(2).name == "IreliaE2" then
											local EPOS =
												objsq.pos +
												(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
													(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 300)
											if (enemy.pos:dist(objsq.pos) > 300) then
												spellE.speed = EPOS:dist(objsq.pos)
											end

											local pos2 = preds.linear.get_prediction(spellE, enemy, vec2(objsq.x, objsq.z))
											if pos2 and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 930 then
												local EPOS2 =
													objsq.pos +
													(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y) - objsq.pos):norm() *
														(objsq.pos:dist(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y)) + 300)
												player:castSpell("pos", 2, EPOS2)

												enemy = nil
											end
										end
									end
								end
							end,
							0.4
						)

						if aaaaaaaaaa < os.clock() and player:spellSlot(2).name == "IreliaE" then
							local pos2 = preds.linear.get_prediction(spellEA, dasher)
							if (pos2) and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 900 then
								local EPOS2 =
									dasher.path.serverPos +
									(((player.pos:dist(dasher.pos)) * -0.5 + 200 + dasher.path.serverPos:dist(player.path.serverPos)) /
										dasher.path.serverPos:dist(player.path.serverPos)) *
										(player.path.serverPos - dasher.path.serverPos)
								player:castSpell("pos", 2, EPOS2)
								enemy = dasher
							end
						end
					end
				end
			end
		end
	end
end
local function GetClosestMobKill()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion and minion.health < GetQDamage(minion) then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 400 then
				local minionDistanceToMouse = minionPos:dist(mousePos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end

local function GetClosestJungleKill()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion and minion.health < GetQDamage(minion) then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 400 then
				local minionDistanceToMouse = minionPos:dist(mousePos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end
local function GetClosestMobMark()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion and minion.buff["ireliamark"] then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 400 then
				local minionDistanceToMouse = minionPos:dist(mousePos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end

local function GetClosestJungleMark()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion and minion.buff["ireliamark"] then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 400 then
				local minionDistanceToMouse = minionPos:dist(mousePos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end
local function GetClosestMob()
	local enemyMinions = common.GetMinionsInRange(900, TEAM_ENEMY, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 400 then
				local minionDistanceToMouse = minionPos:dist(mousePos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end

local function GetClosestJungle()
	local enemyMinions = common.GetMinionsInRange(900, TEAM_NEUTRAL, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 400 then
				local minionDistanceToMouse = minionPos:dist(mousePos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end
local function Flee()
	if menu.flee.fleekey:get() then
		local target = GetTarget()
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if menu.flee.fleeq:get() then
			if not menu.flee.fleekill:get() then
				local minion = GetClosestMob()
				if minion then
					player:castSpell("obj", 0, minion)
				end
				local jungleeeee = GetClosestJungle()
				if jungleeeee then
					player:castSpell("obj", 0, jungleeeee)
				end
			end
		end
		if menu.flee.fleeq:get() then
			if menu.flee.fleekill:get() then
				local minion = GetClosestMobKill()
				if minion then
					player:castSpell("obj", 0, minion)
				end
				local jungleeeee = GetClosestJungleKill()
				if jungleeeee then
					player:castSpell("obj", 0, jungleeeee)
				end
				local minionm = GetClosestMobMark()
				if minionm then
					player:castSpell("obj", 0, minionm)
				end
				local jungleeeeem = GetClosestJungleMark()
				if jungleeeeem then
					player:castSpell("obj", 0, jungleeeeem)
				end
			end
		end
		if menu.flee.fleee:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) <= spellE.range) then
					if aaaaaaaaaa < os.clock() and player:spellSlot(2).name == "IreliaE" and player:spellSlot(2).state == 0 then
						if menu.combo.emode:get() == 1 then
							local pos2 = preds.linear.get_prediction(spellEA, target)
							if (pos2) and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 900 then
								local EPOS2 =
									target.path.serverPos +
									(((player.pos:dist(target.pos)) * -0.5 + 600 + target.path.serverPos:dist(player.path.serverPos)) /
										target.path.serverPos:dist(player.path.serverPos)) *
										(player.path.serverPos - target.path.serverPos)
								player:castSpell("pos", 2, EPOS2)
								delayyyyyyy = os.clock() + 0.5
							end
						end
						if menu.combo.emode:get() == 2 then
							-- Thanks to asdf. ♡
							if not target.path.isActive then
								if target.pos:dist(player.pos) <= 900 then
									local cast1 = player.pos + (target.pos - player.pos):norm() * 900
									player:castSpell("pos", 2, cast1)
								end
							else
								local pathStartPos = target.path.point[0]
								local pathEndPos = target.path.point[target.path.count]
								local pathNorm = (pathEndPos - pathStartPos):norm()
								local tempPred = common.GetPredictedPos(target, 1)
								if tempPred then
									local dist1 = player.pos:dist(tempPred)
									if dist1 <= 900 then
										local dist2 = player.pos:dist(target.pos)
										if dist1 < dist2 then
											pathNorm = pathNorm * -1
										end
										local cast2 = RaySetDist(target.pos, pathNorm, player.pos, 900)
										player:castSpell("pos", 2, cast2)
									end
								end
							end
							delayyyyyyy = os.clock() + 0.5
						end
					end
				end
			end
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) <= spellE.range) then
					for _, objsq in pairs(blade) do
						if objsq and objsq.x and objsq.z and not target.buff["ireliamark"] then
							local pos = preds.linear.get_prediction(spellE, target, vec2(objsq.x, objsq.z))
							if pos and player:spellSlot(2).name == "IreliaE2" then
								local EPOS =
									objsq.pos +
									(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
										(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 320)
								if (target.pos:dist(objsq.pos) > 300) then
									spellE.speed = EPOS:dist(objsq.pos)
								end

								local pos2 = preds.linear.get_prediction(spellE, target, vec2(objsq.x, objsq.z))
								if pos2 and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 930 then
									local EPOS2 =
										objsq.pos +
										(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y) - objsq.pos):norm() *
											(objsq.pos:dist(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y)) + 320)
									player:castSpell("pos", 2, EPOS2)
								end
							end
						end
					end
				end
			end
		end
	end
end

orb.combat.register_f_after_attack(
	function()
		if menu.keys.combokey:get() or menu.keys.harasskey:get() then
			if orb.combat.target then
				if
					menu.combo.items:get() and orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					for i = 6, 11 do
						local item = player:spellSlot(i).name
						if item and (item == "ItemTitanicHydraCleave" or item == "ItemTiamatCleave") and player:spellSlot(i).state == 0 then
							player:castSpell("obj", i, player)
							orb.core.set_server_pause()
							orb.combat.set_invoke_after_attack(false)
							player:attack(orb.combat.target)
							orb.core.set_server_pause()
							orb.combat.set_invoke_after_attack(false)
							return "on_after_attack_hydra"
						end
					end
				end
			end
		end
	end
)

function RaySetDist(start, path, center, dist)
	local a = start.x - center.x
	local b = start.y - center.y
	local c = start.z - center.z
	local x = path.x
	local y = path.y
	local z = path.z

	local n1 = a * x + b * y + c * z
	local n2 =
		z ^ 2 * dist ^ 2 - a ^ 2 * z ^ 2 - b ^ 2 * z ^ 2 + 2 * a * c * x * z + 2 * b * c * y * z + 2 * a * b * x * y +
		dist ^ 2 * x ^ 2 +
		dist ^ 2 * y ^ 2 -
		a ^ 2 * y ^ 2 -
		b ^ 2 * x ^ 2 -
		c ^ 2 * x ^ 2 -
		c ^ 2 * y ^ 2
	local n3 = x ^ 2 + y ^ 2 + z ^ 2

	local r1 = -(n1 + math.sqrt(n2)) / n3
	local r2 = -(n1 - math.sqrt(n2)) / n3
	local r = math.max(r1, r2)

	return start + r * path
end

local function Combo()
	local target = GetTarget()
	local mode = menu.combo.rusage:get()

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
	local delayyyyyyy = 0
	local meow = 0
	if (meow < os.clock()) then
		if common.IsValidTarget(target) then
			if menu.combo.qcombo:get() then
				if common.IsValidTarget(target) then
					if target.buff["ireliamark"] or target.health <= GetQDamage(target) then
						player:castSpell("obj", 0, target)
						meow = os.clock() + 1
					end
				end
			end
		end
	end

	if
		menu.combo.jumparound:get() and menu.combo.jumpmana:get() <= (player.mana / player.maxMana) * 100 and
			(player.health / player.maxHealth) * 100 <= 80 and
			(first == 0)
	 then
		if common.IsValidTarget(target) then
			if menu.combo.qcombo:get() then
				if common.IsValidTarget(target) then
					for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
						local minion = objManager.minions[TEAM_ENEMY][i]
						if
							minion and minion.isVisible and not minion.isDead and minion.type == TYPE_MINION and
								minion.pos:dist(player.pos) < spellQ.range and
								minion.pos:dist(target.pos) < spellQ.range - 150
						 then
							if (GetQDamage(minion) >= minion.health) and not common.is_under_tower(vec3(minion.x, minion.y, minion.z)) then
								player:castSpell("obj", 0, minion)
							end
						end
					end
				end
			end
		end
	end
	if common.IsValidTarget(target) then
		if menu.combo.ecombo:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) <= spellE.range) then
					if aaaaaaaaaa < os.clock() and player:spellSlot(2).name == "IreliaE" and player:spellSlot(2).state == 0 then
						if menu.combo.emode:get() == 1 then
							local pos2 = preds.linear.get_prediction(spellEA, target)
							if (pos2) and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 900 then
								local EPOS2 =
									target.path.serverPos +
									(((player.pos:dist(target.pos)) * -0.5 + 600 + target.path.serverPos:dist(player.path.serverPos)) /
										target.path.serverPos:dist(player.path.serverPos)) *
										(player.path.serverPos - target.path.serverPos)
								player:castSpell("pos", 2, EPOS2)
								delayyyyyyy = os.clock() + 0.5
							end
						end
						if menu.combo.emode:get() == 2 then
							local pathStartPos = target.path.point[0]
							local pathEndPos = target.path.point[target.path.count]
							local pathNorm = (pathEndPos - pathStartPos):norm()
							local tempPred = common.GetPredictedPos(target, 1.2)
							-- Thanks to asdf. ♡
							if not target.path.isActive then
								if target.pos:dist(player.pos) <= 830 then
									local cast1 = player.pos + (target.pos - player.pos):norm() * 900
									player:castSpell("pos", 2, cast1)
								end
							else
								if tempPred then
									local dist1 = player.pos:dist(tempPred)
									if dist1 <= 900 then
										local dist2 = player.pos:dist(target.pos)
										if dist1 < dist2 then
											pathNorm = pathNorm * -1
										end
										local cast2 = RaySetDist(target.pos, pathNorm, player.pos, 900)
										player:castSpell("pos", 2, cast2)
									end
								end
							end
							delayyyyyyy = os.clock() + 0.5
						end
					end
				end
			end
		end
	end
	if common.IsValidTarget(target) and target then
		if mode == 1 then
			if (target.pos:dist(player) < spellR.range) then
				local pos = preds.linear.get_prediction(spellR, target)
				if
					pos and pos.startPos:dist(pos.endPos) < spellR.range and
						menu.combo.hitr:get() <= #count_enemies_in_range(target.pos, 400)
				 then
					player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
		if mode == 2 then
			if (GetQDamage(target) + RDamage(target) * 2 + EDamage(target) >= target.health) then
				if (target.pos:dist(player) < spellR.range) then
					local pos = preds.linear.get_prediction(spellR, target)
					if
						pos and pos.startPos:dist(pos.endPos) < spellR.range and
							(target.health / target.maxHealth) * 100 >= menu.combo.saver:get()
					 then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end

	if common.IsValidTarget(target) then
		if menu.combo.ecombo:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) <= spellE.range) then
					for _, objsq in pairs(blade) do
						if objsq and objsq.x and objsq.z and not target.buff["ireliamark"] then
							local pos = preds.linear.get_prediction(spellE, target, vec2(objsq.x, objsq.z))
							if pos and player:spellSlot(2).name == "IreliaE2" then
								local EPOS =
									objsq.pos +
									(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
										(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 320)
								if (target.pos:dist(objsq.pos) > 300) then
									spellE.speed = EPOS:dist(objsq.pos)
								end

								local pos2 = preds.linear.get_prediction(spellE, target, vec2(objsq.x, objsq.z))
								if pos2 and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 930 then
									local EPOS2 =
										objsq.pos +
										(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y) - objsq.pos):norm() *
											(objsq.pos:dist(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y)) + 320)
									player:castSpell("pos", 2, EPOS2)
								end
							end
						end
					end
				end
			end
		end
	end
	local targets = GetTargetGap()
	if menu.combo.gapq:get() and menu.combo.outofq:get() then
		if common.IsValidTarget(targets) and targets then
			if (targets.pos:dist(player) > spellQ.range) then
				local minion = GetClosestMobToEnemyForGap()
				if minion and vec3(minion.x, minion.y, minion.z):dist(player.pos) <= spellQ.range then
					if player.mana > player.manaCost0 and GetQDamage(minion) >= minion.health then
						player:castSpell("obj", 0, minion)
					end
				end
			end
		end
	end
	if menu.combo.gapq:get() and not menu.combo.outofq:get() then
		if common.IsValidTarget(targets) and targets then
			if (targets.pos:dist(player) < spellQ.range * 2) then
				local minion = GetClosestMobToEnemyForGap(targets)
				if minion and vec3(minion.x, minion.y, minion.z):dist(player.pos) <= spellQ.range then
					if player.mana > player.manaCost0 and GetQDamage(minion) >= minion.health then
						if (vec3(minion.x, minion.y, minion.z):dist(targets.pos) < vec3(targets.x, targets.y, targets.z):dist(player.pos)) then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
		end
	end
	if (delayyyyyyy < os.clock()) then
		if common.IsValidTarget(target) then
			if menu.combo.qcombo:get() and not menu.combo.markedq:get() then
				if common.IsValidTarget(target) then
					--[[if not menu.combo.waitq:get() then
					if (target.pos:dist(player) < spellQ.range) then
						if target.buff["ireliamark"] then
							player:castSpell("obj", 0, target)
						end
						if (target.pos:dist(player)) > menu.combo.minq:get() then
							player:castSpell("obj", 0, target)
						end
					end
				end]]
					if not target.buff["ireliamark"] then
						if (os.clock() > waiting) then
							if (target.pos:dist(player) < spellQ.range) then
								if (target.pos:dist(player)) > menu.combo.minq:get() then
									if (first == 0) then
										player:castSpell("obj", 0, target)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if common.IsValidTarget(target) then
		if
			player:spellSlot(0).state ~= 0 or
				(player:spellSlot(0).state == 0 and target.pos:dist(player.pos) < menu.combo.minq:get())
		 then
			if menu.combo.wcombo:get() then
				if common.IsValidTarget(target) then
					if (target.pos:dist(player) <= spellW.range) then
						if not player.buff["ireliawdefense"] and target.pos:dist(player) < spellW.range - 180 then
							local pos = preds.linear.get_prediction(spellW, target)
							if pos and pos.startPos:dist(pos.endPos) < spellW.range then
								player:castSpell("pos", 1, player.pos)
							end
						end

						if player.buff["ireliawdefense"] and os.clock() - chargingW > menu.combo.chargew:get() / 1000 then
							local pos = preds.linear.get_prediction(spellW, target)
							if pos and pos.startPos:dist(pos.endPos) <= spellW.range then
								player:castSpell("release", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
						if menu.combo.forcew:get() then
							if player.buff["ireliawdefense"] then
								if (target.pos:dist(player) > spellW.range - 150) then
									local pos = preds.linear.get_prediction(spellW, target)
									if pos and pos.startPos:dist(pos.endPos) <= spellW.range + 100 then
										player:castSpell("release", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
-- Credits to Avada's Kalista. <3
function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		local pos = graphics.world_to_screen(target.pos)
		if (math.floor((GetQDamage(target) + RDamage(target) * 2 + EDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(GetQDamage(target) + RDamage(target) * 2 + EDamage(target))) ..
					" (" ..
						tostring(math.floor((GetQDamage(target) + RDamage(target) * 2 + EDamage(target)) / target.health * 100)) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if (math.floor((GetQDamage(target) + RDamage(target) * 2 + EDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(GetQDamage(target) + RDamage(target) * 2 + EDamage(target))) ..
					" (" ..
						tostring(math.floor((GetQDamage(target) + RDamage(target) * 2 + EDamage(target)) / target.health * 100)) ..
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
	--print("crashed Jungle Clear")

	local meow = 0
	if menu.farming.jungleclear.useq:get() then
		--print("crashed Jungle Clear -- Q")

		local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL)
		for i, minion in pairs(enemyMinionsQ) do
			if minion and not minion.isDead and common.IsValidTarget(minion) then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				if minionPos:dist(player.pos) <= spellQ.range then
					if (meow < os.clock()) then
						if minion.buff["ireliamark"] or minion.health <= GetQDamage(minion) then
							player:castSpell("obj", 0, minion)
							meow = os.clock() + 1
						end
					end
				end
			end
		end
	end

	if menu.farming.jungleclear.usee:get() then
		--print("crashed Jungle Clear -- E")

		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < spellE.range then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				if minionPos:dist(player.pos) <= spellE.range then
					if aaaaaaaaaa < os.clock() and player:spellSlot(2).name == "IreliaE" and player:spellSlot(2).state == 0 then
						if menu.combo.emode:get() == 2 then
							-- Thanks to asdf. ♡
							if not minion.path.isActive then
								if minion.pos:dist(player.pos) <= 900 then
									local cast1 = player.pos + (minion.pos - player.pos):norm() * 900

									player:castSpell("pos", 2, cast1)
								end
							else
								local pathStartPos = minion.path.point[0]
								local pathEndPos = minion.path.point[minion.path.count]
								local pathNorm = (pathEndPos - pathStartPos):norm()
								local tempPred = common.GetPredictedPos(minion, 1.2)
								if tempPred then
									local dist1 = player.pos:dist(tempPred)
									if dist1 <= 900 then
										local dist2 = player.pos:dist(minion.pos)
										if dist1 < dist2 then
											pathNorm = pathNorm * -1
										end
										local cast2 = RaySetDist(minion.pos, pathNorm, player.pos, 900)
										player:castSpell("pos", 2, cast2)
									end
								end
							end
							delayyyyyyy = os.clock() + 0.5
						end
					end

					for _, objsq in pairs(blade) do
						--print("crashed Jungle Clear -- E5")
						if objsq and objsq.x and objsq.z and not minion.buff["ireliamark"] then
							print("crashed Jungle Clear -- E4")
							local pos = preds.linear.get_prediction(spellE, minion, vec2(objsq.x, objsq.z))
							--print("crashed Jungle Clear -- E9999")
							if pos and player:spellSlot(2).name == "IreliaE2" then
								local EPOS =
									objsq.pos +
									(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
										(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 300)
								if (minion.pos:dist(objsq.pos) > 300) then
									spellE.speed = EPOS:dist(objsq.pos)
								end

								local pos2 = preds.linear.get_prediction(spellE, minion, vec2(objsq.x, objsq.z))
								if pos2 and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 930 then
									local EPOS2 =
										objsq.pos +
										(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y) - objsq.pos):norm() *
											(objsq.pos:dist(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y)) + 300)
									player:castSpell("pos", 2, EPOS2)
								end
							end
						end
					end
				end
			end
		end
	end
	if menu.farming.jungleclear.useq:get() then
		--print("crashed Jungle Clear -- Q2")

		local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL)
		for i, minion in pairs(enemyMinionsQ) do
			if minion and not minion.isDead and common.IsValidTarget(minion) then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				if minionPos:dist(player.pos) <= spellQ.range then
					if (delayyyyyyy < os.clock()) then
						if menu.farming.jungleclear.markedq:get() then
							if minion.buff["ireliamark"] then
								if (os.clock() > waiting) then
									if (meow < os.clock()) then
										if minion.buff["ireliamark"] or minion.health <= GetQDamage(minion) then
											player:castSpell("obj", 0, minion)
											meow = os.clock() + 1
										end
									end
								end
							end
						end
						if not menu.farming.jungleclear.markedq:get() then
							if not minion.buff["ireliamark"] then
								if (os.clock() > waiting) then
									player:castSpell("obj", 0, minion)
								end
							end
						end
					end
				end
			end
		end
	end
end

local function Harass()
	local target = GetTarget()
	local mode = menu.combo.rusage:get()
	local delayyyyyyy = 0
	local meow = 0
	if (meow < os.clock()) then
		if common.IsValidTarget(target) then
			if menu.harass.qcombo:get() then
				if common.IsValidTarget(target) then
					if target.buff["ireliamark"] then
						player:castSpell("obj", 0, target)
						meow = os.clock() + 0.5
					end
				end
			end
		end
	end

	if common.IsValidTarget(target) then
		if menu.harass.ecombo:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) <= spellE.range) then
					if aaaaaaaaaa < os.clock() and player:spellSlot(2).name == "IreliaE" and player:spellSlot(2).state == 0 then
						if menu.combo.emode:get() == 1 then
							local pos2 = preds.linear.get_prediction(spellEA, target)
							if (pos2) and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 900 then
								local EPOS2 =
									target.path.serverPos +
									(((player.pos:dist(target.pos)) * -0.5 + 600 + target.path.serverPos:dist(player.path.serverPos)) /
										target.path.serverPos:dist(player.path.serverPos)) *
										(player.path.serverPos - target.path.serverPos)
								player:castSpell("pos", 2, EPOS2)
								delayyyyyyy = os.clock() + 0.5
							end
						end
						if menu.combo.emode:get() == 2 then
							-- Thanks to asdf. ♡
							local pathStartPos = target.path.point[0]
							local pathEndPos = target.path.point[target.path.count]
							local pathNorm = (pathEndPos - pathStartPos):norm()
							local tempPred = common.GetPredictedPos(target, 1.2)
							if not target.path.isActive then
								if target.pos:dist(player.pos) <= 830 then
									local cast1 = player.pos + (target.pos - player.pos):norm() * 900
									player:castSpell("pos", 2, cast1)
								end
							else
								if tempPred then
									local dist1 = player.pos:dist(tempPred)
									if dist1 <= 900 then
										local dist2 = player.pos:dist(target.pos)
										if dist1 < dist2 then
											pathNorm = pathNorm * -1
										end
										local cast2 = RaySetDist(target.pos, pathNorm, player.pos, 900)
										player:castSpell("pos", 2, cast2)
									end
								end
							end
							delayyyyyyy = os.clock() + 0.5
						end
					end
				end
			end
		end
	end

	if common.IsValidTarget(target) then
		if menu.harass.ecombo:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) <= spellE.range) then
					for _, objsq in pairs(blade) do
						if objsq and objsq.x and objsq.z and not target.buff["ireliamark"] then
							local pos = preds.linear.get_prediction(spellE, target, vec2(objsq.x, objsq.z))
							if pos and player:spellSlot(2).name == "IreliaE2" then
								local EPOS =
									objsq.pos +
									(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
										(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 300)
								if (target.pos:dist(objsq.pos) > 300) then
									spellE.speed = EPOS:dist(objsq.pos)
								end

								local pos2 = preds.linear.get_prediction(spellE, target, vec2(objsq.x, objsq.z))
								if pos2 and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 930 then
									local EPOS2 =
										objsq.pos +
										(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y) - objsq.pos):norm() *
											(objsq.pos:dist(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y)) + 300)
									player:castSpell("pos", 2, EPOS2)
								end
							end
						end
					end
				end
			end
		end
	end
	local targets = GetTargetGap()
	if menu.harass.gapq:get() and menu.harass.outofq:get() then
		if common.IsValidTarget(targets) and targets then
			if (targets.pos:dist(player) > spellQ.range) then
				local minion = GetClosestMobToEnemyForGap()
				if minion and vec3(minion.x, minion.y, minion.z):dist(player.pos) <= spellQ.range then
					if player.mana > player.manaCost0 and GetQDamage(minion) >= minion.health then
						player:castSpell("obj", 0, minion)
					end
				end
			end
		end
	end
	if menu.harass.gapq:get() and not menu.harass.outofq:get() then
		if common.IsValidTarget(targets) and targets then
			if (targets.pos:dist(player) < spellQ.range * 2) then
				local minion = GetClosestMobToEnemyForGap()
				if minion and vec3(minion.x, minion.y, minion.z):dist(player.pos) <= spellQ.range then
					if player.mana > player.manaCost0 and GetQDamage(minion) >= minion.health then
						if (vec3(minion.x, minion.y, minion.z):dist(targets.pos) < vec3(targets.x, targets.y, targets.z):dist(player.pos)) then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
		end
	end
	if (delayyyyyyy < os.clock()) then
		if common.IsValidTarget(target) then
			if menu.harass.qcombo:get() and not menu.harass.markedq:get() then
				if common.IsValidTarget(target) then
					--[[if not menu.combo.waitq:get() then
					if (target.pos:dist(player) < spellQ.range) then
						if target.buff["ireliamark"] then
							player:castSpell("obj", 0, target)
						end
						if (target.pos:dist(player)) > menu.combo.minq:get() then
							player:castSpell("obj", 0, target)
						end
					end
				end]]
					if not target.buff["ireliamark"] then
						if (os.clock() > waiting) then
							if (target.pos:dist(player) < spellQ.range) then
								if (target.pos:dist(player)) > menu.harass.minq:get() then
									player:castSpell("obj", 0, target)
								end
							end
						end
					end
				end
			end
		end
	end
	if common.IsValidTarget(target) then
		if
			player:spellSlot(0).state ~= 0 or
				(player:spellSlot(0).state == 0 and target.pos:dist(player.pos) < menu.harass.minq:get())
		 then
			if menu.harass.wcombo:get() then
				if common.IsValidTarget(target) then
					if (target.pos:dist(player) <= spellW.range) then
						if not player.buff["ireliawdefense"] and target.pos:dist(player) < spellW.range - 100 then
							local pos = preds.linear.get_prediction(spellW, target)
							if pos and pos.startPos:dist(pos.endPos) < spellW.range then
								player:castSpell("pos", 1, player.pos)
							end
						end

						if player.buff["ireliawdefense"] and os.clock() - chargingW > menu.harass.chargew:get() / 1000 then
							local pos = preds.linear.get_prediction(spellW, target)
							if pos and pos.startPos:dist(pos.endPos) <= spellW.range then
								player:castSpell("release", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
						if menu.harass.forcew:get() then
							if player.buff["ireliawdefense"] then
								if (target.pos:dist(player) > spellW.range - 150) then
									local pos = preds.linear.get_prediction(spellW, target)
									if pos and pos.startPos:dist(pos.endPos) <= spellW.range + 100 then
										player:castSpell("release", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
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
						GetQDamage(enemies) >= hp
				 then
					player:castSpell("obj", 0, enemies)
				end
			end
			if menu.killsteal.kse:get() then
				if vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range and dmglib.GetSpellDamage(2, enemies) - 5 > hp then
					if common.IsValidTarget(enemies) then
						if common.IsValidTarget(enemies) then
							if (enemies.pos:dist(player) <= spellE.range) then
								if aaaaaaaaaa < os.clock() and player:spellSlot(2).name == "IreliaE" and player:spellSlot(2).state == 0 then
									if menu.combo.emode:get() == 1 then
										local pos2 = preds.linear.get_prediction(spellEA, enemies)
										if (pos2) and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 900 then
											local EPOS2 =
												enemies.path.serverPos +
												(((player.pos:dist(enemies.pos)) * -0.5 + 600 + enemies.path.serverPos:dist(player.path.serverPos)) /
													enemies.path.serverPos:dist(player.path.serverPos)) *
													(player.path.serverPos - enemies.path.serverPos)
											player:castSpell("pos", 2, EPOS2)
											delayyyyyyy = os.clock() + 0.5
										end
									end
									if menu.combo.emode:get() == 2 then
										-- Thanks to asdf. ♡
										if not enemies.path.isActive then
											if enemies.pos:dist(player.pos) <= 900 then
												local cast1 = player.pos + (enemies.pos - player.pos):norm() * 900
												player:castSpell("pos", 2, cast1)
											end
										else
											local pathStartPos = enemies.path.point[0]
											local pathEndPos = enemies.path.point[enemies.path.count]
											local pathNorm = (pathEndPos - pathStartPos):norm()
											local tempPred = common.GetPredictedPos(enemies, 1)
											if tempPred then
												local dist1 = player.pos:dist(tempPred)
												if dist1 <= 900 then
													local dist2 = player.pos:dist(enemies.pos)
													if dist1 < dist2 then
														pathNorm = pathNorm * -1
													end
													local cast2 = RaySetDist(enemies.pos, pathNorm, player.pos, 900)
													player:castSpell("pos", 2, cast2)
												end
											end
										end
										delayyyyyyy = os.clock() + 0.5
									end
								end
							end
						end
					end

					if (enemies.pos:dist(player) <= spellE.range) then
						for _, objsq in pairs(blade) do
							if objsq and objsq.x and objsq.z then
								local pos = preds.linear.get_prediction(spellE, enemies, vec2(objsq.x, objsq.z))
								if pos and player:spellSlot(2).name == "IreliaE2" then
									local EPOS =
										objsq.pos +
										(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
											(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 300)
									if (enemies.pos:dist(objsq.pos) > 300) then
										spellE.speed = EPOS:dist(objsq.pos)
									end

									local pos2 = preds.linear.get_prediction(spellE, enemies, vec2(objsq.x, objsq.z))
									if pos2 and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 930 then
										local EPOS2 =
											objsq.pos +
											(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y) - objsq.pos):norm() *
												(objsq.pos:dist(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y)) + 300)
										player:castSpell("pos", 2, EPOS2)
									end
								end
							end
						end
					end
				end
			end
			if menu.killsteal.ksr:get() then
				if
					player:spellSlot(3).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellR.range and
						RDamage(enemies) > hp
				 then
					local pos = preds.linear.get_prediction(spellR, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellR.range then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
			if menu.killsteal.gapq:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) > spellQ.range and
						vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range * 2 - 70 and
						GetQDamage(enemies) > hp
				 then
					local minion = GetClosestMobToEnemyForGap()
					if minion and minion.health < GetQDamage(minion) then
						player:castSpell("obj", 0, minion)
					end

					local minios = GetClosestMobToEnemyForGap()
					if minios and minion.health < GetQDamage(minion) then
						player:castSpell("obj", 0, minios)
					end
				end
			end
		end
	end
end
local function LaneClear()
	--	print("crashed Lane Clear")
	if uhh then
		return
	end
	if (player.mana / player.maxMana) * 100 >= menu.farming.laneclear.mana:get() then
		if menu.farming.laneclear.farmq:get() then
			--	print("crashed Lane Clear -- Q")
			local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
			for i, minion in pairs(enemyMinionsQ) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellQ.range then
						if not menu.farming.laneclear.lastq:get() then
							if menu.farming.laneclear.turret:get() and not common.is_under_tower(vec3(minion.x, minion.y, minion.z)) then
								player:castSpell("obj", 0, minion)
							end
							if not menu.farming.laneclear.turret:get() then
								player:castSpell("obj", 0, minion)
							end
						end
						if menu.farming.laneclear.lastq:get() and GetQDamage(minion) > minion.health then
							if menu.farming.laneclear.turret:get() and not common.is_under_tower(vec3(minion.x, minion.y, minion.z)) then
								if not menu.farming.laneclear.qaa:get() then
									player:castSpell("obj", 0, minion)
								end
								if menu.farming.laneclear.qaa:get() then
									if player.pos:dist(minion.pos) > 200 then
										player:castSpell("obj", 0, minion)
									end
								end
							end
							if not menu.farming.laneclear.turret:get() then
								if not menu.farming.laneclear.qaa:get() then
									player:castSpell("obj", 0, minion)
								end
								if menu.farming.laneclear.qaa:get() then
									if player.pos:dist(minion.pos) > 200 then
										player:castSpell("obj", 0, minion)
									end
								end
							end
						end
					end
				end
			end
		end
		if menu.farming.laneclear.farme:get() then
			--	print("crashed Lane Clear -- E")

			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < spellE.range then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellE.range then
						if aaaaaaaaaa < os.clock() and player:spellSlot(2).name == "IreliaE" and player:spellSlot(2).state == 0 then
							-- Thanks to asdf. ♡
							if not minion.path.isActive then
								if minion.pos:dist(player.pos) <= 900 then
									local cast1 = player.pos + (minion.pos - player.pos):norm() * 900

									player:castSpell("pos", 2, cast1)
								end
							else
								local pathStartPos = minion.path.point[0]
								local pathEndPos = minion.path.point[minion.path.count]
								local pathNorm = (pathEndPos - pathStartPos):norm()
								local tempPred = common.GetPredictedPos(minion, 1)
								--print("crashed Lane Clear -- E1111")
								if tempPred then
									local dist1 = player.pos:dist(tempPred)
									if dist1 <= 900 then
										local dist2 = player.pos:dist(minion.pos)
										if dist1 < dist2 then
											pathNorm = pathNorm * -1
										end
										local cast2 = RaySetDist(minion.pos, pathNorm, player.pos, 900)
										player:castSpell("pos", 2, cast2)
									end
								end
							end
							delayyyyyyy = os.clock() + 0.5
						end
						--	print("crashed Lane Clear -- E22222")

						for _, objsq in pairs(blade) do
							--		print("crashed Lane Clear -- E5")
							if objsq and objsq.x and objsq.z and not minion.buff["ireliamark"] then
								print("crashed Lane Clear -- E4")
								local pos = preds.linear.get_prediction(spellE, minion, vec2(objsq.x, objsq.z))
								--	print("crashed Lane Clear -- E9999")
								if pos and player:spellSlot(2).name == "IreliaE2" then
									--		print("crashed Lane Clear -- E3")
									local EPOS =
										objsq.pos +
										(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
											(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 300)
									if (minion.pos:dist(objsq.pos) > 300) then
										spellE.speed = EPOS:dist(objsq.pos)
									end

									local pos2 = preds.linear.get_prediction(spellE, minion, vec2(objsq.x, objsq.z))
									if pos2 and vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y):dist(player.pos) < 930 then
										local EPOS2 =
											objsq.pos +
											(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y) - objsq.pos):norm() *
												(objsq.pos:dist(vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y)) + 300)
										player:castSpell("pos", 2, EPOS2)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
local function LastHit()
	if (player.mana / player.maxMana) * 100 >= menu.lasthit.mana:get() then
		if menu.lasthit.useq:get() then
			local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
			for i, minion in pairs(enemyMinions) do
				if
					minion and not minion.isDead and minion.isVisible and player.pos:dist(minion.pos) < spellQ.range and
						GetQDamage(minion) >= minion.health
				 then
					if menu.lasthit.turret:get() and not common.is_under_tower(vec3(minion.x, minion.y, minion.z)) then
						if not menu.lasthit.qaa:get() then
							player:castSpell("obj", 0, minion)
						end
						if menu.lasthit.qaa:get() then
							if player.pos:dist(minion.pos) > 200 then
								player:castSpell("obj", 0, minion)
							end
						end
					end
					if not menu.lasthit.turret:get() then
						if not menu.lasthit.qaa:get() then
							player:castSpell("obj", 0, minion)
						end
						if menu.lasthit.qaa:get() then
							if player.pos:dist(minion.pos) > 200 then
								player:castSpell("obj", 0, minion)
							end
						end
					end
				end
			end
		end
	end
end

local function OnDraw()
	if player.isOnScreen then
		--	print("Drawings - 1")
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 50)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 50)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 50)
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 50)
		end
		if menu.draws.drawkill:get() and player:spellSlot(0).state == 0 then
			--	print("Drawings - 2")
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.type == TYPE_MINION and
						minion.pos:dist(player.pos) < spellQ.range + 300
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					local targets = GetTargetGap()
					if (GetQDamage(minion) >= minion.health) then
						graphics.draw_circle(minionPos, 100, 2, graphics.argb(255, 255, 255, 0), 50)
					end
				end
			end
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.type == TYPE_MINION and
						minion.pos:dist(player.pos) < spellQ.range + 300
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					local targets = GetTargetGap()
					if (GetQDamage(minion) >= minion.health) then
						graphics.draw_circle(minionPos, 100, 2, graphics.argb(255, 255, 255, 0), 50)
					end
				end
			end
		end
	end
	if menu.draws.drawtoggle:get() then
		--	print("Drawings - 3")
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))

		if uhh == true then
			graphics.draw_text_2D("Farm: OFF", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 218, 34, 34))
		else
			graphics.draw_text_2D("Farm: ON", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 128, 255, 0))
		end
	end

	if menu.draws.drawdamage:get() then
		--print("Drawings - 4")
		for i = 0, objManager.enemies_n - 1 do
			local enemies = objManager.enemies[i]
			if enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and player.pos:dist(enemies) < 2000 then
				DrawDamagesE(enemies)
			end
		end
	end
	if menu.draws.drawgapclose:get() and player:spellSlot(0).state == 0 then
		--print("Drawings - 5")
		local minion = GetClosestMobToEnemyForGap()
		local targets = GetTargetGap()
		--print("Drawings - 888")
		if targets then
			--print("Drawings - 999")
			if common.IsValidTarget(targets) and minion then
				--print("Drawings - 10000")
				if
					targets and (targets.pos:dist(player) < spellQ.range + spellQ.range - 50) and
						(targets.pos:dist(player)) > spellQ.range
				 then
					if player.mana > player.manaCost0 and GetQDamage(minion) >= minion.health then
						--print("Drawings - 6")
						graphics.draw_line(player, minion, 4, graphics.argb(255, 218, 34, 34))
						graphics.draw_line(minion, targets, 4, graphics.argb(255, 218, 34, 34))
					end
				end

				if
					targets and (targets.pos:dist(player) < spellQ.range + spellQ.range) and (targets.pos:dist(player)) < spellQ.range
				 then
					if player.mana > player.manaCost0 then
						if GetQDamage(minion) >= minion.health or minion.buff["ireliamark"] then
							if
								(vec3(minion.x, minion.y, minion.z):dist(targets.pos) < vec3(targets.x, targets.y, targets.z):dist(player.pos))
							 then
								--print("Drawings - 7")
								graphics.draw_line(player, minion, 4, graphics.argb(255, 218, 34, 34))
								graphics.draw_line(minion, targets, 4, graphics.argb(255, 218, 34, 34))
							end
						end
					end
				end
			end
		end
	end

	if menu.draws.mouse:get() and menu.flee.fleekey:get() then
		graphics.draw_circle(mousePos, 400, 2, graphics.argb(155, 255, 204, 204), 30)
	end

	--[[local target = GetTarget()
	if common.IsValidTarget(target) then
		if menu.combo.ecombo:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) < spellE.range) then
					local pos2 = preds.linear.get_prediction(spellES, target)
					if pos2 then
						local EPOS3 =
							target.path.serverPos +
							(((player.pos:dist(target.pos)) * -0.5 + 600 + target.path.serverPos:dist(player.path.serverPos)) /
								target.path.serverPos:dist(player.path.serverPos)) *
								(player.path.serverPos - target.path.serverPos)

						graphics.draw_circle(EPOS3, 50, 2, graphics.argb(255, 100, 204, 100), 70)
					end

					for _, objsq in pairs(blade) do
						if objsq and not objsq.isDead then
							local pos = preds.linear.get_prediction(spellE, target, vec2(objsq.x, objsq.z))
							if pos then
								local EPOS2 =
									objsq.pos +
									(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
										(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 300)
								graphics.draw_circle(EPOS2, 50, 2, graphics.argb(255, 100, 204, 204), 70)
								graphics.draw_circle(
									vec3(pos.startPos.x, mousePos.y, pos.startPos.y),
									50,
									2,
									graphics.argb(255, 100, 204, 204),
									70
								)
								graphics.draw_circle(vec3(pos.endPos.x, mousePos.y, pos.endPos.y), 50, 2, graphics.argb(255, 100, 204, 100), 70)
							end
						end
					end
				end
			end
		end
	end]]
end

local function OnTick()
	--	print("On Tick")
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
								player:castSpell("pos", 1, player.pos)
							end
						end
						if k.speed == math.huge or spell.data.spell_type == "Circular" then	
							player:castSpell("pos", 1, player.pos)
						end
					end
				end
			end
		end
	end

	if menu.combo.semir:get() then
		local target = GetTarget()
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < spellR.range) then
				local pos = preds.linear.get_prediction(spellR, target)
				if pos and pos.startPos:dist(pos.endPos) < spellR.range then
					player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
	if not player.buff["ireliawdefense"] then
		if
			menu.dodgew["Karthus" .. "R"] and menu.dodgew["Karthus" .. "R"]:get() and player.buff["karthusfallenonetarget"] and
				(player.buff["karthusfallenonetarget"].endTime - game.time) * 1000 <= 300
		 then
			player:castSpell("pos", 1, player.pos)
		end
		if
			menu.dodgew["Zed" .. "R"] and menu.dodgew["Zed" .. "R"]:get() and player.buff["zedrdeathmark"] and
				(player.buff["zedrdeathmark"].endTime - game.time) * 1000 <= 300
		 then
			player:castSpell("pos", 1, player.pos)
		end
		if
			menu.dodgew["Vladimir" .. "R"] and menu.dodgew["Vladimir" .. "R"]:get() and player.buff["vladimirhemoplaguedebuff"] and
				(player.buff["vladimirhemoplaguedebuff"].endTime - game.time) * 1000 <= 300
		 then
			player:castSpell("pos", 1, player.pos)
		end
	end
	local target = GetTarget()
	if common.IsValidTarget(target) then
		if common.IsValidTarget(target) then
			if (target.pos:dist(player) < spellE.range) then
				for _, objsq in pairs(blade) do
					if objsq and objsq.x and objsq.z then
						local pos = preds.linear.get_prediction(spellE, target, vec2(objsq.x, objsq.z))

						local EPOS =
							objsq.pos +
							(vec3(pos.endPos.x, mousePos.y, pos.endPos.y) - objsq.pos):norm() *
								(objsq.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) + 300)
						if (target.pos:dist(objsq.pos) > 500) then
							spellE.speed = EPOS:dist(objsq.pos)
						end

						if (target.pos:dist(objsq.pos) < 500) then
							spellE.speed = EPOS:dist(objsq.pos) * 0.8
						end
					end
				end
			end
		end
	end

	Flee()
	if menu.Gap.GapA:get() then
		WGapcloser()
	end
	Toggle()
	if menu.keys.lastkey:get() then
		LastHit()
	end
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

local function OnRemoveBuff(buff)
	if buff.owner.ptr == player.ptr and buff.name == "sheen" then
		sheenTimer = os.clock() + 1.7
	end
end
cb.add(cb.removebuff, OnRemoveBuff)
cb.add(cb.createobj, CreateObj)
cb.add(cb.deleteobj, DeleteObj)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
orb.combat.register_f_pre_tick(OnTick)
--cb.add(cb.tick, OnTick)
