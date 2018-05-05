local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Zilean by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Zilean by Kornis'!")
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
	delay = 0.7,
	radius = 140,
	speed = 5000,
	range = 900,
	boundingRadiusMod = 1
}

local spellW = {
	range = 0
}

local spellE = {
	range = 600
}

local spellR = {
	range = 900
}

local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local tSelector = avada_lib.targetSelector
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Zilean")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W for Q Reset", true)
menu.combo:boolean("whit", " ^- Only if Q Hits", false)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("prioritye", " ^- Priority E First", false)
menu.combo:menu("rset", "R Settings")
menu.combo.rset:menu("whitelist", "Ally Settings")
menu.combo.rset.whitelist:boolean("autor", "Auto R", true)
menu.combo.rset.whitelist.autor:set("tooltip", "Checks if Incoming Spell will hit and <= X Health")
for i = 0, objManager.allies_n - 1 do
	local ally = objManager.allies[i]

	menu.combo.rset.whitelist:slider(ally.charName, "Use R if X HP: " .. ally.charName, 20, 1, 100, 1)
end
menu.combo.rset:keybind("semir", "Semi-R on Lowest Health Ally", "T", nil)
menu.combo:keybind("qwq", "Q-W-Q to Mouse", "G", nil)

menu:menu("blacklist", "R Blacklist")
for i = 0, objManager.allies_n - 1 do
	local ally = objManager.allies[i]

	menu.blacklist:boolean(ally.charName, "Block: " .. ally.charName, false)
end

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Combo", true)
menu.harass:boolean("wcombo", "Use W for Q Reset", true)
menu.harass:boolean("whit", " ^- Only if Q Hits", false)
menu.harass:boolean("ecombo", "Use E in Combo", true)

menu:menu("we", "W Boost Settings")
menu.we:keybind("wekey", "W Boost Ally", "Z", nil)
menu.we:header("uhhh", "0 - Disabled, 1 - Biggest Priority, 5 - Lowest Priority")
for i = 0, objManager.allies_n - 1 do
	local allies = objManager.allies[i]

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
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawr", "Draw R Range", false)
menu.draws:color("colorr", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawdamage", "Draw Damage", true)
menu.draws:boolean("drawinclude", " ^- Include Q Reset", true)

menu:menu("misc", "Misc.")
menu.misc:boolean("autoe", "Auto E on Slowed Ally", true)
menu.misc:boolean("autoq", "Auto Q on CC", true)
menu.misc:boolean("GapAS", "Use E for Anti-Gapclose", true)
menu.misc:menu("blacklist", "Anti-Gapclose Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("flee", "Flee")
menu.flee:keybind("fleekey", "Flee Key", "A", nil)
menu.flee:boolean("fleew", " ^- Use W for E Reset", false)
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

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

local QLevelDamage = {75, 115, 165, 230, 300}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAP() * .9)), player)
	end
	return damage
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

local function PrioritizedAllyWE()
	local heroTarget = nil
	for i = 0, objManager.allies_n - 1 do
		local hero = objManager.allies[i]
		if not player.isRecalling then
			if
				hero.team == TEAM_ALLY and not hero.isDead and menu.we[hero.charName]:get() > 0 and
					hero.pos:dist(player.pos) <= spellE.range
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

local function AutoInterrupt(spell)
	for i = 0, objManager.allies_n - 1 do
		local ally = objManager.allies[i]

		if ally then
			if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
				if not spell.name:find("crit") then
					if not spell.name:find("BasicAttack") then
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
	for i = 0, objManager.allies_n - 1 do
		local ally = objManager.allies[i]

		if ally and ally.pos:dist(player.pos) <= spellE.range then
			if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
				if spell.name:find("BasicAttack") then
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
	for i = 0, objManager.allies_n - 1 do
		local ally = objManager.allies[i]

		if ally and ally.pos:dist(player.pos) <= spellE.range then
			if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
				if spell.name:find("crit") then
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
	for i = 0, objManager.allies_n - 1 do
		local ally = objManager.allies[i]

		if ally and ally.pos:dist(player.pos) <= spellE.range then
			if spell.owner.type == TYPE_TURRET and spell.owner.team == TEAM_ENEMY and spell.target == ally then
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
							player:castSpell("obj", 2, dasher)
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

