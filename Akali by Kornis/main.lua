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
	range = 600
}

local spellW = {
	range = 270
}

local spellE = {
	range = 300
}

local spellR = {
	range = 700
}
local tSelector = avada_lib.targetSelector
local menu = menu("Akali By Kornis", "Akali By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("procq", " ^-Priority Q Proc.", true)
menu.combo:boolean("wcombo", "Use W to Gapclose", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)

menu.combo:boolean("rcombo", "Use R in Combo", true)
menu.combo:slider("saver", " ^-Save X R Stacks", 1, 0, 3, 1)
menu.combo:slider("suicidal", " ^-Don't jump in X Enemies", 3, 0, 5, 1)
menu.combo:slider("minr", " ^-Min. R Range", 250, 0, 400, 1)
menu.combo:boolean("gappppr", " ^-Use R Minions for Gapclose", true)
--menu.combo:keybind("wrcombo", "W > R Gapclose", "T", nil)
menu.combo:keybind("turret", "W / R Under-Turret Toggle", "Z", nil)
menu.combo:boolean("items", "Use Items", true)
menu.combo:boolean("afterr", " ^-Only after R", false)
menu:menu("blacklist", "R Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu:menu("harass", "Harass")
menu.harass:boolean("qharass", "Use Q to Harass", true)
menu.harass:boolean("wharass", "Use W to Gapclose", true)
menu.harass:boolean("eharass", "Use E to Harass", true)
menu.harass:boolean("autoe", "AUTO E if Enemy in Range", false)

menu:menu("laneclear", "Lane Clear")
menu.laneclear:slider("mana", "Energy Manager", 30, 0, 100, 1)
menu.laneclear:boolean("farmlogic", "Use Farm Logic", true)
menu.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.laneclear:boolean("farme", "Use E to Farm", true)

menu:menu("lasthit", "Last Hit")
menu.lasthit:boolean("qlasthit", "Use Q", true)
menu.lasthit:boolean("qaa", "  ^- Don't Last Hit in AA Range", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)
menu.killsteal:boolean("kse", "Killsteal with E", true)
menu.killsteal:boolean("ksr", "Killsteal with R", true)
menu.killsteal:boolean("ksgap", "Gapclose R for Q", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 0x66, 0x33, 0x00)
--menu.draws:boolean("drawwr", "Draw W + R Range", true)
--menu.draws:color("colorwr", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawtoggle", "Draw Under-Turret Toggle", true)
menu.draws:boolean("drawgapclose", "Draw Gaclose Lines", true)

menu:menu("flee", "Flee")
menu.flee:boolean("fleew", "Use W to Flee", true)
menu.flee:boolean("fleer", "Use R to Flee", true)
menu.flee:keybind("fleekey", "Flee Key:", "G", nil)
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
TS.load_to_menu(menu)

local function CalcMagicDmg(target, amount, from)
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
local function CalcADmg(target, amount, from)
	local from = from or player or objmanager.player
	local target = target or orb.combat.target
	local amount = amount or 0
	local targetD = target.armor * math.ceil(from.percentBonusArmorPenetration)
	local dmgMul = 100 / (100 + targetD)
	amount = amount * dmgMul
	return math.floor(amount)
end
-- Sorry for this mess! :c
local function GetClosestMobForLogic()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion then
			local minionPos = vec3(minion.x, minion.y, minion.z)

			local minionDistanceToMouse = minionPos:dist(player)

			if minionDistanceToMouse < closestMinionDistance then
				closestMinion = minion
				closestMinionDistance = minionDistanceToMouse
			end
		end
	end
	return closestMinion
end
local function GetClosestMob()
	local enemyMinions = common.GetMinionsInRange(700, TEAM_ENEMY, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 200 then
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
local function GetClosestMobToEnemy()
	local enemyMinions = common.GetMinionsInRange(700, TEAM_ENEMY)

	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ap", enemies)

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
local function GetClosestJungle()
	local enemyMinions = common.GetMinionsInRange(700, TEAM_NEUTRAL, mousePos)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(mousePos) < 200 then
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
local function GetClosestJungleEnemy()
	local enemyMinions = common.GetMinionsInRange(700, TEAM_NEUTRAL)

	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ap", enemies)

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
-- Credits to Coozbie. :>
local ElvlDmg = {70, 100, 130, 160, 190}
local function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
			CalcADmg(
			target,
			(ElvlDmg[player:spellSlot(2).level] --[[Potato Code]] + ((common.GetBonusAD() - common.GetTotalAD() / 2) * .8) +
				(common.GetTotalAP() * .6))
		)
	end
	return damage
end
local uhh = false
local something = 0

local TargetSelection = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end
local TargetSelectionGap = function(res, obj, dist)
	if dist < spellR.range * 2 then
		res.obj = obj
		return true
	end
end
orb.combat.register_f_after_attack(
	function()
		if menu.keys.combokey:get() and orb.combat.target then
			if (menu.combo.procq:get() and not enemyCreep) and player:spellSlot(2).state == 0 then
				player:castSpell("obj", 2, player)
			end
		end
	end
)

local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end
local GetTargetGap = function()
	return TS.get_result(TargetSelectionGap).obj
end
local function Toggle()
	if menu.combo.turret:get() then
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
local function Combo()
	local target = GetTarget()
	if common.IsValidTarget(target) then
		if menu.combo.items:get() and not menu.combo.afterr:get() then
			if (target.pos:dist(player) <= 700) then
				for i = 6, 11 do
					local item = player:spellSlot(i).name
					if item and (item == "HextechGunblade") then
						player:castSpell("obj", i, target)
					end
					if item and (item == "BilgewaterCutlass") then
						player:castSpell("obj", i, target)
					end
				end
			end
		end
		if menu.combo.qcombo:get() then
			if (target.pos:dist(player) < spellQ.range) then
				player:castSpell("obj", 0, target)
			end
		end
		if menu.combo.ecombo:get() and not menu.combo.procq:get() then
			if (target.pos:dist(player) < spellE.range) then
				player:castSpell("obj", 2, target)
			end
		end
		if menu.combo.wcombo:get() then
			if (target.pos:dist(player) < spellW.range + 140) and (target.pos:dist(player) >= 200) then
				if uhh == false then
					player:castSpell("obj", 1, target)
				end
				if uhh == true and not common.is_under_tower(vec3(target.x, target.y, target.z)) then
					player:castSpell("obj", 1, target)
				end
			end
		end
		if menu.combo.rcombo:get() then
			if
				(target.pos:dist(player) < spellR.range) and not menu.blacklist[target.charName]:get() and
					(target.pos:dist(player) > menu.combo.minr:get() and player.buff["akalishadowdance"] and
						player.buff["akalishadowdance"].stacks2 > menu.combo.saver:get())
			 then
				if (#count_enemies_in_range(vec3(target.x, target.y, target.z), 600) < menu.combo.suicidal:get()) then
					if uhh == false then
						player:castSpell("obj", 3, target)

						if menu.combo.items:get() and menu.combo.afterr:get() then
							if (target.pos:dist(player) <= 600) then
								for i = 6, 11 do
									local item = player:spellSlot(i).name
									if item and (item == "HextechGunblade") then
										player:castSpell("obj", i, target)
									end
									if item and (item == "BilgewaterCutlass") then
										player:castSpell("obj", i, target)
									end
								end
							end
						end
					end

					if uhh == true and not common.is_under_tower(vec3(target.x, target.y, target.z)) then
						player:castSpell("obj", 3, target)

						if menu.combo.items:get() and menu.combo.afterr:get() then
							if (target.pos:dist(player) <= 600) then
								for i = 6, 11 do
									local item = player:spellSlot(i).name
									if item and (item == "HextechGunblade") then
										player:castSpell("obj", i, target)
									end
									if item and (item == "BilgewaterCutlass") then
										player:castSpell("obj", i, target)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	local targets = GetTargetGap()
	if common.IsValidTarget(targets) then
		if menu.combo.gappppr:get() then
			if
				targets and player:spellSlot(0).state == 0 and (targets.pos:dist(player) < spellR.range + spellQ.range - 160) and
					(targets.pos:dist(player)) > spellR.range and
					not menu.blacklist[targets.charName]:get() and
					(targets.pos:dist(player) > menu.combo.minr:get() and player.buff["akalishadowdance"] and
						player.buff["akalishadowdance"].stacks2 > menu.combo.saver:get())
			 then
				if (targets and #count_enemies_in_range(vec3(targets.x, targets.y, targets.z), 600) < menu.combo.suicidal:get()) then
					if uhh == false then
						local minion = GetClosestMobToEnemy(targets)
						if minion then
							player:castSpell("obj", 3, minion)
						end
					end
					if uhh == true and not common.is_under_tower(vec3(targets.x, targets.y, targets.z)) then
						local minion = GetClosestMobToEnemy(targets)
						if minion then
							player:castSpell("obj", 3, minion)
						end
					end
					if uhh == false then
						local minions = GetClosestJungleEnemy(targets)
						if minions then
							player:castSpell("obj", 3, minions)
						end
					end
					if uhh == true and not common.is_under_tower(vec3(targets.x, targets.y, targets.z)) then
						local minions = GetClosestJungleEnemy(targets)
						if minions then
							player:castSpell("obj", 3, minions)
						end
					end
				end
			end
		end
	end
end

local function Harass()
	local target = GetTarget()
	if not common.IsValidTarget(target) then
		return
	end
	if menu.harass.qharass:get() then
		if (target.pos:dist(player) < spellQ.range) then
			player:castSpell("obj", 0, target)
		end
	end
	if menu.harass.eharass:get() then
		if (target.pos:dist(player) < spellE.range) then
			player:castSpell("obj", 2, target)
		end
	end
	if menu.harass.wharass:get() then
		if (target.pos:dist(player) < spellW.range + 140) and (target.pos:dist(player) >= 200) then
			player:castSpell("obj", 1, target)
		end
	end
end

local function Flee()
	if menu.flee.fleekey:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if menu.flee.fleew:get() then
			player:castSpell("pos", 1, vec3(mousePos.x, mousePos.y, mousePos.z))
		end
		if menu.flee.fleer:get() then
			local enemyMinions = common.GetMinionsInRange(700, TEAM_ENEMY, mousePos)
			local jungle = common.GetMinionsInRange(700, TEAM_NEUTRAL, mousePos)

			local minion = GetClosestMob(target)
			if minion then
				player:castSpell("obj", 3, minion)
			end
			local jungleeeee = GetClosestJungle(target)
			if jungleeeee then
				player:castSpell("obj", 3, jungleeeee)
			end
		end
	end
end

local function KillSteal()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ap", enemies)
			if menu.killsteal.ksq:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range and
						dmglib.GetSpellDamage(0, enemies) > hp
				 then
					player:castSpell("obj", 0, enemies)
				end
			end
			if menu.killsteal.kse:get() then
				if
					player:spellSlot(2).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range and
						EDamage(enemies) > hp
				 then
					player:castSpell("obj", 2, enemies)
				end
			end
			if menu.killsteal.ksr:get() then
				if
					player:spellSlot(3).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellR.range and
						dmglib.GetSpellDamage(3, enemies) > hp
				 then
					player:castSpell("obj", 3, enemies)
				end
			end
			if menu.killsteal.ksgap:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) > spellQ.range and
						vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range + spellR.range - 70 and
						dmglib.GetSpellDamage(0, enemies) > hp
				 then
					local minion = GetClosestMobToEnemy(enemies)
					if minion then
						player:castSpell("obj", 3, minion)
					end

					local minios = GetClosestJungleEnemy(enemies)
					if minios then
						player:castSpell("obj", 3, minios)
					end
				end
			end
		end
	end
end



local function JungleClear()
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
	if menu.laneclear.farme:get() then
		local enemyMinionsE = common.GetMinionsInRange(spellE.range, TEAM_NEUTRAL)
		for i, minion in pairs(enemyMinionsE) do
			if minion and not minion.isDead and common.IsValidTarget(minion) then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				if minionPos:dist(player.pos) <= spellE.range then
					player:castSpell("obj", 2, minion)
				end
			end
		end
	end
end
local function LaneClear()
	if (player.mana / player.maxMana) * 100 >= menu.laneclear.mana:get() then
		if not menu.laneclear.farmlogic:get() then
			if menu.laneclear.farmq:get() then
				local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
				for i, minion in pairs(enemyMinionsQ) do
					if minion and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellQ.range then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
			if menu.laneclear.farme:get() then
				local enemyMinionsE = common.GetMinionsInRange(spellE.range, TEAM_ENEMY)
				for i, minion in pairs(enemyMinionsE) do
					if minion and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellE.range then
							player:castSpell("obj", 2, minion)
						end
					end
				end
			end
		end
		if menu.laneclear.farmlogic:get() then
			local minios = GetClosestMobForLogic(player)
			if minios then
				if minios and dmglib.GetSpellDamage(0, minios) + EDamage(minios) < minios.health then
					if menu.laneclear.farmq:get() then
						if vec3(minios.x, minios.y, minios.z):dist(player.pos) < 200 then
							player:castSpell("obj", 0, minios)
						end
						if vec3(minios.x, minios.y, minios.z):dist(player.pos) > 200 then
							player:castSpell("obj", 0, minios)
						end
					end
				end
				if
					minios and EDamage(minios) > minios.health and vec3(minios.x, minios.y, minios.z):dist(player.pos) <= spellE.range
				 then
					player:castSpell("obj", 2, minios)
				end

				if minios.buff["akalimota"] then
					if minios and EDamage(minios) < minios.health then
						if menu.laneclear.farme:get() then
							if vec3(minios.x, minios.y, minios.z):dist(player.pos) <= spellE.range then
								player:castSpell("obj", 2, minios)
								player:attack(minios)
							end
						end
					end
				end
			end
		end
	end
end

local function LastHit()
	if menu.lasthit.qlasthit:get() then
		local delay = 0
		local enemyMinions = common.GetMinionsInRange(700, TEAM_ENEMY)
		for i, minion in pairs(enemyMinions) do
			if minion then
				delay = player.pos:dist(minion.pos) / 1100 + 0.25
			end
			if
				minion and not minion.isDead and minion.isVisible and player.pos:dist(minion.pos) < spellQ.range and
					dmglib.GetSpellDamage(0, minion) >= orb.farm.predict_hp(minion, delay, true)
			 then
				if not menu.lasthit.qaa:get() then
					orb.farm.set_ignore(minion)
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




local function OnDraw()
	if menu.draws.drawq:get() then
		graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
	end
	if menu.draws.drawe:get() then
		graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 100)
	end
	if menu.draws.drawr:get() then
		graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 100)
	end

	--	if menu.draws.drawwr:get() then
	--	graphics.draw_circle(player.pos, spellR.range + spellW.range-20, 2, menu.draws.colorwr:get(), 100)
	--end
	if menu.draws.drawgapclose:get() then
		local minion = GetClosestMobToEnemy(targets)
		local minions = GetClosestJungleEnemy(targets)

		local targets = GetTargetGap()
		if common.IsValidTarget(targets) then
			if menu.combo.gappppr:get() then
				if
					targets and (targets.pos:dist(player) < spellR.range + spellQ.range - 160) and
						(targets.pos:dist(player)) > spellR.range and
						not menu.blacklist[targets.charName]:get() and
						(targets.pos:dist(player) > menu.combo.minr:get() and player.buff["akalishadowdance"] and
							player.buff["akalishadowdance"].stacks2 > menu.combo.saver:get())
				 then
					if minion then
						graphics.draw_line(player, minion, 5, graphics.argb(255, 218, 34, 34))
						graphics.draw_line(minion, targets, 5, graphics.argb(255, 218, 34, 34))
					end
					if minions then
						graphics.draw_line(player, minions, 5, graphics.argb(255, 218, 34, 34))
						graphics.draw_line(minions, targets, 5, graphics.argb(255, 218, 34, 34))
					end
				end
			end
		end
	end
	if menu.draws.drawtoggle:get() then
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
		if uhh == true then
			graphics.draw_text_2D("W / R Under-Turret: OFF", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 218, 34, 34))
		else
			graphics.draw_text_2D("W / R Under-Turret: ON", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 128, 255, 0))
		end
	end
end
local function OnTick()
	Flee()
	Toggle()
	KillSteal()

	if menu.harass.autoe:get() then
		local enemy = common.GetEnemyHeroesInRange(spellE.range)
		for i, enemies in pairs(enemy) do
			if enemies and not enemies.isDead and common.IsValidTarget(enemies) then
				player:castSpell("obj", 2, player)
			end
		end
	end
	if menu.keys.lastkey:get() then
		LastHit()
	end
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
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
