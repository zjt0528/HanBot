local version = "1.0"

local avada_lib = module.lib("avada_lib")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Kassadin by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Kassadin by Kornis'!")
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
	range = 650
}

local spellW = {}

local spellE = {
	range = 600,
	delay = 0.1,
	width = 80,
	speed = math.huge,
	boundingRadiusMod = 1
}

local spellR = {
	range = 700,
	delay = 0.25,
	speed = 2700,
	radius = 150,
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
local menu = menu("KassadinKornis", "Kassadin By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()

menu:menu("combo", "Combo")
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("waa", " ^- Only for Auto Attack reset", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("rcombo", "Use R in Combo", true)
menu.combo:slider("hpr", "Don't use R if my HP lower than", 20, 0, 100, 1)
menu.combo:slider("dontr", "Don't R in X Enemies", 3, 1, 5, 1)
menu.combo:keybind("toggle", "R Under-Turret toggle", "T", nil)

menu:menu("burst", "Burst")
menu.burst:boolean("waite", "Wait for E", true)
menu.burst:keybind("burstkley", "Burst Key", "G", nil)

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("wcombo", "Use W in Harass", true)
menu.harass:boolean("waa", " ^- Only for Auto Attack reset", true)
menu.harass:boolean("ecombo", "Use E in Harass", true)

menu:menu("farming", "Farming")
menu.farming:menu("laneclear", "Lane Clear")
menu.farming.laneclear:keybind("toggle", "Farm Toggle", "Z", nil)
menu.farming.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.farming.laneclear:boolean("lastq", " ^-Only for Last Hit", true)
menu.farming.laneclear:boolean("qaa", " ^- Don't use Q in AA Range", true)
menu.farming.laneclear:boolean("farmw", "Use W to Last Hit", false)
menu.farming.laneclear:boolean("farme", "Use E in Lane Clear", true)
menu.farming.laneclear:slider("hitse", " ^- if Hits X Minions", 3, 1, 6, 1)
menu.farming:menu("jungleclear", "Jungle Clear")
menu.farming.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.farming.jungleclear:boolean("usew", "Use W in Jungle Clear", true)
menu.farming.jungleclear:boolean("usee", "Use E in Jungle Clear", true)
menu:menu("lasthit", "Last Hit")
menu.lasthit:boolean("useq", "Use Q to Last Hit", true)
menu.lasthit:boolean("qaa", " ^-Don't use Q in AA Range", true)
menu.lasthit:boolean("usew", "Use W to Last Hit", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)
menu.killsteal:boolean("kse", "Killsteal with E", true)
menu.killsteal:boolean("ksr", "Killsteal with R", true)
menu.killsteal:boolean("ksrq", "Gapclose with R for Q", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawflash", "Draw Burst Range", true)
menu.draws:boolean("drawtoggle", "Draw Toggle", true)
menu.draws:boolean("drawdamage", "Draw Damage", true)
menu:menu("flee", "Flee")
menu.flee:boolean("fleer", "Use R to Flee", true)
menu.flee:keybind("fleekey", "Flee Key:", "A", nil)
menu:menu("misc", "Misc.")
menu.misc:menu("Gap", "Gapcloser Settings")
menu.misc.Gap:boolean("GapA", "Use E for Anti-Gapclose", true)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("inte", "Use Q to Interrupt", true)
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

TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist <= spellR.range then
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
local meowmeow = 0
local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end
local GetTargetGap = function()
	return TS.get_result(TargetSelectionGap).obj
end
local uhh = false
local something = 0
local function Toggle()
	if menu.combo.toggle:get() then
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
local mhh = false
local hellow = 0
local function Toggle2()
	if menu.farming.laneclear.toggle:get() then
		if (mhh == false and os.clock() > hellow) then
			mhh = true
			hellow = os.clock() + 0.3
		end
		if (mhh == true and os.clock() > hellow) then
			mhh = false
			hellow = os.clock() + 0.3
		end
	end
end

orb.combat.register_f_after_attack(
	function()
		if menu.keys.combokey:get() then
			if orb.combat.target then
				if
					menu.combo.waa:get() and menu.combo.wcombo:get() and orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					if player:spellSlot(1).state == 0 then
						player:castSpell("self", 1)
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
					menu.harass.waa:get() and menu.harass.wcombo:get() and orb.combat.target and
						common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
				 then
					if player:spellSlot(1).state == 0 then
						player:castSpell("self", 1)
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

local last_item_update = 0
local hasSheen = false
local hasTF = false
sheenTimer = os.clock()
function SheenDamage(target)
	local sheendamage = 0
	if os.clock() > last_item_update then
		hasSheen = false
		hasTF = false
		for i = 0, 5 do
			if player:itemID(i) == 3057 then
				hasSheen = true
			end
			if player:itemID(i) == 3078 then
				hasTF = true
			end
		end
		last_item_update = os.clock() + 5
	end

	if hasSheen and not hasTF and (os.clock() >= sheenTimer or player.buff[sheen]) then
		sheendamage = player.baseAttackDamage - 3
	end
	if hasTF and (os.clock() >= sheenTimer or player.buff[sheen]) then
		sheendamage = 1.95 * player.baseAttackDamage
	end
	return sheendamage * common.PhysicalReduction(target)
end
local extradamage = {40, 50, 60}
local RLevelDamage = {80, 100, 120}
function RDamage(target)
	local damage = 0
	local extra = 0
	if player:spellSlot(3).level > 0 then
		if player.buff["riftwalk"] then
			extra =
				(extradamage[player:spellSlot(3).level] + (common.GetTotalAP() * .1) + (player.maxMana * 0.01)) *
				player.buff["riftwalk"].stacks
		end
		damage =
			common.CalculateMagicDamage(
			target,
			(RLevelDamage[player:spellSlot(3).level] + (common.GetTotalAP() * .3) + (player.maxMana * 0.02) + extra),
			player
		)
	end
	return damage
end
local WLevelDamage = {40, 65, 90, 115, 140}
function WDamage(target)
	local damage = 0
	if player:spellSlot(1).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (WLevelDamage[player:spellSlot(1).level] + (common.GetTotalAP() * .7)), player)
	end
	return damage + common.CalculateAADamage(target) + SheenDamage(target)
end
local QLevelDamage = {65, 95, 125, 155, 185}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAP() * .7)), player)
	end
	return damage
end
local ELevelDamage = {80, 105, 130, 155, 180}
function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (ELevelDamage[player:spellSlot(2).level] + (common.GetTotalAP() * .7)), player)
	end
	return damage