local function Harass()
	local target = GetTargetQ()
	if menu.harass.ecombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < spellE.range) then
				player:castSpell("obj", 2, target)
			end
		end
	end
	if menu.harass.qcombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < spellQ.range) then
				local pos = preds.circular.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
					player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
	if menu.harass.wcombo:get() then
		if menu.harass.whit:get() then
			if player:spellSlot(0).state ~= 0 and player.mana > player.manaCost0 + player.manaCost1 then
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) < spellQ.range) then
						if target.buff["zileanqenemybomb"] then
							local pos = preds.circular.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								player:castSpell("self", 1)
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
		if not menu.harass.whit:get() then
			if player:spellSlot(0).state ~= 0 and player.mana > player.manaCost0 + player.manaCost1 then
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) < spellQ.range) then
						local pos = preds.circular.get_prediction(spellQ, target)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
							player:castSpell("self", 1)
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
	end
end

local aaaaaaaaaaaaammm = 0
local function Combo()
	local target = GetTargetQ()
	if menu.combo.prioritye:get() then
		if menu.combo.ecombo:get() then
			if player:spellSlot(2).state == 0 then
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) < spellE.range) then
						player:castSpell("obj", 2, target)
						aaaaaaaaaaaaammm = game.time + 0.3
					end
				end
			end
		end
		if aaaaaaaaaaaaammm - game.time < 0 then
			if menu.combo.qcombo:get() then
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) <= spellQ.range) then
						local pos = preds.circular.get_prediction(spellQ, target)
						if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.combo.wcombo:get() and menu.combo.qcombo:get() then
				if menu.combo.whit:get() then
					if player:spellSlot(0).state ~= 0 and player.mana > player.manaCost0 + player.manaCost1 then
						if common.IsValidTarget(target) and target then
							if (target.pos:dist(player) <= spellQ.range) then
								if target.buff["zileanqenemybomb"] then
									local pos = preds.circular.get_prediction(spellQ, target)
									if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
										player:castSpell("self", 1)

										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
				if not menu.combo.whit:get() then
					if player:spellSlot(0).state ~= 0 and player.mana > player.manaCost0 + player.manaCost1 then
						if common.IsValidTarget(target) and target then
							if (target.pos:dist(player) <= spellQ.range) then
								local pos = preds.circular.get_prediction(spellQ, target)
								if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
									player:castSpell("self", 1)
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end
	if not menu.combo.prioritye:get() then
		if menu.combo.ecombo:get() then
			if common.IsValidTarget(target) and target then
				if (target.pos:dist(player) < spellE.range) then
					player:castSpell("obj", 2, target)
				end
			end
		end
		if menu.combo.qcombo:get() then
			if common.IsValidTarget(target) and target then
				if (target.pos:dist(player) < spellQ.range) then
					local pos = preds.circular.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
		if menu.combo.wcombo:get() and menu.combo.qcombo:get() then
			if menu.combo.whit:get() then
				if player:spellSlot(0).state ~= 0 and player.mana > player.manaCost0 + player.manaCost1 then
					if common.IsValidTarget(target) and target then
						if (target.pos:dist(player) < spellQ.range) then
							if target.buff["zileanqenemybomb"] then
								local pos = preds.circular.get_prediction(spellQ, target)
								if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
									player:castSpell("self", 1)
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
			if not menu.combo.whit:get() then
				if player:spellSlot(0).state ~= 0 and player.mana > player.manaCost0 + player.manaCost1 then
					if common.IsValidTarget(target) and target then
						if (target.pos:dist(player) < spellQ.range) then
							local pos = preds.circular.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								player:castSpell("self", 1)
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
	end
end

