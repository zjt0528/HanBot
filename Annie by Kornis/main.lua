local version = "1.0"

local avada_lib = module.lib("avada_lib")
if not avada_lib then
	print("")
	console.set_color(79)
	print("                                                                                   ")
	print("----------- Annie by Kornis -------------                                          ")
	print("You need to have Avada Lib in your community_libs folder to run this script!       ")
	print("You can find it here:                                                              ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                          ")
	console.set_color(79)
	print("                                                                                   ")
	console.set_color(12)
	local menuerror = menu("AnnieaKornis", "Annie By Kornis")
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
elseif avada_lib.version < 1 then
	print("")
	console.set_color(79)
	print("                                                                                   ")
	print("----------- Annie by Kornis -------------                                          ")
	print("You need to have Avada Lib in your community_libs folder to run this script!       ")
	print("You can find it here:                                                              ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                          ")
	console.set_color(79)
	print("                                                                                   ")
	console.set_color(12)
	local menuerror = menu("AnnieaKornis", "Annie By Kornis")
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
end

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = avada_lib.common
local dmglib = avada_lib.damageLib

local spellQ = {
	range = 630
}

local spellW = {
	range = 625,
	width = 200,
	speed = math.huge,
	boundingRadiusMod = 0,
	delay = 0.5
}

local spellE = {
	range = 0
}

local spellR = {
	range = 600,
	delay = 0.3,
	speed = math.huge,
	radius = 85,
	boundingRadiusMod = 0
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

local tSelector = avada_lib.targetSelector
local menu = menu("AnnieaKornis", "Annie By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()

menu:menu("combo", "Combo")
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("startq", "Start Combo with Q", true)
menu.combo:slider("forcew", " ^- Force W if X Enemies", 3, 1, 5, 1)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("ecombo", "Auto E on Enemy Auto Attacks", true)
menu.combo:boolean("follow", "Auto Bear Control", true)
menu.combo:header("uhh", "-- 1 v 1 Settings --")
menu.combo:dropdown("rusage", "R Usage", 2, {"At X Health", "Only if Killable", "Never"})
menu.combo:slider("waster", " ^- Don't waste R if Enemy Health Percent <= ", 15, 0, 100, 1)
menu.combo:slider("hpr", "R if Target has X Health Percent", 60, 0, 100, 1)
menu.combo:header("uhhh", "-- Teamfight Settings --")
menu.combo:boolean("forcer", "Force R in TeamFights", true)
menu.combo:slider("hitr", "Min. Enemies to Hit", 2, 2, 5, 1)

menu:menu("harass", "Harass")
menu.harass:slider("mana", "Mana Manager", 50, 1, 100, 1)
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("wcombo", "Use W in Harass", true)

menu:menu("laneclear", "Lane Clear")
menu.laneclear:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.laneclear:boolean("lastq", " ^-Only for Last Hit", true)
menu.laneclear:boolean("farmw", "Use W to Farm", false)
menu.laneclear:slider("hitw", " ^- if Hits X", 2, 1, 6, 1)

menu:menu("lasthit", "Last Hit")
menu.lasthit:boolean("useq", "Use Q to Last Hit", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)
menu.killsteal:boolean("ksw", "Killsteal with W", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawflash", "Draw Flash - R Range", true)
menu.draws:boolean("drawtoggle", "Draw Stack Toggle", true)
menu.draws:boolean("drawdamage", "Draw Damage", true)

menu:menu("misc", "Misc.")
menu.misc:boolean("disable", "Disable Auto Attack in Combo", true)
menu.misc:boolean("disableq", " ^- Only if Q is up", true)
menu.misc:slider("level", "Disable AA at X Level", 6, 1, 18, 1)

menu.misc:menu("Gap", "Gapcloser Settings")
menu.misc.Gap:boolean("GapA", "Use Stacked W for Anti-Gapclose", true)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("inte", "Use W to Interrupt if Possible", true)
menu.misc.interrupt:menu("interruptmenu", "Interrupt Settings")
for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.misc.interrupt.interruptmenu:boolean(
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
menu:keybind("stack", "Save Stacks Toggle", "T", nil)
menu:boolean("stacke", "Auto Stack with E", true)
menu:slider("stackingw", " ^- Mana Manager", 50, 1, 100, 1)
menu:keybind("flashr", "Flash - R Key", "G", nil)

TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist <= spellQ.range then
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
	if menu.stack:get() then
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

local RLevelDamage = {150, 275, 400}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (RLevelDamage[player:spellSlot(3).level] + (common.GetTotalAP() * .65)), player)
	end
	return damage
end
local QLevelDamage = {80, 115, 150, 185, 220}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAP() * .8)), player)
	end
	return damage
