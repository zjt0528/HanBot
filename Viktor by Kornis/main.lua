local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
if not avada_lib then
	print("")
	console.set_color(79)
	print("                                                                                   ")
	print("----------- Viktor by Kornis -------------                                         ")
	print("You need to have Avada Lib in your community_libs folder to run this script!       ")
	print("You can find it here:                                                              ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                          ")
	console.set_color(79)
	print("                                                                                   ")
	console.set_color(12)
	local menuerror = menu("ViktorKornis", "Viktor By Kornis")
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
elseif avada_lib.version < 1 then
	print("")
	console.set_color(79)
	print("                                                                                   ")
	print("----------- Viktor by Kornis -------------                                         ")
	print("You need to have Avada Lib in your community_libs folder to run this script!       ")
	print("You can find it here:                                                              ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                          ")
	console.set_color(79)
	print("                                                                                   ")
	console.set_color(12)
	local menuerror = menu("ViktorKornis", "Viktor By Kornis")
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
end

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = avada_lib.common
local dmglib = avada_lib.damageLib

local spellQ = {
	range = 730
}

local spellW = {
	range = 700,
	radius = 50,
	speed = math.huge,
	delay = 1,
	boundingRadiusMod = 0
}

local spellE = {
	delay = 0.25,
	range = 1150,
	width = 160,
	speed = 1700,
	boundingRadiusMod = 0
}