local allow = true
local timer = 0
local meowsomethinggggg
local function OnTick()
	if menu.combo.qwq:get() then
		if player.pos:dist(mousePos) < spellQ.range then
			player:castSpell("pos", 0, mousePos)
		end
		if player.pos:dist(mousePos) > spellQ.range then
			local EPOS = player.pos + (mousePos - player.pos):norm() * 800
			player:castSpell("pos", 0, EPOS)
		end
		if player:spellSlot(0).state ~= 0 and player.mana > player.manaCost0 + player.manaCost1 then
			player:castSpell("self", 1)
		end
		if player.pos:dist(mousePos) < spellQ.range then
			player:castSpell("pos", 0, mousePos)
		end
		if player.pos:dist(mousePos) > spellQ.range then
			local EPOS = player.pos + (mousePos - player.pos):norm() * 800
			player:castSpell("pos", 0, EPOS)
		end
	end
	if menu.misc.autoe:get() then
		for i = 0, objManager.enemies_n - 1 do
			local ally = objManager.enemies[i]

			if ally then
				if (ally.buff[10]) then
					if ally.pos:dist(player.pos) <= spellE.range then
						player:castSpell("obj", 2, ally)
					end
				end
			end
		end
	end
	if menu.misc.autoq:get() then
		for i = 0, objManager.enemies_n - 1 do
			local enemies = objManager.enemies[i]
			if
				enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
					player.pos:dist(enemies) < spellQ.range
			 then
				if
					(enemies.buff[5] or enemies.buff[8] or enemies.buff[24] or enemies.buff[11] or enemies.buff[22] or enemies.buff[8] or
						enemies.buff[21])
				 then
					local pos = preds.circular.get_prediction(spellQ, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
	if menu.flee.fleekey:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if player:spellSlot(2).state == 0 then
			player:castSpell("self", 2)
			meowsomethinggggg = game.time + 0.5
		end
		if
			menu.flee.fleew:get() and not player.buff["timewarp"] and player:spellSlot(2).state ~= 0 and
				meowsomethinggggg - game.time < 0
		 then
			player:castSpell("self", 1)
		end
	end
	if menu.combo.rset.whitelist.autor:get() then
		for i = 0, objManager.allies_n - 1 do
			local ally = objManager.allies[i]

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
	if menu.combo.rset.semir:get() and not common.NearFountain() then
		if PrioritizedAllyLow() then
			player:castSpell("obj", 3, PrioritizedAllyLow())
		end
	end
	if menu.we.wekey:get() then
		if PrioritizedAllyWE() then
			player:castSpell("obj", 2, PrioritizedAllyWE())
		end
	end
	WGapcloser()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end

	if not player.isRecalling then
		for i = 1, #evade.core.active_spells do
			local spell = evade.core.active_spells[i]

			for i = 0, objManager.allies_n - 1 do
				local ally = objManager.allies[i]

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
									if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.2) then
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
			for i = 0, objManager.allies_n - 1 do
				local ally = objManager.allies[i]
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
									if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.2) then
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

function DrawDamagesEW(target)
	if target.isVisible and not target.isDead then
		for i = 0, graphics.anchor_n - 1 do
			local obj = objManager.toluaclass(graphics.anchor[i].ptr)
			if obj.type == player.type and obj.team ~= player.team and obj.isOnScreen then
				local hp_bar_pos = graphics.anchor[i].pos
				local xPos = hp_bar_pos.x - 46
				local yPos = hp_bar_pos.y + 11.5
				if obj.charName == "Annie" then
					yPos = yPos + 2
				end

				local Qdmg = 0

				EQmg = QDamage(obj) * 2

				local damage = obj.health - Qdmg

				local x1 = xPos + ((obj.health / obj.maxHealth) * 102)
				local x2 = xPos + (((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if (Qdmg < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if (Qdmg > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if (math.floor(QDamage(target) * 2 / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target) * 2)) ..
					" (" .. tostring(math.floor(QDamage(target) * 2 / target.health * 100)) .. "%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if (math.floor(QDamage(target) * 2 / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target) * 2)) ..
					" (" .. tostring(math.floor(QDamage(target) * 2 / target.health * 100)) .. "%)" .. "Kilable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 150, 255, 200)
			)
		end
	end
end
function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		for i = 0, graphics.anchor_n - 1 do
			local obj = objManager.toluaclass(graphics.anchor[i].ptr)
			if obj.type == player.type and obj.team ~= player.team and obj.isOnScreen then
				local hp_bar_pos = graphics.anchor[i].pos
				local xPos = hp_bar_pos.x - 46
				local yPos = hp_bar_pos.y + 11.5
				if obj.charName == "Annie" then
					yPos = yPos + 2
				end

				local Qdmg = 0

				EQmg = QDamage(obj)

				local damage = obj.health - Qdmg

				local x1 = xPos + ((obj.health / obj.maxHealth) * 102)
				local x2 = xPos + (((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if (Qdmg < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if (Qdmg > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if (math.floor(QDamage(target) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target))) ..
					" (" .. tostring(math.floor(QDamage(target) / target.health * 100)) .. "%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if (math.floor(QDamage(target) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target))) ..
					" (" .. tostring(math.floor(QDamage(target) / target.health * 100)) .. "%)" .. "Kilable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 150, 255, 200)
			)
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
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 100)
		end
	end
	if menu.draws.drawdamage:get() then
		for i = 0, objManager.enemies_n - 1 do
			local enemies = objManager.enemies[i]
			if enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and player.pos:dist(enemies) < 2000 then
				if not menu.draws.drawinclude:get() then
					DrawDamagesE(enemies)
				end
				if menu.draws.drawinclude:get() then
					DrawDamagesEW(enemies)
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