end
local WLevelDamage = {70, 115, 160, 205, 250}
function WDamage(target)
	local damage = 0
	if player:spellSlot(1).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (WLevelDamage[player:spellSlot(1).level] + (common.GetTotalAP() * .85)), player)
	end
	return damage
end

local waiting = 0
local chargingW = 0
local uhhh = 0
local enemy = nil
local TargetSelectionFollow = function(res, obj, dist)
	if dist < 2000 then
		res.obj = obj
		return true
	end
end
local GetTargetFollow = function()
	return TS.get_result(TargetSelectionFollow).obj
end
local function RFollow()
	if menu.combo.follow:get() then
		if player.buff["infernalguardiantimer"] then
			local target = GetTargetFollow()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					player:castSpell("pos", 3, target.pos)
				end
			end
		end
	end
end
local function AutoInterrupt(spell) -- Thank you Dew for this <3
	if menu.combo.ecombo:get() then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == player then
			if spell.name:find("BasicAttack") then
				player:castSpell("obj", 2, player)
			end
		end
	end
	if player.buff["pyromania_particle"] then
		if menu.misc.interrupt.inte:get() then
			if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
				local enemyName = string.lower(spell.owner.charName)
				if interruptableSpells[enemyName] then
					for i = 1, #interruptableSpells[enemyName] do
						local spellCheck = interruptableSpells[enemyName][i]
						if
							menu.misc.interrupt.interruptmenu[spell.owner.charName .. spellCheck.menuslot]:get() and
								string.lower(spell.name) == spellCheck.spellname
						 then
							if player.pos2D:dist(spell.owner.pos2D) < spellW.range and common.IsValidTarget(spell.owner) then
								player:castSpell("pos", 1, spell.owner.pos)
							end
						end
					end
				end
			end
		end
	end
end

local function WGapcloser()
	if player.buff["pyromania_particle"] then
		if menu.misc.Gap.GapA:get() then
			for i = 0, objManager.enemies_n - 1 do
				local dasher = objManager.enemies[i]
				if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
					if
						dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
							player.pos:dist(dasher.path.point[1]) < spellW.range
					 then
						if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
							player:castSpell("pos", 1, dasher.path.point2D[1])
						end
					end
				end
			end
		end
	end
end

