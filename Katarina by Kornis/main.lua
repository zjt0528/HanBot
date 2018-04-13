local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Katarina by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Katarina by Kornis'!")
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
	range = 625
}

local spellW = {
	range = 400
}

local spellE = {
	range = 725
}

local spellR = {
	range = 550
}

local tSelector = avada_lib.targetSelector
local menu = menu("KatarinaKornis", "Katarina By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
menu.combo:dropdown("combomode", "Combo Mode: ", 2, {"Q E", "E Q", "E>W>R>Q"})
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)
--menu.combo:slider("erange", " ^- Min E Range. ( Only if Target Cast )", 200, 1, 500, 1)
menu.combo:boolean("eturret", " ^- Don't E under The Turret", false)
menu.combo:boolean("savee", " ^- Save E if no Daggers", false)
menu.combo:dropdown("emode", "E Mode: ", 3, {"Infront", "Behind", "Logic"})
menu.combo.emode:set("tooltip", "Logic : If R is not Ready then cast Infront. If R Ready - Cast Behind")
menu.combo:menu("rset", "R Settings")
menu.combo.rset:dropdown("rmod", "R Usage: ", 2, {"Always", "Only if Killable", "Never"})
menu.combo.rset:slider("dagger", "X R Daggers for Damage Check", 8, 1, 16, 1)
menu.combo.rset:slider("rhit", "R Only if Hits X Enemies", 1, 1, 5, 1)
menu.combo.rset:boolean("cancelr", "Cancel R if no Enemies", true)
menu.combo.rset:boolean("cancelrks", "Cancel R for Killsteal", true)
menu.combo.rset:slider("waster", " ^- Don't waste R if Enemy Health <= ", 100, 0, 500, 1)
menu.combo:boolean("items", "Use Items", true)
menu.combo:boolean("magnet", "Magnet to Daggers", false)
menu.combo.magnet:set("tooltip", "It might be Potato, no idea actually. :c")

menu:menu("harass", "Harass")
menu.harass:dropdown("harassmode", "Harass Mode: ", 2, {"Q E", "E Q"})
menu.harass:keybind("toggle", "Harass Toggle", "G", nil)
menu.harass:boolean("qharass", "Use Q to Harass", true)
menu.harass:boolean("wharass", "Use W to Harass", true)
menu.harass:boolean("eharass", "Use E to Harass", true)

menu:menu("laneclear", "Farming")
menu.laneclear:keybind("toggle", "Farm Toggle", "T", nil)
menu.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.laneclear:boolean("qlasthit", " ^- Only for Last Hit", true)
menu.laneclear:boolean("lasthitaa", " ^- Don't Last Hit in Auto Attack Range", true)
menu.laneclear:boolean("farmw", "Use W to Farm", false)
menu.laneclear:slider("hitw", " ^- If Hits", 3, 0, 6, 1)
menu.laneclear:boolean("farme", "Use E to Farm", false)
menu.laneclear:slider("hite", " ^- If Dagger Hits", 3, 0, 6, 1)
menu.laneclear:boolean("turret", " ^- Don't E Under the Turret", true)

