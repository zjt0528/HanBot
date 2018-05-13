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
local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = avada_lib.common
local dmglib = avada_lib.damageLib

local spellQ = {
	range = 850,
	delay = 0.75,
	speed = math.huge,
	radius = 170,
	boundingRadiusMod = 0
}

local spellW = {
	range = 850,
	radius = 150,
	speed = 3000,
	delay = 0.7,
	boundingRadiusMod = 0
}

local spellE = {
	range = 750
}

local spellR = {
	range = 825,
	delay = 0.5,
	width = 100,
	speed = math.huge,
	boundingRadiusMod = 0
}

local FlashSlot = nil
if player:spellSlot(4).name == "SummonerFlash" then
	FlashSlot = 4
elseif player:spellSlot(5).name == "SummonerFlash" then
	FlashSlot = 5
end

local tSelector = avada_lib.targetSelector
local menu = menu("CassiopeiabyKornis", "Cassiopeia By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:menu("qset", "Q Settings")
menu.combo.qset:boolean("qcombo", "Use Q in Combo", true)
menu.combo.qset:boolean("qpoison", " ^-Only if NOT POISONED", false)
menu.combo.qset:boolean("autoq", "Auto Q on Dash", true)
menu.combo.qset:boolean("turret", " ^-Don't Under the Turret", true)

menu.combo:menu("wset", "W Settings")
menu.combo.wset:boolean("wcombo", "Use W in Combo", true)
menu.combo.wset:boolean("startw", "Start Combo with W", true)
menu.combo.wset:slider("rangew", "W Max Range", 780, 400, 850, 1)

menu.combo:menu("eset", "E Settings")
menu.combo.eset:boolean("ecombo", "Use E in Combo", true)
menu.combo.eset:boolean("epoison", " ^-Only if POISONED", false)

menu.combo:menu("rset", "R Settings")
menu.combo.rset:slider("range", "R Range", 750, 100, 825, 1)
menu.combo.rset:header("uhh", "-- 1 v 1 Settings --")
menu.combo.rset:dropdown("rusage", "R Usage", 1, {"At X Health", "Only if Killable", "Never"})
menu.combo.rset:slider("waster", "Don't waste R if Enemy Health < X", 100, 0, 500, 1)
menu.combo.rset:slider("hpr", "R if Target has X Health Percent", 60, 0, 100, 1)
menu.combo.rset:boolean("face", "Use R only if Facing", true)
menu.combo.rset:header("uhhh", "-- Teamfight Settings --")
menu.combo.rset:slider("hitr", "Min. Enemies to Hit", 2, 2, 5, 1)
menu.combo.rset:boolean("facer", " ^-Only count if Facing", true)

menu.combo:boolean("rylais", "Rylais Combo ( Starts with E )", false)
menu.combo:keybind("rflash", "R-Flash Key", "G", nil)
menu.combo:boolean("flashrface", " ^- Only if Facing", true)
menu.combo:keybind("semir", "Semi-R Key", "T", nil)
menu:menu("blacklist", "R Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu:menu("harass", "Harass")
menu.harass:slider("mana", "Mana Manager", 50, 0, 100, 1)
menu.harass:boolean("qharass", "Use Q to Harass", true)
menu.harass:boolean("eharass", "Use E to Harass", true)
menu.harass:boolean("epoison", " ^-Only use if POISONED", false)
menu.harass:boolean("laste", "Last Hit with E", true)

menu:menu("laneclear", "Farming")
menu.laneclear:keybind("toggle", "Farm Toggle", "Z", nil)
menu.laneclear:menu("push", "Pushing")
menu.laneclear.push:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear.push:boolean("useq", "Use Q to Farm", true)
menu.laneclear.push:slider("hitq", " ^-If Hits", 2, 0, 6, 1)
menu.laneclear.push:boolean("farme", "Use E to Farm", true)
menu.laneclear.push:boolean("epoison", " ^-Only if POISONED", true)
menu.laneclear.push:boolean("disable", "Disable AA", true)

menu.laneclear:menu("passive", "Freeze")
menu.laneclear.passive:boolean("farme", "Use E to Last Hit", true)

menu.laneclear:menu("jungle", "Jungle Clear")
menu.laneclear.jungle:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear.jungle:boolean("useq", "Use Q in Jungle", true)
menu.laneclear.jungle:boolean("usee", "Use E in Jungle", true)

menu:menu("lasthit", "Last Hit")
menu.lasthit:boolean("qlasthit", "Use E", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)
menu.killsteal:boolean("kse", "Killsteal with E", true)
menu.killsteal:boolean("ksr", "Killsteal with R", true)
menu.killsteal:slider("saver", "Don't waste R if Enemy Health < X", 100, 0, 500, 1)

menu:menu("misc", "Misc.")
menu.misc:slider("qpred", "Q Radius: ", 170, 130, 200, 1)
menu.misc.qpred:set("tooltip", "Lower - Will try to cast more behind enemy, Higher - Will try to cast more further of target.")
menu.misc:slider("lasthittimer", "Last Hit E Delay", 125, 50, 200, 1)
menu.misc.lasthittimer:set("tooltip", "Lower - Casts later, Higher - Casts earlier // Default is 125")
menu.misc:boolean("disable", "Disable Auto Attack", true)
menu.misc:slider("level", "Disable AA at X Level", 6, 1, 18, 1)
menu.misc:boolean("GapA", "Use R for Anti-Gapclose", true)
menu.misc:slider("health", " ^-Only if my Health Percent < X", 50, 1, 100, 1)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("inte", "Use R to Interrupt", true)
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
local delay = 0
local hello = 0
function count_enemies_in_something_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.enemies_n - 1 do
		local enemy = objManager.enemies[i]
		if
			pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) and player.pos:dist(enemy.pos) < spellR.range and
				player.pos:dist(enemy.pos) > 370
		 then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end
-- Thanks to Avada's Cassiopeia. <3

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", false)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawwmin", "Draw Min. W Range", false)
menu.draws:color("colorwmin", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", false)
menu.draws:color("colorr", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawrf", "Draw R-Flash Range", false)
menu.draws:color("colorrf", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawtoggle", "Draw Farm Toggle", true)
menu.draws:boolean("drawdamage", "Draw Damage", true)
menu.draws:boolean("drawkill", "Draw Killable Minions with E", true)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
TS.load_to_menu(menu)

local TargetSelection = function(res, obj, dist)
	if dist < spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end
function count_enemies_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.enemies_n - 1 do
		local enemy = objManager.enemies[i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end

local uhh = false
local something = 0

local function Toggle()
	if menu.laneclear.toggle:get() then
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
local function IsFacing(target)
	return player.path.serverPos:distSqr(target.path.serverPos) >
		player.path.serverPos:distSqr(target.path.serverPos + target.direction)
end
local ElvlDmgBonus = {10, 30, 50, 70, 90}
local ElvlDamage = 4
function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		if
			(target.buff["poisontrailtarget"] or target.buff["TwitchDeadlyVenom"] or target.buff["cassiopeiawpoison"] or
				target.buff["cassiopeiaqdebuff"] or
				target.buff["ToxicShotParticle"] or
				target.buff["bantamtraptarget"])
		 then
			damage =
				CalcMagicDmg(
				target,
				(((52 + ElvlDamage * (player.levelRef - 1)) + (common.GetTotalAP() * .1)) + ElvlDmgBonus[player:spellSlot(2).level] +
					(common.GetTotalAP() * .6))
			)
		else
			damage = CalcMagicDmg(target, ((52 + ElvlDamage * (player.levelRef - 1)) + (common.GetTotalAP() * .1)))
		end
	end
	return damage
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

local function AutoDash()
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
			if menu.combo.qset.turret:get() then
				if not common.is_under_tower(vec3(pred_pos.x, target.y, pred_pos.y)) then
					player:castSpell("pos", 0, vec3(pred_pos.x, target.y, pred_pos.y))
				end
			else
				--orb.core.set_server_pause()
				player:castSpell("pos", 0, vec3(pred_pos.x, target.y, pred_pos.y))
			end
		end
	end
end

local function WGapcloser()
	if player:spellSlot(3).state == 0 and menu.misc.GapA:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < 850
				 then
					if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
						if ((player.health / player.maxHealth) * 100 <= menu.misc.health:get()) then
							player:castSpell("pos", 3, dasher.path.point2D[1])
						end
					end
				end
			end
		end
	end
end

local TargetSelectionFR = function(res, obj, dist)
	if dist < spellR.range + 410 then
		res.obj = obj
		return true
	end
end
local GetTargetFR = function()
	return TS.get_result(TargetSelectionFR).obj
end
local function FlashR()
	if menu.combo.rflash:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		local target = GetTargetFR()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player.pos) <= spellR.range + 410) then
					if (FlashSlot and player:spellSlot(FlashSlot).state) then
						if (target.pos:dist(player.pos) > spellR.range) then
							if (menu.combo.flashrface:get()) and IsFacing(target) then
								local pos = preds.linear.get_prediction(spellR, target)
								if pos and pos.startPos:dist(pos.endPos) < spellR.range + 410 then
									player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))

									common.DelayAction(
										function()
											player:castSpell("pos", FlashSlot, target.pos)
										end,
										0.25 + network.latency
									)
								end
							end

							if not (menu.combo.flashrface:get()) then
								local pos = preds.linear.get_prediction(spellR, target)
								if pos and pos.startPos:dist(pos.endPos) < spellR.range + 410 then
									player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))

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
	end
