local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Alistar by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Alistar by Kornis'!")
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
	range = 355,
	delay = 0.25,
	speed = 1500,
	radius = 150,
	boundingRadiusMod = 1
}

local spellW = {
	range = 650
}

local spellE = {
	range = 350
}

local spellR = {
	range = 0
}
local FlashSlot = nil
if player:spellSlot(4).name == "SummonerFlash" then
	FlashSlot = 4
elseif player:spellSlot(5).name == "SummonerFlash" then
	FlashSlot = 5
end

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
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Alistar")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:keybind("wtog", " ^- Toggle for W without Q", "T', nil")
menu.combo:boolean("wastew", "Don't waste W if target in Q range", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("waite", " ^- Block Auto Attacks if not Stacked", true)
menu.combo:boolean("rcombo", "Auto R on CC", true)
menu.combo:slider("hp", " ^- Min. Health Percent", 25, 1, 100, 1)
menu.combo:slider("hitr", " ^- Min. Enemies", 2, 1, 5, 1)

menu:menu("blacklist", "W Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawfq", "Draw Q Flash Range", true)
menu.draws:color("colorfq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draweng", "Draw Engage Range", true)
menu.draws:color("coloreng", "  ^- Color", 255, 255, 255, 255)

menu:menu("misc", "Misc.")
menu.misc:boolean("GapAS", "Use Q for Anti-Gapclose", true)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("intq", "Use Q to Interrupt", true)
menu.misc.interrupt:boolean("intw", "Use W to Interrupt", true)
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
menu:keybind("flashq", "Q Flash", "Z", nil)
menu:keybind("engage", "W Q Flash", "G", nil)
menu:keybind("Insec", "Insec", "A", nil)

local function AutoInterrupt(spell)
	if menu.misc.interrupt.intq:get() and player:spellSlot(0).state == 0 then
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
								player:spellSlot(0).state == 0
						 then
							player:castSpell("self", 0)
						end
					end
				end
			end
		end
	end
	if menu.misc.interrupt.intw:get() and player:spellSlot(1).state == 0 then
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
							player.pos2D:dist(spell.owner.pos2D) < spellW.range and common.IsValidTarget(spell.owner) and
								player:spellSlot(1).state == 0
						 then
							if player:spellSlot(0).state ~= 0 or spell.owner.pos:dist(player.pos) > spellQ.range then
								player:castSpell("obj", 1, spell.owner)
							end
						end
					end
				end
			end
		end
	end
end
local function WGapcloser()
	if player:spellSlot(0).state == 0 and menu.misc.GapAS:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < 300
				 then
					if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
						player:castSpell("self", 0)
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

local function FlashQ()
	if menu.flashq:get() then
		player:move(mousePos)
		if (FlashSlot and player:spellSlot(FlashSlot).state == 0 and player:spellSlot(1).state == 0) then
			local target = GetTargetFQ()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) > spellQ.range then
						local pos = preds.circular.get_prediction(spellQ, target)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range + 380 then
							player:castSpell("self", 0)
							common.DelayAction(
								function()
									player:castSpell("pos", FlashSlot, target.pos)
								end,
								0.2
							)
						end
					end
				end
			end
		end
	end
end

local function Toggle()
	if menu.combo.wtog:get() then
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

local TargetSelectionEngage = function(res, obj, dist)
	if dist < 1300 then
		res.obj = obj
		return true
	end
end
local GetTargetEngage = function()
	return TS.get_result(TargetSelectionEngage).obj
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

local TargetSelectionR = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end

local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
end

local function Engage()
	if menu.engage:get() then
		player:move(mousePos)

		if
			(player.mana > player.manaCost0 + player.manaCost1 and FlashSlot and player:spellSlot(FlashSlot).state == 0 and
				player:spellSlot(0).state == 0)
		 then
			local target = GetTargetEngage()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) > spellQ.range then
						local enemyMinionsE = common.GetMinionsInRange(spellW.range, TEAM_ENEMY)
						for i, minion in pairs(enemyMinionsE) do
							if
								minion and not minion.isDead and minion.pos:dist(target.pos) < spellQ.range + 380 and
									common.IsValidTarget(minion)
							 then
								player:castSpell("obj", 1, minion)
								if (player:spellSlot(1).state ~= 0) then
									player:castSpell("self", 0)
									common.DelayAction(
										function()
											player:castSpell("pos", FlashSlot, target.pos)
										end,
										0.2
									)
								end
							end
						end
					end
				end
			end
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
	local target = GetTargetW()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if
				menu.combo.wcombo:get() and player.mana > player.manaCost0 + player.manaCost1 and player:spellSlot(0).state == 0 and
					player:spellSlot(1).state == 0
			 then
				if not menu.blacklist[target.charName]:get() then
					if not menu.combo.wastew:get() then
						player:castSpell("obj", 1, target)
					end
					if menu.combo.wastew:get() and target.pos:dist(player.pos) > spellQ.range then
						player:castSpell("obj", 1, target)
					end
				end
			end
			if menu.combo.wcombo:get() and uhh then
				if not menu.blacklist[target.charName]:get() then
					player:castSpell("obj", 1, target)
				end
			end
			if menu.combo.qcombo:get() then
				if target.pos:dist(player.pos) < spellQ.range then
					local pos = preds.circular.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range + 380 then
						player:castSpell("self", 0)
					end
				end
			end
			if menu.combo.ecombo:get() then
				if target.pos:dist(player.pos) < spellE.range then
					player:castSpell("self", 2)
				end
			end
		end
	end
