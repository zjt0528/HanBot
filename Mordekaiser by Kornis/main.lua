local version = "1.0"

local avada_lib = module.lib("avada_lib")
if not avada_lib then
	print("")
	console.set_color(79)
	print("                                                                                        ")
	print("----------- Mordekaiser by Kornis -------------                                         ")
	print("You need to have Avada Lib in your community_libs folder to run this script!            ")
	print("You can find it here:                                                                   ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                               ")
	console.set_color(79)
	print("                                                                                        ")
	console.set_color(12)
	local menuerror = menu("MordekaiserKornis", "Mordekaiser By Kornis")
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
elseif avada_lib.version < 1 then
	print("")
	console.set_color(79)
	print("                                                                                        ")
	print("----------- Mordekaiser by Kornis -------------                                         ")
	print("You need to have Avada Lib in your community_libs folder to run this script!            ")
	print("You can find it here:                                                                   ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                               ")
	console.set_color(79)
	print("                                                                                        ")
	console.set_color(12)
	local menuerror = menu("MordekaiserKornis", "Mordekaiser By Kornis")
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
end

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = avada_lib.common
local dmglib = avada_lib.damageLib

local spellQ = {
	range = 300
}

local spellW = {
	range = 1000
}

local spellE = {
	range = 675,
	delay = 0.25,
	width = 12 * 2 * math.pi / 100,
	speed = 3000,
	boundingRadiusMod = 1
}

local spellR = {
	range = 650
}

