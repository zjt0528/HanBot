local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Bra by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Rakan by Kornis'!")
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
	speed = 1600,
	width = 80,
	delay = 0.25,
	boundingRadiusMod = 1,
	collision = {
		hero = false,
		minion = true,
		wall = true
	}
}

local spellW = {
	range = 650
}

local spellE = {
	range = 200
}

local spellR = {
	range = 1200,
	speed = 1500,
	delay = 0.6,
	width = 130,
	boundingRadiusMod = 1,
	collision = {
		hero = false,
		minion = false,
		wall = true
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
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Braum")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo with Logic", true)
menu.combo:boolean("rcombo", "Use R in Combo", false)
menu.combo:slider("mine", " ^- Min. Enemies", 2, 1, 5, 1)
menu.combo:slider("mina", " ^- Min. Allies", 1, 1, 4, 1)
menu.combo:keybind("semir", "Semi-R Key", "T", nil)
menu.combo.semir:set("tooltip", "It Ignores how many Enemies it can hit.")
menu.combo:keybind("semiwe", "W > E Lowest Health Ally", "G", nil)

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)

menu:menu("we", "W > E Settings")
menu.we:keybind("wekey", "W > E  Key", "Z", nil)
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
menu:menu("jungleclear", "Jungle Clear")
menu.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 233, 121, 121)
menu:menu("miscc", "Misc.")
menu.miscc:menu("flee", "Flee")
menu.miscc.flee:keybind("fleekey", "Flee Key", "G", nil)
menu.miscc.flee:boolean("fleew", "Use W to Flee", true)
menu.miscc:menu("misc", "Anti-Gapclose Settings")
menu.miscc.misc:boolean("GapA", "Use Q for Anti-Gapclose", true)
menu.miscc.misc:menu("blacklist", "Anti-Gapclose Blacklist")

local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.miscc.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("SpellsMenu", "Shielding")
menu.SpellsMenu:boolean("enable", "Enable Shielding", true)
menu.SpellsMenu:slider("dontjump", "Don't Shield if my Health lower than X", 20, 1, 100, 1)
menu.SpellsMenu.dontjump:set("tooltip", "Prevents being suicidal in some situations.")

menu.SpellsMenu:menu("blacklist", "Ally Shield Blacklist")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	menu.SpellsMenu.blacklist:boolean(allies.charName, "Don't Shield: " .. allies.charName, false)
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

			if i.type ~= "circular" and i.speeds ~= math.huge then
				if (menu.SpellsMenu[i.charName] == nil) then
					menu.SpellsMenu:menu(i.charName, i.charName)
				end
				menu.SpellsMenu[i.charName]:menu(_, "" .. i.charName .. " | " .. (str[i.slot] or "?") .. " " .. _)

				menu.SpellsMenu[i.charName][_]:boolean("Dodge", "Enable Block", true)

				menu.SpellsMenu[i.charName][_]:slider("hp", "HP to Dodge", 100, 1, 100, 5)
			end
		end
	end
end
menu.SpellsMenu:header("hello", " -- Misc. -- ")
menu.SpellsMenu:boolean("targeteteteteteed", "Shield on Targeted Spells", true)
menu:header("hello", " -- Key Settings -- ")
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
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

local function AutoInterrupt(spell)
	if (player.health / player.maxHealth) * 100 >= menu.SpellsMenu.dontjump:get() then
		if menu.SpellsMenu.targeteteteteteed:get() then
			local allies = common.GetAllyHeroes()
			for z, ally in ipairs(allies) do
				if ally then
					if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
						if
							spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally and
								not (spell.name:find("BasicAttack") or spell.name:find("crit"))
						 then
							if menu.SpellsMenu.targeteteteteteed:get() then
								if ally.pos:dist(player.pos) <= spellW.range then
									player:castSpell("obj", 1, ally)
								end
								if ally.pos:dist(player.pos) <= 200 then
									player:castSpell("pos", 2, spell.owner.pos)
								end
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

local TargetSelectionWQ = function(res, obj, dist)
	if dist < spellW.range + spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetWQ = function()
	return TS.get_result(TargetSelectionWQ).obj
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
local TargetSelectionR = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end
local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
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
	local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if menu.harass.qcombo:get() then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
					if not preds.collision.get_prediction(spellQ, pos, target) then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
end

local function Combo()
	local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if menu.combo.qcombo:get() then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
					if not preds.collision.get_prediction(spellQ, pos, target) then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
	if menu.combo.wcombo:get() then
		local target = GetTargetWQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local allies = common.GetAllyHeroes()
				for z, ally in ipairs(allies) do
					if ally and ally.charName ~= "Braum" and ally.pos:dist(player.pos) <= spellW.range then
						if
							ally.pos:dist(target.pos) < 500 and ally.pos:dist(player.pos) > 200 and player.pos:dist(target.pos) > 300 and
								(player.health / player.maxHealth) * 100 > 20
						 then
							player:castSpell("obj", 1, ally)
						end
					end
				end
			end
		end
	end
	if menu.combo.rcombo:get() then
		local target = GetTargetR()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local pos = preds.linear.get_prediction(spellR, target)
				if pos and pos.startPos:dist(pos.endPos) < spellR.range then
					if
						#count_enemies_in_range(vec3(pos.endPos.x, mousePos.y, pos.endPos.y), 190) >= menu.combo.mine:get() and
							#count_allies_in_range(player.pos, 800) > menu.combo.mina:get()
					 then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