local function Combo()
	local target = GetTarget()
	if menu.combo.startq:get() then
		if common.IsValidTarget(target) and target then
			if menu.combo.forcer:get() and player:spellSlot(3).state == 0 then
				if #count_enemies_in_range(target.pos, 290) >= menu.combo.hitr:get() then
					local pos = preds.circular.get_prediction(spellR, target)
					if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
			if menu.combo.rusage:get() == 1 and player:spellSlot(3).state == 0 then
				if (target.health / target.maxHealth) * 100 > menu.combo.waster:get() then
					if (target.health / target.maxHealth) * 100 <= menu.combo.hpr:get() then
						local pos = preds.circular.get_prediction(spellR, target)
						if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.combo.rusage:get() == 2 and player:spellSlot(3).state == 0 then
				if (target.health / target.maxHealth) * 100 > menu.combo.waster:get() then
					if (target.health <= QDamage(target) + WDamage(target) + RDamage(target)) then
						local pos = preds.circular.get_prediction(spellR, target)
						if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end

		if menu.combo.wcombo:get() then
			if common.IsValidTarget(target) and target then
				if menu.combo.forcew:get() <= #count_enemies_in_range(target.pos, 200) then
					if (target.pos:dist(player) < spellR.range) then
						local pos = preds.linear.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
		if menu.combo.qcombo:get() then
			if common.IsValidTarget(target) and target then
				if (target.pos:dist(player) <= spellQ.range) then
					player:castSpell("obj", 0, target)
				end
			end
		end
		if menu.combo.wcombo:get() then
			if common.IsValidTarget(target) and target then
				if (target.pos:dist(player) < spellR.range) then
					local pos = preds.linear.get_prediction(spellW, target)
					if pos and pos.startPos:dist(pos.endPos) < spellW.range then
						player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
	if not menu.combo.startq:get() then
		if common.IsValidTarget(target) and target then
			if menu.combo.forcer:get() and player:spellSlot(3).state == 0 then
				if #count_enemies_in_range(target.pos, 290) >= menu.combo.hitr:get() then
					local pos = preds.circular.get_prediction(spellR, target)
					if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
			if menu.combo.rusage:get() == 1 and player:spellSlot(3).state == 0 then
				if (target.health / target.maxHealth) * 100 > menu.combo.waster:get() then
					if (target.health / target.maxHealth) * 100 <= menu.combo.hpr:get() then
						local pos = preds.circular.get_prediction(spellR, target)
						if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.combo.rusage:get() == 2 and player:spellSlot(3).state == 0 then
				if (target.health / target.maxHealth) * 100 > menu.combo.waster:get() then
					if (target.health <= QDamage(target) + WDamage(target) + RDamage(target)) then
						local pos = preds.circular.get_prediction(spellR, target)
						if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
		if menu.combo.wcombo:get() then
			if common.IsValidTarget(target) and target then
				if (target.pos:dist(player) < spellR.range) then
					local pos = preds.linear.get_prediction(spellW, target)
					if pos and pos.startPos:dist(pos.endPos) < spellW.range then
						player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
		if menu.combo.qcombo:get() then
			if common.IsValidTarget(target) and target then
				if (target.pos:dist(player) <= spellQ.range) then
					player:castSpell("obj", 0, target)
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
				local Edmg = 0
				local Wdmg = 0

				Rdmg = WDamage(obj)
				Edmg = QDamage(obj)
				Wdmg = RDamage(obj)

				local damage = obj.health - (Rdmg + Edmg + Wdmg)

				local x1 = xPos + ((obj.health / obj.maxHealth) * 102)
				local x2 = xPos + (((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if ((Rdmg + Edmg + Wdmg) < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if ((Rdmg + Edmg + Wdmg) > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if (math.floor((WDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(WDamage(target) + RDamage(target) + QDamage(target))) ..
					" (" ..
						tostring(math.floor((WDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if (math.floor((WDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(WDamage(target) + RDamage(target) + QDamage(target))) ..
					" (" ..
						tostring(math.floor((WDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)) ..
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
	if uhh then
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
				local enemyMinionsQ = common.GetMinionsInRange(spellW.range, TEAM_NEUTRAL)
				for i, minion in pairs(enemyMinionsQ) do
					if minion and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellW.range then
							local pos = preds.linear.get_prediction(spellW, minion)
							if pos and pos.startPos:dist(pos.endPos) < spellW.range then
								player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
	end
	if not uhh and not player.buff["pyromania_particle"] then
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
				local enemyMinionsQ = common.GetMinionsInRange(spellW.range, TEAM_NEUTRAL)
				for i, minion in pairs(enemyMinionsQ) do
					if minion and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellW.range then
							local pos = preds.linear.get_prediction(spellW, minion)
							if pos and pos.startPos:dist(pos.endPos) < spellW.range then
								player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
	end
end

local function Harass()
	if (player.mana / player.maxMana) * 100 >= menu.harass.mana:get() then
		if uhh then
			local target = GetTarget()
			if menu.harass.wcombo:get() then
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) < spellW.range) then
						local pos = preds.linear.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.harass.qcombo:get() then
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) <= spellQ.range) then
						player:castSpell("obj", 0, target)
					end
				end
			end
		end
		if not uhh and not player.buff["pyromania_particle"] then
			local target = GetTarget()
			if menu.harass.wcombo:get() then
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) < spellW.range) then
						local pos = preds.linear.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.harass.qcombo:get() then
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) <= spellQ.range) then
						player:castSpell("obj", 0, target)
					end
				end
			end
		end
	end
end
local function KillSteal()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("AP", enemies)
			if menu.killsteal.ksq:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range and
						QDamage(enemies) >= hp
				 then
					player:castSpell("obj", 0, enemies)
				end
			end
			if menu.killsteal.ksw:get() then
				if
					player:spellSlot(1).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellW.range and
						WDamage(enemies) >= hp
				 then
					local pos = preds.linear.get_prediction(spellW, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellW.range then
						player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
end
local function LaneClear()
	if uhh then
		if (player.mana / player.maxMana) * 100 >= menu.laneclear.mana:get() then
			if menu.laneclear.farmq:get() and player:spellSlot(0).state == 0 then
				local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
				for i, minion in pairs(enemyMinionsQ) do
					if minion and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellQ.range then
							if not menu.laneclear.lastq:get() then
								player:castSpell("obj", 0, minion)
							end
							if menu.laneclear.lastq:get() then
								for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
									local minion = objManager.minions[TEAM_ENEMY][i]
									if minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) <= spellQ.range then
										local minionPos = vec3(minion.x, minion.y, minion.z)
										--delay = player.pos:dist(minion.pos) / 3500 + 0.2
										delay = 0.25 + player.pos:dist(minion.pos) / 750
										if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150 and player.mana > player.manaCost0) then
											orb.core.set_pause_attack(1)
										end
										if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
											player:castSpell("obj", 0, minion)
										end
									end
								end
							end
						end
					end
				end
			end
			if player:spellSlot(1).state == 0 then
				if menu.laneclear.farmw:get() then
					for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
						local minion = objManager.minions[TEAM_ENEMY][i]
						if minion and minion.pos:dist(player.pos) <= spellW.range and not minion.isDead and common.IsValidTarget(minion) then
							local minionPos = vec3(minion.x, minion.y, minion.z)
							if minionPos then
								if #count_minions_in_range(minionPos, 200) >= menu.laneclear.hitw:get() then
									local seg = preds.linear.get_prediction(spellW, minion)
									if seg and seg.startPos:dist(seg.endPos) < spellW.range then
										player:castSpell("pos", 1, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if not uhh and not player.buff["pyromania_particle"] then
		if (player.mana / player.maxMana) * 100 >= menu.laneclear.mana:get() then
			if menu.laneclear.farmq:get() and player:spellSlot(0).state == 0 then
				local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
				for i, minion in pairs(enemyMinionsQ) do
					if minion and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellQ.range then
							if not menu.laneclear.lastq:get() then
								player:castSpell("obj", 0, minion)
							end
							if menu.laneclear.lastq:get() then
								for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
									local minion = objManager.minions[TEAM_ENEMY][i]
									if minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) <= spellQ.range then
										local minionPos = vec3(minion.x, minion.y, minion.z)
										--delay = player.pos:dist(minion.pos) / 3500 + 0.2
										delay = 0.25 + player.pos:dist(minion.pos) / 750
										if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150 and player.mana > player.manaCost0) then
											orb.core.set_pause_attack(1)
										end
										if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
											player:castSpell("obj", 0, minion)
										end
									end
								end
							end
						end
					end
				end
			end
			if menu.laneclear.farmw:get() then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if minion and minion.pos:dist(player.pos) <= spellW.range and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos then
							if #count_minions_in_range(minionPos, 200) >= menu.laneclear.hitw:get() then
								local seg = preds.linear.get_prediction(spellW, minion)
								if seg and seg.startPos:dist(seg.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
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
	if uhh then
		if menu.lasthit.useq:get() and player:spellSlot(0).state == 0 then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) <= spellQ.range
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					--delay = player.pos:dist(minion.pos) / 3500 + 0.2
					delay = 0.25 + player.pos:dist(minion.pos) / 750
					if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150 and player.mana > player.manaCost0) then
						orb.core.set_pause_attack(1)
					end
					if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
						player:castSpell("obj", 0, minion)
					end
				end
			end
		end
	end
	if not uhh and not player.buff["pyromania_particle"] then
		if menu.lasthit.useq:get() and player:spellSlot(0).state == 0 then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) <= spellQ.range
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					--delay = player.pos:dist(minion.pos) / 3500 + 0.2
					delay = 0.25 + player.pos:dist(minion.pos) / 750
					if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150 and player.mana > player.manaCost0) then
						orb.core.set_pause_attack(1)
					end
					if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
						player:castSpell("obj", 0, minion)
					end
				end
			end
		end
	end