local tSelector = avada_lib.targetSelector
local menu = menu("MordekaiserKornis", "Mordekaiser By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()

menu:menu("combo", "Combo")
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("qaa", " ^- Only for AA Reset", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:slider("chargew", " ^- Release After (seconds)", 2, 1, 5, 1)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("rcombo", "Use R in Combo", false)
menu.combo:slider("hpr", " ^- if Enemy has below X Health", 25, 0, 100, 1)
menu.combo:boolean("autor", "Auto R if Can Kill", true)
menu.combo:boolean("useitems", "Use Items ( Gunblade )", true)
menu.combo:header("aaa", " -- Ghost Settings -- ")
menu.combo:dropdown("rghost", "Ghost Mode: ", 2, {"Manual Control", "Fight With Me", "Roam through Map"})

menu:menu("blacklist", "R Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("qaa", " ^- Only for AA Reset", true)
menu.harass:boolean("wcombo", "Use W in Harass", true)
menu.harass:boolean("ecombo", "Use E in Harass", true)

menu:menu("farming", "Farming")
menu.farming:menu("laneclear", "Lane Clear")
menu.farming.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.farming.laneclear:boolean("lastq", " ^- Only for Last Hit", true)
menu.farming.laneclear:boolean("usew", "Use W in Lane Clear", true)
menu.farming.laneclear:slider("chargew", " ^- Release After (seconds)", 2, 1, 5, 1)
menu.farming.laneclear:boolean("farme", "Use E in Lane Clear", true)
menu.farming.laneclear:slider("hitse", " ^- if Hits X Minions", 3, 1, 6, 1)
menu.farming:menu("jungleclear", "Jungle Clear")
menu.farming.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.farming.jungleclear:boolean("usew", "Use W in Jungle Clear", true)
menu.farming.jungleclear:slider("chargew", " ^- Release After (seconds)", 2, 1, 5, 1)
menu.farming.jungleclear:boolean("usee", "Use E in Jungle Clear", true)
menu:menu("lasthit", "Last Hit")
menu.lasthit:boolean("useq", "Use Q to Last Hit", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawrg", "Draw Ghost Control Range", true)
menu.draws:boolean("drawdamage", "Draw R Damage", true)
menu.draws:boolean("drawghost", "Draw Ghost Position", true)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist <= spellE.range then
		res.obj = obj
		return true
	end
end
local TargetSelectionW = function(res, obj, dist)
	if dist <= spellW.range then
		res.obj = obj
		return true
	end
end

local TargetSelectionGap = function(res, obj, dist)
	if dist < (spellR.range) then
		res.obj = obj
		return true
	end
end
local Ghoooooooooooooooost
local Dragoooooon
local function DeleteObj(object)
	if object and object.name:find("R_tar_Dragon") then
		Dragoooooon = nil
	end
	if object and object.name:find("R_tar_pet") then
		Ghoooooooooooooooost = nil
	end
end
local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end
local GetTargetW = function()
	return TS.get_result(TargetSelectionW).obj
end
local GetTargetGap = function()
	return TS.get_result(TargetSelectionGap).obj
end

local last_item_update = 0
local HasItem = false
function GetExtraDamage(target)
	local extradamage = 0
	if os.clock() > last_item_update then
		HasItem = false
		for i = 0, 5 do
			if player:itemID(i) == 3151 then
				HasItem = true
			end
		end
		last_item_update = os.clock() + 1.
	end
	if HasItem then
		extradamage = target.maxHealth * 0.01
		if
			(target.buff[5] or target.buff[8] or target.buff[24] or target.buff[10] or target.buff[11] or target.buff[22] or
				target.buff[8] or
				target.buff[21])
		 then
			extradamage = (target.maxHealth * 0.01) * 2
		end
		extradamage = (extradamage * 8.5) - target.healthRegenRate * 3
	end
	return extradamage
end
local wtime = 0
local wtimejungle = 0
local wtimelane = 0
local allow = true
local function AutoInterrupt(spell)
	if
		spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY and spell.owner == player and
			spell.target.type == TYPE_HERO
	 then
		if spell.name:find("BasicAttack") or spell.name:find("QAttack") then
			allow = false
		end
	end
	if spell.owner.charName == "Mordekaiser" then
		if spell.name == "MordekaiserCreepingDeathCast" then
			wtime = os.clock() + menu.combo.chargew:get()
			wtimelane = os.clock() + menu.farming.laneclear.chargew:get()
			wtimejungle = os.clock() + menu.farming.jungleclear.chargew:get()
		end
	end
end
orb.combat.register_f_after_attack(
	function()
		allow = true
		if menu.keys.combokey:get() then
			if orb.combat.target then
				if
					menu.combo.qaa:get() and menu.combo.qcombo:get() and orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					if player:spellSlot(0).state == 0 then
						player:castSpell("self", 0)
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
		if menu.keys.harasskey:get() then
			if orb.combat.target then
				if
					menu.harass.qaa:get() and menu.harass.qcombo:get() and orb.combat.target and
						common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					if player:spellSlot(0).state == 0 then
						player:castSpell("self", 0)
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
		local target2 = GetTargetW()
		if menu.harass.wcombo:get() and player:spellSlot(1).state == 0 then
			if common.IsValidTarget(target2) and target2 then
				if (target2.pos:dist(player) <= spellW.range) then
					if player.buff["mordekaiserwactive"] or player.buff["mordekaiserwinactive"] then
						if target2.pos:dist(player.pos) < 300 and wtime < os.clock() then
							player:castSpell("self", 1)
						end
					end
				end
			end
		end
	end
)

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
local RDamages = {24, 29, 34}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
			common.CalculateMagicDamage(
			target,
			(RDamages[player:spellSlot(3).level] / 100 + (0.04 / 100 * common.GetTotalAP())) * target.maxHealth,
			player
		)
	end
	if player.buff["liandrysbuff"] then
		damage = (damage + damage * (0.01 * player.buff["liandrysbuff"].stacks2))
	end
	return math.floor(damage) - (target.healthRegenRate * 10) + GetExtraDamage(target)
end
local QLevelDamage = {10, 20, 30, 40, 50}
local QLevelDamageAD = {0.5, 0.6, 0.7, 0.8, 0.9}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculateMagicDamage(
			target,
			(QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAP() * .6)) +
				QLevelDamageAD[player:spellSlot(0).level] * common.GetTotalAD(),
			player
		)
	end
	return damage + common.CalculateAADamage(target)
end

local function Combo()
	local target = GetTarget()

	if menu.combo.useitems:get() then
		if common.IsValidTarget(target) and target then
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
	end
	if menu.combo.rcombo:get() then
		local target = GetTargetGap()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if
					(target.pos:dist(player.pos) <= spellR.range) and (target.health / target.maxHealth) * 100 <= menu.combo.hpr:get()
				 then
					if menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
						player:castSpell("obj", 3, target)
					end
				end
			end
		end
	end
	if menu.combo.ecombo:get() and player:spellSlot(2).state == 0 then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellE.range) then
				local seg = preds.linear.get_prediction(spellE, target)
				if seg and seg.startPos:dist(seg.endPos) <= spellE.range then
					player:castSpell("pos", 2, vec3(seg.endPos.x, target.y, seg.endPos.y))
				end
			end
		end
	end
	if menu.combo.qcombo:get() and not menu.combo.qaa:get() and player:spellSlot(0).state == 0 then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < 300) then
				player:castSpell("self", 0)
				player:attack(target)
			end
		end
	end
	local target2 = GetTargetW()
	if menu.combo.wcombo:get() and player:spellSlot(1).state == 0 then
		if common.IsValidTarget(target2) and target2 then
			if (target2.pos:dist(player) <= spellW.range) then
				if player.buff["mordekaiserwactive"] or player.buff["mordekaiserwinactive"] then
					if target2.pos:dist(player.pos) < 300 and allow and os.clock() > wtime then
						player:castSpell("self", 1)
					end
				end
				if #count_allies_in_range(player.pos, spellW.range) > 1 then
					for i = 0, objManager.allies_n - 1 do
						local hero = objManager.allies[i]

						if hero and hero.isVisible and not hero.isDead and hero.pos:dist(player.pos) <= spellW.range then
							if not player.buff["mordekaiserwactive"] and not player.buff["mordekaiserwinactive"] then
								if player.pos:dist(target2.pos) < hero.pos:dist(target2.pos) then
									if target2.pos:dist(player.pos) < 300 then
										player:castSpell("self", 1)
									end
								end
								if player.pos:dist(target2.pos) > hero.pos:dist(target2.pos) then
									if target2.pos:dist(hero.pos) < 300 then
										player:castSpell("pos", 1, hero.pos)
									end
								end
							end
						end
					end
				end
				if not player.buff["mordekaiserwactive"] and not player.buff["mordekaiserwinactive"] then
					if #count_allies_in_range(player.pos, spellW.range) == 1 then
						if target2.pos:dist(player.pos) < 300 then
							player:castSpell("self", 1)
						end
					end
				end
			end
		end
	end
	if menu.combo.ecombo:get() and player:spellSlot(2).state == 0 then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellE.range) then
				local seg = preds.linear.get_prediction(spellE, target)
				if seg and seg.startPos:dist(seg.endPos) <= spellE.range then
					player:castSpell("pos", 2, vec3(seg.endPos.x, target.y, seg.endPos.y))
				end
			end
		end
	end
