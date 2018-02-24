local version = "1.0"

local avada_lib = module.lib("avada_lib")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Akali by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Akali by Kornis'!")
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
	range = 650
}

local spellW = {
	range = 400
}

local spellE = {
	range = 325
}

local spellR = {
	range = 1000,
	delay = 0.25,
	speed = 2000,
	width = 120,
	collision = false,
	boundingRadiusMod = 1
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

local tSelector = avada_lib.targetSelector
local menu = menu("IreliaKornis", "Irelia By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:slider("minq", " ^-Min. Q Range", 220, 0, 400, 1)
menu.combo:boolean("gapq", "Use Q for Gapclose on Minion", true)
menu.combo:boolean("outofq", " ^-Only if out of Q Range", false)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("stune", " ^-Only if Stuns", false)
menu.combo:dropdown("rusage", "R Usage", 3, {"Always", "Only if Killable", "Never"})
menu.combo:boolean("gapr", "Use R on Minions for Q Gapclose", true)
menu.combo:boolean("sheen", "Sheen Proc.", false)
menu.combo:boolean("items", "Use Items", true)

menu:menu("harass", "Harass")
menu.harass:slider("manaharass", "Mana Manager", 30, 0, 100, 1)
menu.harass:boolean("qcombo", "Use Q to Harass", true)
menu.harass:boolean("gapq", "Use Q for Gapclose on Minion", true)
menu.harass:boolean("wharass", "Use W to Harass", true)
menu.harass:boolean("eharass", "Use E to Harass", true)
--menu.harass:boolean("lastq", "Use Q to Last Hit", true)
--menu.harass:boolean("lastq", " ^-Don't use Q in AA Range", true)
--menu.harass:boolean("turret", " ^-Don't use Q Under the Turret", true)

menu:menu("laneclear", "Lane Clear")
menu.laneclear:keybind("toggle", "Farm Toggle", "Z", nil)
menu.laneclear:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.laneclear:boolean("lastq", " ^-Only for Last Hit", true)
menu.laneclear:boolean("turret", " ^-Don't use Q Under the Turret", true)
menu.laneclear:boolean("farmw", "Use W to Farm", true)

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
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawtoggle", "Draw Farm Toggle", true)
menu.draws:boolean("drawkill", "Draw Minions Killable with Q", true)
menu.draws:boolean("drawgapclose", "Draw Gapclose Lines", true)
menu.draws:boolean("drawdamage", "Draw Damage", true)

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

menu:menu("flee", "Flee")
menu.flee:boolean("fleeq", "Use Q to Flee", true)
menu.flee:boolean("fleekill", " ^- Only if Minion is Killable", true)
menu.flee:keybind("fleekey", "Flee Key", "G", nil)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist < spellQ.range then
		res.obj = obj
		return true
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
	if menu.laneclear.toggle:get() then
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

local QLevelDamage = {20, 50, 80, 110, 140}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage = CalcADmg(target, (QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAD() / 2) * 1.2))
	end
	return damage
end
local RLevelDamage = {80, 120, 160}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
			CalcADmg(
			target,
			(RLevelDamage[player:spellSlot(3).level] + ((common.GetBonusAD() - common.GetTotalAD() / 2) * .7)) +
				common.GetTotalAP() * 0.5
		)
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
local function GetClosestMobToEnemy()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)

	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ad", enemies)

			for i, minion in pairs(enemyMinions) do
				if minion then
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

local function GetClosestMobToEnemyForR()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)

	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ad", enemies)

			for i, minion in pairs(enemyMinions) do
				if
					minion and
						(minion.health > QDamage(minion) and player.mana > player.manaCost0 + player.manaCost3 and
							(minion.health - RDamage(minion) * 2) < QDamage(minion))
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
local function GetClosestMobToEnemyForGap()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)

	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ad", enemies)

			for i, minion in pairs(enemyMinions) do
				if minion and minion.health < QDamage(minion) then
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

local function GetClosestJungleEnemy()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL)

	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ad", enemies)

			for i, minion in pairs(enemyMinions) do
				if minion and minion.health < QDamage(minion) then
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
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL)

	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ad", enemies)

			for i, minion in pairs(enemyMinions) do
				if minion then
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
local function AutoInterrupt(spell) -- Thank you Dew for this <3
	if menu.interrupt.inte:get() and player:spellSlot(2).state == 0 then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if
						menu.interrupt.interruptmenu[spell.owner.charName .. spellCheck.menuslot]:get() and
							string.lower(spell.name) == spellCheck.spellname
					 then
						if
							player.pos2D:dist(spell.owner.pos2D) < spellE.range and spell.owner.health > player.health and
								common.IsValidTarget(spell.owner) and
								player:spellSlot(2).state == 0
						 then
							player:castSpell("obj", 2, spell.owner)
						end
					end
				end
			end
		end
	end
