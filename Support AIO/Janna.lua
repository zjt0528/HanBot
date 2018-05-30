local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Janna by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Janna by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
end

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = avada_lib.common
local dmglib = avada_lib.damageLib

local spellQ = {
	range = 860,
	speed = 900,
	width = 120,
	delay = 0.35,
	boundingRadiusMod = 0
}

local spellW = {
	range = 620
}

local spellE = {
	range = 800
}

local spellR = {
	range = 725
}
local FlashSlot = nil
if player:spellSlot(4).name == "SummonerFlash" then
	FlashSlot = 4
elseif player:spellSlot(5).name == "SummonerFlash" then
	FlashSlot = 5
end
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

local ShildSpellsDB = {
	{charName = "Ashe", spellName = "Volley", description = "W", important = 1},
	{charName = "Caitlyn", spellName = "CaitlynPiltoverPeacemaker", description = "Q", important = 1},
	{charName = "Caitlyn", spellName = "CaitlynAceintheHole", description = "R", important = 3},
	{charName = "Corki", spellName = "PhosphorusBomb", description = "Q", important = 1},
	{charName = "Corki", spellName = "GGun", description = "E", important = 1},
	{charName = "Corki", spellName = "MissileBarrage", description = "R", important = 3},
	{charName = "Draven", spellName = "DravenSpinning", description = "Q", important = 1},
	{charName = "Draven", spellName = "DravenDoubleShot", description = "E", important = 2},
	{charName = "Draven", spellName = "DravenRCast", description = "R", important = 3},
	{charName = "Ezreal", spellName = "EzrealMysticShot", description = "Q", important = 1},
	{charName = "Ezreal", spellName = "EzrealTrueshotBarrage", description = "R", important = 3},
	{charName = "Graves", spellName = "GravesClusterShot", description = "Q", important = 1},
	{charName = "Graves", spellName = "GravesChargeShot", description = "R", important = 3},
	{charName = "Jinx", spellName = "JinxW", description = "W", important = 2},
	{charName = "Jinx", spellName = "JinxRWrapper", description = "R", important = 3},
	{charName = "KogMaw", spellName = "KogMawLivingArtillery", description = "R", important = 3},
	{charName = "Lucian", spellName = "LucianQ", description = "Q", important = 2},
	{charName = "Lucian", spellName = "LucianW", description = "W", important = 1},
	{charName = "Lucian", spellName = "LucianR", description = "R", important = 3},
	{charName = "MissFortune", spellName = "MissFortuneRicochetShot", description = "Q", important = 2},
	{charName = "MissFortune", spellName = "MissFortuneBulletTime", description = "R", important = 3},
	{charName = "Quinn", spellName = "QuinnQ", description = "Q", important = 1},
	{charName = "Quinn", spellName = "QuinnE", description = "E", important = 3},
	{charName = "Sivir", spellName = "SivirQ", description = "Q", important = 2},
	--	{charName = "Sivir", spellName = "SivirW", description = "W", important = 2},
	{charName = "Tristana", spellName = "RapidFire", description = "Q", important = 1},
	{charName = "Tristana", spellName = "RocketJump", description = "W", important = 3},
	{charName = "Twitch", spellName = "Expunge", description = "E", important = 3},
	--	{charName = "Twitch", spellName = "FullAutomatic", description = "R", important = 3}, -- new ult name ???
	{charName = "Urgot", spellName = "UrgotHeatseekingMissile", description = "Q", important = 2},
	{charName = "Urgot", spellName = "UrgotPlasmaGrenade", description = "E", important = 1},
	{charName = "Varus", spellName = "VarusQ", description = "Q", important = 3},
	{charName = "Varus", spellName = "VarusE", description = "E", important = 1},
	{charName = "Vayne", spellName = "VayneTumble", description = "Q", important = 2},
	{charName = "Vayne", spellName = "VayneCondemn", description = "E", important = 1},
	{charName = "Vayne", spellName = "VayneInquisition", description = "R", important = 3},
	{charName = "LeeSin", spellName = "BlindMonkRKick", description = "R", important = 3},
	{charName = "Nasus", spellName = "NasusQ", description = "Q", important = 2},
	{charName = "Nocturne", spellName = "NocturneParanoia", description = "R", important = 3},
	{charName = "Shaco", spellName = "TwoShivPoison", description = "E", important = 2},
	{charName = "Trundle", spellName = "TrundleTrollSmash", description = "Q", important = 2},
	{charName = "Vi", spellName = "ViE", description = "E", important = 2},
	{charName = "XinZhao", spellName = "XenZhaoComboTarget", description = "Q", important = 2},
	{charName = "Khazix", spellName = "KhazixQ", description = "Q", important = 2},
	{charName = "Khazix", spellName = "KhazixW", description = "W", important = 2},
	{charName = "MasterYi", spellName = "AlphaStrike", description = "Q", important = 1},
	{charName = "MasterYi", spellName = "WujuStyle", description = "E", important = 1},
	{charName = "Talon", spellName = "TalonNoxianDiplomacy", description = "Q", important = 1},
	{charName = "Talon", spellName = "TalonShadowAssault", description = "R", important = 3},
	{charName = "Pantheon", spellName = "PantheonQ", description = "Q", important = 2}, -- mby wrong name
	{charName = "Yasuo", spellName = "YasuoQW", description = "Q", important = 2},
	{charName = "Zed", spellName = "ZedShuriken", description = "Q", important = 1}, -- mby wrong name
	{charName = "Zed", spellName = "ZedPBAOEDummy", description = "E", important = 2}, -- mby wrong name
	{charName = "Aatrox", spellName = "AatroxW", description = "W", important = 2},
	{charName = "Darius", spellName = "DariusExecute", description = "R", important = 3},
	{charName = "Gangplank", spellName = "Parley", description = "Q", important = 1},
	{charName = "Garen", spellName = "GarenQ", description = "Q", important = 1},
	{charName = "Garen", spellName = "GarenE", description = "E", important = 2},
	{charName = "Jayce", spellName = "JayceToTheSkies", description = "Q", important = 2},
	{charName = "Jayce", spellName = "jayceshockblast", description = "2 Q", important = 2},
	{charName = "Renekton", spellName = "RenektonCleave", description = "Q", important = 2},
	{charName = "Renekton", spellName = "RenektonPreExecute", description = "W", important = 2},
	{charName = "Renekton", spellName = "RenektonSliceAndDice", description = "E", important = 2},
	{charName = "Rengar", spellName = "RengarQ", description = "Q", important = 2},
	{charName = "Rengar", spellName = "RengarE", description = "E", important = 1},
	{charName = "Rengar", spellName = "RengarR", description = "R", important = 3},
	{charName = "Riven", spellName = "RivenFengShuiEngine", description = "R", important = 3},
	{charName = "Tryndamere", spellName = "UndyingRage", description = "R", important = 3},
	{charName = "MonkeyKing", spellName = "MonkeyKingDoubleAttack", description = "Q", important = 1},
	{charName = "MonkeyKing", spellName = "MonkeyKingNimbus", description = "E", important = 2},
	{charName = "MonkeyKing", spellName = "MonkeyKingSpinToWin", description = "R", important = 3},
	{charName = "Kalista", spellName = "KalistaMysticShot", description = "Q", important = 2},
	{charName = "Kalista", spellName = "KalistaExpungeWrapper", description = "E", important = 3}
}