end
-- Credits to Avada's Kalista. <3
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

				local Rdmg = 0
				Rdmg = RDamage(obj)

				local damage = obj.health - Rdmg

				local x1 = xPos + ((obj.health / obj.maxHealth) * 102)
				local x2 = xPos + (((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if (Rdmg < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if (Rdmg > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if (math.floor((RDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(RDamage(target))) ..
					" (" .. tostring(math.floor((RDamage(target)) / target.health * 100)) .. "%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if (math.floor((RDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(RDamage(target))) ..
					" (" .. tostring(math.floor((RDamage(target)) / target.health * 100)) .. "%)" .. "Kilable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 150, 255, 200)
			)
		end
	end
end

local function JungleClear()
	if menu.farming.jungleclear.useq:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < 300
			 then
				player:castSpell("self", 0)
				player:attack(minion)
			end
		end
	end

	if menu.farming.jungleclear.usew:get() and player:spellSlot(1).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < 350
			 then
				if player.buff["mordekaiserwactive"] or player.buff["mordekaiserwinactive"] then
					if minion.pos:dist(player.pos) < 300 and allow and os.clock() > wtimejungle then
						player:castSpell("self", 1)
					end
				end
				if not player.buff["mordekaiserwactive"] and not player.buff["mordekaiserwinactive"] then
					player:castSpell("self", 1)
				end
			end
		end
	end
	if menu.farming.jungleclear.usee:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellE.range
			 then
				local seg = preds.linear.get_prediction(spellE, minion)
				if seg and seg.startPos:dist(seg.endPos) < spellE.range then
					player:castSpell("pos", 2, vec3(seg.endPos.x, minion.y, seg.endPos.y))
				end
			end
		end
	end
end

local function Harass()
	local target = GetTarget()
	if menu.harass.ecombo:get() and player:spellSlot(2).state == 0 then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellE.range) then
				local seg = preds.linear.get_prediction(spellE, target)
				if seg and seg.startPos:dist(seg.endPos) <= spellE.range then
					player:castSpell("pos", 2, vec3(seg.endPos.x, target.y, seg.endPos.y))
				end
			end
		end
	end
	if menu.harass.qcombo:get() and not menu.harass.qaa:get() and player:spellSlot(0).state == 0 then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < 300) then
				player:castSpell("self", 0)
				player:attack(target)
			end
		end
	end
	local target2 = GetTargetW()
	if menu.harass.wcombo:get() and player:spellSlot(1).state == 0 then
		if common.IsValidTarget(target2) and target2 then
			if (target2.pos:dist(player) <= spellW.range) then
				if player.buff["mordekaiserwactive"] or player.buff["mordekaiserwinactive"] then
					if target2.pos:dist(player.pos) < 300 and allow and os.clock() > wtime then
						player:castSpell("self", 1)
					end
				end
				if #count_allies_in_range(player.pos, spellW.range) > 1 then
					for i = 0, objManager.allies_n - 1 do
						local hero = objManager.allies[i]

						if hero and hero.isVisible and not hero.isDead and hero.pos:dist(player.pos) <= spellW.range then
							if not player.buff["mordekaiserwactive"] and not player.buff["mordekaiserwinactive"] then
								if player.pos:dist(target2.pos) < hero.pos:dist(target2.pos) then
									if target2.pos:dist(player.pos) < 300 then
										player:castSpell("self", 1)
									end
								end
								if player.pos:dist(target2.pos) > hero.pos:dist(target2.pos) then
									if target2.pos:dist(hero.pos) < 300 then
										player:castSpell("pos", 1, hero.pos)
									end
								end
							end
						end
					end
				end
				if not player.buff["mordekaiserwactive"] and not player.buff["mordekaiserwinactive"] then
					if #count_allies_in_range(player.pos, spellW.range) == 1 then
						if target2.pos:dist(player.pos) < 300 then
							player:castSpell("self", 1)
						end
					end
				end
			end
		end
	end
end

local function LaneClear()
	if not mhh then
		if menu.farming.laneclear.farmq:get() and player:spellSlot(0).state == 0 then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) <= spellQ.range
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellQ.range then
						if not menu.farming.laneclear.lastq:get() then
							player:castSpell("self", 0)
							player:attack(minion)
						end
						if menu.farming.laneclear.lastq:get() and player:spellSlot(0).state == 0 then
							for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
								local minion = objManager.minions[TEAM_ENEMY][i]
								if
									minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
										minion.pos:dist(player.pos) <= spellQ.range
								 then
									if minion.health <= QDamage(minion) then
										player:castSpell("self", 0)
										player:attack(minion)
									end
								end
							end
						end
					end
				end
			end
		end
		if menu.farming.jungleclear.usew:get() and player:spellSlot(1).state == 0 then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < 350
				 then
					if player.buff["mordekaiserwactive"] or player.buff["mordekaiserwinactive"] then
						if minion.pos:dist(player.pos) < 300 and allow and os.clock() > wtimelane then
							player:castSpell("self", 1)
						end
					end
					if not player.buff["mordekaiserwactive"] and not player.buff["mordekaiserwinactive"] then
						player:castSpell("self", 1)
					end
				end
			end
		end
		if player:spellSlot(2).state == 0 then
			if menu.farming.laneclear.farme:get() then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if minion and minion.pos:dist(player.pos) <= spellE.range and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos then
							if #count_minions_in_range(minionPos, 250) >= menu.farming.laneclear.hitse:get() then
								local seg = preds.linear.get_prediction(spellE, minion)
								if seg and seg.startPos:dist(seg.endPos) < spellE.range then
									player:castSpell("pos", 2, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end
end
local function LastHit()
	if menu.lasthit.useq:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) <= 300
			 then
				if minion.health <= QDamage(minion) then
					player:castSpell("self", 0)
					player:attack(minion)
				end
			end
		end
	end
end

local function OnDraw()
	if menu.draws.drawghost:get() then
		if Ghoooooooooooooooost and Ghoooooooooooooooost.isOnScreen then
			graphics.draw_circle(Ghoooooooooooooooost.pos, 120, 2, graphics.argb(255, 255, 204, 204), 20)
			graphics.draw_circle(Ghoooooooooooooooost.pos, 100, 2, graphics.argb(155, 255, 204, 204), 20)
			graphics.draw_circle(Ghoooooooooooooooost.pos, 80, 2, graphics.argb(55, 255, 204, 204), 20)
			graphics.draw_circle(Ghoooooooooooooooost.pos, 60, 2, graphics.argb(5, 255, 204, 204), 20)
		end
		if Dragoooooon and Dragoooooon.isOnScreen then
			graphics.draw_circle(Dragoooooon.pos, 120, 2, graphics.argb(255, 255, 204, 204), 20)
			graphics.draw_circle(Dragoooooon.pos, 100, 2, graphics.argb(155, 255, 204, 204), 20)
			graphics.draw_circle(Dragoooooon.pos, 80, 2, graphics.argb(55, 255, 204, 204), 20)
			graphics.draw_circle(Dragoooooon.pos, 60, 2, graphics.argb(5, 255, 204, 204), 20)
		end
	end
	if player.isOnScreen then
		if Ghoooooooooooooooost then
			if menu.draws.drawrg:get() then
				graphics.draw_circle(player.pos, 2100, 4, graphics.argb(50, 255, 204, 204), 80)
			end
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 80)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 80)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 80)
		end
	end
	if menu.draws.drawdamage:get() then
		local enemy = common.GetEnemyHeroes()
		for i, enemies in ipairs(enemy) do
			if
				enemies and enemies.isOnScreen and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 100000 and
					not common.HasBuffType(enemies, 17)
			 then
				DrawDamagesE(enemies)
			end
		end
	end