menu:menu("lasthit", "Last Hit")
menu.lasthit:boolean("farmq", "Use Q to Last Hit", true)
menu.lasthit:boolean("lastaa", " ^- Don't Last Hit in Auto Attack Range", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)
menu.killsteal:boolean("kse", "Killsteal with E", true)
menu.killsteal:boolean("ksedagger", " ^- Killsteal with E Dagger", true)
menu.killsteal:boolean("ksegap", "Killsteal with E Gapclose for Q", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", false)
menu.draws:color("colore", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawtoggle", "Draw Farm Toggle", true)
menu.draws:boolean("drawharass", "Draw Harass Toggle", true)
menu.draws:boolean("drawdaggers", "Draw Daggers", true)
menu.draws:boolean("drawdamage", "Draw Damage", true)

menu:menu("flee", "Flee")
menu.flee:boolean("fleew", "Use W to Flee", true)
menu.flee:boolean("fleee", "Use E to Flee", true)
menu.flee:boolean("dagger", " ^- Use E on Daggers", true)
menu.flee:keybind("fleekey", "Flee Key:", "Z", nil)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
TS.load_to_menu(menu)
local objHolder = {}
local allowing = true
local function CreateObj(object)
	if object and object.name then
		if object.name:find("W_Indicator_Ally") then
			objHolder[object.ptr] = object
		end
	end
end

local function DeleteObj(object)
	if object and object.name then
		objHolder[object.ptr] = nil
	end
end

local function updatebuff(buff)
	if buff.name == "katarinarsound" then
		allowing = false
		if (evade) then
			evade.core.set_pause(math.huge)
		end
		orb.core.set_pause_move(math.huge)
		orb.core.set_pause_attack(math.huge)
	end
end
local function removebuff(buff)
	if buff.name == "katarinarsound" then
		allowing = true

		if (evade) then
			evade.core.set_pause(0)
		end

		orb.core.set_pause_move(0)
		orb.core.set_pause_attack(0)
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
local TargetSelectionQ = function(res, obj, dist)
	if dist < spellQ.range then
		res.obj = obj
		return true
	end
end
local TargetSelectionW = function(res, obj, dist)
	if dist < spellW.range then
		res.obj = obj
		return true
	end
end
local TargetSelectionE = function(res, obj, dist)
	if dist < spellE.range then
		res.obj = obj
		return true
	end
end
local TargetSelectionR = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end
function size()
	local count = 0
	for _ in pairs(objHolder) do
		count = count + 1
	end
	return count
end

local timer = 0
local TimeW = 0
local TimeR = 0
local function Spellsssss(slot, vec3, vec3, networkID, isInjected)
	if (slot == 3 and isInjected == true) then
		allowing = false
	end
	if (slot == 1) and isInjected == true then
		TimeW = os.clock() + 1.2
	end
	if (slot == 3) and isInjected == true then
		TimeR = os.clock() + 1
	end

	if
		(slot == 0 or slot == 1 or slot == 2 or slot == 6 or slot == 7 or slot == 8 or slot == 9 or slot == 10 or slot == 11) and
			isInjected == true and
			allowing == false
	 then
		core.block_input()
	end
end
local GetTargetQ = function()
	return TS.get_result(TargetSelectionQ).obj
end
local GetTargetW = function()
	return TS.get_result(TargetSelectionW).obj
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
end
local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
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

local uhhfarm = false
local somethingfarm = 0

local uhh = false
local something = 0

local function ToggleFarm()
	if menu.laneclear.toggle:get() then
		if (uhhfarm == false and os.clock() > somethingfarm) then
			uhhfarm = true
			somethingfarm = os.clock() + 0.3
		end
		if (uhhfarm == true and os.clock() > somethingfarm) then
			uhhfarm = false
			somethingfarm = os.clock() + 0.3
		end
	end
end
local function ToggleHarass()
	if menu.harass.toggle:get() then
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
local function GetClosestJungle()
	local enemyMinions = common.GetMinionsInRange(spellE.range, TEAM_NEUTRAL, mousePos)

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

local function GetClosestMob()
	local enemyMinions = common.GetMinionsInRange(spellE.range, TEAM_ENEMY, mousePos)

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
local function GetClosestDagger()
	local closestDagger = nil
	local closestDaggerDistance = 9999
	for _, objs in pairs(objHolder) do
		if objs then
			if objs.pos:dist(player.pos) < 360 then
				local DaggerDist = objs.pos:dist(player.pos)

				if DaggerDist < closestDaggerDistance then
					closestDagger = objs
					closestDaggerDistance = DaggerDist
				end
			end
		end
	end
	return closestDagger
end
local function GetClosestMobToEnemy()
	local enemyMinions = common.GetMinionsInRange(spellE.range, TEAM_ENEMY)

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
local function GetClosestJungleEnemy()
	local enemyMinions = common.GetMinionsInRange(spellE.range, TEAM_NEUTRAL)

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
local function Flee()
	if menu.flee.fleekey:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if menu.flee.fleew:get() then
			player:castSpell("pos", 1, player.pos)
		end
		if menu.flee.fleee:get() then
			local minion = GetClosestMob()
			if minion then
				player:castSpell("pos", 2, minion.pos)
			end
			local jungleeeee = GetClosestJungle()
			if jungleeeee then
				player:castSpell("pos", 2, jungleeeee.pos)
			end
		end
		if menu.flee.dagger:get() then
			if (menu.draws.drawdaggers:get()) then
				for _, objs in pairs(objHolder) do
					if objs then
						if (objs.pos:dist(mousePos) < 200) then
							player:castSpell("pos", 2, objs.pos)
						end
					end
				end
			end
		end
	end
end

local ElvlDmg = {15, 30, 45, 60, 75}
local function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
			CalcMagicDmg(
			target,
			(ElvlDmg[player:spellSlot(2).level] + ((common.GetTotalAD() / 2) * .5) + (common.GetTotalAP() * .25)) - 10
		)
	end
	return damage
end

local RlvlDmg = {25, 37.5, 50}
local function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
			CalcMagicDmg(
			target,
			(RlvlDmg[player:spellSlot(3).level] --[[Potato Code]] + ((common.GetBonusAD() - common.GetTotalAD() / 2) * .22) +
				(common.GetTotalAP() * .19))
		)
	end
	return damage * menu.combo.rset.dagger:get()
end
local PlvlDmg = {25, 37.5, 50}
local PDamages = {68, 72, 77, 82, 89, 96, 103, 112, 121, 131, 142, 154, 166, 180, 194, 208, 224, 240}
local function PDamage(target)
	local damage = 0
	if (player.levelRef >= 1 and player.levelRef < 6) then
		leveldamage = 0.55
	end
	if (player.levelRef >= 6 and player.levelRef < 11) then
		leveldamage = 0.7
	end
	if (player.levelRef >= 11 and player.levelRef < 16) then
		leveldamage = 0.85
	end
	if (player.levelRef >= 16) then
		leveldamage = 1
	end
	for _, objs in pairs(objHolder) do
		if objs then
			if target.pos:dist(objs.pos) < 450 then
				local damage = 0

				damage =
					CalcMagicDmg(
					target,
					(PDamages[player.levelRef] + (common.GetBonusAD() - common.GetTotalAD() / 2) + (common.GetTotalAP() * leveldamage))
				)

				return damage
			end
		end
	end
	return damage
end

local function LastHit()
	if menu.lasthit.farmq:get() then
		local enemyMinionsE = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
		for i, minion in pairs(enemyMinionsE) do
			if minion and not minion.isDead then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				--delay = player.pos:dist(minion.pos) / 3500 + 0.2

				if (dmglib.GetSpellDamage(0, minion) >= orb.farm.predict_hp(minion, 0.25, true)) then
					if (menu.lasthit.lastaa:get() and player.pos:dist(minion) > 300) then
						player:castSpell("obj", 0, minion)
					end
					if not menu.lasthit.lastaa:get() then
						player:castSpell("obj", 0, minion)
					end
				end
			end
		end
	end
end

local function KillSteal()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and enemies.isVisible and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ap", enemies)
			if menu.killsteal.ksedagger:get() then
				for _, objs in pairs(objHolder) do
					if objs then
						if (enemies.pos:dist(player.pos) <= spellE.range and objs.pos:dist(enemies) < 450 and PDamage(enemies) > hp) then
							allowing = true
							local direction = (objs.pos - enemies.pos):norm()
							local extendedPos = objs.pos - direction * 200
							player:castSpell("pos", 2, extendedPos)
						end
					end
				end
			end

			if menu.killsteal.ksq:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range and
						dmglib.GetSpellDamage(0, enemies) > hp
				 then
					allowing = true
					player:castSpell("obj", 0, enemies)
				end
			end
			if menu.killsteal.kse:get() then
				if
					player:spellSlot(2).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range and
						EDamage(enemies) > hp
				 then
					allowing = true
					player:castSpell("pos", 2, enemies.pos)
				end
			end

			if menu.killsteal.ksegap:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) > spellQ.range and
						vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range + spellE.range - 70 and
						dmglib.GetSpellDamage(0, enemies) - 30 > hp
				 then
					allowing = true
					local minion = GetClosestMobToEnemy(enemies)
					if minion then
						player:castSpell("pos", 2, minion.pos)
					end

					local minios = GetClosestJungleEnemy(enemies)
					if minios then
						player:castSpell("pos", 2, minios.pos)
					end
				end
			end
		end
	end
end
local function LaneClear()
	if uhhfarm == true then
		if menu.laneclear.farmq:get() and menu.laneclear.qlasthit:get() then
			local enemyMinionsE = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
			for i, minion in pairs(enemyMinionsE) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					--delay = player.pos:dist(minion.pos) / 3500 + 0.2

					if (dmglib.GetSpellDamage(0, minion) >= orb.farm.predict_hp(minion, 0.25, true)) then
						if not (menu.laneclear.lasthitaa:get()) then
							player:castSpell("obj", 0, minion)
						end
						if (menu.laneclear.lasthitaa:get()) and minion.pos:dist(player.pos) > 250 then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
		end
		if menu.laneclear.farmq:get() and not menu.laneclear.qlasthit:get() then
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
		if menu.laneclear.farmw:get() then
			local enemyMinionsE = common.GetMinionsInRange(450, TEAM_ENEMY)
			for i, minion in pairs(enemyMinionsE) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if #count_minions_in_range(player.pos, 450) >= menu.laneclear.hitw:get() and player:spellSlot(1).state == 0 then
						player:castSpell("pos", 1, minion.pos)
					end
				end
			end
		end

		if menu.laneclear.farme:get() and TimeW < os.clock() then
			local enemyMinionsE = common.GetMinionsInRange(spellE.range, TEAM_ENEMY)
			for i, minion in pairs(enemyMinionsE) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					for _, objs in pairs(objHolder) do
						if objs then
							local minionPos = vec3(minion.x, minion.y, minion.z)
							local direction = (objs.pos - minion.pos):norm()
							local extendedPos = objs.pos - direction * 200

							if #count_minions_in_range(player.pos, 450) >= menu.laneclear.hite:get() then
								local minionPos = vec3(minion.x, minion.y, minion.z)
								local direction = (objs.pos - minion.pos):norm()
								local extendedPos = objs.pos - direction * 200

								if menu.laneclear.turret:get() then
									if not common.is_under_tower(objs.pos) then
										player:castSpell("pos", 2, extendedPos)
									end
								else
									player:castSpell("pos", 2, extendedPos)
								end
							end
						end
					end
				end
			end
		end
	end
end

local function JungleClear()
	if (uhhfarm) then
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
					if minionPos:dist(player.pos) <= 300 then
						player:castSpell("pos", 1, minion.pos)
					end
				end
			end
		end
	end
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

local function Combo()
	if menu.combo.rset.cancelr:get() then
		if (player.buff["katarinarsound"]) then
			if (#count_enemies_in_range(player.pos, spellR.range + 10) == 0) then
				player:move(mousePos)
			end
		end
	end
	if menu.combo.rset.cancelrks:get() then
		local target = GetTargetE()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player.pos) <= spellE.range) then
					if not common.HasBuffType(target, 17) then
						if (player.buff["katarinarsound"]) then
							if (target.pos:dist(player.pos) >= spellR.range - 100 and player:spellSlot(2).state == 0) then
								if (size() > 0) then
									for _, objs in pairs(objHolder) do
										if objs then
											if
												(target.pos:dist(objs) < 450 and target.pos:dist(player) < spellE.range and player:spellSlot(2).state == 0)
											 then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(objs.pos) then
														allowing = true
														local direction = (objs.pos - target.pos):norm()
														local extendedPos = objs.pos - direction * 200
														player:castSpell("pos", 2, extendedPos)
													end
												else
													allowing = true
													local direction = (objs.pos - target.pos):norm()
													local extendedPos = objs.pos - direction * 200
													player:castSpell("pos", 2, extendedPos)
												end
											end
											if
												(player.pos:dist(objs) > spellE.range and target.pos:dist(player) < spellE.range and
													player:spellSlot(2).state == 0)
											 then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														allowing = true
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													allowing = true
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end

											if
												(target.pos:dist(objs) > 450 and target.pos:dist(player) < spellE.range and player:spellSlot(2).state == 0)
											 then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														allowing = true
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													allowing = true
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end
										end
									end
								end
								if (size() == 0) then
									if player:spellSlot(2).state == 0 then
										if menu.combo.eturret:get() then
											if not common.is_under_tower(target.pos) then
												allowing = true
												local direction = (target.pos - player.pos):norm()
												local extendedPos = target.pos - direction * -50

												player:castSpell("pos", 2, extendedPos)
											end
										else
											allowing = true
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * -50
											player:castSpell("pos", 2, extendedPos)
										end
									end
								end
							end

							if (dmglib.GetSpellDamage(0, target) + EDamage(target)) >= target.health and player:spellSlot(2).state == 0 then
								if (size() > 0) then
									for _, objs in pairs(objHolder) do
										if objs then
											if (target.pos:dist(objs.pos) < 450) then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(objs.pos) then
														allowing = true
														local direction = (objs.pos - target.pos):norm()
														local extendedPos = objs.pos - direction * 200
														player:castSpell("pos", 2, extendedPos)
													end
												else
													allowing = true
													local direction = (objs.pos - target.pos):norm()
													local extendedPos = objs.pos - direction * 200
													player:castSpell("pos", 2, extendedPos)
												end
											end

											if (objs.pos:dist(player.pos) > spellE.range) then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														allowing = true
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													allowing = true
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end
											if (target.pos:dist(objs) > 450) then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														allowing = true
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													allowing = true
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end
										end
									end
								end
								if (size() == 0 and player:spellSlot(2).state == 0) then
									if menu.combo.eturret:get() then
										if not common.is_under_tower(target.pos) then
											allowing = true
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * -50
											player:castSpell("pos", 2, extendedPos)
										end
									else
										allowing = true
										local direction = (target.pos - player.pos):norm()
										local extendedPos = target.pos - direction * -50
										player:castSpell("pos", 2, extendedPos)
									end
								end
								if (target.pos:dist(player.pos) < spellQ.range and player:spellSlot(1).state == 0) then
									allowing = true
									player:castSpell("obj", 0, target)
								end
							end
						end
					end
				end
			end
		end
	end
	local target = GetTargetE()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if not player.buff["katarinarsound"] then
				if menu.combo.items:get() then
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
				if menu.combo.combomode:get() == 1 then
					if (menu.combo.qcombo:get()) then
						if (target.pos:dist(player.pos) <= spellQ.range) then
							player:castSpell("obj", 0, target)
						end
					end
					if (menu.combo.ecombo:get()) and player:spellSlot(0).state ~= 0 then
						if (size() > 0) then
							for _, objs in pairs(objHolder) do
								if objs then
									if not menu.combo.savee:get() then
										if (target.pos:dist(objs.pos) < 450) then
											if menu.combo.eturret:get() then
												if not common.is_under_tower(objs.pos) then
													local direction = (objs.pos - target.pos):norm()
													local extendedPos = objs.pos - direction * 200
													player:castSpell("pos", 2, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):norm()
												local extendedPos = objs.pos - direction * 200
												player:castSpell("pos", 2, extendedPos)
											end
										end
										if menu.combo.emode:get() == 1 then
											if objs.pos:dist(player.pos) > spellE.range then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * 50
													player:castSpell("pos", 2, extendedPos)
												end
											end
											if (objs.pos:dist(target.pos) > 450) then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * 50
													player:castSpell("pos", 2, extendedPos)
												end
											end
										end
										if menu.combo.emode:get() == 2 then
											if objs.pos:dist(player.pos) > spellE.range then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end

											if (objs.pos:dist(target.pos) > 450) then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end
										end
										if menu.combo.emode:get() == 3 then
											if player:spellSlot(3).state ~= 0 or player:spellSlot(3).level == 0 then
												if objs.pos:dist(player.pos) > spellE.range then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * 50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												end
												if (objs.pos:dist(target.pos) > 450) then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * 50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												end
											end

											if player:spellSlot(3).state == 0 then
												if objs.pos:dist(player.pos) > spellE.range then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * -50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												end

												if (objs.pos:dist(target.pos) > 450) then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * -50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												end
											end
										end
									end

									if menu.combo.savee:get() then
										if (target.pos:dist(objs.pos) < 450) then
											if menu.combo.eturret:get() then
												if not common.is_under_tower(objs.pos) then
													local direction = (objs.pos - target.pos):norm()
													local extendedPos = objs.pos - direction * 200
													player:castSpell("pos", 2, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):norm()
												local extendedPos = objs.pos - direction * 200
												player:castSpell("pos", 2, extendedPos)
											end
										end
									end
								end
							end
						end
						if (size() == 0) then
							if not menu.combo.savee:get() then
								if menu.combo.emode:get() == 1 then
									if menu.combo.eturret:get() then
										if not common.is_under_tower(target.pos) then
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * 50
											player:castSpell("pos", 2, extendedPos)
										end
									else
										local direction = (target.pos - player.pos):norm()
										local extendedPos = target.pos - direction * 50
										player:castSpell("pos", 2, extendedPos)
									end
								end

								if menu.combo.emode:get() == 2 then
									if menu.combo.eturret:get() then
										if not common.is_under_tower(target.pos) then
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * -50
											player:castSpell("pos", 2, extendedPos)
										end
									else
										local direction = (target.pos - player.pos):norm()
										local extendedPos = target.pos - direction * -50
										player:castSpell("pos", 2, extendedPos)
									end
								end

								if menu.combo.emode:get() == 3 then
									if player:spellSlot(3).state ~= 0 or player:spellSlot(3).level == 0 then
										if menu.combo.eturret:get() then
											if not common.is_under_tower(target.pos) then
												local direction = (target.pos - player.pos):norm()
												local extendedPos = target.pos - direction * 50
												player:castSpell("pos", 2, extendedPos)
											end
										else
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * 50
											player:castSpell("pos", 2, extendedPos)
										end
									end

									if player:spellSlot(3).state == 0 then
										if menu.combo.eturret:get() then
											if not common.is_under_tower(target.pos) then
												local direction = (target.pos - player.pos):norm()
												local extendedPos = target.pos - direction * -50
												player:castSpell("pos", 2, extendedPos)
											end
										else
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * -50
											player:castSpell("pos", 2, extendedPos)
										end
									end
								end
							end
						end
					end
					if (menu.combo.wcombo:get()) then
						if (#count_enemies_in_range(player.pos, spellW.range) > 0) then
							local target = GetTargetW()
							if target and target.isVisible then
								if common.IsValidTarget(target) then
									if (target.pos:dist(player.pos) <= spellW.range) then
										player:castSpell("pos", 1, target.pos)
									end
								end
							end
						end
					end
					if menu.combo.rset.rmod:get() == 1 and player:spellSlot(3).state == 0 then
						if (target.pos:dist(player.pos) <= spellR.range - 50) then
							if (#count_enemies_in_range(player.pos, spellR.range - 100) >= menu.combo.rset.rhit:get()) then
								if (target.health >= menu.combo.rset.waster:get() and player:spellSlot(0).state ~= 0) then
									if (player:spellSlot(1).state ~= 0) then
										player:castSpell("pos", 3, player.pos)
									end
								end
							end
						end
					end
					if menu.combo.rset.rmod:get() == 2 and player:spellSlot(3).state == 0 then
						if (target.pos:dist(player.pos) <= spellR.range - 50) then
							if (target.health <= RDamage(target) + EDamage(target) + PDamage(target) + dmglib.GetSpellDamage(0, target)) then
								if (target.health >= menu.combo.rset.waster:get() and player:spellSlot(0).state ~= 0) then
									if (player:spellSlot(1).state ~= 0) then
										player:castSpell("pos", 3, player.pos)
									end
								end
							end
						end
					end
				end
				if menu.combo.combomode:get() == 2 then
					if (menu.combo.ecombo:get()) then
						if (size() > 0) then
							for _, objs in pairs(objHolder) do
								if objs then
									if not menu.combo.savee:get() then
										if (target.pos:dist(objs.pos) < 450) then
											if menu.combo.eturret:get() then
												if not common.is_under_tower(objs.pos) then
													local direction = (objs.pos - target.pos):norm()
													local extendedPos = objs.pos - direction * 200
													player:castSpell("pos", 2, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):norm()
												local extendedPos = objs.pos - direction * 200
												player:castSpell("pos", 2, extendedPos)
											end
										end
										if menu.combo.emode:get() == 1 then
											if objs.pos:dist(player.pos) > spellE.range then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * 50
													player:castSpell("pos", 2, extendedPos)
												end
											end
											if (objs.pos:dist(target.pos) > 450) then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * 50
													player:castSpell("pos", 2, extendedPos)
												end
											end
										end
										if menu.combo.emode:get() == 2 then
											if objs.pos:dist(player.pos) > spellE.range then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end

											if (objs.pos:dist(target.pos) > 450) then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end
										end
										if menu.combo.emode:get() == 3 then
											if player:spellSlot(3).state ~= 0 or player:spellSlot(3).level == 0 then
												if objs.pos:dist(player.pos) > spellE.range then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * 50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												end
												if (objs.pos:dist(target.pos) > 450) then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * 50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												end
											end

											if player:spellSlot(3).state == 0 then
												if objs.pos:dist(player.pos) > spellE.range then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * -50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												end

												if (objs.pos:dist(target.pos) > 450) then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * -50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												end
											end
										end
									end

									if menu.combo.savee:get() then
										if (target.pos:dist(objs.pos) < 450) then
											if menu.combo.eturret:get() then
												if not common.is_under_tower(objs.pos) then
													local direction = (objs.pos - target.pos):norm()
													local extendedPos = objs.pos - direction * 200
													player:castSpell("pos", 2, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):norm()
												local extendedPos = objs.pos - direction * 200
												player:castSpell("pos", 2, extendedPos)
											end
										end
									end
								end
							end
						end
						if (size() == 0) then
							if not menu.combo.savee:get() then
								if menu.combo.emode:get() == 1 then
									if menu.combo.eturret:get() then
										if not common.is_under_tower(target.pos) then
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * 50
											player:castSpell("pos", 2, extendedPos)
										end
									else
										local direction = (target.pos - player.pos):norm()
										local extendedPos = target.pos - direction * 50
										player:castSpell("pos", 2, extendedPos)
									end
								end

								if menu.combo.emode:get() == 2 then
									if menu.combo.eturret:get() then
										if not common.is_under_tower(target.pos) then
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * -50
											player:castSpell("pos", 2, extendedPos)
										end
									else
										local direction = (target.pos - player.pos):norm()
										local extendedPos = target.pos - direction * -50
										player:castSpell("pos", 2, extendedPos)
									end
								end

								if menu.combo.emode:get() == 3 then
									if player:spellSlot(3).state ~= 0 or player:spellSlot(3).level == 0 then
										if menu.combo.eturret:get() then
											if not common.is_under_tower(target.pos) then
												local direction = (target.pos - player.pos):norm()
												local extendedPos = target.pos - direction * 50
												player:castSpell("pos", 2, extendedPos)
											end
										else
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * 50
											player:castSpell("pos", 2, extendedPos)
										end
									end

									if player:spellSlot(3).state == 0 then
										if menu.combo.eturret:get() then
											if not common.is_under_tower(target.pos) then
												local direction = (target.pos - player.pos):norm()
												local extendedPos = target.pos - direction * -50
												player:castSpell("pos", 2, extendedPos)
											end
										else
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * -50
											player:castSpell("pos", 2, extendedPos)
										end
									end
								end
							end
						end
					end

					if (menu.combo.wcombo:get()) then
						if (#count_enemies_in_range(player.pos, spellW.range) > 0) then
							local target = GetTargetW()
							if target and target.isVisible then
								if common.IsValidTarget(target) then
									if (target.pos:dist(player.pos) <= spellW.range) then
										player:castSpell("pos", 1, target.pos)
									end
								end
							end
						end
					end
					if (menu.combo.qcombo:get()) then
						if (target.pos:dist(player.pos) <= spellQ.range) and player:spellSlot(0).state == 0 then
							player:castSpell("obj", 0, target)
						end
					end
					if menu.combo.rset.rmod:get() == 1 and player:spellSlot(3).state == 0 then
						if (target.pos:dist(player.pos) <= spellR.range - 50) then
							if (#count_enemies_in_range(player.pos, spellR.range - 100) >= menu.combo.rset.rhit:get()) then
								if (target.health >= menu.combo.rset.waster:get() and player:spellSlot(0).state ~= 0) then
									if (player:spellSlot(1).state ~= 0) then
										player:castSpell("pos", 3, player.pos)
									end
								end
							end
						end
					end
					if menu.combo.rset.rmod:get() == 2 and player:spellSlot(3).state == 0 then
						if (target.pos:dist(player.pos) <= spellR.range - 50) then
							if (target.health <= RDamage(target) + EDamage(target) + PDamage(target) + dmglib.GetSpellDamage(0, target)) then
								if (target.health >= menu.combo.rset.waster:get() and player:spellSlot(0).state ~= 0) then
									if (player:spellSlot(1).state ~= 0) then
										player:castSpell("pos", 3, player.pos)
									end
								end
							end
						end
					end
				end
				if menu.combo.combomode:get() == 3 then
					if (menu.combo.qcombo:get() and player:spellSlot(3).state ~= 0) and TimeR < os.clock() then
						if (target.pos:dist(player.pos) <= spellQ.range) then
							player:castSpell("obj", 0, target)
						end
					end
					if (menu.combo.ecombo:get()) then
						if (size() > 0) then
							for _, objs in pairs(objHolder) do
								if objs then
									if not menu.combo.savee:get() then
										if (target.pos:dist(objs.pos) < 450) then
											if menu.combo.eturret:get() then
												if not common.is_under_tower(objs.pos) then
													local direction = (objs.pos - target.pos):norm()
													local extendedPos = objs.pos - direction * 200
													player:castSpell("pos", 2, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):norm()
												local extendedPos = objs.pos - direction * 200
												player:castSpell("pos", 2, extendedPos)
											end
										end
										if menu.combo.emode:get() == 1 then
											if objs.pos:dist(player.pos) > spellE.range then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * 50
													player:castSpell("pos", 2, extendedPos)
												end
											end
											if (objs.pos:dist(target.pos) > 450) then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * 50
													player:castSpell("pos", 2, extendedPos)
												end
											end
										end
										if menu.combo.emode:get() == 2 then
											if objs.pos:dist(player.pos) > spellE.range then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end

											if (objs.pos:dist(target.pos) > 450) then
												if menu.combo.eturret:get() then
													if not common.is_under_tower(target.pos) then
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												else
													local direction = (target.pos - player.pos):norm()
													local extendedPos = target.pos - direction * -50
													player:castSpell("pos", 2, extendedPos)
												end
											end
										end
										if menu.combo.emode:get() == 3 then
											if player:spellSlot(3).state ~= 0 or player:spellSlot(3).level == 0 then
												if objs.pos:dist(player.pos) > spellE.range then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * 50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												end
												if (objs.pos:dist(target.pos) > 450) then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * 50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * 50
														player:castSpell("pos", 2, extendedPos)
													end
												end
											end

											if player:spellSlot(3).state == 0 then
												if objs.pos:dist(player.pos) > spellE.range then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * -50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												end

												if (objs.pos:dist(target.pos) > 450) then
													if menu.combo.eturret:get() then
														if not common.is_under_tower(target.pos) then
															local direction = (target.pos - player.pos):norm()
															local extendedPos = target.pos - direction * -50
															player:castSpell("pos", 2, extendedPos)
														end
													else
														local direction = (target.pos - player.pos):norm()
														local extendedPos = target.pos - direction * -50
														player:castSpell("pos", 2, extendedPos)
													end
												end
											end
										end
									end

									if menu.combo.savee:get() then
										if (target.pos:dist(objs.pos) < 450) then
											if menu.combo.eturret:get() then
												if not common.is_under_tower(objs.pos) then
													local direction = (objs.pos - target.pos):norm()
													local extendedPos = objs.pos - direction * 200
													player:castSpell("pos", 2, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):norm()
												local extendedPos = objs.pos - direction * 200
												player:castSpell("pos", 2, extendedPos)
											end
										end
									end
								end
							end
						end
						if (size() == 0) then
							if not menu.combo.savee:get() then
								if menu.combo.emode:get() == 1 then
									if menu.combo.eturret:get() then
										if not common.is_under_tower(target.pos) then
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * 50
											player:castSpell("pos", 2, extendedPos)
										end
									else
										local direction = (target.pos - player.pos):norm()
										local extendedPos = target.pos - direction * 50
										player:castSpell("pos", 2, extendedPos)
									end
								end

								if menu.combo.emode:get() == 2 then
									if menu.combo.eturret:get() then
										if not common.is_under_tower(target.pos) then
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * -50
											player:castSpell("pos", 2, extendedPos)
										end
									else
										local direction = (target.pos - player.pos):norm()
										local extendedPos = target.pos - direction * -50
										player:castSpell("pos", 2, extendedPos)
									end
								end

								if menu.combo.emode:get() == 3 then
									if player:spellSlot(3).state ~= 0 or player:spellSlot(3).level == 0 then
										if menu.combo.eturret:get() then
											if not common.is_under_tower(target.pos) then
												local direction = (target.pos - player.pos):norm()
												local extendedPos = target.pos - direction * 50
												player:castSpell("pos", 2, extendedPos)
											end
										else
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * 50
											player:castSpell("pos", 2, extendedPos)
										end
									end

									if player:spellSlot(3).state == 0 then
										if menu.combo.eturret:get() then
											if not common.is_under_tower(target.pos) then
												local direction = (target.pos - player.pos):norm()
												local extendedPos = target.pos - direction * -50
												player:castSpell("pos", 2, extendedPos)
											end
										else
											local direction = (target.pos - player.pos):norm()
											local extendedPos = target.pos - direction * -50
											player:castSpell("pos", 2, extendedPos)
										end
									end
								end
							end
						end
					end
					if (menu.combo.wcombo:get()) then
						if (#count_enemies_in_range(player.pos, spellW.range) > 0) then
							local target = GetTargetW()
							if target and target.isVisible then
								if common.IsValidTarget(target) then
									if (target.pos:dist(player.pos) <= spellW.range) then
										player:castSpell("pos", 1, target.pos)
									end
								end
							end
						end
					end

					if (target.pos:dist(player.pos) <= spellR.range - 50) then
						if (player:spellSlot(1).state ~= 0) then
							player:castSpell("pos", 3, player.pos)
						end
					end
				end
			end
		end
	end
end

local function Harass()
	local target = GetTargetE()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if (menu.harass.harassmode:get() == 1) then
				if (menu.harass.wharass:get()) then
					if (#count_enemies_in_range(player.pos, spellW.range) > 0) then
						local target = GetTargetW()
						if target and target.isVisible then
							if common.IsValidTarget(target) then
								if (target.pos:dist(player.pos) <= spellW.range) then
									player:castSpell("pos", 1, target.pos)
								end
							end
						end
					end
				end
				if (menu.harass.qharass:get()) then
					if (target.pos:dist(player.pos) <= spellQ.range) then
						player:castSpell("obj", 0, target)
					end
				end
				if (menu.harass.eharass:get() and player:spellSlot(0).state ~= 0) then
					if (target.pos:dist(player.pos) <= spellE.range) then
						for _, objs in pairs(objHolder) do
							if objs then
								if (target.pos:dist(objs.pos) < 450) then
									local direction = (objs.pos - target.pos):norm()
									local extendedPos = objs.pos - direction * 200
									player:castSpell("pos", 2, extendedPos)
								end
								if (objs.pos:dist(player.pos) > spellE.range) then
									local direction = (target.pos - player.pos):norm()
									local extendedPos = target.pos - direction * 50
									player:castSpell("pos", 2, extendedPos)
								end
								if (target.pos:dist(objs.pos) > 450) then
								end
							end
						end

						if (size() == 0) then
							local direction = (target.pos - player.pos):norm()
							local extendedPos = target.pos - direction * 50
							player:castSpell("pos", 2, extendedPos)
						end
					end
				end
			end
			if (menu.harass.harassmode:get() == 2) then
				if (menu.harass.wharass:get()) then
					if (#count_enemies_in_range(player.pos, spellW.range) > 0) then
						local target = GetTargetW()
						if target and target.isVisible then
							if common.IsValidTarget(target) then
								if (target.pos:dist(player.pos) <= spellW.range) then
									player:castSpell("pos", 1, target.pos)
								end
							end
						end
					end
				end
				if (menu.harass.eharass:get()) then
					if (target.pos:dist(player.pos) <= spellE.range) then
						for _, objs in pairs(objHolder) do
							if objs then
								if (target.pos:dist(objs.pos) < 450) then
									local direction = (objs.pos - target.pos):norm()
									local extendedPos = objs.pos - direction * 200
									player:castSpell("pos", 2, extendedPos)
								end
								if (objs.pos:dist(player.pos) > spellE.range) then
									local direction = (target.pos - player.pos):norm()
									local extendedPos = target.pos - direction * 50
									player:castSpell("pos", 2, extendedPos)
								end
								if (target.pos:dist(objs.pos) > 450) then
								end
							end
						end

						if (size() == 0) then
							local direction = (target.pos - player.pos):norm()
							local extendedPos = target.pos - direction * 50
							player:castSpell("pos", 2, extendedPos)
						end
					end
				end

				if (menu.harass.qharass:get()) then
					if (target.pos:dist(player.pos) <= spellQ.range) then
						player:castSpell("obj", 0, target)
					end
				end
			end
		end
	end
end

function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		local pos = graphics.world_to_screen(target.pos)
		if
			(math.floor(
				(RDamage(target) + EDamage(target) + PDamage(target) + dmglib.GetSpellDamage(0, target)) / target.health * 100
			) < 100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(
					"R: " .. math.floor(RDamage(target) + PDamage(target) + EDamage(target) + dmglib.GetSpellDamage(0, target))
				) ..
					" (" ..
						tostring(
							math.floor(
								(RDamage(target) + PDamage(target) + EDamage(target) + dmglib.GetSpellDamage(0, target)) / target.health * 100
							)
						) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if
			(math.floor(
				(RDamage(target) + EDamage(target) + PDamage(target) + dmglib.GetSpellDamage(0, target)) / target.health * 100
			) >= 100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(
					"R: " .. math.floor(RDamage(target) + PDamage(target) + EDamage(target) + dmglib.GetSpellDamage(0, target))
				) ..
					" (" ..
						tostring(
							math.floor(
								(RDamage(target) + PDamage(target) + EDamage(target) + dmglib.GetSpellDamage(0, target)) / target.health * 100
							)
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
	if (menu.draws.drawdaggers:get()) then
		for _, objs in pairs(objHolder) do
			if objs then
				if player.isOnScreen then
					if (#count_enemies_in_range(objs.pos, 450) > 0) then
						graphics.draw_circle(objs.pos, 450, 2, graphics.argb(255, 0, 255, 0), 50)
						graphics.draw_circle(objs.pos, 150, 2, graphics.argb(255, 0, 255, 0), 50)
					end
					if (#count_enemies_in_range(objs.pos, 450) == 0) then
						graphics.draw_circle(objs.pos, 450, 2, graphics.argb(255, 255, 0, 0), 50)
						graphics.draw_circle(objs.pos, 150, 2, graphics.argb(255, 255, 0, 0), 50)
					end
				end
			end
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
	if menu.draws.drawtoggle:get() then
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))

		if uhhfarm == true then
			graphics.draw_text_2D("Farm: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
			graphics.draw_text_2D("ON", 17, pos.x + 23, pos.y + 10, graphics.argb(255, 51, 255, 51))
		else
			graphics.draw_text_2D("Farm: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
			graphics.draw_text_2D("OFF", 17, pos.x + 23, pos.y + 10, graphics.argb(255, 255, 0, 0))
		end
	end
	if menu.draws.drawharass:get() then
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))

		if uhh == true then
			graphics.draw_text_2D("Auto Q: ", 17, pos.x - 20, pos.y + 30, graphics.argb(255, 255, 255, 255))
			graphics.draw_text_2D("ON", 17, pos.x + 37, pos.y + 30, graphics.argb(255, 51, 255, 51))
		else
			graphics.draw_text_2D("Auto Q: ", 17, pos.x - 20, pos.y + 30, graphics.argb(255, 255, 255, 255))
			graphics.draw_text_2D("OFF", 17, pos.x + 37, pos.y + 30, graphics.argb(255, 255, 0, 0))
		end
	end
end

local function OnTick()
	if not player.buff["katarinarsound"] then
		allowing = true
	end
	if (size() == 0) then
		orb.core.set_pause_move(0)
		orb.core.set_pause_move(0)
	end
	if (menu.combo.magnet:get()) then
		local enemy = common.GetEnemyHeroes()
		for i, enemies in ipairs(enemy) do
			if
				enemies and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 1000 and
					not common.HasBuffType(enemies, 17)
			 then
				if not (player.buff["katarinarsound"]) and size() > 0 then
					if (GetClosestDagger()) and enemies.pos:dist(player.pos) < 500 then
						local direction = (GetClosestDagger().pos - enemies.pos):norm()
						local extendedPos = GetClosestDagger().pos - direction * 150
						if (menu.keys.combokey:get() and GetClosestDagger().pos:dist(player.pos) >= 160) then
							orb.core.set_pause_move(1)
							orb.core.set_pause_move(1)
							player:move(extendedPos)
						else
							orb.core.set_pause_move(0)
							orb.core.set_pause_move(0)
						end
					end
				end
			end
		end
	end

	ToggleFarm()
	KillSteal()
	ToggleHarass()
	Flee()
	if uhh then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player.pos) <= spellQ.range) then
					player:castSpell("obj", 0, target)
				end
			end
		end
	end
	if (menu.keys.combokey:get()) then
		Combo()
	end
	if (menu.keys.harasskey:get()) then
		Harass()
	end
	if (menu.keys.lastkey:get()) then
		LastHit()
	end
	if (menu.keys.clearkey:get()) then
		JungleClear()
		LaneClear()
	end
end
orb.combat.register_f_pre_tick(OnTick)
--cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)

cb.add(cb.createobj, CreateObj)
cb.add(cb.deleteobj, DeleteObj)
cb.add(cb.castspell, Spellsssss)
cb.add(cb.updatebuff, updatebuff)
cb.add(cb.removebuff, removebuff)