end
local function SemiR()
	local target = GetTargetR()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if menu.combo.rcombo:get() then
				local pos = preds.circular.get_prediction(spellR, target)
				if pos and pos.startPos:dist(pos.endPos) < spellR.range then
					player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
end
local function AutoDash()
	local seg = {}
	local target =
		TS.get_result(
		function(res, obj, dist)
			if dist <= spellE.range and obj.path.isActive and obj.path.isDashing then --add invulnverabilty check
				res.obj = obj
				return true
			end
		end
	).obj
	if target then
		local pred_pos = preds.core.lerp(target.path, network.latency + spellE.delay, target.path.dashSpeed)
		if pred_pos and pred_pos:dist(player.path.serverPos2D) <= spellE.range then
			player:castSpell("pos", 2, vec3(pred_pos.x, target.y, pred_pos.y))
		end
	end
end
local TargetSelectionInsec = function(res, obj, dist)
	if dist < spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetInsec = function()
	return TS.get_result(TargetSelectionInsec).obj
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
local function Insec()
	player:move(mousePos)
	local target = GetTargetInsec()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if target.pos:dist(player.pos) <= 300 then
				if
					(FlashSlot and player:spellSlot(FlashSlot).state == 0 and player:spellSlot(1).state == 0 and
						player:spellSlot(0).state == 0)
				 then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally and ally.pos:dist(player.pos) <= 1000 and ally ~= player then
							local direction = (ally.pos - target.pos):norm()
							local extendedPos = target.pos - direction * 150
							player:castSpell("pos", FlashSlot, extendedPos)
							player:castSpell("self", 0)
							common.DelayAction(
								function()
									player:castSpell("obj", 1, target)
								end,
								0.33 + network.latency
							)
						end
					end
					if (#count_allies_in_range(player.pos, 1000)) == 1 then
						local direction = (player.pos - target.pos):norm()
						local extendedPos = target.pos - direction * 150
						player:castSpell("pos", FlashSlot, extendedPos)
						player:castSpell("self", 0)
						common.DelayAction(
							function()
								player:castSpell("obj", 1, target)
							end,
							0.33 + network.latency
						)
					end
				end
			end
		end
	end
end
local function OnTick()
	if menu.Insec:get() then
		Insec()
	end
	FlashQ()
	Engage()
	if (player.buff["alistare"] and menu.combo.waite:get()) then
		if (player.buff["alistare"].stacks2) < 5 then
			orb.core.set_pause_attack(math.huge)
		else
			orb.core.set_pause_attack(0)
		end
	else
		orb.core.set_pause_attack(0)
	end
	if menu.combo.rcombo:get() then
		if (#count_enemies_in_range(player.pos, 600) >= menu.combo.hitr:get()) then
			if (player.health / player.maxHealth) * 100 <= menu.combo.hp:get() then
				if
					(player.buff[5] or player.buff[8] or player.buff[24] or player.buff[11] or player.buff[22] or player.buff[8] or
						player.buff[21])
				 then
					player:castSpell("self", 3)
				end
			end
		end
	end

	WGapcloser()
	Toggle()
	if menu.keys.combokey:get() then
		Combo()
	end
end

local function OnDraw()
	--print("Drawings - 4")
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
		if menu.draws.draweng:get() then
			graphics.draw_circle(player.pos, 1300, 2, menu.draws.coloreng:get(), 100)
		end
		if menu.draws.drawfq:get() then
			graphics.draw_circle(player.pos, spellQ.range + 380, 2, menu.draws.colorfq:get(), 100)
		end
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
		if uhh == true then
			graphics.draw_text_2D("W without Q: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
			graphics.draw_text_2D("ON", 17, pos.x + 75, pos.y + 10, graphics.argb(255, 51, 255, 51))
		else
			graphics.draw_text_2D("W without Q: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
			graphics.draw_text_2D("OFF", 17, pos.x + 75, pos.y + 10, graphics.argb(255, 255, 0, 0))
		end
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)

cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