end

local TargetSelectionGhost = function(res, obj, dist)
	if dist <= spellE.range then
		res.obj = obj
		return true
	end
end

local GetTargetGhost = function()
	return TS.get_result(TargetSelectionGhost).obj
end
local TargetSelectionGhost2 = function(res, obj, dist)
	if dist <= 2000 then
		res.obj = obj
		return true
	end
end

local GetTargetGhost2 = function()
	return TS.get_result(TargetSelectionGhost2).obj
end
local TargetSelectionGragon2 = function(res, obj, dist)
	if dist <= 20000000000 then
		res.obj = obj
		return true
	end
end

local GetTargetDragon2 = function()
	return TS.get_result(TargetSelectionGragon2).obj
end
local LastMovemenent = 0
local function GhostControl()
	if LastMovemenent < os.clock() then
		if player.buff["mordekaisercotgself"] then
			if menu.combo.rghost:get() == 2 then
				local target = GetTargetGhost()
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) <= spellE.range) then
						player:castSpell("pos", 3, target.pos)
						LastMovemenent = os.clock() + 1
					end
				end
				if #count_enemies_in_range(player.pos, 800) == 0 then
					player:castSpell("pos", 3, player.pos)
					LastMovemenent = os.clock() + 1
				end
			end
			if Dragoooooon then
				if menu.combo.rghost:get() == 3 then
					local target = GetTargetDragon2()
					if common.IsValidTarget(target) and target then
						if (target.pos:dist(player) <= 100000) then
							player:castSpell("pos", 3, target.pos)
							LastMovemenent = os.clock() + 1
						end
					end
				end
			end
			if Ghoooooooooooooooost then
				if menu.combo.rghost:get() == 3 then
					local target = GetTargetGhost2()
					if common.IsValidTarget(target) and target then
						if (target.pos:dist(player) <= 2000) then
							player:castSpell("pos", 3, target.pos)
							LastMovemenent = os.clock() + 1
						end
					end
				end
			end
		end
	end
end
local timer = 0
local function OnTick()
	if os.clock() > timer then
		objManager.loop(
			function(obj)
				if
					obj and obj.team == TEAM_ALLY and obj.owner == player and obj.type == TYPE_MINION and obj.moveSpeed > 0 and
						obj.isTargetable and
						obj.health > 200
				 then
					Ghoooooooooooooooost = obj
					timer = os.clock() + 5
				end
				if obj and obj.team == TEAM_ALLY and obj.owner == player and obj.name:find("dragon") then
					Dragoooooon = obj
					timer = os.clock() + 5
				end
			end
		)
	end
	GhostControl()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and enemies.isVisible and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ap", enemies)
			if menu.combo.autor:get() then
				if
					player:spellSlot(3).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) <= spellR.range and
						RDamage(enemies) > hp
				 then
					player:castSpell("obj", 3, enemies)
				end
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

cb.add(cb.draw, OnDraw)
orb.combat.register_f_pre_tick(OnTick)
cb.add(cb.spell, AutoInterrupt)
cb.add(cb.deleteobj, DeleteObj)
--cb.add(cb.tick, OnTick)
