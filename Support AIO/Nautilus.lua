local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Nautilus by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Nautilus by Kornis'!")
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
	range = 1000,
	speed = 2000,
	boundingRadiusMod = 1,
	width = 90,
	delay = 0.25,
	collision = {
		hero = false,
		minion = true,
		wall = true
	}
}

local spellW = {
	range = 0
}

local spellE = {
	range = 600,
	delay = 0.95,
	radius = 130,
	speed = 1800,
	boundingRadiusMod = 0
}

local spellR = {
	range = 825
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
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Nautilus")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W for Auto Attack Reset", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("cce", " ^- Only if Enemy not CC'd", false)
menu.combo:boolean("rcombo", "Use R in Combo", true)
menu.combo:slider("hpr", " ^- if Enemy Health lower than X", 50, 0, 100, 1)
menu.combo:slider("minr", " ^- Min. R Range", 300, 0, 500, 1)
menu.combo:menu("blacklist", "R Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.combo.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("blacklist", "Q Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("wcombo", "Use W for Auto Attack Reset", true)
menu.harass:boolean("ecombo", "Use E in Harass", true)

menu:menu("farming", "Farming")
menu.farming:menu("laneclear", "Lane Clear")
menu.farming.laneclear:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.farming.laneclear:boolean("farmq", "Use E to Farm", false)
menu.farming.laneclear:slider("hite", " ^- Only if Hits X Minions", 3, 1, 6, 1)
menu.farming:menu("jungleclear", "Jungle Clear")
menu.farming.jungleclear:boolean("usew", "Use W for Auto Attack Reset", true)
menu.farming.jungleclear:boolean("usee", "Use E in Jungle Clear", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
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
menu.misc:boolean("GapAS", "Use E for Anti-Gapclose", true)
menu.misc:slider("health", " ^- Only if my Health Percent < X", 50, 1, 100, 1)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("intr", "Use R to Interrupt", false)
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

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
menu:menu("SpellsMenu", "W Shielding")
menu.SpellsMenu:boolean("enable", "Enable Shielding", true)
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

local function AutoInterrupt(spell)
	if menu.SpellsMenu.targeteteteteteed:get() then
		if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == player then
			if not spell.name:find("crit") then
				if not spell.name:find("BasicAttack") then
					if menu.SpellsMenu.targeteteteteteed:get() then
						player:castSpell("self", 1)
					end
				end
			end
		end
	end
	if menu.SpellsMenu.BasicAttack.aa:get() then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == player then
			if spell.name:find("BasicAttack") then
				if (player.health / player.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
					player:castSpell("self", 1)
				end
			end
		end
	end
	if menu.SpellsMenu.BasicAttack.critaa:get() then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == player then
			if spell.name:find("crit") then
				if (player.health / player.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.crithp:get() then
					player:castSpell("self", 1)
				end
			end
		end
	end

	if menu.SpellsMenu.BasicAttack.minionaa:get() then
		if spell.owner.type == TYPE_MINION and spell.owner.team == TEAM_ENEMY and spell.target == player then
			if (player.health / player.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.minionhp:get() then
				player:castSpell("self", 1)
			end
		end
	end

	if menu.SpellsMenu.BasicAttack.turret:get() then
		if spell.owner.type == TYPE_TURRET and spell.owner.team == TEAM_ENEMY and spell.target == player then
			player:castSpell("self", 1)
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
							player:castSpell("obj", 3, spell.owner)
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
					if menu.misc.blacklist[dasher.charName] and not menu.misc.blacklist[dasher.charName]:get() then
						if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
							if ((player.health / player.maxHealth) * 100 <= menu.misc.health:get()) then
								player:castSpell("self", 2)
							end
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

local TargetSelectionR = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end
local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
end

orb.combat.register_f_after_attack(
	function()
		if menu.keys.combokey:get() then
			if orb.combat.target then
				if
					orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					if menu.combo.wcombo:get() and player:spellSlot(1).state == 0 then
						player:castSpell("self", 1)
						orb.core.reset()
						orb.combat.set_invoke_after_attack(false)
						return "waa"
					end
				end
			end
		end
		if menu.keys.harasskey:get() then
			if orb.combat.target then
				if
					orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					if menu.harass.wcombo:get() and player:spellSlot(1).state == 0 then
						player:castSpell("self", 1)
						orb.core.reset()
						orb.combat.set_invoke_after_attack(false)
						return "waa"
					end
				end
			end
		end
		if menu.keys.clearkey:get() then
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < common.GetAARange(minion)
				 then
					if menu.farming.jungleclear.usew:get() and player:spellSlot(1).state == 0 then
						player:castSpell("self", 1)
						orb.core.reset()
						orb.combat.set_invoke_after_attack(false)
						return "waa"
					end
				end
			end
		end
	end
)
local function meowmeowcheck(start, endpos)
	for k = 0, start:dist(endpos), 1 do
		if navmesh.isWall(endpos - k * (endpos - start):norm()) then
			return true
		end
	end
	return false
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

local function JungleClear()
	if menu.farming.jungleclear.usee:get() then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellE.range
			 then
				local pos = preds.circular.get_prediction(spellE, minion)
				if pos and pos.startPos:dist(pos.endPos) < spellE.range then
					player:castSpell("self", 2)
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
	if menu.farming.laneclear.farmq:get() and player:spellSlot(1).state == 0 then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellE.range
			 then
				if #count_minions_in_range(player.pos, spellE.range) >= menu.farming.laneclear.hite:get() then
					player:castSpell("self", 2)
				end
			end
		end
	end
end
local function Harass()
	local target = GetTargetQ()
	if menu.harass.qcombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellQ.range) then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
					if not preds.collision.get_prediction(spellQ, pos, target) then
						if not meowmeowcheck(player.pos, vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) then
							if menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
	end
	if menu.harass.ecombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < spellE.range) then
				local pos = preds.circular.get_prediction(spellE, target)
				if pos and pos.startPos:dist(pos.endPos) < spellE.range then
					player:castSpell("self", 2)
				end
			end
		end
	end
end
local function Combo()
	local target = GetTargetQ()
	if menu.combo.qcombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellQ.range) then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
					if not preds.collision.get_prediction(spellQ, pos, target) then
						if not meowmeowcheck(player.pos, vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) then
							if menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
	end
	if menu.combo.ecombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < spellE.range) then
				local pos = preds.circular.get_prediction(spellE, target)
				if pos and pos.startPos:dist(pos.endPos) < spellE.range then
					if not menu.combo.cce:get() then
						player:castSpell("self", 2)
					end
					if menu.combo.cce:get() then
						if
							not (target.buff[5] or target.buff[8] or target.buff[24] or target.buff[10] or target.buff[11] or target.buff[22] or
								target.buff[8] or
								target.buff[21])
						 then
							player:castSpell("self", 2)
						end
					end
				end
			end
		end
	end
	if menu.combo.rcombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < spellR.range) then
				if
					(target.health / target.maxHealth) * 100 <= menu.combo.hpr:get() and
						target.pos:dist(player.pos) >= menu.combo.minr:get()
				 then
					if menu.combo.blacklist[target.charName] and not menu.combo.blacklist[target.charName]:get() then
						player:castSpell("obj", 3, target)
					end
				end
			end
		end
	end
end

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
	WGapcloser()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.clearkey:get() then
		JungleClear()
		LaneClear()
	end
	if not player.isRecalling then
		if menu.SpellsMenu.cc:get() then
			if
				(player.buff[5] or player.buff[8] or player.buff[24] or player.buff[23] or player.buff[11] or player.buff[22] or
					player.buff[8] or
					player.buff[21])
			 then
				player:castSpell("self", 1)
			end
		end

		if menu.SpellsMenu.enable:get() then
			for i = 1, #evade.core.active_spells do
				local spell = evade.core.active_spells[i]

				if spell.data.spell_type == "Target" and spell.target == player and spell.owner.type == TYPE_HERO then
					if not spell.name:find("crit") then
						if not spell.name:find("basicattack") then
							if menu.SpellsMenu.targeteteteteteed:get() then
								player:castSpell("self", 1)
							end
						end
					end
				elseif
					spell.polygon and spell.polygon:Contains(player.path.serverPos) ~= 0 and
						(not spell.data.collision or #spell.data.collision == 0)
				 then
					for _, k in pairs(database) do
						if
							spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
								menu.SpellsMenu[k.charName][_].hp:get() >= (player.health / player.maxHealth) * 100
						 then
							if spell.missile then
								if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
									player:castSpell("self", 1)
								end
							end
							if spell.name:find(_:lower()) then
								if k.speeds == math.huge or spell.data.spell_type == "Circular" then
									player:castSpell("self", 1)
								end
							end
							if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
								player:castSpell("self", 1)
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
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
