local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Karma by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Karma by Kornis'!")
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
	range = 950,
	speed = 1400,
	width = 100,
	delay = 0.25,
	boundingRadiusMod = 1,
	collision = {
		hero = false,
		minion = true,
		wall = true
	}
}

local spellW = {
	range = 675
}

local spellE = {
	range = 800
}

local spellR = {
	range = 0
}
local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local tSelector = avada_lib.targetSelector
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Karma")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
menu.combo:dropdown("mode", "Combo Mode", 1, {"R - Q", "R - W"})
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:slider("forcew", " ^- Force R - W if my HP lower than X", 25, 1, 100, 1)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:slider("forcee", " ^- Force R - E if X Allies in Range", 3, 1, 5, 1)
menu.combo:keybind("survivecombo", "Survival Combo", "T", nil)
menu.combo:keybind("chasingcombo", "Chasing Combo", "Z", nil)

menu:menu("harass", "Harass")
menu.harass:dropdown("mode", "Harass Mode", 1, {"R - Q", "R - W"})
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("wcombo", "Use W in Harass", true)
menu.harass:boolean("ecombo", "Use E in Harass", true)

menu:menu("jungleclear", "Jungle Clear")
menu.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.jungleclear:boolean("usew", "Use W in Jungle Clear", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", false)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 233, 121, 121)

menu:menu("misc", "Misc.")
menu.misc:menu("blacklist", "Anti-Gapclose Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu.misc:boolean("GapAS", "Use W for Anti-Gapclose", true)
menu.misc:slider("health", " ^- Only if my Health Percent < X", 50, 1, 100, 1)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
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
menu:keybind("rq", "R-Q to Mouse", "G", nil)

local function AutoInterrupt(spell)
	if menu.rq:get() then
		if spell and spell.owner.type == TYPE_HERO and spell.owner == player then
			if spell.name == "KarmaMantra" then
				player:castSpell("pos", 0, mousePos)
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
local function WGapcloser()
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
local TargetSelectionE = function(res, obj, dist)
	if dist < spellQ.range + 150 then
		res.obj = obj
		return true
	end
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
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
local function something()
	local countminion = {}
	local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			local pos = preds.linear.get_prediction(spellQ, target)
			if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
				local collision = preds.collision.get_prediction(spellQ, pos, target)
				if not collision then
				else
					for i = 1, #collision do
						local obj = collision[i]
						if
							obj and obj.type and obj.type == TYPE_MINION and obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 230
						 then
							countminion[#countminion + 1] = obj
						end
					end
				end
			end
		end
	end
	return countminion
end
local function Harass()
	if menu.harass.mode:get() == 1 then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if player:spellSlot(0).state == 0 and player:spellSlot(3).state == 0 and menu.harass.qcombo:get() then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						local collision = preds.collision.get_prediction(spellQ, pos, target)
						if not collision then
							player:castSpell("self", 3)
						else
							if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
											obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 230 - obj.boundingRadius
									 then
										player:castSpell("self", 3)
									end
								end
							end
						end
					end
				end

				if menu.harass.qcombo:get() then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						local collision = preds.collision.get_prediction(spellQ, pos, target)
						if not collision then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						else
							if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
								for i = 1, #collision do
									local obj = collision[i]

									if
										obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
											obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 230 - obj.boundingRadius
									 then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
			end
		end
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if menu.harass.qcombo:get() and not player.buff["karmamantra"] then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						local collision = preds.collision.get_prediction(spellQ, pos, target)
						if not collision then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						else
							if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
											obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 130 - obj.boundingRadius
									 then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
				if menu.harass.qcombo:get() and player.buff["karmamantra"] then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						local collision = preds.collision.get_prediction(spellQ, pos, target)
						if not collision then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						else
							if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
											obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 230 - obj.boundingRadius
									 then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
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
		if menu.harass.ecombo:get() then
			local target = GetTargetQ()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) <= spellQ.range then
						player:castSpell("self", 2)
					end
				end
			end
		end
	end
	if menu.harass.mode:get() == 2 then
		local target = GetTargetW()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if player:spellSlot(1).state == 0 and player:spellSlot(3).state == 0 and menu.harass.wcombo:get() then
					player:castSpell("self", 3)
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
		if not player.buff["karmamantra"] and (player:spellSlot(1).state ~= 0 or player:spellSlot(3).state ~= 0) then
			if menu.harass.qcombo:get() then
				local target = GetTargetQ()
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						local pos = preds.linear.get_prediction(spellQ, target)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
							local collision = preds.collision.get_prediction(spellQ, pos, target)
							if not collision then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							else
								if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
									for i = 1, #collision do
										local obj = collision[i]
										if
											obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
												obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 130 - obj.boundingRadius
										 then
											player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if menu.harass.ecombo:get() and not player.buff["karmamantra"] then
			local target = GetTargetW()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) <= spellW.range then
						player:castSpell("self", 2)
					end
				end
			end
		end
	end
end

local function Combo()
	if menu.combo.forcew:get() >= (player.health / player.maxHealth) * 100 then
		if player:spellSlot(1).state == 0 and player:spellSlot(3).state == 0 and menu.combo.wcombo:get() then
			local target = GetTargetW()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if menu.combo.wcombo:get() then
						player:castSpell("self", 3)
					end
				end
				if menu.combo.wcombo:get() then
					player:castSpell("obj", 1, target)
				end
			end
		end
	end
	if menu.combo.forcee:get() <= #count_allies_in_range(player.pos, 600) + 1 then
		if player:spellSlot(2).state == 0 and player:spellSlot(3).state == 0 and menu.combo.ecombo:get() then
			local target = GetTargetQ()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if menu.combo.ecombo:get() then
						player:castSpell("self", 3)
					end
				end
				if menu.combo.ecombo:get() then
					player:castSpell("self", 2)
				end
			end
		end
	end
	if menu.combo.mode:get() == 1 then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if player:spellSlot(0).state == 0 and player:spellSlot(3).state == 0 and menu.combo.qcombo:get() then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						local collision = preds.collision.get_prediction(spellQ, pos, target)
						if not collision then
							player:castSpell("self", 3)
						else
							if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
											obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 230 - obj.boundingRadius
									 then
										player:castSpell("self", 3)
									end
								end
							end
						end
					end
				end

				if menu.combo.qcombo:get() then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						local collision = preds.collision.get_prediction(spellQ, pos, target)
						if not collision then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						else
							if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
											obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 230 - obj.boundingRadius
									 then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
			end
		end
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if menu.combo.qcombo:get() and not player.buff["karmamantra"] then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						local collision = preds.collision.get_prediction(spellQ, pos, target)
						if not collision then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						else
							if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
											obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 130 - obj.boundingRadius
									 then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
				if menu.combo.qcombo:get() and player.buff["karmamantra"] then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						local collision = preds.collision.get_prediction(spellQ, pos, target)
						if not collision then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						else
							if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
											obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 230 - obj.boundingRadius
									 then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
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
		if menu.combo.ecombo:get() then
			local target = GetTargetQ()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) <= spellQ.range then
						player:castSpell("self", 2)
					end
				end
			end
		end
	end
	if menu.combo.mode:get() == 2 then
		local target = GetTargetW()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if player:spellSlot(1).state == 0 and player:spellSlot(3).state == 0 and menu.combo.wcombo:get() then
					player:castSpell("self", 3)
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
		if not player.buff["karmamantra"] and (player:spellSlot(1).state ~= 0 or player:spellSlot(3).state ~= 0) then
			if menu.combo.qcombo:get() then
				local target = GetTargetQ()
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						local pos = preds.linear.get_prediction(spellQ, target)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
							local collision = preds.collision.get_prediction(spellQ, pos, target)
							if not collision then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							else
								if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
									for i = 1, #collision do
										local obj = collision[i]
										if
											obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
												obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 130 - obj.boundingRadius
										 then
											player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if menu.combo.ecombo:get() and not player.buff["karmamantra"] then
			local target = GetTargetW()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) <= spellW.range then
						player:castSpell("self", 2)
					end
				end
			end
		end
	end