end
function KillSteal()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and enemies.isVisible and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ap", enemies)
			if menu.killsteal.ksq:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range and
						dmglib.GetSpellDamage(0, enemies) > hp
				 then
					local pos = preds.circular.get_prediction(spellQ, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
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
						hp < dmglib.GetSpellDamage(3, enemies) and
						hp > menu.killsteal.saver:get()
				 then
					local pos = preds.linear.get_prediction(spellR, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellR.range then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
end

local function LastHit()
	if menu.lasthit.qlasthit:get() then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellE.range
			 then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				--delay = player.pos:dist(minion.pos) / 3500 + 0.2
				delay = menu.misc.lasthittimer:get() / 1000 + player.pos:dist(minion.pos) / 840
				if (EDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150 and player.mana > player.manaCost2) then
					orb.core.set_pause_attack(1)
				end
				if (EDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
					player:castSpell("obj", 2, minion)
				end
			end
		end
	end
end
function JungleClear()
	if (player.mana / player.maxMana) * 100 >= menu.laneclear.jungle.mana:get() then
		if menu.laneclear.jungle.useq:get() then
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and not minion.isDead and minion.moveSpeed > 0 and minion.isTargetable and minion.isVisible and
						minion.type == TYPE_MINION
				 then
					if minion.pos:dist(player.pos) <= spellQ.range then
						local pos = preds.circular.get_prediction(spellQ, minion)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
		if menu.laneclear.jungle.usee:get() then
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and not minion.isDead and minion.moveSpeed > 0 and minion.isTargetable and minion.isVisible and
						minion.type == TYPE_MINION
				 then
					if minion.pos:dist(player.pos) <= spellE.range then
						player:castSpell("obj", 2, minion)
					end
				end
			end
		end
	end
end
local function Harass()
	if menu.harass.laste:get() then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if minion and minion.isVisible and not minion.isDead and minion.pos:dist(player.pos) < spellE.range then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				--delay = player.pos:dist(minion.pos) / 3500 + 0.2
				delay = menu.misc.lasthittimer:get() / 1000 + player.pos:dist(minion.pos) / 840
				if (EDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150 and player.mana > player.manaCost2) then
					orb.core.set_pause_attack(1)
				end
				if (EDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
					player:castSpell("obj", 2, minion)
				end
			end
		end
	end
	if (player.mana / player.maxMana) * 100 >= menu.harass.mana:get() then
		local target = GetTarget()
		if not common.IsValidTarget(target) then
			return
		end
		if target and target.isVisible then
			if menu.harass.qharass:get() then
				if (target.pos:dist(player) < spellQ.range) then
					local pos = preds.circular.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
			if menu.harass.eharass:get() then
				if (target.pos:dist(player) < spellE.range) then
					if menu.harass.epoison:get() then
						if
							(target.buff["poisontrailtarget"] or target.buff["TwitchDeadlyVenom"] or target.buff["cassiopeiawpoison"] or
								target.buff["cassiopeiaqdebuff"] or
								target.buff["ToxicShotParticle"] or
								target.buff["bantamtraptarget"])
						 then
							player:castSpell("obj", 2, target)
						end
					end
					if not menu.harass.epoison:get() then
						player:castSpell("obj", 2, target)
					end
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
	if uhh == false then
		if menu.laneclear.passive.farme:get() then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < spellE.range
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					--delay = player.pos:dist(minion.pos) / 3500 + 0.2
					delay = menu.misc.lasthittimer:get() / 1000 + player.pos:dist(minion.pos) / 840
					if (EDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150 and player.mana > player.manaCost2) then
						orb.core.set_pause_attack(1)
					end
					if (EDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
						player:castSpell("obj", 2, minion)
					end
				end
			end
		end
	end

	if uhh == true then
		if (player.mana / player.maxMana) * 100 >= menu.laneclear.push.mana:get() then
			-- Thanks to Avada's Cassiopeia. <3
			if menu.laneclear.push.useq:get() then
				local minions = objManager.minions
				for a = 0, minions.size[TEAM_ENEMY] - 1 do
					local minion1 = minions[TEAM_ENEMY][a]
					if
						minion1 and minion1.moveSpeed > 0 and minion1.isTargetable and not minion1.isDead and minion1.isVisible and
							player.path.serverPos:distSqr(minion1.path.serverPos) <= (spellQ.range * spellQ.range)
					 then
						local count = 0
						for b = 0, minions.size[TEAM_ENEMY] - 1 do
							local minion2 = minions[TEAM_ENEMY][b]
							if
								minion2 and minion2.moveSpeed > 0 and minion2.isTargetable and minion2 ~= minion1 and not minion2.isDead and
									minion2.isVisible and
									minion2.path.serverPos:distSqr(minion1.path.serverPos) <= (spellQ.radius * spellQ.radius)
							 then
								count = count + 1
							end
							if count >= menu.laneclear.push.hitq:get() then
								local seg = preds.circular.get_prediction(spellQ, minion1)
								if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
									player:castSpell("pos", 0, vec3(seg.endPos.x, minion1.y, seg.endPos.y))
									--orb.core.set_server_pause()
									break
								end
							end
						end
					end
				end
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if
						minion and minion.moveSpeed > 0 and minion.isTargetable and minion.pos:dist(player.pos) <= spellQ.range and
							minion.path.count == 0 and
							not minion.isDead and
							common.IsValidTarget(minion)
					 then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos then
							if #count_minions_in_range(minionPos, 150) >= menu.laneclear.push.hitq:get() then
								local seg = preds.circular.get_prediction(spellQ, minion)
								if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
									player:castSpell("pos", 0, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
								end
							end
						end
					end
				end
			end

			if menu.laneclear.push.farme:get() then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if
						minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
							minion.pos:dist(player.pos) < spellE.range
					 then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						--delay = player.pos:dist(minion.pos) / 3500 + 0.2
						delay = menu.misc.lasthittimer:get() / 1000 + player.pos:dist(minion.pos) / 840
						if (EDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150 and player.mana > player.manaCost2) then
							orb.core.set_pause_attack(1)
						end
						if (EDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
							player:castSpell("obj", 2, minion)
						end
					end
				end
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if minion and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellE.range then
							if (menu.laneclear.push.epoison:get()) then
								if
									(minion.buff["poisontrailtarget"] or minion.buff["TwitchDeadlyVenom"] or minion.buff["cassiopeiawpoison"] or
										minion.buff["cassiopeiaqdebuff"] or
										minion.buff["ToxicShotParticle"] or
										minion.buff["bantamtraptarget"])
								 then
									player:castSpell("obj", 2, minion)
								end
							end
						end
					end
				end
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if
						minion and minion.moveSpeed > 0 and minion.isTargetable and
							(minion.buff["poisontrailtarget"] or minion.buff["TwitchDeadlyVenom"] or minion.buff["cassiopeiawpoison"] or
								minion.buff["cassiopeiaqdebuff"] or
								minion.buff["ToxicShotParticle"] or
								minion.buff["bantamtraptarget"]) and
							not minion.isDead and
							common.IsValidTarget(minion)
					 then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellE.range then
							if not menu.laneclear.push.epoison:get() then
								player:castSpell("obj", 2, minion)
							end
						end
					end
				end
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if minion and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellE.range then
							if not menu.laneclear.push.epoison:get() then
								player:castSpell("obj", 2, minion)
							end
						end
					end
				end
			end
		end
	end
end

local GetNumberOfHits = function(res, obj, dist)
	if dist > spellR.range then
		return
	end
	local target = GetTarget()
	local aaa = preds.linear.get_prediction(spellR, obj)
	if menu.combo.rset.facer:get() then
		if
			obj and IsFacing(obj) and target and target.pos:dist(obj.pos) < 350 and
				obj.pos:dist(vec3(aaa.endPos.x, mousePos.y, aaa.endPos.y)) < 350 and
				obj.pos:dist(player.pos) > 350
		 then
			res.num_hits = res.num_hits and res.num_hits + 1 or 1
		end
	end
	if not menu.combo.rset.facer:get() then
		if
			obj and target and target.pos:dist(obj.pos) < 350 and
				obj.pos:dist(vec3(aaa.endPos.x, mousePos.y, aaa.endPos.y)) < 350 and
				obj.pos:dist(player.pos) > 350
		 then
			res.num_hits = res.num_hits and res.num_hits + 1 or 1
		end
	end
end

local GetPred = function()
	local res = TS.loop(GetNumberOfHits)
	if res.num_hits and res.num_hits > 1 then
		return res.num_hits
	end
end

local function Combo()
	local mode = menu.combo.rset.rusage:get()
	local target = GetTarget()
	if not common.IsValidTarget(target) then
		return
	end
	if target and target.isVisible then
		if mode == 1 then
			if
				target and (target.health / target.maxHealth) * 100 <= menu.combo.rset.hpr:get() and
					target.health >= menu.combo.rset.waster:get()
			 then
				if menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
					local pos = preds.linear.get_prediction(spellR, target)
					if pos and pos.startPos:dist(pos.endPos) < spellR.range and #count_enemies_in_range(player.pos, 900) == 1 then
						if (menu.combo.rset.face:get()) then
							if (IsFacing(target)) then
								player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						else
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
		if mode == 2 then
			if
				target and target.health < EDamage(target) * 3 + dmglib.GetSpellDamage(3, target) + dmglib.GetSpellDamage(0, target) and
					target.health >= menu.combo.rset.waster:get()
			 then
				if menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
					local pos = preds.linear.get_prediction(spellR, target)
					if pos and pos.startPos:dist(pos.endPos) < spellR.range and #count_enemies_in_range(player.pos, 900) == 1 then
						if (menu.combo.rset.face:get()) then
							if (IsFacing(target)) then
								player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						else
							player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
		if mode == 2 or mode == 1 then
			if GetPred() and GetPred() >= menu.combo.rset.hitr:get() then
				local pos = preds.linear.get_prediction(spellR, target)
				if pos and pos.startPos:dist(pos.endPos) < spellR.range then
					player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
		if not menu.combo.wset.startw:get() and not menu.combo.rylais:get() then
			if menu.combo.qset.qcombo:get() then
				if (target.pos:dist(player) < spellQ.range) then
					local pos = preds.circular.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						if not menu.combo.qset.qpoison:get() then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
						if menu.combo.qset.qpoison:get() then
							if
								not target.buff["poisontrailtarget"] and not target.buff["TwitchDeadlyVenom"] and
									not target.buff["cassiopeiawpoison"] and
									not target.buff["cassiopeiaqdebuff"] and
									not target.buff["ToxicShotParticle"] and
									not target.buff["bantamtraptarget"]
							 then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
			if menu.combo.eset.ecombo:get() then
				if (menu.combo.eset.epoison:get()) then
					if
						(target.buff["poisontrailtarget"] or target.buff["TwitchDeadlyVenom"] or target.buff["cassiopeiawpoison"] or
							target.buff["cassiopeiaqdebuff"] or
							target.buff["ToxicShotParticle"] or
							target.buff["bantamtraptarget"])
					 then
						player:castSpell("obj", 2, target)
					end
				else
					player:castSpell("obj", 2, target)
				end
			end
			if menu.combo.wset.wcombo:get() then
				local pos = preds.circular.get_prediction(spellW, target)
				if pos and pos.startPos:dist(pos.endPos) < spellW.range and player.pos:dist(target.pos) >= 500 then
					player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
		if menu.combo.wset.startw:get() and not menu.combo.rylais:get() then
			if menu.combo.wset.wcombo:get() then
				local pos = preds.circular.get_prediction(spellW, target)
				if pos and pos.startPos:dist(pos.endPos) < spellW.range and player.pos:dist(target.pos) >= 500 then
					player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
			if (os.clock() > hello) then
				if menu.combo.qset.qcombo:get() then
					if (target.pos:dist(player) < spellQ.range) then
						local pos = preds.circular.get_prediction(spellQ, target)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
							if not menu.combo.qset.qpoison:get() then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
							if menu.combo.qset.qpoison:get() then
								if
									not target.buff["poisontrailtarget"] and not target.buff["TwitchDeadlyVenom"] and
										not target.buff["cassiopeiawpoison"] and
										not target.buff["cassiopeiaqdebuff"] and
										not target.buff["ToxicShotParticle"] and
										not target.buff["bantamtraptarget"]
								 then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
			if menu.combo.eset.ecombo:get() then
				if (menu.combo.eset.epoison:get()) then
					if
						(target.buff["poisontrailtarget"] or target.buff["TwitchDeadlyVenom"] or target.buff["cassiopeiawpoison"] or
							target.buff["cassiopeiaqdebuff"] or
							target.buff["ToxicShotParticle"] or
							target.buff["bantamtraptarget"])
					 then
						player:castSpell("obj", 2, target)
					end
				else
					player:castSpell("obj", 2, target)
				end
			end
		end
		if menu.combo.rylais:get() then
			if menu.combo.eset.ecombo:get() then
				if (menu.combo.eset.epoison:get()) then
					if
						(target.buff["poisontrailtarget"] or target.buff["TwitchDeadlyVenom"] or target.buff["cassiopeiawpoison"] or
							target.buff["cassiopeiaqdebuff"] or
							target.buff["ToxicShotParticle"] or
							target.buff["bantamtraptarget"])
					 then
						player:castSpell("obj", 2, target)
					end
				else
					player:castSpell("obj", 2, target)
				end
			end
			if menu.combo.qset.qcombo:get() then
				if (target.pos:dist(player) < spellQ.range) then
					local pos = preds.circular.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range  then
						if not menu.combo.qset.qpoison:get() then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
						if menu.combo.qset.qpoison:get() then
							if
								not target.buff["poisontrailtarget"] and not target.buff["TwitchDeadlyVenom"] and
									not target.buff["cassiopeiawpoison"] and
									not target.buff["cassiopeiaqdebuff"] and
									not target.buff["ToxicShotParticle"] and
									not target.buff["bantamtraptarget"]
							 then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
			if menu.combo.wset.wcombo:get() then
				local pos = preds.circular.get_prediction(spellW, target)
				if pos and pos.startPos:dist(pos.endPos) < spellW.range and player.pos:dist(target.pos) >= 500 then
					player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
end
local function OnTick()
	spellQ.radius = menu.misc.qpred:get()
	if menu.combo.semir:get() then
		local target = GetTarget()
		if common.IsValidTarget(target) then
			if target and target.isVisible then
				local pos = preds.linear.get_prediction(spellR, target)
				if pos and pos.startPos:dist(pos.endPos) < spellR.range then
					player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
	FlashR()
	Toggle()
	KillSteal()
	if (orb.combat.is_active()) then
		if (menu.misc.disable:get() and menu.misc.level:get() <= player.levelRef) and player.mana > 100 then
			orb.core.set_pause_attack(math.huge)
		end
	end
	if menu.keys.clearkey:get() and menu.laneclear.push.disable:get() and uhh == true then
		orb.core.set_pause_attack(math.huge)
	end
	if orb.combat.is_active() and player.mana < 100 then
		orb.core.set_pause_attack(0)
	end
	if not orb.combat.is_active() and not menu.keys.lastkey:get() and not menu.keys.clearkey:get() then
		if orb.core.is_attack_paused() then
			orb.core.set_pause_attack(0)
		end
		if orb.combat.is_active() and player.mana > 100 then
			orb.core.set_pause_attack(0)
		end
	end
	spellR.range = menu.combo.rset.range:get()
	spellW.range = menu.combo.wset.rangew:get()
	if menu.misc.GapA:get() then
		WGapcloser()
	end
	if menu.combo.qset.autoq:get() then
		AutoDash()
	end
	if menu.keys.lastkey:get() then
		LastHit()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.clearkey:get() then
		LaneClear()
		JungleClear()
	end
end

local function AutoInterrupt(spell)
	if orb.combat.is_active and menu.combo.wset.startw:get() then
		if
			spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY and spell.owner.charName == "Cassiopeia" and
				spell.name == "CassiopeiaW"
		 then
			hello = os.clock() + 0.3
		end
		if
			spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY and spell.owner.charName == "Cassiopeia" and
				spell.name == "CassiopeiaQ"
		 then
			hello = 0
		end
	end
	if menu.misc.interrupt.inte:get() and player:spellSlot(3).state == 0 then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if
						menu.misc.interrupt.interruptmenu[spell.owner.charName .. spellCheck.menuslot]:get() and
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

orb.combat.register_f_pre_tick(OnTick)

-- Credits to Avada's Kalista. <3
function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		local pos = graphics.world_to_screen(target.pos)
		if
			(math.floor(
				(EDamage(target) * 3 + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target)) / target.health * 100
			) < 100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(EDamage(target) * 3 + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target))) ..
					" (" ..
						tostring(
							math.floor(
								(EDamage(target) * 3 + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target)) / target.health *
									100
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
				(EDamage(target) * 3 + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target)) / target.health * 100
			) >= 100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(EDamage(target) * 3 + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target))) ..
					" (" ..
						tostring(
							math.floor(
								(EDamage(target) * 3 + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target)) / target.health *
									100
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
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 100)
		end
		if menu.draws.drawwmin:get() then
			graphics.draw_circle(player.pos, 500, 2, menu.draws.colorwmin:get(), 100)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 100)
		end
		if menu.draws.drawrf:get() then
			graphics.draw_circle(player.pos, spellR.range + 410, 2, menu.draws.colorrf:get(), 100)
		end
	end

	if menu.draws.drawkill:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and not minion.isDead and minion.moveSpeed > 0 and minion.isTargetable and
					minion.pos:dist(player.pos) < spellE.range
			 then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				--delay = player.pos:dist(minion.pos) / 3500 + 0.2
				delay = (menu.misc.lasthittimer:get() / 1000) + (player.pos:dist(minion.pos) / 840)
				if (EDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
					if minion.isOnScreen then
						graphics.draw_circle(minionPos, 100, 2, graphics.argb(255, 255, 255, 0), 100)
					end
				end
			end
		end
	end

	if menu.draws.drawdamage:get() then
		local enemy = common.GetEnemyHeroes()
		for i, enemies in ipairs(enemy) do
			if
				enemies and enemies.isVisible and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 1000 and
					not common.HasBuffType(enemies, 17)
			 then
				DrawDamagesE(enemies)
			end
		end
	end
	if menu.draws.drawtoggle:get() then
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
		if uhh == true then
			graphics.draw_text_2D("Farm Mode: PUSHING", 16, pos.x - 20, pos.y + 30, graphics.argb(255, 255, 102, 178))
		else
			graphics.draw_text_2D("Farm Mode: FREEZING", 16, pos.x - 20, pos.y + 30, graphics.argb(255, 255, 102, 178))
		end
	end
end
cb.add(cb.draw, OnDraw)
cb.add(cb.tick, OnTick)
cb.add(cb.spell, AutoInterrupt)