end

local function WGapcloser()
	if player:spellSlot(2).state == 0 and menu.Gap.GapA:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < spellE.range
				 then
					if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
						print("working")
						player:castSpell("obj", 2, dasher)
					end
				end
			end
		end
	end
end
local function GetClosestMob()
	local enemyMinions = common.GetMinionsInRange(700, TEAM_ENEMY, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 300 then
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
	local enemyMinions = common.GetMinionsInRange(700, TEAM_NEUTRAL, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 300 then
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
local function GetClosestMobKill()
	local enemyMinions = common.GetMinionsInRange(700, TEAM_ENEMY, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion and minion.health < QDamage(minion) then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 300 then
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
	local enemyMinions = common.GetMinionsInRange(700, TEAM_NEUTRAL, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion and minion.health < QDamage(minion) then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 300 then
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
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if menu.flee.fleeq:get() then
			if not menu.flee.fleekill:get() then
				local minion = GetClosestMob(target)
				if minion then
					player:castSpell("obj", 0, minion)
				end
				local jungleeeee = GetClosestJungle(target)
				if jungleeeee then
					player:castSpell("obj", 0, jungleeeee)
				end
			end
		end
		if menu.flee.fleeq:get() then
			if  menu.flee.fleekill:get() then
				local minion = GetClosestMobKill(target)
				if minion then
					player:castSpell("obj", 0, minion)
				end
				local jungleeeee = GetClosestJungleKill(target)
				if jungleeeee then
					player:castSpell("obj", 0, jungleeeee)
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

function Combo()
	local mode = menu.combo.rusage:get()
	local target = GetTarget()
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
	local targets = GetTargetGap()
	if menu.combo.gapq:get() and menu.combo.outofq:get() then
		if common.IsValidTarget(targets) and targets then
			if (targets.pos:dist(player) > spellQ.range) then
				local minion = GetClosestMobToEnemyForGap(targets)
				local something = GetClosestMobToEnemyForR(targets)
				if minion and vec3(minion.x, minion.y, minion.z):dist(player.pos) <= spellQ.range then
					if player.mana > player.manaCost0 and QDamage(minion) >= minion.health then
						player:castSpell("obj", 0, minion)
					end
				end
				if something and vec3(something.x, something.y, something.z):dist(player.pos) <= spellQ.range then
					if mode == 1 then
						local pos = preds.linear.get_prediction(spellR, something)
						if pos and pos.startPos:dist(pos.endPos) < spellR.range then
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
					if mode == 2 then
						if (QDamage(targets) + RDamage(targets) * 3 + dmglib.GetSpellDamage(2, targets) >= targets.health) then
							local pos = preds.linear.get_prediction(spellR, something)
							if pos and pos.startPos:dist(pos.endPos) < spellR.range then
								player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
	end
	if menu.combo.gapq:get() and not menu.combo.outofq:get() then
		if common.IsValidTarget(targets) and targets then
			if (targets.pos:dist(player) < spellQ.range * 2) then
				local minion = GetClosestMobToEnemyForGap(targets)
				local something = GetClosestMobToEnemyForR(targets)
				if minion and vec3(minion.x, minion.y, minion.z):dist(player.pos) <= spellQ.range then
					if player.mana > player.manaCost0 and QDamage(minion) >= minion.health then
						if (vec3(minion.x, minion.y, minion.z):dist(targets.pos) < vec3(targets.x, targets.y, targets.z):dist(player.pos)) then
							player:castSpell("obj", 0, minion)
						end
					end
				end
				if something and vec3(something.x, something.y, something.z):dist(player.pos) <= spellQ.range then
					if mode == 1 then
						local pos = preds.linear.get_prediction(spellR, something)
						if pos and pos.startPos:dist(pos.endPos) < spellR.range then
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
					if mode == 2 then
						if (QDamage(targets) + RDamage(targets) * 3 + dmglib.GetSpellDamage(2, targets) >= targets.health) then
							local pos = preds.linear.get_prediction(spellR, something)
							if pos and pos.startPos:dist(pos.endPos) < spellR.range then
								player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
	end
	if common.IsValidTarget(target) then
		if menu.combo.qcombo:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) < spellQ.range) then
					if (target.pos:dist(player)) > menu.combo.minq:get() then
						player:castSpell("obj", 0, target)
					end
				end
			end
		end
	end
	if common.IsValidTarget(target) then
		if menu.combo.wcombo:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) < 250) then
					player:castSpell("obj", 1, target)
				end
			end
		end
	end
	if common.IsValidTarget(target) then
		if menu.combo.ecombo:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) < spellE.range) then
					if menu.combo.stune:get() and (target.health / target.maxHealth) * 100 > (player.health / player.maxHealth) * 100 then
						player:castSpell("obj", 2, target)
					end
					if not menu.combo.stune:get() then
						player:castSpell("obj", 2, target)
					end
				end
			end
		end
	end

	if common.IsValidTarget(target) and target then
		if player.buff["ireliatranscendentbladesspell"] then
			if (target.pos:dist(player) < spellR.range) then
				local pos = preds.linear.get_prediction(spellR, target)
				if pos and pos.startPos:dist(pos.endPos) < spellR.range then
					player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end

		if mode == 1 then
			if (target.pos:dist(player) < spellR.range) then
				if menu.combo.sheen:get() then
					if not player.buff["sheen"] and player.pos:dist(vec3(target.x, target.y, target.z)) < 250 then
						local pos = preds.linear.get_prediction(spellR, target)
						if pos and pos.startPos:dist(pos.endPos) < spellR.range then
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if not menu.combo.sheen:get() then
					local pos = preds.linear.get_prediction(spellR, target)
					if pos and pos.startPos:dist(pos.endPos) < spellR.range then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
		if mode == 2 then
			if (QDamage(target) + RDamage(target) * 3 + dmglib.GetSpellDamage(2, target) >= target.health) then
				if (target.pos:dist(player) < spellR.range) then
					if menu.combo.sheen:get() then
						if not player.buff["sheen"] and player.pos:dist(vec3(target.x, target.y, target.z)) < 250 then
							local pos = preds.linear.get_prediction(spellR, target)
							if pos and pos.startPos:dist(pos.endPos) < spellR.range then
								player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
					if not menu.combo.sheen:get() then
						local pos = preds.linear.get_prediction(spellR, target)
						if pos and pos.startPos:dist(pos.endPos) < spellR.range then
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
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
		if (math.floor((QDamage(target) + RDamage(target) + dmglib.GetSpellDamage(2, target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target) + RDamage(target) * 3 + dmglib.GetSpellDamage(2, target))) ..
					" (" ..
						tostring(
							math.floor((QDamage(target) + RDamage(target) * 3 + dmglib.GetSpellDamage(2, target)) / target.health * 100)
						) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if
			(math.floor((QDamage(target) + RDamage(target) * 3 + dmglib.GetSpellDamage(2, target)) / target.health * 100) >= 100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target) + RDamage(target) * 3 + dmglib.GetSpellDamage(2, target))) ..
					" (" ..
						tostring(
							math.floor((QDamage(target) + RDamage(target) * 3 + dmglib.GetSpellDamage(2, target)) / target.health * 100)
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
	if (player.mana / player.maxMana) * 100 >= menu.laneclear.mana:get() then
		if menu.laneclear.farmq:get() then
			local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL)
			for i, minion in pairs(enemyMinionsQ) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellQ.range then
						player:castSpell("obj", 0, minion)
					end
				end
			end
		end
		if menu.laneclear.farmw:get() then
			local enemyMinionsE = common.GetMinionsInRange(250, TEAM_NEUTRAL)
			for i, minion in pairs(enemyMinionsE) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= 250 then
						player:castSpell("obj", 1, player)
					end
				end
			end
		end
	end