end

local function JungleClear()
	if menu.jungleclear.useq:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellQ.range
			 then
				local seg = preds.linear.get_prediction(spellQ, minion)
				if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
					player:castSpell("pos", 0, vec3(seg.endPos.x, minion.y, seg.endPos.y))
				end
			end
		end
	end
	if menu.jungleclear.usew:get() and player:spellSlot(1).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellW.range
			 then
				player:castSpell("obj", 1, minion)
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
	if menu.combo.survivecombo:get() then
		if not orb.combat.is_active() then
			player:move(mousePos)
		end
		local target = GetTargetW()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local target = GetTargetW()
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						if player:spellSlot(1).state == 0 and player:spellSlot(3).state == 0 and menu.harass.wcombo:get() then
							player:castSpell("self", 3)
						end
					end
				end

				local target = GetTargetW()
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						if target.pos:dist(player.pos) <= spellW.range then
							player:castSpell("obj", 1, target)
						end
					end
				end
			end
			if not player.buff["karmamantra"] then
				local target = GetTargetW()
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						if target.pos:dist(player.pos) <= spellW.range then
							player:castSpell("self", 2)
						end
					end
				end
			end
		end

		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
					local collision = preds.collision.get_prediction(spellQ, pos, target)
					if not collision then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					else
						if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
							for i = 1, #collision do
								local obj = collision[i]
								if
									obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
										obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 130 - obj.boundingRadius
								 then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end
	if menu.combo.chasingcombo:get() then
		if not orb.combat.is_active() then
			player:move(mousePos)
		end
		local target = GetTargetE()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if not player.buff["karmamantra"] then
					if target.pos:dist(player.pos) <= spellQ.range + 150 then
						player:castSpell("self", 2)
					end
				end
			end
		end
		local target = GetTargetW()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
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
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if target.pos:dist(player.pos) <= spellQ.range then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						local collision = preds.collision.get_prediction(spellQ, pos, target)
						player:castSpell("self", 3)
					end
				end
			end
		end

		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
					local collision = preds.collision.get_prediction(spellQ, pos, target)
					if not collision then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					else
						if (#something() == table.getn(preds.collision.get_prediction(spellQ, pos, target))) then
							for i = 1, #collision do
								local obj = collision[i]
								if
									obj and obj.type and obj.type == TYPE_MINION and not obj.path.isActive and
										obj.pos:dist(vec3(pos.endPos.x, mousePos.y, pos.endPos.y)) < 130 - obj.boundingRadius
								 then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end

	if menu.rq:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if player.manaCost0 <= player.mana then
			player:castSpell("self", 3)
		end
		if player.buff["karmamantra"] then
			player:castSpell("pos", 0, mousePos)
		end
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
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