local spellR = {
	range = 700,
	radius = 325,
	speed = 1000,
	delay = 1,
	boundingRadiusMod = 0
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
local tSelector = avada_lib.targetSelector
local menu = menu("ViktorKornis", "Viktor By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
--menu.combo:menu("qset", "Q Settings")
menu.combo:boolean("qcombo", "Use Q in Combo", true)

--menu.combo:menu("wset", "W Settings")
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:dropdown("wusage", " ^- W Usage", 2, {"Always", "Only on Slowed/CC", "Together with R"})

--menu.combo:menu("eset", "E Settings")
menu.combo:boolean("ecombo", "Use E in Combo", true)

menu.combo:menu("rset", "R Settings")
menu.combo.rset:boolean("follow", "Auto R Follow", true)
menu.combo.rset:header("uhh", "-- 1 v 1 Settings --")
menu.combo.rset:dropdown("rusage", "R Usage", 2, {"At X Health", "Only if Killable", "Never"})
menu.combo.rset:boolean("wait", "Wait for Spells", false)
menu.combo.rset:slider("rtick", "Include X R Ticks ( Killable Mode )", 1, 1, 3, 1)
menu.combo.rset:slider("waster", " ^- Don't waste R if Enemy Health Percent <= ", 15, 0, 100, 1)
menu.combo.rset:slider("hpr", "R if Target has X Health Percent", 60, 0, 100, 1)
menu.combo.rset:header("uhhh", "-- Teamfight Settings --")
menu.combo.rset:boolean("forcer", "Force R in TeamFights", true)
menu.combo.rset:slider("hitr", "Min. Enemies to Hit", 2, 2, 5, 1)

menu:menu("blacklist", "R Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("harass", "Harass")
menu.harass:slider("mana", "Mana Manager", 50, 1, 100, 1)
menu.harass:boolean("qharass", "Use Q to Harass", true)
menu.harass:boolean("eharass", "Use E to Harass", true)

menu:menu("laneclear", "Farming")
menu.laneclear:keybind("toggle", "Farm Toggle", "Z", nil)
menu.laneclear:menu("push", "Lane Clear")
menu.laneclear.push:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear.push:boolean("farmq", "Use Q to Farm", true)
menu.laneclear.push:boolean("lastq", " ^- Use for Last Hit", true)
menu.laneclear.push:boolean("unkillable", "Use Q on Unkillable", true)
menu.laneclear.push:boolean("farme", "Use E to Farm", true)
menu.laneclear.push:slider("hite", " ^- If Hits X", 3, 1, 6, 1)

menu.laneclear:menu("jungle", "Jungle Clear")
menu.laneclear.jungle:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear.jungle:boolean("useq", "Use Q in Jungle", true)
menu.laneclear.jungle:boolean("usee", "Use E in Jungle", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)
menu.killsteal:boolean("kse", "Killsteal with E", true)

menu:menu("misc", "Misc.")
menu.misc:boolean("disable", "Disable Auto Attack", false)
menu.misc:slider("level", "Disable AA at X Level", 6, 1, 18, 1)
menu.misc:boolean("GapA", "Use W for Anti-Gapclose", true)
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

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", false)
menu.draws:color("colorw", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawr", "Draw R Range", false)
menu.draws:color("colorr", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawdamage", "Draw Damage", true)
menu.draws:boolean("drawfarm", "Draw Farm Toggle", true)

menu:menu("flee", "Flee")
menu.flee:boolean("fleeq", "Use Q to Flee", true)
menu.flee:keybind("fleekey", "Flee Key:", "G", nil)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
TS.load_to_menu(menu)
local objHolder = {}

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
local TargetSelectionQ = function(res, obj, dist)
	if dist < spellE.range then
		res.obj = obj
		return true
	end
end
local GetTargetQ = function()
	return TS.get_result(TargetSelectionQ).obj
end
local TargetSelectionFollow = function(res, obj, dist)
	if dist < 2000 then
		res.obj = obj
		return true
	end
end
local GetTargetFollow = function()
	return TS.get_result(TargetSelectionFollow).obj
end
local function AutoInterrupt(spell)
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
							player:castSpell("pos", 3, spell.owner.pos)
						end
					end
				end
			end
		end
	end
	if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY then
		if spell.name == "ViktorPowerTransfer" then
			orb.core.set_pause_attack(0.2)
			player:move(mousePos)
			if (orb.core.can_attack()) then
				orb.core.set_pause_attack(0)
				orb.core.reset()
			end
		end
	end
end
local function WGapcloser()
	if player:spellSlot(1).state == 0 and menu.misc.GapA:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < 700
				 then
					if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
						if ((player.health / player.maxHealth) * 100 <= menu.misc.health:get()) then
							player:castSpell("pos", 1, dasher.path.point2D[1])
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
local function RFollow()
	if menu.combo.rset.follow:get() then
		if player.buff["viktorchaosstormtimer"] then
			local target = GetTargetFollow()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					player:castSpell("pos", 3, target.pos)
				end
			end
		end
	end
end
local function Combo()
	local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if menu.combo.rset.forcer:get() and player:spellSlot(3).state == 0 then
				if #count_enemies_in_range(target.pos, 300) >= menu.combo.rset.hitr:get() then
					if menu.combo.wusage:get() == 3 and menu.combo.wcombo:get() then
						if target.pos:dist(player.pos) < spellW.range then
							local pos = preds.circular.get_prediction(spellW, target)
							if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range then
								player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
					local pos = preds.circular.get_prediction(spellR, target)
					if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
			if menu.combo.rset.rusage:get() == 1 and player:spellSlot(3).state == 0 then
				if (target.health / target.maxHealth) * 100 > menu.combo.rset.waster:get() then
					if (target.health / target.maxHealth) * 100 <= menu.combo.rset.hpr:get() then
						if
							not (menu.combo.rset.wait:get()) and menu.blacklist[target.charName] and
								not menu.blacklist[target.charName]:get()
						 then
							if menu.combo.wusage:get() == 3 and menu.combo.wcombo:get() then
								if target.pos:dist(player.pos) < spellW.range then
									local pos = preds.circular.get_prediction(spellW, target)
									if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range then
										player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
							local pos = preds.circular.get_prediction(spellR, target)
							if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
								player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
						if (menu.combo.rset.wait:get()) and menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
							if (player:spellSlot(0).state == 0 or player:spellSlot(2).state == 0) then
								if menu.combo.wusage:get() == 3 and menu.combo.wcombo:get() then
									if target.pos:dist(player.pos) < spellW.range then
										local pos = preds.circular.get_prediction(spellW, target)
										if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range then
											player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
										end
									end
								end
								local pos = preds.circular.get_prediction(spellR, target)
								if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
									player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
			if menu.combo.rset.rusage:get() == 2 and player:spellSlot(3).state == 0 then
				if (target.health / target.maxHealth) * 100 > menu.combo.rset.waster:get() then
					if
						(target.health <=
							dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(2, target) + dmglib.GetSpellDamage(3, target) +
								dmglib.GetSpellDamage(3, target, 2) * menu.combo.rset.rtick:get())
					 then
						if
							not (menu.combo.rset.wait:get()) and menu.blacklist[target.charName] and
								not menu.blacklist[target.charName]:get()
						 then
							if menu.combo.wusage:get() == 3 and menu.combo.wcombo:get() then
								if target.pos:dist(player.pos) < spellW.range then
									local pos = preds.circular.get_prediction(spellW, target)
									if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range then
										player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
							local pos = preds.circular.get_prediction(spellR, target)
							if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
								player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
						if (menu.combo.rset.wait:get()) and menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
							if (player:spellSlot(0).state == 0 or player:spellSlot(2).state == 0) then
								if menu.combo.wusage:get() == 3 and menu.combo.wcombo:get() then
									if target.pos:dist(player.pos) < spellW.range then
										local pos = preds.circular.get_prediction(spellW, target)
										if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range then
											player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
										end
									end
								end
								local pos = preds.circular.get_prediction(spellR, target)
								if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
									player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
			if menu.combo.qcombo:get() then
				if (target.pos:dist(player.pos) <= spellQ.range) then
					player:castSpell("obj", 0, target)
				end
			end
			if menu.combo.ecombo:get() then
				if (target.pos:dist(player.pos) <= spellE.range) then
					if target.pos:dist(player.pos) > 500 then
						local direction = (target.pos - player.pos):norm()
						local extendedPos = player.pos + direction * 500
						local pos = preds.linear.get_prediction(spellE, target, extendedPos:to2D())
						if pos and player.pos:to2D():dist(pos.endPos) <= spellE.range then
							player:castSpell("line", 2, extendedPos, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
					if target.pos:dist(player) < 500 then
						local pos = preds.linear.get_prediction(spellE, target, target)
						if pos and player.pos:to2D():dist(pos.endPos) <= spellE.range then
							player:castSpell("line", 2, target.pos, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.combo.wcombo:get() then
				if menu.combo.wusage:get() == 1 then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.combo.wusage:get() == 2 then
					if
						(target.buff[5] or target.buff[8] or target.buff[24] or target.buff[10] or target.buff[11] or target.buff[22] or
							target.buff[8] or
							target.buff[21])
					 then
						if target.pos:dist(player.pos) < spellW.range then
							spellW.delay = 0.8
							local pos = preds.circular.get_prediction(spellW, target)
							if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range then
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
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if menu.harass.qharass:get() then
					if (target.pos:dist(player.pos) <= spellQ.range) then
						player:castSpell("obj", 0, target)
					end
				end
				if menu.harass.eharass:get() then
					if (target.pos:dist(player.pos) <= spellE.range) then
						if target.pos:dist(player.pos) > 500 then
							local direction = (target.pos - player.pos):norm()
							local extendedPos = player.pos + direction * 500
							local pos = preds.linear.get_prediction(spellE, target, extendedPos:to2D())
							if pos and player.pos:to2D():dist(pos.endPos) <= spellE.range then
								player:castSpell("line", 2, extendedPos, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
						if target.pos:dist(player) < 500 then
							local pos = preds.linear.get_prediction(spellE, target, target)
							if pos and player.pos:to2D():dist(pos.endPos) <= spellE.range then
								player:castSpell("line", 2, target.pos, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
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
						dmglib.GetSpellDamage(2, enemies) > hp
				 then
					if enemies.pos:dist(player.pos) > 500 then
						local direction = (enemies.pos - player.pos):norm()
						local extendedPos = player.pos + direction * 500
						local pos = preds.linear.get_prediction(spellE, enemies, extendedPos:to2D())
						if pos and player.pos:to2D():dist(pos.endPos) <= spellE.range then
							player:castSpell("line", 2, extendedPos, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
					if enemies.pos:dist(player) < 500 then
						local pos = preds.linear.get_prediction(spellE, enemies, enemies)
						if pos and player.pos:to2D():dist(pos.endPos) <= spellE.range then
							player:castSpell("line", 2, enemies.pos, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
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
				(dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(2, target) + dmglib.GetSpellDamage(3, target) +
					dmglib.GetSpellDamage(3, target, 2) * menu.combo.rset.rtick:get()) /
					target.health *
					100
			) < 100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(
					math.floor(
						dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(2, target) + dmglib.GetSpellDamage(3, target) +
							dmglib.GetSpellDamage(3, target, 2) * menu.combo.rset.rtick:get()
					)
				) ..
					" (" ..
						tostring(
							math.floor(
								(dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(2, target) + dmglib.GetSpellDamage(3, target) +
									dmglib.GetSpellDamage(3, target, 2) * menu.combo.rset.rtick:get()) /
									target.health *
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
				(dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(2, target) + dmglib.GetSpellDamage(3, target) +
					dmglib.GetSpellDamage(3, target, 2) * menu.combo.rset.rtick:get()) /
					target.health *
					100
			) >= 100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(
					math.floor(
						dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(2, target) +
							dmglib.GetSpellDamage(3, target) * menu.combo.rset.rtick:get()
					)
				) ..
					" (" ..
						tostring(
							math.floor(
								(dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(2, target) + dmglib.GetSpellDamage(3, target) +
									dmglib.GetSpellDamage(3, target, 2) * menu.combo.rset.rtick:get()) /
									target.health *
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
local function GetClosestJungle()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(player.pos) < spellQ.range then
				local minionDistanceToMouse = minionPos:dist(player.pos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end
local function GetClosestMinion()
	local enemyMinions = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)

	local closestMinion = nil
	local closestMinionDistance = 9999

	for i, minion in pairs(enemyMinions) do
		if minion then
			local minionPos = vec3(minion.x, minion.y, minion.z)
			if minionPos:dist(player.pos) < spellQ.range then
				local minionDistanceToMouse = minionPos:dist(player.pos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end

-- Thanks to Ryan. <3
local function JungleClear()
	if uhh == true then
		if (player.mana / player.maxMana) * 100 >= menu.laneclear.jungle.mana:get() then
			if menu.laneclear.jungle.useq:get() then
				local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL)
				for i, minion in pairs(enemyMinionsQ) do
					if minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(player.pos) <= spellQ.range then
							player:castSpell("obj", 0, minion)
						end
					end
				end
			end
			if menu.laneclear.jungle.usee:get() then
				local valid = {}
				local minions = objManager.minions
				for i = 0, minions.size[TEAM_NEUTRAL] - 1 do
					local minion = minions[TEAM_NEUTRAL][i]
					if
						minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
							player.path.serverPos:distSqr(minion.path.serverPos) <= (spellE.range * spellE.range)
					 then
						valid[#valid + 1] = minion
					end
				end
				local max_count, cast_pos = 0, nil
				for i = 1, #valid do
					local minion_a = valid[i]
					local current_pos, hit_count =
						player.path.serverPos +
							((minion_a.path.serverPos - player.path.serverPos):norm() *
								(minion_a.path.serverPos:dist(player.path.serverPos) + 400)),
						1
					for j = 1, #valid do
						if j ~= i then
							local minion_b = valid[j]
							local point = mathf.closest_vec_line(minion_b.path.serverPos, player.path.serverPos, current_pos)
							if point and point:dist(minion_b.path.serverPos) < (95 + minion_b.boundingRadius) then
								hit_count = hit_count + 1
							end
						end
					end
					local zzz = 0
					if not cast_pos or hit_count > max_count then
						cast_pos, max_count = current_pos, hit_count
					end
					if cast_pos then
						if (max_count > 1) then
							zzz = 1
							local direction = (player.pos - cast_pos):norm()
							local uhh = cast_pos:dist(player.pos)
							local extendedPos = cast_pos + direction * 500
							if (extendedPos:dist(player.pos) < 500) then
								player:castSpell("line", 2, extendedPos, cast_pos)
							end
							break
						elseif zzz == 0 then
							local direction = (player.pos - cast_pos):norm()
							local uhh = cast_pos:dist(player.pos)
							local extendedPos = cast_pos + direction * 500
							if (extendedPos:dist(player.pos) < 500) then
								player:castSpell("line", 2, extendedPos, cast_pos)
							end

							break
						end
					end
				end
			end
		end
	end
end
local function LastHit()
	if menu.laneclear.push.lastq:get() then
		local enemyMinionsE = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
		for i, minion in pairs(enemyMinionsE) do
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellQ.range
			 then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				--delay = player.pos:dist(minion.pos) / 3500 + 0.2
				local delay = player.path.serverPos2D:dist(minion.path.serverPos2D) / 2000 + 0.25 - network.latency
				if (dmglib.GetSpellDamage(0, minion) - 10 >= orb.farm.predict_hp(minion, delay, true)) then
					player:castSpell("obj", 0, minion)
				end
			end
		end
	end
end
local q_damage = function(target)
	return dmglib.GetSpellDamage(0, target) - 10
end
local q_hit_time = function(source, target)
	return source.path.serverPos2D:dist(target.path.serverPos2D) / 2000 + 0.25 - network.latency
end
local q_max_range = 700
local invoke_farm_assist = function()
	if menu.laneclear.push.unkillable:get() then
		if player:spellSlot(0).state ~= 0 then
			return
		end
		local t = orb.farm.skill_farm_assist(q_hit_time, q_damage, q_max_range)
		if t then
			orb.farm.set_ignore(t)
			player:castSpell("obj", 0, t)
			orb.core.set_server_pause()
			return true
		end
	end
end
local function LaneClear()
	if uhh == true then
		if menu.laneclear.push.farmq:get() then
			local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
			for i, minion in pairs(enemyMinionsQ) do
				if minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellQ.range then
						player:castSpell("obj", 0, minion)
					end
				end
			end
		end
		if (player.mana / player.maxMana) * 100 >= menu.laneclear.push.mana:get() then
			if menu.laneclear.push.farme:get() then
				local valid = {}
				local minions = objManager.minions
				for i = 0, minions.size[TEAM_ENEMY] - 1 do
					local minion = minions[TEAM_ENEMY][i]
					if
						minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
							player.path.serverPos:distSqr(minion.path.serverPos) <= (spellE.range * spellE.range)
					 then
						valid[#valid + 1] = minion
					end
				end
				local max_count, cast_pos = 0, nil
				for i = 1, #valid do
					local minion_a = valid[i]
					local current_pos, hit_count =
						player.path.serverPos +
							((minion_a.path.serverPos - player.path.serverPos):norm() *
								(minion_a.path.serverPos:dist(player.path.serverPos) + 300)),
						1
					for j = 1, #valid do
						if j ~= i then
							local minion_b = valid[j]
							local point = mathf.closest_vec_line(minion_b.path.serverPos, player.path.serverPos, current_pos)
							if point and point:dist(minion_b.path.serverPos) < (95 + minion_b.boundingRadius) then
								hit_count = hit_count + 1
							end
						end
					end
					if not cast_pos or hit_count > max_count then
						cast_pos, max_count = current_pos, hit_count
					end
					if cast_pos and max_count >= menu.laneclear.push.hite:get() then
						local direction = (player.pos - cast_pos):norm()
						local uhh = cast_pos:dist(player.pos)
						local extendedPos = cast_pos + direction * 500
						if (extendedPos:dist(player.pos) < 500) then
							player:castSpell("line", 2, extendedPos, cast_pos)
						end

						break
					end
				end
			end
		end
	end
end

local function Flee()
	if menu.flee.fleekey:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if menu.flee.fleeq:get() then
			local enemy = common.GetEnemyHeroes()
			for i, enemies in ipairs(enemy) do
				if enemies and common.IsValidTarget(enemies) and player.pos:dist(enemies) < spellQ.range then
					player:castSpell("obj", 0, enemies)
				end
			end
			if (GetClosestMinion()) then
				player:castSpell("obj", 0, GetClosestMinion())
			end
			if (GetClosestJungle()) then
				player:castSpell("obj", 0, GetClosestJungle())
			end
		end
	end
end

local function OnTick()
	if (orb.combat.is_active() and not player.buff["viktorpowertransferreturn"]) then
		if (menu.misc.disable:get() and menu.misc.level:get() <= player.levelRef) and player.mana > 100 then
			orb.core.set_pause_attack(math.huge)
		end
	end
	if orb.combat.is_active() and player.mana < 100 or player.buff["viktorpowertransferreturn"] then
		orb.core.set_pause_attack(0)
	end
	spellW.delay = 1
	KillSteal()
	RFollow()
	Toggle()
	Flee()
	if menu.misc.GapA:get() then
		WGapcloser()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.lastkey:get() then
		LastHit()
	end
	if menu.keys.clearkey:get() then
		LaneClear()
		JungleClear()
		invoke_farm_assist()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
end

local function OnDraw()
	if menu.draws.drawdamage:get() then
		local enemy = common.GetEnemyHeroes()
		for i, enemies in ipairs(enemy) do
			if
				enemies and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 1200 and
					not common.HasBuffType(enemies, 17)
			 then
				DrawDamagesE(enemies)
			end
		end
	end

	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 70)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 70)
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 70)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 70)
		end

		if menu.draws.drawfarm:get() then
			local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
			if uhh == true then
				graphics.draw_text_2D("Farm: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
				graphics.draw_text_2D("ON", 17, pos.x + 23, pos.y + 10, graphics.argb(255, 51, 255, 51))
			else
				graphics.draw_text_2D("Farm: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
				graphics.draw_text_2D("OFF", 17, pos.x + 23, pos.y + 10, graphics.argb(255, 255, 0, 0))
				graphics.draw_text_2D("OFF", 17, pos.x + 23, pos.y + 10, graphics.argb(255, 255, 0, 0))
			end
		end
	end
end

orb.combat.register_f_pre_tick(OnTick)
--cb.add(cb.tick, OnTick)
cb.add(cb.spell, AutoInterrupt)
cb.add(cb.draw, OnDraw)