end

local function Harass()
	if (player.mana / player.maxMana) * 100 >= menu.harass.manaharass:get() then
		local target = GetTarget()
		local targets = GetTargetGap()
		if menu.harass.gapq:get() then
			if common.IsValidTarget(targets) and target then
				if (targets.pos:dist(player) > spellQ.range) then
					local minion = GetClosestMobToEnemyForGap(targets)
					if minion and vec3(minion.x, minion.y, minion.z):dist(player.pos) <= spellQ.range then
						if player.mana > player.manaCost0 and QDamage(minion) >= minion.health then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
		end
		if menu.harass.gapq:get() then
			if common.IsValidTarget(targets) and targets then
				if (targets.pos:dist(player) < spellQ.range) then
					local minion = GetClosestMobToEnemyForGap(targets)
					if minion and vec3(minion.x, minion.y, minion.z):dist(player.pos) <= spellQ.range then
						if player.mana > player.manaCost0 and QDamage(minion) >= minion.health then
							if
								(vec3(minion.x, minion.y, minion.z):dist(targets.pos) < vec3(targets.x, targets.y, targets.z):dist(player.pos))
							 then
								player:castSpell("obj", 0, minion)
							end
						end
					end
				end
			end
		end
		if menu.harass.qcombo:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) < spellQ.range) then
					player:castSpell("obj", 0, target)
				end
			end
		end
		if menu.harass.eharass:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) < spellE.range) then
					player:castSpell("obj", 2, target)
				end
			end
		end
		if menu.harass.wharass:get() then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) < 250) then
					player:castSpell("obj", 1, target)
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
						QDamage(enemies) >= hp
				 then
					player:castSpell("obj", 0, enemies)
				end
			end
			if menu.killsteal.kse:get() then
				if
					player:spellSlot(2).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range and
						dmglib.GetSpellDamage(2, enemies) - 5 > hp
				 then
					player:castSpell("obj", 2, enemies)
				end
			end
			if menu.killsteal.ksr:get() then
				if
					player:spellSlot(3).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellR.range and
						RDamage(enemies) * 2 > hp
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
						QDamage(enemies) > hp
				 then
					local minion = GetClosestMobToEnemyForGap(enemies)
					if minion and minion.health < QDamage(minion) then
						player:castSpell("obj", 0, minion)
					end

					local minios = GetClosestMobToEnemyForGap(enemies)
					if minios and minion.health < QDamage(minion) then
						player:castSpell("obj", 0, minios)
					end
				end
			end
		end
	end
