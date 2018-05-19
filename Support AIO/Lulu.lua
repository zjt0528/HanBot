local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Lulu by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Lulu by Kornis'!")
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
	range = 925,
	speed = 1800,
	width = 60,
	delay = 0.25,
	boundingRadiusMod = 0
}

local spellW = {
	range = 650
}

local spellE = {
	range = 650
}

local spellR = {
	range = 900
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
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Lulu")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("useeq", "Use E > Q Extended", false)
menu.combo:boolean("wcomboenemy", "Use W in Combo on Enemy", false)
menu.combo:menu("wblacklist", "W Blacklist for Enemy")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.combo.wblacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu.combo:boolean("wcombo", "Auto W on Ally", true)
menu.combo:menu("wset", "W Priority")
menu.combo.wset:boolean("enablew", "Enable W usage", true)
menu.combo.wset:boolean("enablee", "Auto E together with W", false)
menu.combo.wset:header("uhhh", "0 - Disabled, 1 - Biggest Priority, 5 - Lowest Priority")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	if
		allies.charName ~= "Lulu" and allies.charName ~= "Twitch" and allies.charName ~= "KogMaw" and
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
		menu.combo.wset:slider(allies.charName, "Priority: " .. allies.charName, 0, 0, 5, 1)
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
		menu.combo.wset:slider(allies.charName, "Priority: " .. allies.charName, 1, 0, 5, 1)
	end
	if allies.charName == "Lulu" then
		menu.combo.wset:slider(allies.charName, "Priority: " .. allies.charName, 0, 0, 5, 1)
	end
end
menu.combo:dropdown("eusage", "E Usage", 2, {"Always", "Logic", "Never"})
menu.combo:menu("rset", "R Settings")
menu.combo.rset:boolean("rcombo", "Use R in Combo", true)
menu.combo.rset:slider("hitr", " ^- if Knocks Up X Enemies", 2, 1, 5, 1)
menu.combo.rset:menu("whitelist", "Ally Settings")
menu.combo.rset.whitelist:boolean("autor", "Auto R", true)
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	menu.combo.rset.whitelist:slider(allies.charName, "Use R if X HP: " .. allies.charName, 30, 1, 100, 1)
end
menu.combo.rset:keybind("semir", "Semi-R on Lowest Health Ally", "T", nil)
menu:menu("harass", "Harass")

menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("ecombo", "Use E in Harass", true)
menu.harass:boolean("useeq", "Use E > Q Extended", true)
menu:menu("we", "W > E Settings")
menu.we:keybind("wekey", "W > E Boost Ally", "Z", nil)
menu.we:header("uhhh", "0 - Disabled, 1 - Biggest Priority, 5 - Lowest Priority")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	if
		allies.charName ~= "Twitch" and allies.charName ~= "KogMaw" and allies.charName ~= "Tristana" and
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
		menu.we:slider(allies.charName, "Priority: " .. allies.charName, 0, 0, 5, 1)
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
		menu.we:slider(allies.charName, "Priority: " .. allies.charName, 1, 0, 5, 1)
	end
end

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", false)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawr", "Draw R Range", false)
menu.draws:color("colorr", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawpix", "Draw Pix Position", true)
menu.draws:boolean("drawrangespix", "Draw Ranges from Pix", true)

menu:menu("misc", "Misc.")
menu.misc:boolean("GapAS", "Use W for Anti-Gapclose", true)
menu.misc:menu("blacklist", "Anti-Gapclose Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("intw", "Use W to Interrupt", true)
menu.misc.interrupt:menu("interruptmenuw", "W Interrupting")
for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.misc.interrupt.interruptmenuw:boolean(
				string.format(tostring(enemy.charName) .. tostring(spell.menuslot)),
				"Interrupt " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
				true
			)
		end
	end
end
menu.misc.interrupt:boolean("intr", "Use R to Interrupt from Ally/Me", true)
menu.misc.interrupt:menu("interruptmenur", "R Interrupting")
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
menu:menu("blacklist", "R Blacklist")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	menu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
menu.keys:keybind("fleekey", "Flee", "G", nil)
menu:menu("SpellsMenu", "Shielding")
menu.SpellsMenu:boolean("enable", "Enable Shielding", true)
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
local objHolder = {}
local Pix = nil
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

local function PrioritizedAllyW()
	local heroTarget = nil
	for i = 0, objManager.allies_n - 1 do
		local hero = objManager.allies[i]
		if not player.isRecalling then
			if
				hero.team == TEAM_ALLY and not hero.isDead and menu.combo.wset[hero.charName]:get() > 0 and
					hero.pos:dist(player.pos) <= spellW.range
			 then
				if heroTarget == nil then
					heroTarget = hero
				elseif menu.combo.wset[hero.charName]:get() < menu.combo.wset[heroTarget.charName]:get() then
					heroTarget = hero
				end
			end
		end
	end

	return heroTarget
end

local function PrioritizedAllyWE()
	local heroTarget = nil
	for i = 0, objManager.allies_n - 1 do
		local hero = objManager.allies[i]
		if not player.isRecalling then
			if
				hero.team == TEAM_ALLY and not hero.isDead and menu.we[hero.charName]:get() > 0 and
					hero.pos:dist(player.pos) <= spellW.range
			 then
				if heroTarget == nil then
					heroTarget = hero
				elseif menu.we[hero.charName]:get() < menu.we[heroTarget.charName]:get() then
					heroTarget = hero
				end
			end
		end
	end

	return heroTarget
end

local function PrioritizedAllyLow()
	local heroTarget = nil
	for i = 0, objManager.allies_n - 1 do
		local hero = objManager.allies[i]
		if not player.isRecalling then
			if hero.team == TEAM_ALLY and not hero.isDead and hero.pos:dist(player.pos) <= spellR.range then
				if heroTarget == nil then
					heroTarget = hero
				elseif (hero.health / hero.maxHealth) * 100 < (heroTarget.health / heroTarget.maxHealth) * 100 then
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
	"AsheQAttack"
}
local function AutoInterrupt(spell)
	--	print("int")

	if menu.combo.wcombo:get() then
		local heroTarget = nil
		if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY and spell.target.type == TYPE_HERO then
			for i = 1, #PSpells do
				if
					spell.name:lower():find(PSpells[i]:lower()) and spell.owner.pos:dist(player.pos) <= spellW.range and
						menu.combo.wset[spell.owner.charName]:get() > 0
				 then
					if heroTarget == nil then
						heroTarget = spell.owner
					elseif menu.combo.wset[hero.charName]:get() < menu.combo.wset[heroTarget.charName]:get() then
						heroTarget = spell.owner
					end
					if (heroTarget) then
						if menu.combo.wset.enablew:get() then
							player:castSpell("obj", 1, heroTarget)
						end
						if menu.combo.wset.enablee:get() then
							player:castSpell("obj", 2, heroTarget)
						end
					end
				end
			end
			if
				spell.name:find("BasicAttack") and spell.owner.pos:dist(player.pos) <= spellW.range and
					menu.combo.wset[spell.owner.charName]:get() > 0
			 then
				if heroTarget == nil then
					heroTarget = spell.owner
				elseif menu.combo.wset[hero.charName]:get() < menu.combo.wset[heroTarget.charName]:get() then
					heroTarget = spell.owner
				end
				if (heroTarget) then
					if menu.combo.wset.enablew:get() then
						player:castSpell("obj", 1, heroTarget)
					end
					if menu.combo.wset.enablee:get() then
						player:castSpell("obj", 2, heroTarget)
					end
				end
			end
		end
		if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY then
			if
				spell.name:find("KogMawBioArcaneBarrage") and spell.owner.pos:dist(player.pos) <= spellW.range and
					menu.combo.wset[spell.owner.charName]:get() > 0
			 then
				if heroTarget == nil then
					heroTarget = spell.owner
				elseif menu.combo.wset[hero.charName]:get() < menu.combo.wset[heroTarget.charName]:get() then
					heroTarget = spell.owner
				end
				if (heroTarget) then
					if menu.combo.wset.enablew:get() then
						player:castSpell("obj", 1, heroTarget)
					end
					if menu.combo.wset.enablee:get() then
						player:castSpell("obj", 2, heroTarget)
					end
				end
			end
		end
	end
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

										if menu.SpellsMenu.targeteteteteteed:get() then
											if ally.pos:dist(player.pos) <= spellE.range then
												player:castSpell("obj", 2, ally)
											end
										end
									end
									if menu.combo.rset.whitelist.autor:get() then
										if
											menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
												ally.pos:dist(player.pos) <= spellR.range and
												menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
										 then
											player:castSpell("obj", 3, ally)
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
	if menu.SpellsMenu.BasicAttack.aa:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally and ally.pos:dist(player.pos) <= spellE.range then
			if ally and ally.pos:dist(player.pos) <= spellE.range then
				if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					for i = 1, #PSpells do
						if spell.name:lower():find(PSpells[i]:lower()) then
							if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
								if not menu.SpellsMenu.blacklist[ally.charName]:get() then
									if ally.pos:dist(player.pos) <= spellE.range then
										player:castSpell("obj", 2, ally)
									end
									if menu.combo.rset.whitelist.autor:get() then
										if
											menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
												ally.pos:dist(player.pos) <= spellR.range and
												menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
										 then
											player:castSpell("obj", 3, ally)
										end
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
								if menu.combo.rset.whitelist.autor:get() then
									if
										menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
											ally.pos:dist(player.pos) <= spellR.range and
											menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
									 then
										player:castSpell("obj", 3, ally)
									end
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
								if menu.combo.rset.whitelist.autor:get() then
									if
										menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
											ally.pos:dist(player.pos) <= spellR.range and
											menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
									 then
										player:castSpell("obj", 3, ally)
									end
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
						if menu.combo.rset.whitelist.autor:get() then
							if
								menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
									ally.pos:dist(player.pos) <= spellR.range and
									menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
							 then
								player:castSpell("obj", 3, ally)
							end
						end
					end
				end
			end
		end
	end

	if menu.misc.interrupt.intw:get() then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if
						menu.misc.interrupt.interruptmenuw[spell.owner.charName .. spellCheck.menuslot]:get() and
							string.lower(spell.name) == spellCheck.spellname
					 then
						if player.pos2D:dist(spell.owner.pos2D) < spellQ.range and common.IsValidTarget(spell.owner) then
							player:castSpell("obj", 1, spell.owner)
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
						local allies = common.GetAllyHeroes()
						for z, ally in ipairs(allies) do
							if ally and not ally.isDead and ally.isVisible and ally.pos:dist(player.pos) <= spellR.range then
								if
									ally.pos2D:dist(spell.owner.pos2D) < 350 and common.IsValidTarget(spell.owner) and
										player:spellSlot(3).state == 0
								 then
									player:castSpell("obj", 3, ally)
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
	if player:spellSlot(1).state == 0 and menu.misc.GapAS:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < 650
				 then
					if menu.misc.blacklist[dasher.charName] and not menu.misc.blacklist[dasher.charName]:get() then
						if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
							player:castSpell("obj", 1, dasher)
						end
					end
				end
			end
		end
	end
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
local TargetSelectionQE = function(res, obj, dist)
	if dist < 1800 then
		res.obj = obj
		return true
	end
end
local GetTargetQE = function()
	return TS.get_result(TargetSelectionQE).obj
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

local function GetClosestMobToEnemyForGap()
	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < spellE.range and
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

local function Harass()
	if menu.harass.qcombo:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range - 50 then
					player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end

				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range - 50 then
					player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
		if Pix and not player.isDead then
			for i = 0, objManager.enemies_n - 1 do
				local hero = objManager.enemies[i]

				if
					hero and hero.isVisible and hero.team == TEAM_ENEMY and not hero.isDead and hero.pos:dist(Pix.pos) <= spellQ.range and
						hero.pos:dist(player.pos) > spellQ.range
				 then
					local pos = preds.linear.get_prediction(spellQ, hero, vec2(Pix.x, Pix.z))
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range - 50 then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
	if menu.harass.ecombo:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if
					(#count_allies_in_range(player.pos, spellE.range + 200) == 1 or
						((target.health / target.maxHealth) * 100 < 5 and (player.health / player.maxHealth) * 100 > 20))
				 then
					if target.pos:dist(player.pos) < spellE.range then
						player:castSpell("obj", 2, target)
					end
				end
			end
		end
	end
	if menu.harass.useeq:get() then
		if player:spellSlot(0).state == 0 then
			local allies = common.GetAllyHeroes()
			for z, ally in ipairs(allies) do
				if ally and not ally.isDead and ally.isVisible and ally.pos:dist(player.pos) <= spellE.range then
					for i = 0, objManager.enemies_n - 1 do
						local hero = objManager.enemies[i]

						if
							hero and hero.isVisible and hero.team == TEAM_ENEMY and not hero.isDead and
								hero.pos:dist(player.pos) > spellQ.range
						 then
							if (ally.pos:dist(hero.pos) < spellQ.range - 150) then
								player:castSpell("obj", 2, ally)
							end
						end
					end
				end
			end
			local minion = GetClosestMobToEnemyForGap()

			if minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < spellE.range then
				for i = 0, objManager.enemies_n - 1 do
					local hero = objManager.enemies[i]

					if
						hero and hero.isVisible and hero.team == TEAM_ENEMY and not hero.isDead and
							hero.pos:dist(player.pos) > spellQ.range
					 then
						if (minion.pos:dist(hero.pos) < spellQ.range - 150) and minion.health > dmglib.GetSpellDamage(2, minion) then
							player:castSpell("obj", 2, minion)
						end
					end
				end
			end
		end
	end
end

local function Combo()
	if menu.combo.wcomboenemy:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) and target.pos:dist(player.pos) <= spellW.range then
				if menu.combo.wblacklist[target.charName] and not menu.combo.wblacklist[target.charName]:get() then
					player:castSpell("obj", 1, target)
				end
			end
		end
	end
	if menu.combo.qcombo:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range - 50 then
					player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end

				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range - 50 then
					player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
	local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) and target.pos:dist(player.pos) <= spellE.range then
			if menu.combo.eusage:get() == 1 then
				player:castSpell("obj", 2, target)
			end
			if menu.combo.eusage:get() == 2 then
				if
					(#count_allies_in_range(player.pos, spellE.range + 200) == 1 or
						((target.health / target.maxHealth) * 100 < 5 and (player.health / player.maxHealth) * 100 > 20))
				 then
					player:castSpell("obj", 2, target)
				end
			end
		end
	end
	if menu.combo.rset.rcombo:get() then
		for i = 0, objManager.allies_n - 1 do
			local hero = objManager.allies[i]

			if
				hero and hero.isVisible and not hero.isDead and menu.blacklist[hero.charName] and
					not menu.blacklist[hero.charName]:get() and
					hero.pos:dist(player.pos) <= spellR.range
			 then
				if (menu.combo.rset.hitr:get() <= #count_enemies_in_range(hero.pos, 350)) then
					player:castSpell("obj", 3, hero)
				end
			end
		end
	end
	if Pix and not player.isDead then
		for i = 0, objManager.enemies_n - 1 do
			local hero = objManager.enemies[i]

			if
				hero and hero.isVisible and hero.team == TEAM_ENEMY and not hero.isDead and hero.pos:dist(Pix.pos) <= spellQ.range and
					hero.pos:dist(player.pos) > spellQ.range
			 then
				local pos = preds.linear.get_prediction(spellQ, hero, vec2(Pix.x, Pix.z))
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range - 50 then
					player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
	if menu.combo.useeq:get() then
		if player:spellSlot(0).state == 0 then
			local allies = common.GetAllyHeroes()
			for z, ally in ipairs(allies) do
				if ally and not ally.isDead and ally.isVisible and ally.pos:dist(player.pos) <= spellE.range then
					for i = 0, objManager.enemies_n - 1 do
						local hero = objManager.enemies[i]

						if
							hero and hero.isVisible and hero.team == TEAM_ENEMY and not hero.isDead and
								hero.pos:dist(player.pos) > spellQ.range
						 then
							if (ally.pos:dist(hero.pos) < spellQ.range - 150) then
								player:castSpell("obj", 2, ally)
							end
						end
					end
				end
			end
			local minion = GetClosestMobToEnemyForGap()

			if minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < spellE.range then
				for i = 0, objManager.enemies_n - 1 do
					local hero = objManager.enemies[i]

					if
						hero and hero.isVisible and hero.team == TEAM_ENEMY and not hero.isDead and
							hero.pos:dist(player.pos) > spellQ.range
					 then
						if (minion.pos:dist(hero.pos) < spellQ.range - 150) and minion.health > dmglib.GetSpellDamage(2, minion) then
							player:castSpell("obj", 2, minion)
						end
					end
				end
			end
		end
	end
end

local allow = true
local timer = 0
local function OnTick()
	--	print("ontick")
	if not evade then
		print(" ")
		console.set_color(79)
		print("-----------Support AIO--------------")
		print("You need to have enabled 'Premium Evade' for Shielding Champions.")
		print("If you don't want Evade to dodge, disable dodging but keep Module enabled. :>")
		print("------------------------------------")
		console.set_color(12)
	end
	if menu.combo.rset.whitelist.autor:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally and ally.pos:dist(player.pos) <= spellR.range then
				if
					menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
						ally.pos:dist(player.pos) <= spellR.range and
						menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
				 then
					if (ally.buff[23] or ally.buff[24] or ally.buff[22] or ally.buff[21] or ally.buff[18] or ally.buff[12]) then
						player:castSpell("obj", 3, ally)
					end
				end
			end
		end
	end
	if menu.keys.fleekey:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		player:castSpell("self", 1)
	end
	if menu.combo.rset.semir:get() then
		if PrioritizedAllyLow() then
			player:castSpell("obj", 3, PrioritizedAllyLow())
		end
	end
	if menu.we.wekey:get() then
		if PrioritizedAllyWE() then
			player:castSpell("obj", 1, PrioritizedAllyWE())
			player:castSpell("obj", 2, PrioritizedAllyWE())
		end
	end
	if os.clock() > timer then
		objManager.loop(
			function(obj)
				if obj and obj.name == "RobotBuddy" and obj.team == TEAM_ALLY and obj.owner == player then
					Pix = obj
					timer = os.clock() + 10
				end
			end
		)
	end
	WGapcloser()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end

	if not player.isRecalling then
		if menu.SpellsMenu.cc:get() then
			local allies = common.GetAllyHeroes()
			for z, ally in ipairs(allies) do
				if ally then
					if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
						if
							(ally.buff[5] or ally.buff[8] or ally.buff[24] or ally.buff[23] or ally.buff[11] or ally.buff[22] or ally.buff[8] or
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
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
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
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
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
														menu.SpellsMenu[k.charName][_].hp:get() >= (player.health / player.maxHealth) * 100
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
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
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

		for i = 1, #evade.core.active_spells do
			local spell = evade.core.active_spells[i]

			local allies = common.GetAllyHeroes()
			for z, ally in ipairs(allies) do
				if ally and ally.pos:dist(player.pos) <= spellR.range and ally ~= player then
					if (spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0) then
						allow = false
					else
						allow = true
					end

					if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
						if not spell.name:find("crit") then
							if not spell.name:find("basicattack") then
								if menu.combo.rset.whitelist.autor:get() then
									if
										menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
											ally.pos:dist(player.pos) <= spellR.range and
											menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
									 then
										player:castSpell("obj", 3, ally)
									end
								end
							end
						end
					elseif
						spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0 and
							(not spell.data.collision or #spell.data.collision == 0)
					 then
						for _, k in pairs(database) do
							if ally ~= player then
								if spell.missile then
									if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.4) then
										if menu.combo.rset.whitelist.autor:get() then
											if
												menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
													ally.pos:dist(player.pos) <= spellR.range and
													menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
											 then
												player:castSpell("obj", 3, ally)
											end
										end
									end
								end

								if spell.name:find(_:lower()) then
									if k.speeds == math.huge or spell.data.spell_type == "Circular" then
										if menu.combo.rset.whitelist.autor:get() then
											if
												menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
													ally.pos:dist(player.pos) <= spellR.range and
													menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
											 then
												player:castSpell("obj", 3, ally)
											end
										end
									end
								end

								if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
									if menu.combo.rset.whitelist.autor:get() then
										if
											menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
												ally.pos:dist(player.pos) <= spellR.range and
												menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
										 then
											player:castSpell("obj", 3, ally)
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
					if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
						if not spell.name:find("crit") then
							if not spell.name:find("basicattack") then
								if menu.combo.rset.whitelist.autor:get() then
									if
										menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
											ally.pos:dist(player.pos) <= spellR.range and
											menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
									 then
										player:castSpell("obj", 3, ally)
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
								if spell.missile then
									if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.4) then
										if menu.combo.rset.whitelist.autor:get() then
											if
												menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
													ally.pos:dist(player.pos) <= spellR.range and
													menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
											 then
												player:castSpell("obj", 3, ally)
											end
										end
									end
								end
								if spell.name:find(_:lower()) then
									if k.speeds == math.huge or spell.data.spell_type == "Circular" then
										--print("me")
										if menu.combo.rset.whitelist.autor:get() then
											if
												menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
													ally.pos:dist(player.pos) <= spellR.range and
													menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
											 then
												player:castSpell("obj", 3, ally)
											end
										end
									end
								end
								if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
									--print("me")
									if menu.combo.rset.whitelist.autor:get() then
										if
											menu.blacklist[ally.charName] and not menu.blacklist[ally.charName]:get() and
												ally.pos:dist(player.pos) <= spellR.range and
												menu.combo.rset.whitelist[ally.charName]:get() >= (ally.health / ally.maxHealth) * 100
										 then
											player:castSpell("obj", 3, ally)
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
	--print("Drawing")
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
	if menu.draws.drawpix:get() then
		if Pix and not player.isDead and Pix.isOnScreen then
			graphics.draw_circle(Pix.pos, 50, 2, graphics.argb(255, 255, 105, 180), 100)
		end
	end
	if menu.draws.drawrangespix:get() then
		if Pix and not player.isDead and Pix.isOnScreen then
			for i = 0, objManager.allies_n - 1 do
				local hero = objManager.allies[i]

				if
					hero and hero.isVisible and hero.team == TEAM_ALLY and not hero.isDead and hero ~= player and
						hero.pos:dist(player.pos) <= 1800
				 then
					if hero.buff["lulufaerieattackaid"] then
						graphics.draw_circle(Pix.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
					end
				end
			end
			for i = 0, objManager.enemies_n - 1 do
				local hero = objManager.enemies[i]

				if hero and hero.isVisible and hero.team == TEAM_ENEMY and not hero.isDead and hero.pos:dist(player.pos) <= 1800 then
					if hero.buff["lulufaerieburn"] then
						graphics.draw_circle(Pix.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
					end
				end
			end
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < 1800 then
					if minion.buff["lulufaerieburn"] or minion.buff["lulufaerieattackaid"] or minion.buff["luluevision"] then
						graphics.draw_circle(Pix.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
					end
				end
			end
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < 1800 then
					if minion.buff["lulufaerieburn"] or minion.buff["lulufaerieattackaid"] or minion.buff["luluevision"] then
						graphics.draw_circle(Pix.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
					end
				end
			end
		end
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