local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local tSelector = avada_lib.targetSelector
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Janna")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:keybind("insec", "Insec Key", "T", nil)
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)

menu:menu("harass", "Harass")

menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("wcombo", "Use W in Harass", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", false)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawr", "Draw R Range", false)
menu.draws:color("colorr", "  ^- Color", 255, 233, 121, 121)

menu:menu("misc", "Misc.")
menu.misc:menu("blacklist", "Anti-Gapclose Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu.misc:boolean("GapA", "Use Q for Anti-Gapclose", true)
menu.misc:boolean("GapAS", "Use W for Anti-Gapclose", true)
menu.misc:slider("health", " ^-Only if my Health Percent < X", 50, 1, 100, 1)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("inte", "Use Q to Interrupt", true)
menu.misc.interrupt:boolean("intr", "Use R to Interrupt", false)
menu.misc.interrupt:menu("interruptmenuq", "Q Interrupting")
menu.misc.interrupt:menu("interruptmenur", "R Interrupting")
for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.misc.interrupt.interruptmenuq:boolean(
				string.format(tostring(enemy.charName) .. tostring(spell.menuslot)),
				"Interrupt " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
				true
			)
		end
	end
end
for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.misc.interrupt.interruptmenur:boolean(
				string.format(tostring(enemy.charName) .. tostring(spell.menuslot)),
				"Interrupt " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
				false
			)
		end
	end
end

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
menu:menu("SpellsMenu", "Shielding")
menu.SpellsMenu:slider("mana", "Mana Manager", 2, 0, 100, 5)
menu.SpellsMenu:boolean("enable", "Enable Shielding", true)
menu.SpellsMenu:boolean("blockr", "Don't Cancel R to Shield", false)
menu.SpellsMenu:boolean("priority", "Priority Ally", true)
menu.SpellsMenu:menu("blacklist", "Ally Shield Blacklist")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	menu.SpellsMenu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu.SpellsMenu:header("hello", " -- Enemy Skillshots -- ")
for _, i in pairs(database) do
	for l, k in pairs(common.GetEnemyHeroes()) do
		-- k = myHero
		if not database[_] then
			return
		end
		if i.charName == k.charName then
			if i.displayname == "" then
				i.displayname = _
			end
			if i.danger == 0 then
				i.danger = 1
			end
			if (menu.SpellsMenu[i.charName] == nil) then
				menu.SpellsMenu:menu(i.charName, i.charName)
			end
			menu.SpellsMenu[i.charName]:menu(_, "" .. i.charName .. " | " .. (str[i.slot] or "?") .. " " .. _)

			menu.SpellsMenu[i.charName][_]:boolean("Dodge", "Enable Block", true)

			menu.SpellsMenu[i.charName][_]:slider("hp", "HP to Dodge", 100, 1, 100, 5)
		end
	end
end
menu.SpellsMenu:header("hello", " -- Misc. -- ")
menu.SpellsMenu:boolean("targeteteteteteed", "Shield on Targeted Spells", true)
menu.SpellsMenu:boolean("cc", "Auto Shield on CC", true)
menu.SpellsMenu:menu("BasicAttack", "Basic Attack Sielding", true)
menu.SpellsMenu.BasicAttack:boolean("aa", "Shield on Basic attack", true)
menu.SpellsMenu.BasicAttack:slider("aahp", " ^- HP to Shield", 40, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("critaa", "Shield on Crit attack", true)
menu.SpellsMenu.BasicAttack:slider("crithp", " ^- HP to Shield", 40, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("minionaa", "Shield on Minion attack", true)
menu.SpellsMenu.BasicAttack:slider("minionhp", " ^- HP to Shield", 10, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("turret", "Shield on Turret attack", true)

menu:menu("boost", "Boost Ally Damage on Spells")
menu.boost:boolean("enable", "Enable E Usage", true)
for _, i in pairs(ShildSpellsDB) do
	for l, k in pairs(common.GetAllyHeroes()) do
		-- k = myHero
		if not ShildSpellsDB[_] then
			return
		end

		if i.charName == k.charName then
			if i.displayname == "" then
				i.displayname = _
			end
			if i.danger == 0 then
				i.danger = 1
			end
			if (menu.boost[i.charName] == nil) then
				menu.boost:menu(i.charName, i.charName)
			end
			menu.boost[i.charName]:menu(i.spellName, "" .. i.charName .. " | " .. i.description .. " - " .. i.spellName)

			menu.boost[i.charName][i.spellName]:boolean("Dodge", "Enable", true)
		end
	end
end
menu.boost:menu("wset", "E on Auto Attack")
menu.boost.wset:boolean("enablee", "Enable E on Auto Attack", false)
menu.boost.wset:header("uhhh", "0 - Disabled, 1 - Biggest Priority, 5 - Lowest Priority")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	if
		allies.charName ~= "Janna" and allies.charName ~= "Twitch" and allies.charName ~= "KogMaw" and
			allies.charName ~= "Tristana" and
			allies.charName ~= "Ashe" and
			allies.charName ~= "Vayne" and
			allies.charName ~= "Varus" and
			allies.charName ~= "Xayah" and
			allies.charName ~= "Lucian" and
			allies.charName ~= "Sivir" and
			allies.charName ~= "Draven" and
			allies.charName ~= "Kalista" and
			allies.charName ~= "Caitlyn" and
			allies.charName ~= "Jinx" and
			allies.charName ~= "Ezreal"
	 then
		menu.boost.wset:slider(allies.charName, "Priority: " .. allies.charName, 0, 0, 5, 1)
	end
	if
		allies.charName == "Twitch" or allies.charName == "KogMaw" or allies.charName == "Tristana" or
			allies.charName == "Ashe" or
			allies.charName == "Vayne" or
			allies.charName == "Varus" or
			allies.charName == "Xayah" or
			allies.charName == "Lucian" or
			allies.charName == "Sivir" or
			allies.charName == "Draven" or
			allies.charName == "Kalista" or
			allies.charName == "Caitlyn" or
			allies.charName == "Jinx" or
			allies.charName == "Ezreal"
	 then
		menu.boost.wset:slider(allies.charName, "Priority: " .. allies.charName, 1, 0, 5, 1)
	end
	if allies.charName == "Janna" then
		menu.boost.wset:slider(allies.charName, "Priority: " .. allies.charName, 0, 0, 5, 1)
	end
end

local function Spellsssss(slot, vec3, vec3, networkID, isInjected)
	if (slot == 0 and isInjected == true) then
		player:castSpell("self", 0)
	end
end
local function PrioritizedAllyW()
	local heroTarget = nil
	for i = 0, objManager.allies_n - 1 do
		local hero = objManager.allies[i]
		if not player.isRecalling then
			if
				hero.team == TEAM_ALLY and not hero.isDead and menu.boost.wset[hero.charName]:get() > 0 and
					hero.pos:dist(player.pos) <= spellE.range
			 then
				if heroTarget == nil then
					heroTarget = hero
				elseif menu.boost.wset[hero.charName]:get() < menu.boost.wset[heroTarget.charName]:get() then
					heroTarget = hero
				end
			end
		end
	end

	return heroTarget
end
local PSpells = {
	"CaitlynHeadshotMissile",
	"RumbleOverheatAttack",
	"JarvanIVMartialCadenceAttack",
	"ShenKiAttack",
	"MasterYiDoubleStrike",
	"sonahymnofvalorattackupgrade",
	"sonaariaofperseveranceupgrade",
	"sonasongofdiscordattackupgrade",
	"NocturneUmbraBladesAttack",
	"NautilusRavageStrikeAttack",
	"ZiggsPassiveAttack",
	"QuinnWEnhanced",
	"LucianPassiveAttack",
	"SkarnerPassiveAttack",
	"KarthusDeathDefiedBuff",
	"GarenQAttack",
	"KennenMegaProc",
	"MordekaiserQAttack",
	"MordekaiserQAttack2",
	"BlueCardPreAttack",
	"RedCardPreAttack",
	"GoldCardPreAttack",
	"XenZhaoThrust",
	"XenZhaoThrust2",
	"XenZhaoThrust3",
	"ViktorQBuff",
	"TrundleQ",
	"RenektonSuperExecute",
	"RenektonExecute",
	"GarenSlash2",
	"frostarrow",
	"SivirWAttack",
	"rengarnewpassivebuffdash",
	"YorickQAttack",
	"ViEAttack",
	"SejuaniBasicAttackW",
	"ShyvanaDoubleAttackHit",
	"ShenQAttack",
	"SonaEAttackUpgrade",
	"SonaWAttackUpgrade",
	"SonaQAttackUpgrade",
	"PoppyPassiveAttack",
	"NidaleeTakedownAttack",
	"NasusQAttack",
	"KindredBasicAttackOverrideLightbombFinal",
	"LeonaShieldOfDaybreakAttack",
	"KassadinBasicAttack3",
	"JhinPassiveAttack",
	"JayceHyperChargeRangedAttack",
	"JaycePassiveRangedAttack",
	"JaycePassiveMeleeAttack",
	"illaoiwattack",
	"hecarimrampattack",
	"DrunkenRage",
	"GalioPassiveAttack",
	"FizzWBasicAttack",
	"FioraEAttack",
	"EkkoEAttack",
	"ekkobasicattackp3",
	"MasochismAttack",
	"DravenSpinningAttack",
	"DianaBasicAttack3",
	"DariusNoxianTacticsONHAttack",
	"CamilleQAttackEmpowered",
	"CamilleQAttack",
	"PowerFistAttack",
	"AsheQAttack",
	"jinxqattack",
	"jinxqattack2",
	"KogMawBioArcaneBarrage"
}
local function AutoInterrupt(spell)
	if menu.boost.wset.enablee:get() then
		local heroTarget = nil
		if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY and spell.target.type == TYPE_HERO then
			for i = 1, #PSpells do
				if
					spell.name:lower():find(PSpells[i]:lower()) and spell.owner.pos:dist(player.pos) <= spellE.range and
						menu.boost.wset[spell.owner.charName]:get() > 0
				 then
					if heroTarget == nil then
						heroTarget = spell.owner
					elseif menu.boost.wset[spell.owner.charName]:get() < menu.boost.wset[heroTarget.charName]:get() then
						heroTarget = spell.owner
					end
					if (heroTarget) then
						player:castSpell("obj", 2, heroTarget)
					end
				end
			end
			if
				spell.name:find("BasicAttack") and spell.owner.pos:dist(player.pos) <= spellE.range and
					menu.boost.wset[spell.owner.charName]:get() > 0
			 then
				if heroTarget == nil then
					heroTarget = spell.owner
				elseif menu.boost.wset[spell.owner.charName]:get() < menu.boost.wset[heroTarget.charName]:get() then
					heroTarget = spell.owner
				end
				if (heroTarget) then
					player:castSpell("obj", 2, heroTarget)
				end
			end
		end
	end
	if (player.mana / player.maxMana) * 100 >= menu.SpellsMenu.mana:get() then
		if menu.SpellsMenu.blockr:get() then
			if not player.buff["reapthewhirlwind"] then
				if menu.SpellsMenu.targeteteteteteed:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
									if not spell.name:find("crit") then
										if not spell.name:find("BasicAttack") then
											if menu.SpellsMenu.targeteteteteteed:get() then
												if ally.pos:dist(player.pos) <= spellE.range then
													player:castSpell("obj", 2, ally)
												end
											end
										end
									end
								end
							end
						end
					end
				end
				if menu.SpellsMenu.BasicAttack.aa:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally and ally.pos:dist(player.pos) <= spellE.range then
							if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
								for i = 1, #PSpells do
									if spell.name:lower():find(PSpells[i]:lower()) then
										if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
											if not menu.SpellsMenu.blacklist[ally.charName]:get() then
												if ally.pos:dist(player.pos) <= spellE.range then
													player:castSpell("obj", 2, ally)
												end
											end
										end
									end
								end
								if spell.name:find("BasicAttack") then
									if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
										if not menu.SpellsMenu.blacklist[ally.charName]:get() then
											if ally.pos:dist(player.pos) <= spellE.range then
												player:castSpell("obj", 2, ally)
											end
										end
									end
								end
							end
						end
					end
				end
				if menu.SpellsMenu.BasicAttack.critaa:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally and ally.pos:dist(player.pos) <= spellE.range then
							if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
								if spell.name:find("crit") then
									if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.crithp:get() then
										if not menu.SpellsMenu.blacklist[ally.charName]:get() then
											if ally.pos:dist(player.pos) <= spellE.range then
												player:castSpell("obj", 2, ally)
											end
										end
									end
								end
							end
						end
					end
				end
				if menu.SpellsMenu.BasicAttack.minionaa:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally and ally.pos:dist(player.pos) <= spellE.range then
							if spell.owner.type == TYPE_MINION and spell.owner.team == TEAM_ENEMY and spell.target == ally then
								if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.minionhp:get() then
									if not menu.SpellsMenu.blacklist[ally.charName]:get() then
										if ally.pos:dist(player.pos) <= spellE.range then
											player:castSpell("obj", 2, ally)
										end
									end
								end
							end
						end
					end
				end
				if menu.SpellsMenu.BasicAttack.turret:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally and ally.pos:dist(player.pos) <= spellE.range then
							if spell.owner.type == TYPE_TURRET and spell.owner.team == TEAM_ENEMY and spell.target == ally then
								if not menu.SpellsMenu.blacklist[ally.charName]:get() then
									if ally.pos:dist(player.pos) <= spellE.range then
										player:castSpell("obj", 2, ally)
									end
								end
							end
						end
					end
				end
			end
		end
		if not menu.SpellsMenu.blockr:get() then
			if menu.SpellsMenu.targeteteteteteed:get() then
				local allies = common.GetAllyHeroes()
				for z, ally in ipairs(allies) do
					if ally then
						if not menu.SpellsMenu.blacklist[ally.charName]:get() then
							if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
								if not spell.name:find("crit") then
									if not spell.name:find("BasicAttack") then
										if menu.SpellsMenu.targeteteteteteed:get() then
											if ally.pos:dist(player.pos) <= spellE.range then
												player:castSpell("obj", 2, ally)
											end
										end
									end
								end
							end
						end
					end
				end
			end
			if menu.SpellsMenu.BasicAttack.aa:get() then
				local allies = common.GetAllyHeroes()
				for z, ally in ipairs(allies) do
					if ally and ally.pos:dist(player.pos) <= spellE.range then
						if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
							for i = 1, #PSpells do
								if spell.name:lower():find(PSpells[i]:lower()) then
									if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
										if not menu.SpellsMenu.blacklist[ally.charName]:get() then
											if ally.pos:dist(player.pos) <= spellE.range then
												player:castSpell("obj", 2, ally)
											end
										end
									end
								end
							end
							if spell.name:find("BasicAttack") then
								if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
									if not menu.SpellsMenu.blacklist[ally.charName]:get() then
										if ally.pos:dist(player.pos) <= spellE.range then
											player:castSpell("obj", 2, ally)
										end
									end
								end
							end
						end
					end
				end
			end
			if menu.SpellsMenu.BasicAttack.critaa:get() then
				local allies = common.GetAllyHeroes()
				for z, ally in ipairs(allies) do
					if ally and ally.pos:dist(player.pos) <= spellE.range then
						if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
							if spell.name:find("crit") then
								if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.crithp:get() then
									if not menu.SpellsMenu.blacklist[ally.charName]:get() then
										if ally.pos:dist(player.pos) <= spellE.range then
											player:castSpell("obj", 2, ally)
										end
									end
								end
							end
						end
					end
				end
			end
			if menu.SpellsMenu.BasicAttack.minionaa:get() then
				local allies = common.GetAllyHeroes()
				for z, ally in ipairs(allies) do
					if ally and ally.pos:dist(player.pos) <= spellE.range then
						if spell.owner.type == TYPE_MINION and spell.owner.team == TEAM_ENEMY and spell.target == ally then
							if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.minionhp:get() then
								if not menu.SpellsMenu.blacklist[ally.charName]:get() then
									if ally.pos:dist(player.pos) <= spellE.range then
										player:castSpell("obj", 2, ally)
									end
								end
							end
						end
					end
				end
			end
			if menu.SpellsMenu.BasicAttack.turret:get() then
				local allies = common.GetAllyHeroes()
				for z, ally in ipairs(allies) do
					if ally and ally.pos:dist(player.pos) <= spellE.range then
						if spell.owner.type == TYPE_TURRET and spell.owner.team == TEAM_ENEMY and spell.target == ally then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if ally.pos:dist(player.pos) <= spellE.range then
									player:castSpell("obj", 2, ally)
								end
							end
						end
					end
				end
			end
		end
	end
	if menu.misc.interrupt.inte:get() then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if
						menu.misc.interrupt.interruptmenuq[spell.owner.charName .. spellCheck.menuslot]:get() and
							string.lower(spell.name) == spellCheck.spellname
					 then
						if player.pos2D:dist(spell.owner.pos2D) < spellQ.range and common.IsValidTarget(spell.owner) then
							local pos = preds.linear.get_prediction(spellQ, spell.owner)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								common.DelayAction(
									function()
										player:castSpell("self", 0)
									end,
									0.2
								)
							end
						end
					end
				end
			end
		end
	end
	if menu.misc.interrupt.intr:get() and player:spellSlot(3).state == 0 then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if
						menu.misc.interrupt.interruptmenur[spell.owner.charName .. spellCheck.menuslot]:get() and
							string.lower(spell.name) == spellCheck.spellname
					 then
						if
							player.pos2D:dist(spell.owner.pos2D) < spellR.range and common.IsValidTarget(spell.owner) and
								player:spellSlot(3).state == 0
						 then
							player:castSpell("self", 3)
						end
					end
				end
			end
		end
	end
	if menu.boost.enable:get() then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY then
			local allies = common.GetAllyHeroes()
			for z, ally in ipairs(allies) do
				if ally then
					for _, k in pairs(ShildSpellsDB) do
						if spell.name:find(k.spellName) and menu.boost[k.charName][k.spellName].Dodge:get() and spell.owner == ally then
							if ally.pos:dist(player.pos) < spellE.range then
								if ally.pos:dist(player.pos) <= spellE.range then
									player:castSpell("obj", 2, ally)
								end
							end
						end
					end
				end
			end
		end
	end
end

local function WGapcloser()
	if player:spellSlot(0).state == 0 and menu.misc.GapA:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < 800
				 then
					if menu.misc.blacklist[dasher.charName] and not menu.misc.blacklist[dasher.charName]:get() then
						if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
							if ((player.health / player.maxHealth) * 100 <= menu.misc.health:get()) then
								local pos = preds.linear.get_prediction(spellQ, dasher)
								if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									common.DelayAction(
										function()
											player:castSpell("self", 0)
										end,
										0.2
									)
								end
							end
						end
					end
				end
			end
		end
	end
	if player:spellSlot(1).state == 0 and menu.misc.GapAS:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < spellW.range
				 then
					if menu.misc.blacklist[dasher.charName] and not menu.misc.blacklist[dasher.charName]:get() then
						if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
							if ((player.health / player.maxHealth) * 100 <= menu.misc.health:get()) then
								player:castSpell("obj", 1, dasher)
							end
						end
					end
				end
			end
		end
	end
end
local TargetSelectionInsec = function(res, obj, dist)
	if dist < spellR.range + 410 then
		res.obj = obj
		return true
	end
end
local GetTargetInsec = function()
	return TS.get_result(TargetSelectionInsec).obj
end
local TargetSelectionQ = function(res, obj, dist)
	if dist < spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetQ = function()
	return TS.get_result(TargetSelectionQ).obj
end

local TargetSelectionW = function(res, obj, dist)
	if dist < spellW.range then
		res.obj = obj
		return true
	end
end
local GetTargetW = function()
	return TS.get_result(TargetSelectionW).obj
end
local function count_allies_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.allies_n - 1 do
		local enemy = objManager.allies[i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end

local function Harass()
	if not player.buff["reapthewhirlwind"] then
		if menu.harass.qcombo:get() then
			local target = GetTargetQ()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
		if menu.harass.wcombo:get() then
			local target = GetTargetW()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) <= spellW.range then
						player:castSpell("obj", 1, target)
					end
				end
			end
		end
	end
end
local function Combo()
	if not player.buff["reapthewhirlwind"] then
		if menu.combo.qcombo:get() then
			local target = GetTargetQ()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
		if menu.combo.wcombo:get() then
			local target = GetTargetW()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) <= spellW.range then
						player:castSpell("obj", 1, target)
					end
				end
			end
		end
	end
end

local function Insec()
	player:move(mousePos)
	local target = GetTargetInsec()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if target.pos:dist(player.pos) <= 380 then
				if (FlashSlot and player:spellSlot(FlashSlot).state == 0 and player:spellSlot(3).state == 0) then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally and ally.pos:dist(player.pos) <= 1000 and ally ~= player then
							local direction = (target.pos - ally.pos):norm()
							local extendedPos = target.pos - direction * -100
							player:castSpell("pos", FlashSlot, extendedPos)
							player:castSpell("self", 3)
						end
					end
					if (#count_allies_in_range(player.pos, 1000)) == 1 then
						local direction = (target.pos - player.pos):norm()
						local extendedPos = target.pos - direction * -100
						player:castSpell("pos", FlashSlot, extendedPos)
						player:castSpell("self", 3)
					end
				end
			end
		end
	end
end
local allow = true

local function OnTick()
	if not evade then
		print(" ")
		console.set_color(79)
		print("-----------Support AIO--------------")
		print("You need to have enabled 'Premium Evade' for Shielding Champions.")
		print("If you don't want Evade to dodge, disable dodging but keep Module enabled. :>")
		print("------------------------------------")
		console.set_color(12)
	end
	if player.buff["reapthewhirlwind"] then
		orb.core.set_pause_move(math.huge)
		orb.core.set_pause_attack(math.huge)
		if (evade) then
			evade.core.set_pause(math.huge)
		end
	else
		orb.core.set_pause_move(0)
		orb.core.set_pause_attack(0)
		if (evade) then
			evade.core.set_pause(0)
		end
	end
	WGapcloser()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.insec:get() then
		Insec()
	end
	if not player.isRecalling then
		if (player.mana / player.maxMana) * 100 >= menu.SpellsMenu.mana:get() then
			if menu.SpellsMenu.blockr:get() then
				if not player.buff["reapthewhirlwind"] then
					if menu.SpellsMenu.cc:get() then
						local allies = common.GetAllyHeroes()
						for z, ally in ipairs(allies) do
							if ally then
								if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
									if
										(ally.buff[5] or ally.buff[8] or ally.buff[24] or ally.buff[23] or ally.buff[11] or ally.buff[22] or
											ally.buff[8] or
											ally.buff[21])
									 then
										if ally.pos:dist(player.pos) <= spellE.range then
											player:castSpell("obj", 2, ally)
										end
									end
								end
							end
						end
					end
					if menu.SpellsMenu.enable:get() then
						for i = 1, #evade.core.active_spells do
							local spell = evade.core.active_spells[i]
							if menu.SpellsMenu.priority:get() then
								local allies = common.GetAllyHeroes()
								for z, ally in ipairs(allies) do
									if ally and ally.pos:dist(player.pos) <= spellE.range and ally ~= player then
										if not menu.SpellsMenu.blacklist[ally.charName]:get() then
											if (spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0) then
												allow = false
											else
												allow = true
											end

											if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
												if not spell.name:find("crit") then
													if not spell.name:find("basicattack") then
														if menu.SpellsMenu.targeteteteteteed:get() then
															if ally.pos:dist(player.pos) <= spellE.range then
																player:castSpell("obj", 2, ally)
															end
														end
													end
												end
											elseif
												spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0 and
													(not spell.data.collision or #spell.data.collision == 0)
											 then
												for _, k in pairs(database) do
													if menu.SpellsMenu[k.charName] then
														if
															spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
																menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
														 then
															if ally.pos:dist(player.pos) <= spellE.range then
																if ally ~= player then
																	if spell.missile then
																		if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																			if ally.pos:dist(player.pos) <= spellE.range then
																				player:castSpell("obj", 2, ally)
																			end
																		end
																	end
																	if spell.name:find(_:lower()) then
																		if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																			if ally.pos:dist(player.pos) <= spellE.range then
																				player:castSpell("obj", 2, ally)
																			end
																		end
																	end
																	if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
																		if ally.pos:dist(player.pos) <= spellE.range then
																			player:castSpell("obj", 2, ally)
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
								end
								for z, ally in ipairs(allies) do
									if ally and ally == player and allow then
										if not menu.SpellsMenu.blacklist[ally.charName]:get() then
											if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
												if not spell.name:find("crit") then
													if not spell.name:find("basicattack") then
														if menu.SpellsMenu.targeteteteteteed:get() then
															if ally.pos:dist(player.pos) <= spellE.range then
																player:castSpell("obj", 2, ally)
															end
														end
													end
												end
											elseif
												spell.polygon and spell.polygon:Contains(player.path.serverPos) ~= 0 and
													(not spell.data.collision or #spell.data.collision == 0)
											 then
												for _, k in pairs(database) do
													if ally == player then
														if menu.SpellsMenu[k.charName] then
															if
																spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and
																	menu.SpellsMenu[k.charName][_].Dodge:get() and
																	menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
															 then
																if player.pos:dist(player.pos) <= spellE.range then
																	if spell.missile then
																		if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																			player:castSpell("obj", 2, player)
																		end
																	end
																	if spell.name:find(_:lower()) then
																		if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																			player:castSpell("obj", 2, player)
																		end
																	end
																	if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
																		player:castSpell("obj", 2, player)
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
							end

							if not menu.SpellsMenu.priority:get() then
								local allies = common.GetAllyHeroes()
								for z, ally in ipairs(allies) do
									if ally then
										if not menu.SpellsMenu.blacklist[ally.charName]:get() then
											if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
												if not spell.name:find("crit") then
													if not spell.name:find("basicattack") then
														if menu.SpellsMenu.targeteteteteteed:get() then
															if ally.pos:dist(player.pos) <= spellE.range then
																player:castSpell("obj", 2, ally)
															end
														end
													end
												end
											elseif
												spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0 and
													(not spell.data.collision or #spell.data.collision == 0)
											 then
												for _, k in pairs(database) do
													if
														spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
															menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
													 then
														if ally.pos:dist(player.pos) <= spellE.range then
															if spell.missile then
																if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																	if ally.pos:dist(player.pos) <= spellE.range then
																		player:castSpell("obj", 2, ally)
																	end
																end
															end
															if spell.name:find(_:lower()) then
																if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																	if ally.pos:dist(player.pos) <= spellE.range then
																		player:castSpell("obj", 2, ally)
																	end
																end
															end
															if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
																if ally.pos:dist(player.pos) <= spellE.range then
																	player:castSpell("obj", 2, ally)
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
						end
					end
				end
			end
			if not menu.SpellsMenu.blockr:get() then
				if menu.SpellsMenu.cc:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally then
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if
									(ally.buff[5] or ally.buff[8] or ally.buff[24] or ally.buff[23] or ally.buff[11] or ally.buff[22] or
										ally.buff[8] or
										ally.buff[21])
								 then
									if ally.pos:dist(player.pos) <= spellE.range then
										player:castSpell("obj", 2, ally)
									end
								end
							end
						end
					end
				end
				if menu.SpellsMenu.enable:get() then
					for i = 1, #evade.core.active_spells do
						local spell = evade.core.active_spells[i]
						if menu.SpellsMenu.priority:get() then
							local allies = common.GetAllyHeroes()
							for z, ally in ipairs(allies) do
								if ally and ally.pos:dist(player.pos) <= spellE.range and ally ~= player then
									if not menu.SpellsMenu.blacklist[ally.charName]:get() then
										if (spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0) then
											allow = false
										else
											allow = true
										end

										if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
											if not spell.name:find("crit") then
												if not spell.name:find("basicattack") then
													if menu.SpellsMenu.targeteteteteteed:get() then
														if ally.pos:dist(player.pos) <= spellE.range then
															player:castSpell("obj", 2, ally)
														end
													end
												end
											end
										elseif
											spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0 and
												(not spell.data.collision or #spell.data.collision == 0)
										 then
											for _, k in pairs(database) do
												if menu.SpellsMenu[k.charName] then
													if
														spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
															menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
													 then
														if ally.pos:dist(player.pos) <= spellE.range then
															if ally ~= player then
																if spell.missile then
																	if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																		if ally.pos:dist(player.pos) <= spellE.range then
																			player:castSpell("obj", 2, ally)
																		end
																	end
																end
																if spell.name:find(_:lower()) then
																	if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																		if ally.pos:dist(player.pos) <= spellE.range then
																			player:castSpell("obj", 2, ally)
																		end
																	end
																end
																if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
																	if ally.pos:dist(player.pos) <= spellE.range then
																		player:castSpell("obj", 2, ally)
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
							end
							for z, ally in ipairs(allies) do
								if ally and ally == player and allow then
									if not menu.SpellsMenu.blacklist[ally.charName]:get() then
										if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
											if not spell.name:find("crit") then
												if not spell.name:find("basicattack") then
													if menu.SpellsMenu.targeteteteteteed:get() then
														if ally.pos:dist(player.pos) <= spellE.range then
															player:castSpell("obj", 2, ally)
														end
													end
												end
											end
										elseif
											spell.polygon and spell.polygon:Contains(player.path.serverPos) ~= 0 and
												(not spell.data.collision or #spell.data.collision == 0)
										 then
											for _, k in pairs(database) do
												if ally == player then
													if menu.SpellsMenu[k.charName] then
														if
															spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
																menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
														 then
															if player.pos:dist(player.pos) <= spellE.range then
																if spell.missile then
																	if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																		player:castSpell("obj", 2, player)
																	end
																end
																if spell.name:find(_:lower()) then
																	if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																		player:castSpell("obj", 2, player)
																	end
																end
																if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
																	player:castSpell("obj", 2, player)
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
						end

						if not menu.SpellsMenu.priority:get() then
							local allies = common.GetAllyHeroes()
							for z, ally in ipairs(allies) do
								if ally then
									if not menu.SpellsMenu.blacklist[ally.charName]:get() then
										if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
											if not spell.name:find("crit") then
												if not spell.name:find("basicattack") then
													if menu.SpellsMenu.targeteteteteteed:get() then
														if ally.pos:dist(player.pos) <= spellE.range then
															player:castSpell("obj", 2, ally)
														end
													end
												end
											end
										elseif
											spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0 and
												(not spell.data.collision or #spell.data.collision == 0)
										 then
											for _, k in pairs(database) do
												if
													spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
														menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
												 then
													if ally.pos:dist(player.pos) <= spellE.range then
														if spell.missile then
															if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																if ally.pos:dist(player.pos) <= spellE.range then
																	player:castSpell("obj", 2, ally)
																end
															end
														end
														if spell.name:find(_:lower()) then
															if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																if ally.pos:dist(player.pos) <= spellE.range then
																	player:castSpell("obj", 2, ally)
																end
															end
														end
														if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
															if ally.pos:dist(player.pos) <= spellE.range then
																player:castSpell("obj", 2, ally)
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
					end
				end
			end
		end
	end
end

local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 100)
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 100)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 100)
		end
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
cb.add(cb.castspell, Spellsssss)