end
local function GetClosestMob()
	local closestMinion = nil
	local closestMinionDistance = 9999

	for i = 0, objManager.minions.size[TEAM_ALLY] - 1 do
		local minion = objManager.minions[TEAM_ALLY][i]
		if
			minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
				minion.pos:dist(player.pos) < spellW.range and
				minion.pos:dist(mousePos) < player.pos:dist(mousePos) and
				minion.type == TYPE_MINION
		 then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(player.pos) < spellW.range then
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
			if hero.team == TEAM_ALLY and hero ~= player and not hero.isDead and hero.pos:dist(player.pos) <= spellW.range then
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
local function JungleClear()
	if menu.jungleclear.useq:get() then
		local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL)
		for i, minion in pairs(enemyMinionsQ) do
			if minion and not minion.isDead and minion.moveSpeed > 0 and minion.isTargetable and common.IsValidTarget(minion) then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				if minionPos:dist(player.pos) <= spellQ.range then
					local pos = preds.linear.get_prediction(spellQ, minion)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
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
	if menu.combo.semir:get() then
		local target = GetTargetR()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local pos = preds.linear.get_prediction(spellR, target)
				if pos and pos.startPos:dist(pos.endPos) < spellR.range then
					player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
	if menu.combo.semiwe:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if PrioritizedAllyLow() then
			player:castSpell("obj", 1, PrioritizedAllyLow())
			for i = 0, objManager.enemies_n - 1 do
				local enemies = objManager.enemies[i]
				if
					enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
						player.pos:dist(enemies) < spellR.range
				 then
					if player.pos:dist(PrioritizedAllyLow().pos) < 300 then
						player:castSpell("pos", 2, enemies.pos)
					end
				end
			end
		end
	end
	if menu.we.wekey:get() then
		if PrioritizedAllyWE() then
			player:castSpell("obj", 1, PrioritizedAllyWE())
			for i = 0, objManager.enemies_n - 1 do
				local enemies = objManager.enemies[i]
				if
					enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
						player.pos:dist(enemies) < spellR.range
				 then
					if player.pos:dist(PrioritizedAllyWE().pos) < 300 then
						player:castSpell("pos", 2, enemies.pos)
					end
				end
			end
		end
	end
	if menu.miscc.flee.fleekey:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if menu.miscc.flee.fleew:get() then
			local minion = GetClosestMob()
			if minion then
				player:castSpell("obj", 1, minion)
			end
		end
	end
	if (player.health / player.maxHealth) * 100 >= menu.SpellsMenu.dontjump:get() then
		if not player.isRecalling then
			if menu.SpellsMenu.enable:get() then
				for i = 1, #evade.core.active_spells do
					local spell = evade.core.active_spells[i]

					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally then
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
									if not spell.name:find("crit") then
										if not spell.name:find("basicattack") then
											if menu.SpellsMenu.targeteteteteteed:get() then
												if ally.pos:dist(player.pos) <= spellW.range then
													player:castSpell("obj", 1, ally)
												end
												if ally.pos:dist(player.pos) <= 200 then
													player:castSpell("pos", 2, spell.owner.pos)
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
											spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_] and
												menu.SpellsMenu[k.charName][_].Dodge:get() and
												menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
										 then
											if ally.pos:dist(player.pos) <= spellW.range and player.mana > player.manaCost1 then
												if spell.missile then
													if
														(ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + player.pos:dist(ally.pos) / 1700)
													 then
														player:castSpell("obj", 1, ally)

														player:castSpell("pos", 2, spell.missile.startPos)
													end
												end
											end
											if ally.pos:dist(player.pos) <= 200 then
												if spell.missile then
													if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.2) then
														if ally.pos:dist(player.pos) <= 200 then
															player:castSpell("pos", 2, spell.missile.startPos)
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
	if menu.miscc.misc.GapA:get() then
		local seg = {}
		local target =
			TS.get_result(
			function(res, obj, dist)
				if dist <= spellQ.range and obj.path.isActive and obj.path.isDashing then --add invulnverabilty check
					res.obj = obj
					return true
				end
			end
		).obj
		if target then
			local pred_pos = preds.core.lerp(target.path, network.latency + spellQ.delay, target.path.dashSpeed)
			if pred_pos and pred_pos:dist(player.path.serverPos2D) <= spellQ.range then
				seg.startPos = player.path.serverPos2D
				seg.endPos = vec2(pred_pos.x, pred_pos.y)

				if not preds.collision.get_prediction(spellQ, seg, target.pos:to2D()) then
					if menu.miscc.misc.blacklist[target.charName] and not menu.miscc.misc.blacklist[target.charName]:get() then
						player:castSpell("pos", 0, vec3(pred_pos.x, target.y, pred_pos.y))
					end
				end
			end
		end
	end

	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.clearkey:get() then
		JungleClear()
	end
end
local function OnDraw()
	--print("Drawing")

	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 100)
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