end

local waiting = 0
local chargingW = 0
local uhhh = 0
local enemy = nil

local function AutoInterrupt(spell) -- Thank you Dew for this <3
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
						if player.pos2D:dist(spell.owner.pos2D) < spellQ.range and common.IsValidTarget(spell.owner) then
							player:castSpell("obj", 0, spell.owner)
						end
					end
				end
			end
		end
	end
end

local function WGapcloser()
	if menu.misc.Gap.GapA:get() then
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

local function Combo()
	local target = GetTarget()
	if menu.combo.rcombo:get() then
		if (player.health / player.maxHealth) * 100 >= menu.combo.hpr:get() then
			if common.IsValidTarget(target) and target then
				if menu.combo.dontr:get() > #count_enemies_in_range(target.pos, spellR.range) then
					if not uhh then
						local seg = preds.circular.get_prediction(spellR, target)
						if seg and seg.startPos:dist(seg.endPos) < spellR.range then
							player:castSpell("pos", 3, vec3(seg.endPos.x, target.y, seg.endPos.y))
						end
					end
					if uhh and not common.is_under_tower(target.pos) then
						local seg = preds.circular.get_prediction(spellR, target)
						if seg and seg.startPos:dist(seg.endPos) < spellR.range then
							player:castSpell("pos", 3, vec3(seg.endPos.x, target.y, seg.endPos.y))
						end
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
	if menu.combo.wcombo:get() and not menu.combo.waa:get() and player:spellSlot(1).state == 0 then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < 300) and os.clock() > meowmeow then
				player:castSpell("self", 1)
				player:attack(target)
				meowmeow = os.clock() + 0.1
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
				local Edmg = 0
				local Wdmg = 0

				Edmg = EDamage(obj)
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
		if (math.floor((WDamage(target) + EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(WDamage(target) + EDamage(target) + RDamage(target) + QDamage(target))) ..
					" (" ..
						tostring(
							math.floor((WDamage(target) + EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)
						) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if (math.floor((WDamage(target) + EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(WDamage(target) + EDamage(target) + RDamage(target) + QDamage(target))) ..
					" (" ..
						tostring(
							math.floor((WDamage(target) + EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)
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

local function JungleClear()
	if menu.farming.jungleclear.useq:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellQ.range
			 then
				player:castSpell("obj", 0, minion)
			end
		end
	end
	if menu.farming.jungleclear.usew:get() and player:spellSlot(1).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					os.clock() > meowmeow and
					minion.pos:dist(player.pos) < 300
			 then
				player:castSpell("self", 1)
				player:attack(minion)
				meowmeow = os.clock() + 0.3
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
	if menu.harass.qcombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellQ.range) then
				player:castSpell("obj", 0, target)
			end
		end
	end
	if menu.harass.wcombo:get() and not menu.harass.waa:get() and player:spellSlot(1).state == 0 then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) < 300) and os.clock() > meowmeow then
				player:castSpell("self", 1)
				player:attack(target)
				meowmeow = os.clock() + 0.1
			end
		end
	end
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
			if menu.killsteal.kse:get() then
				if
					player:spellSlot(2).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range and
						EDamage(enemies) >= hp
				 then
					local seg = preds.linear.get_prediction(spellE, enemies)
					if seg and seg.startPos:dist(seg.endPos) < spellE.range then
						player:castSpell("pos", 2, vec3(seg.endPos.x, enemies.y, seg.endPos.y))
					end
				end
			end
			if menu.killsteal.ksr:get() then
				if
					player:spellSlot(3).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellR.range and
						RDamage(enemies) >= hp
				 then
					local seg = preds.circular.get_prediction(spellR, enemies)
					if seg and seg.startPos:dist(seg.endPos) < spellR.range then
						player:castSpell("pos", 3, vec3(seg.endPos.x, enemies.y, seg.endPos.y))
					end
				end
			end
			if menu.killsteal.ksrq:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellR.range + spellQ.range and
						QDamage(enemies) >= hp and
						enemies.pos:dist(player.pos) > spellQ.range
				 then
					player:castSpell("pos", 3, enemies.pos)
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
							player:castSpell("obj", 0, minion)
						end
						if menu.farming.laneclear.lastq:get() and player:spellSlot(0).state == 0 then
							for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
								local minion = objManager.minions[TEAM_ENEMY][i]
								if
									minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
										minion.pos:dist(player.pos) <= spellQ.range
								 then
									local minionPos = vec3(minion.x, minion.y, minion.z)
									--delay = player.pos:dist(minion.pos) / 3500 + 0.2
									delay = 0.25 + player.pos:dist(minion.pos) / 1600
									if (QDamage(minion) >= orb.farm.predict_hp(minion, delay, true)) then
										if menu.farming.laneclear.qaa:get() and 300 < minion.pos:dist(player.pos) then
											player:castSpell("obj", 0, minion)
										end
										if not menu.farming.laneclear.qaa:get() then
											player:castSpell("obj", 0, minion)
										end
									end
								end
							end
						end
					end
				end
			end
		end

		if menu.farming.laneclear.farmw:get() and player:spellSlot(1).state == 0 then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) <= 300
				 then
					if minion.health <= WDamage(minion) and os.clock() > meowmeow then
						player:castSpell("self", 1)
						player:attack(minion)
						meowmeow = os.clock() + 0.3
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
					minion.pos:dist(player.pos) <= spellQ.range
			 then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				--delay = player.pos:dist(minion.pos) / 3500 + 0.2
				delay = 0.25 + player.pos:dist(minion.pos) / 1600
				if (QDamage(minion) >= orb.farm.predict_hp(minion, delay, true)) then
					if menu.lasthit.qaa:get() and 300 < minion.pos:dist(player.pos) then
						player:castSpell("obj", 0, minion)
					end
					if not menu.lasthit.qaa:get() then
						player:castSpell("obj", 0, minion)
					end
				end
			end
		end
	end
	if menu.lasthit.usew:get() and player:spellSlot(1).state == 0 then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) <= 300
			 then
				if minion.health <= WDamage(minion) and os.clock() > meowmeow then
					player:castSpell("self", 1)
					player:attack(minion)
					meowmeow = os.clock() + 0.3
				end
			end
		end
	end
end

local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 80)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 80)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 80)
		end
		if menu.draws.drawflash:get() then
			graphics.draw_circle(player.pos, spellR.range + 460, 2, menu.draws.colore:get(), 80)
		end
	end
	if menu.draws.drawtoggle:get() then
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))

		if uhh == true then
			graphics.draw_text_2D("R Under-Turret: OFF", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 218, 34, 34))
		else
			graphics.draw_text_2D("R Under-Turret: ON", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 128, 255, 0))
		end
		if mhh == true then
			graphics.draw_text_2D("Farm: OFF", 18, pos.x - 20, pos.y + 20, graphics.argb(255, 218, 34, 34))
		else
			graphics.draw_text_2D("Farm: ON", 18, pos.x - 20, pos.y + 20, graphics.argb(255, 128, 255, 0))
		end
	end

	if menu.draws.drawdamage:get() then
		for i = 0, objManager.enemies_n - 1 do
			local enemies = objManager.enemies[i]
			if
				enemies and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 3000 and enemies.isOnScreen and
					not common.HasBuffType(enemies, 17)
			 then
				DrawDamagesE(enemies)
			end
		end
	end
