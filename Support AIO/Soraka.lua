local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Nami by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Nami by Kornis'!")
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
	range = 780,
	delay = 0.5,
	speed = 1750,
	radius = 120,
	boundingRadiusMod = 1
}

local spellW = {
	range = 550
}

local spellE = {
	range = 925,
	delay = 0.4,
	speed = 1750,
	radius = 70,
	boundingRadiusMod = 1
}

local spellR = {
	range = 0
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
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Soraka")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)

menu:menu("wpriority", "Healing")
menu.wpriority:header("something", " -- W Settings -- ")
menu.wpriority:boolean("enable", "Enable Auto W", true)
menu.wpriority:slider("me", "Don't W if my Health <= ", 30, 1, 100, 1)
menu.wpriority:header("uhhh", "0 - Disabled, 1 - Biggest Priority, 5 - Lowest Priority")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	if allies.charName ~= "Soraka" then
		menu.wpriority:slider(allies.charName, "Priority: " .. allies.charName, 1, 0, 5, 1)
		menu.wpriority:slider(allies.charName .. "hp", " ^- Health Percent: ", 50, 1, 100, 1)
	end
end
menu.wpriority:header("something", " -- R Settings -- ")
menu.wpriority:boolean("enabler", "Enable Auto R", true)
menu.wpriority:boolean("semir", " ^- Semi Manual R", true)
menu.wpriority.semir:set("tooltip", "Manual R usage with Notifiaction if someone needs it.")
menu.wpriority:slider("rhealth", "Ally R Health <= ", 20, 1, 100, 1)
menu.wpriority:menu("rblack", "R Blacklist")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	if allies.charName == "Soraka" then
		menu.wpriority.rblack:boolean(allies.charName, "Block: " .. allies.charName, true)
	else
		menu.wpriority.rblack:boolean(allies.charName, "Block: " .. allies.charName, false)
	end
end

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawe", "Draw E Range", false)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)

menu:menu("misc", "Misc.")
menu.misc:boolean("autoq", "Auto E on CC", true)
menu.misc:boolean("GapAS", "Use E for Anti-Gapclose", true)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("intq", "Use E to Interrupt", true)
menu.misc.interrupt:menu("interruptmenur", "Interruptable Spells")

for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.misc.interrupt.interruptmenur:boolean(
				string.format(tostring(enemy.charName) .. tostring(spell.menuslot)),
				"Interrupt " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
				true
			)
		end
	end
end

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

local function PrioritizedAllyW()
	if menu.wpriority.enable:get() and (player.health / player.maxHealth) * 100 >= menu.wpriority.me:get() then
		local heroTarget = nil
		for i = 0, objManager.allies_n - 1 do
			local hero = objManager.allies[i]
			if not player.isRecalling then
				if
					hero.team == TEAM_ALLY and not hero.isDead and hero ~= player and menu.wpriority[hero.charName]:get() > 0 and
						hero.pos:dist(player.pos) <= spellW.range and
						not hero.isRecalling and
						menu.wpriority[hero.charName .. "hp"]:get() >= (hero.health / hero.maxHealth) * 100
				 then
					if heroTarget == nil then
						heroTarget = hero
					elseif menu.wpriority[hero.charName]:get() < menu.wpriority[heroTarget.charName]:get() then
						heroTarget = hero
					end
				end
			end
		end
		return heroTarget
	end
end

local function AutoInterrupt(spell)
	if menu.misc.interrupt.intq:get() and player:spellSlot(2).state == 0 then
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
							player.pos2D:dist(spell.owner.pos2D) < spellQ.range and common.IsValidTarget(spell.owner) and
								player:spellSlot(2).state == 0
						 then
							player:castSpell("pos", 2, spell.owner.pos)
						end
					end
				end
			end
		end
	end
end
local function WGapcloser()
	if player:spellSlot(2).state == 0 and menu.misc.GapAS:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < spellE.range
				 then
					if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
						player:castSpell("pos", 2, dasher.path.point2D[1])
					end
				end
			end
		end
	end
end
local uhh = false
local something = 0
local TargetSelectionFQ = function(res, obj, dist)
	if dist < spellQ.range + 380 then
		res.obj = obj
		return true
	end
end
local GetTargetFQ = function()
	return TS.get_result(TargetSelectionFQ).obj
end

local TargetSelectionE = function(res, obj, dist)
	if dist < spellE.range then
		res.obj = obj
		return true
	end
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
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

local TargetSelectionR = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end

local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
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

local function Combo()
	if menu.combo.ecombo:get() then
		local target = GetTargetE()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if target.pos:dist(player.pos) < spellE.range then
					local pos = preds.circular.get_prediction(spellE, target)
					if pos and pos.startPos:dist(pos.endPos) < spellE.range then
						player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
	if menu.combo.qcombo:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if menu.combo.qcombo:get() then
					if target.pos:dist(player.pos) < spellQ.range then
						local pos = preds.circular.get_prediction(spellQ, target)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
	end
end

local function OnTick()
	if menu.wpriority.enabler:get() and not menu.wpriority.semir:get() then
		local enemy = common.GetAllyHeroes()
		for i, enemies in ipairs(enemy) do
			if
				enemies and not enemies.isDead and menu.wpriority.rhealth:get() >= (enemies.health / enemies.maxHealth) * 100 and
					not enemies.isRecalling and
					not menu.wpriority.rblack[enemies.charName]:get() and
					#count_enemies_in_range(enemies.pos, 3000) > 0
			 then
				if player:spellSlot(3).state == 0 then
					player:castSpell("self", 3)
				end
			end
		end
	end
	if PrioritizedAllyW() then
		player:castSpell("obj", 1, PrioritizedAllyW())
	end
	if menu.misc.autoq:get() then
		local allies = common.GetEnemyHeroes()
		for z, ally in ipairs(allies) do
			if ally and ally.pos:dist(player.pos) <= spellQ.range then
				if
					(ally.buff[5] or ally.buff[8] or ally.buff[24] or ally.buff[23] or ally.buff[11] or ally.buff[22] or ally.buff[8] or
						ally.buff[21])
				 then
					player:castSpell("pos", 2, ally.pos)
				end
			end
		end
	end

	WGapcloser()
	if menu.keys.combokey:get() then
		Combo()
	end
end

local function OnDraw()
	local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
	local enemy = common.GetAllyHeroes()
	for i, enemies in ipairs(enemy) do
		if
			enemies and not enemies.isDead and menu.wpriority.rhealth:get() >= (enemies.health / enemies.maxHealth) * 100 and
				menu.wpriority.semir:get() and
				not enemies.isRecalling and
				not menu.wpriority.rblack[enemies.charName]:get()
		 then
			if player:spellSlot(3).state == 0 then
				graphics.draw_text_2D("ALLY IS LOW - PRESS R !", 35, pos.x - 250, pos.y - 150, graphics.argb(255, 255, 0, 0))
			end
		end
	end
	if player.isOnScreen then
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 100)
		end
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 100)
		end
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)

cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