end

local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 50)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 50)
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 50)
		end
		if menu.draws.drawflash:get() then
			graphics.draw_circle(player.pos, spellR.range + 320, 2, menu.draws.colorw:get(), 50)
		end
	end
	if menu.draws.drawtoggle:get() then
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))

		if uhh == true then
			graphics.draw_text_2D("Save Stacks: OFF", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 218, 34, 34))
		else
			graphics.draw_text_2D("Save Stacks: ON", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 128, 255, 0))
		end
	end

	if menu.draws.drawdamage:get() then
		local enemy = common.GetEnemyHeroes()
		for i, enemies in ipairs(enemy) do
			if
				enemies and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 2000 and enemies.isOnScreen and
					not common.HasBuffType(enemies, 17)
			 then
				DrawDamagesE(enemies)
			end
		end
	end
end

local TargetSelectionFR = function(res, obj, dist)
	if dist < spellR.range + 320 then
		res.obj = obj
		return true
	end
end

local GetTargetFR = function()
	return TS.get_result(TargetSelectionFR).obj
end
local function OnTick()
	RFollow()
	if menu.flashr:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		local target = GetTargetFR()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player.pos) <= spellR.range + 320) then
					if
						(FlashSlot and player:spellSlot(FlashSlot).state and player:spellSlot(FlashSlot).state == 0 and
							player:spellSlot(3).state == 0)
					 then
						if (target.pos:dist(player.pos) > spellR.range) then
							local direction = (target.pos - player.pos):norm()
							local extendedPos = player.pos + direction * 320
							local seg = preds.circular.get_prediction(spellR, target, vec2(extendedPos.x, extendedPos.z))
							if seg and seg.startPos:dist(seg.endPos) <= spellR.range + 320 then
								player:castSpell("pos", 3, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))

								common.DelayAction(
									function()
										player:castSpell("pos", FlashSlot, target.pos)
									end,
									0.25 + network.latency
								)
							end
						end
					end
				end
			end
		end
	end
	if (orb.combat.is_active()) then
		if menu.misc.disableq:get() then
			if
				(menu.misc.disable:get() and menu.misc.level:get() <= player.levelRef and player:spellSlot(0).state == 0) and
					player.mana > 100
			 then
				orb.core.set_pause_attack(math.huge)
			end
		end
		if not menu.misc.disableq:get() then
			if (menu.misc.disable:get() and menu.misc.level:get() <= player.levelRef) and player.mana > 100 then
				orb.core.set_pause_attack(math.huge)
			end
		end
	end
	
		if menu.misc.disableq:get() then
			if orb.combat.is_active() and (player.mana < 100 or player:spellSlot(0).state ~= 0 or menu.misc.level:get() > player.levelRef) then
				orb.core.set_pause_attack(0)
			end
		end
		if not menu.misc.disableq:get() then
			if orb.combat.is_active() and (player.mana < 100 or menu.misc.level:get() > player.levelRef) then
				orb.core.set_pause_attack(0)
			end
		end
		if menu.stacke:get() and menu.stackingw:get() <= (player.mana / player.maxMana) * 100 then
			if not player.buff["pyromania_particle"] and not player.isRecalling then
				player:castSpell("pos", 2, player.pos)
			end
		end
	
	if menu.misc.Gap.GapA:get() then
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
orb.combat.register_f_pre_tick(OnTick)
--cb.add(cb.tick, OnTick)