end

local TargetSelectionFR = function(res, obj, dist)
	if dist < spellR.range + 460 then
		res.obj = obj
		return true
	end
end

local GetTargetFR = function()
	return TS.get_result(TargetSelectionFR).obj
end
local function Flee()
	if menu.flee.fleekey:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if menu.flee.fleer:get() then
			player:castSpell("pos", 3, mousePos)
		end
	end
end
local function OnTick()
	Flee()
	if menu.burst.burstkley:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		local target = GetTargetFR()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if menu.burst.waite:get() then
					if (target.pos:dist(player.pos) <= spellR.range + 460) then
						if
							(FlashSlot and player:spellSlot(FlashSlot).state and player:spellSlot(FlashSlot).state == 0 and
								player:spellSlot(3).state == 0 and
								player:spellSlot(2).state == 0)
						 then
							if (target.pos:dist(player.pos) > spellR.range) then
								local direction = (target.pos - player.pos):norm()
								local extendedPos = player.pos + direction * 460
								local seg = preds.circular.get_prediction(spellR, target, vec2(extendedPos.x, extendedPos.z))
								if seg and seg.startPos:dist(seg.endPos) <= spellR.range + 460 then
									player:castSpell("pos", 3, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))

									common.DelayAction(
										function()
											player:castSpell("pos", FlashSlot, target.pos)
										end,
										0.05
									)
								end
							end
						end
					end
				end
				if not menu.burst.waite:get() then
					if (target.pos:dist(player.pos) <= spellR.range + 550) then
						if
							(FlashSlot and player:spellSlot(FlashSlot).state and player:spellSlot(FlashSlot).state == 0 and
								player:spellSlot(3).state == 0)
						 then
							if (target.pos:dist(player.pos) > spellR.range) then
								local direction = (target.pos - player.pos):norm()
								local extendedPos = player.pos + direction * 550
								local seg = preds.circular.get_prediction(spellR, target, vec2(extendedPos.x, extendedPos.z))
								if seg and seg.startPos:dist(seg.endPos) <= spellR.range + 550 then
									player:castSpell("pos", 3, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))

									common.DelayAction(
										function()
											player:castSpell("pos", FlashSlot, target.pos)
										end,
										0.05
									)
								end
							end
						end
					end
				end
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) <= spellQ.range) then
						player:castSpell("obj", 0, target)
					end
				end
				if player:spellSlot(1).state == 0 then
					if common.IsValidTarget(target) and target then
						if (target.pos:dist(player) < 300) and os.clock() > meowmeow then
							player:castSpell("self", 1)
							player:attack(target)
							meowmeow = os.clock() + 0.3
						end
					end
				end
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) <= spellE.range) then
						local seg = preds.linear.get_prediction(spellE, target)
						if seg and seg.startPos:dist(seg.endPos) <= spellE.range then
							player:castSpell("pos", 2, vec3(seg.endPos.x, target.y, seg.endPos.y))
						end
					end
				end
				if common.IsValidTarget(target) and target then
					if (target.pos:dist(player) <= spellR.range) then
						local seg = preds.circular.get_prediction(spellR, target)
						if seg and seg.startPos:dist(seg.endPos) <= spellR.range then
							player:castSpell("pos", 3, vec3(seg.endPos.x, target.y, seg.endPos.y))
						end
					end
				end
			end
		end
	end

	if menu.misc.Gap.GapA:get() then
		WGapcloser()
	end
	Toggle()
	Toggle2()
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

local function OnRemoveBuff(buff)
	if buff.owner.ptr == player.ptr and buff.name == "sheen" then
		sheenTimer = os.clock() + 1.7
	end
end
cb.add(cb.removebuff, OnRemoveBuff)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
orb.combat.register_f_pre_tick(OnTick)
--cb.add(cb.tick, OnTick)