end
local function LaneClear()
	if uhh then
		return
	end
	if (player.mana / player.maxMana) * 100 >= menu.laneclear.mana:get() then
		if menu.laneclear.farmq:get() then
			local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
			for i, minion in pairs(enemyMinionsQ) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellQ.range then
						if not menu.laneclear.lastq:get() then
							if menu.laneclear.turret:get() and not common.is_under_tower(vec3(minion.x, minion.y, minion.z)) then
								player:castSpell("obj", 0, minion)
							end
							if not menu.laneclear.turret:get() then
								player:castSpell("obj", 0, minion)
							end
						end
						if menu.laneclear.lastq:get() and QDamage(minion) > minion.health then
							if menu.laneclear.turret:get() and not common.is_under_tower(vec3(minion.x, minion.y, minion.z)) then
								player:castSpell("obj", 0, minion)
							end
							if not menu.laneclear.turret:get() then
								player:castSpell("obj", 0, minion)
							end
						end
					end
				end
			end
		end
		if menu.laneclear.farmw:get() then
			local enemyMinionsE = common.GetMinionsInRange(250, TEAM_ENEMY)
			for i, minion in pairs(enemyMinionsE) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= 250 then
						player:castSpell("obj", 1, player)
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
						QDamage(minion) >= minion.health
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
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 100)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 100)
		end
		if menu.draws.drawkill:get() and player:spellSlot(0).state == 0 then
			local enemyMinionsE = common.GetMinionsInRange(spellQ.range + 300, TEAM_ENEMY)
			for i, minion in pairs(enemyMinionsE) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					local targets = GetTargetGap()
					if (QDamage(minion) >= minion.health) then
						graphics.draw_circle(minionPos, 100, 2, graphics.argb(255, 255, 255, 0), 100)
					end
				end
			end
		end
	end
	if menu.draws.drawtoggle:get() then
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
		if uhh == true then
			graphics.draw_text_2D("Farm: OFF", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 218, 34, 34))
		else
			graphics.draw_text_2D("Farm: ON", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 128, 255, 0))
		end
	end
	if menu.draws.drawdamage:get() then
		local enemy = common.GetEnemyHeroes()
		for i, enemies in ipairs(enemy) do
			if
				enemies and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 1000 and
					not common.HasBuffType(enemies, 17)
			 then
				DrawDamagesE(enemies)
			end
		end
	end
	if menu.draws.drawgapclose:get() then
		local minion = GetClosestMobToEnemyForGap(targets)
		local minions = GetClosestJungleEnemyToGap(targets)

		local targets = GetTargetGap()

		if common.IsValidTarget(targets) and minion then
			if
				targets and (targets.pos:dist(player) < spellQ.range + spellQ.range - 50) and
					(targets.pos:dist(player)) > spellQ.range
			 then
				if player.mana > player.manaCost0 and QDamage(minion) >= minion.health then
					graphics.draw_line(player, minion, 4, graphics.argb(255, 218, 34, 34))
					graphics.draw_line(minion, targets, 4, graphics.argb(255, 218, 34, 34))
				end
			end
			if targets and (targets.pos:dist(player) < spellQ.range + spellQ.range) and (targets.pos:dist(player)) < spellQ.range then
				if player.mana > player.manaCost0 and QDamage(minion) >= minion.health then
					if (vec3(minion.x, minion.y, minion.z):dist(targets.pos) < vec3(targets.x, targets.y, targets.z):dist(player.pos)) then
						graphics.draw_line(player, minion, 4, graphics.argb(255, 218, 34, 34))
						graphics.draw_line(minion, targets, 4, graphics.argb(255, 218, 34, 34))
					end
				end
			end
		end
	end
end
local function OnTick()
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

cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
cb.add(cb.tick, OnTick)
