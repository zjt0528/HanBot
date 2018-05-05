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
	range = 1050,
	delay = 0.25,
	width = 78,
	speed = 1600,
	boundingRadiusMod = 1,
	collision = {
		hero = false,
		minion = true
	}
}

local spellW = {
	range = 900,
	delay = 0.85,
	radius = 200,
	speed = 2900,
	boundingRadiusMod = 1
}

local spellE = {
	range = 625
}

local spellR = {
	range = 750
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
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Brand")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
menu.combo:dropdown("combomode", "Combo Mode", 1, {"E-Q-W", "E-W-Q", "W-E-Q", "W-Q-E"}, 2)
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("stunq", " ^- Only if Stuns", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("rcombo", "Use R in Combo", true)
menu.combo:dropdown("rmode", "R Mode", 1, {"If X Health", "Only if Killlable"}, 2)
menu.combo:slider("hp", "If X Health", 50, 1, 100, 1)
menu.combo:slider("hitr", "Min. Enemies to Hit", 1, 1, 5, 1)
menu.combo:boolean("minion", " ^- Include Minions for Bounce", true)

menu:menu("harass", "Harass")
menu.harass:dropdown("harassmode", "Harass Mode", 1, {"E-Q-W", "E-W-Q", "W-E-Q", "W-Q-E"}, 2)
menu.harass:boolean("qharass", "Use Q in Combo", true)
menu.harass:boolean("stunq", " ^- Only if Stuns", true)
menu.harass:boolean("wharass", "Use W in Combo", true)
menu.harass:boolean("eharass", "Use E in Combo", true)

menu:menu("laneclear", "Farming")
menu.laneclear:keybind("toggle", "Farm Toggle", "Z", nil)
menu.laneclear:menu("push", "Lane Clear")
menu.laneclear.push:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear.push:boolean("useq", "Use W to Farm", true)
menu.laneclear.push:slider("hitq", " ^- If Hits", 3, 0, 6, 1)

menu.laneclear:menu("jungle", "Jungle Clear")
menu.laneclear.jungle:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear.jungle:boolean("useq", "Use Q in Jungle", true)
menu.laneclear.jungle:boolean("usew", "Use W in Jungle", true)
menu.laneclear.jungle:boolean("usee", "Use E in Jungle", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)
menu.killsteal:boolean("ksw", "Killsteal with W", true)
menu.killsteal:boolean("kse", "Killsteal with E", true)
menu.killsteal:boolean("ksr", "Killsteal with R", true)
menu.killsteal:slider("hitr", " ^- Only if Bounces on X Enemies", 1, 1, 5, 1)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawe", "Draw E Range", false)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", false)
menu.draws:color("colorr", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawdamage", "Draw Damage", true)
menu.draws:boolean("drawtoggle", "Draw Farm Toggle", true)
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
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
	if dist < spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetQ = function()
	return TS.get_result(TargetSelectionQ).obj
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
local function Combo()
	local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if menu.combo.combomode:get() == 2 then
				if menu.combo.ecombo:get() then
					if target.pos:dist(player.pos) < spellE.range then
						player:castSpell("obj", 2, target)
					end
				end
				if menu.combo.qcombo:get() then
					if menu.combo.stunq:get() then
						if target.pos:dist(player.pos) < spellQ.range and target.buff["brandablaze"] then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					else
						if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
				if menu.combo.wcombo:get() then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end

			if menu.combo.combomode:get() == 1 then
				if menu.combo.ecombo:get() then
					if target.pos:dist(player.pos) < spellE.range then
						player:castSpell("obj", 2, target)
					end
				end
				if menu.combo.wcombo:get() then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.combo.qcombo:get() then
					if menu.combo.stunq:get() then
						if target.pos:dist(player.pos) < spellQ.range and target.buff["brandablaze"] then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					else
						if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
			if menu.combo.combomode:get() == 4 then
				if menu.combo.wcombo:get() then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.combo.ecombo:get() then
					if target.pos:dist(player.pos) < spellE.range then
						player:castSpell("obj", 2, target)
					end
				end

				if menu.combo.qcombo:get() then
					if menu.combo.stunq:get() then
						if target.pos:dist(player.pos) < spellQ.range and target.buff["brandablaze"] then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					else
						if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
			if menu.combo.combomode:get() == 3 then
				if menu.combo.wcombo:get() then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end

				if menu.combo.qcombo:get() then
					if menu.combo.stunq:get() then
						if target.pos:dist(player.pos) < spellQ.range and target.buff["brandablaze"] then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					else
						if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
				if menu.combo.ecombo:get() then
					if target.pos:dist(player.pos) < spellE.range then
						player:castSpell("obj", 2, target)
					end
				end
			end
			if menu.combo.rcombo:get() then
				if target.pos:dist(player.pos) < spellR.range then
					if not menu.combo.minion:get() then
						if menu.combo.rmode:get() == 1 then
							if (#count_enemies_in_range(target.pos, 750) >= menu.combo.hitr:get()) then
								if (target.health / target.maxHealth) * 100 <= menu.combo.hp:get() then
									player:castSpell("obj", 3, target)
								end
							end
						end
						if menu.combo.rmode:get() == 2 then
							if
								target.health <
									(dmglib.GetSpellDamage(1, target) + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target) +
										dmglib.GetSpellDamage(2, target))
							 then
								if (#count_enemies_in_range(target.pos, 750) >= menu.combo.hitr:get()) then
									player:castSpell("obj", 3, target)
								end
							end
						end
					end
					if menu.combo.minion:get() then
						if menu.combo.rmode:get() == 1 then
							if (#count_minions_in_range(target.pos, 750) + #count_enemies_in_range(target.pos, 750) >= menu.combo.hitr:get()) then
								if (target.health / target.maxHealth) * 100 <= menu.combo.hp:get() then
									player:castSpell("obj", 3, target)
								end
							end
						end
						if menu.combo.rmode:get() == 2 then
							if
								target.health <
									(dmglib.GetSpellDamage(1, target) + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target) +
										dmglib.GetSpellDamage(2, target))
							 then
								if
									(#count_minions_in_range(target.pos, 750) + #count_enemies_in_range(target.pos, 750) >= menu.combo.hitr:get())
								 then
									player:castSpell("obj", 3, target)
								end
							end
						end
					end
				end
			end
		end
	end
end

local function Harass()
	local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if menu.harass.harassmode:get() == 2 then
				if menu.harass.eharass:get() then
					if target.pos:dist(player.pos) < spellE.range then
						player:castSpell("obj", 2, target)
					end
				end
				if menu.harass.qharass:get() then
					if menu.harass.stunq:get() then
						if target.pos:dist(player.pos) < spellQ.range and target.buff["brandablaze"] then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					else
						if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
				if menu.harass.wharass:get() then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end

			if menu.harass.harassmode:get() == 1 then
				if menu.harass.eharass:get() then
					if target.pos:dist(player.pos) < spellE.range then
						player:castSpell("obj", 2, target)
					end
				end
				if menu.combo.wcombo:get() then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.harass.qharass:get() then
					if menu.harass.stunq:get() then
						if target.pos:dist(player.pos) < spellQ.range and target.buff["brandablaze"] then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					else
						if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
			if menu.harass.harassmode:get() == 4 then
				if menu.harass.wharass:get() then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.harass.eharass:get() then
					if target.pos:dist(player.pos) < spellE.range then
						player:castSpell("obj", 2, target)
					end
				end

				if menu.harass.qharass:get() then
					if menu.harass.stunq:get() then
						if target.pos:dist(player.pos) < spellQ.range and target.buff["brandablaze"] then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					else
						if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
			if menu.harass.harassmode:get() == 3 then
				if menu.harass.wharass:get() then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end

				if menu.harass.qharass:get() then
					if menu.harass.stunq:get() then
						if target.pos:dist(player.pos) < spellQ.range and target.buff["brandablaze"] then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					else
						if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
				if menu.harass.eharass:get() then
					if target.pos:dist(player.pos) < spellE.range then
						player:castSpell("obj", 2, target)
					end
				end
			end
		end
	end
end
local function Killsteal()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and enemies.isVisible and common.IsValidTarget(enemies) and not common.HasBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("ap", enemies)
			if menu.killsteal.ksq:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range and
						dmglib.GetSpellDamage(0, enemies) > hp
				 then
					local pos = preds.linear.get_prediction(spellQ, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						if not preds.collision.get_prediction(spellQ, pos, enemies) then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.killsteal.ksw:get() then
				if
					player:spellSlot(1).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellW.range and
						dmglib.GetSpellDamage(1, enemies) > hp
				 then
					local pos = preds.circular.get_prediction(spellW, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellW.range then
						player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
			if menu.killsteal.kse:get() then
				if
					player:spellSlot(2).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range and
						dmglib.GetSpellDamage(2, enemies) > hp
				 then
					player:castSpell("obj", 2, enemies)
				end
			end
			if menu.killsteal.ksr:get() then
				if
					player:spellSlot(3).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellR.range and
						dmglib.GetSpellDamage(3, enemies) > hp
				 then
					if (#count_enemies_in_range(enemies.pos, 750) >= menu.killsteal.hitr:get()) then
						player:castSpell("obj", 3, enemies)
					end
				end
			end
		end
	end
end
local function LaneClear()
	if uhh == true then
		if (player.mana / player.maxMana) * 100 >= menu.laneclear.push.mana:get() then
			if menu.laneclear.push.useq:get() then
				local minions = objManager.minions
				for a = 0, minions.size[TEAM_ENEMY] - 1 do
					local minion1 = minions[TEAM_ENEMY][a]
					if
						minion1 and not minion1.isDead and minion1.isVisible and
							player.path.serverPos:distSqr(minion1.path.serverPos) <= (spellW.range * spellW.range)
					 then
						local count = 0
						for b = 0, minions.size[TEAM_ENEMY] - 1 do
							local minion2 = minions[TEAM_ENEMY][b]
							if
								minion2 and minion2 ~= minion1 and not minion2.isDead and minion2.isVisible and
									minion2.path.serverPos:distSqr(minion1.path.serverPos) <= (240 * 240)
							 then
								count = count + 1
							end
							if count >= menu.laneclear.push.hitq:get() then
								local seg = preds.circular.get_prediction(spellW, minion1)
								if seg and seg.startPos:dist(seg.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(seg.endPos.x, minion1.y, seg.endPos.y))
									--orb.core.set_server_pause()
									break
								end
							end
						end
					end
				end
				local enemyMinionsE = common.GetMinionsInRange(spellW.range, TEAM_ENEMY)
				for i, minion in pairs(enemyMinionsE) do
					if minion and minion.path.count == 0 and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos then
							if
								#count_minions_in_range(minionPos, 240) >= menu.laneclear.push.hitq:get() and
									#count_minions_in_range(minionPos, spellW.range) < 7
							 then
								local seg = preds.circular.get_prediction(spellW, minion)
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
local function JungleClear()
	if (player.mana / player.maxMana) * 100 >= menu.laneclear.jungle.mana:get() then
		if menu.laneclear.jungle.usee:get() then
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
		if menu.laneclear.jungle.useq:get() then
			local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_NEUTRAL)
			for i, minion in pairs(enemyMinionsQ) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellQ.range then
						local pos = preds.linear.get_prediction(spellQ, minion)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
		if menu.laneclear.jungle.usew:get() then
			local enemyMinionsQ = common.GetMinionsInRange(spellW.range, TEAM_NEUTRAL)
			for i, minion in pairs(enemyMinionsQ) do
				if minion and not minion.isDead and common.IsValidTarget(minion) then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellW.range then
						local pos = preds.circular.get_prediction(spellW, minion)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
	end
end
local function OnTick()
	Killsteal()
	Toggle()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.clearkey:get() then
		JungleClear()
		LaneClear()
	end
end

function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		local pos = graphics.world_to_screen(target.pos)
		if
			(math.floor(
				(dmglib.GetSpellDamage(1, target) + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target) +
					dmglib.GetSpellDamage(2, target)) /
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
						dmglib.GetSpellDamage(1, target) + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target) +
							dmglib.GetSpellDamage(2, target)
					)
				) ..
					" (" ..
						tostring(
							math.floor(
								(dmglib.GetSpellDamage(1, target) + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target) +
									dmglib.GetSpellDamage(2, target)) /
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
				(dmglib.GetSpellDamage(1, target) + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target) +
					dmglib.GetSpellDamage(2, target)) /
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
						dmglib.GetSpellDamage(1, target) + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target) +
							dmglib.GetSpellDamage(2, target)
					)
				) ..
					" (" ..
						tostring(
							math.floor(
								(dmglib.GetSpellDamage(1, target) + dmglib.GetSpellDamage(0, target) + dmglib.GetSpellDamage(3, target) +
									dmglib.GetSpellDamage(2, target)) /
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
local function OnDraw()
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
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 100)
		end
		if menu.draws.drawtoggle:get() then
			local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
			if uhh == true then
				graphics.draw_text_2D("Farm: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
				graphics.draw_text_2D("ON", 17, pos.x + 23, pos.y + 10, graphics.argb(255, 51, 255, 51))
			else
				graphics.draw_text_2D("Farm: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
				graphics.draw_text_2D("OFF", 17, pos.x + 23, pos.y + 10, graphics.argb(255, 255, 0, 0))
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
	--graphics.draw_circle(player.pos, spellQ.range + 380, 2, menu.draws.colorfq:get(), 100)
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)

cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
