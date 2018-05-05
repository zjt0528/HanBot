local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Blitzcrank by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Blitzcrank by Kornis'!")
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
	range = 950,
	delay = 0.25,
	width = 70,
	speed = 1800,
	range = 1050,
	boundingRadiusMod = 1,
	collision = {
		hero = false,
		minion = true
	}
}

local spellW = {
	range = 0
}

local spellE = {
	range = 300
}

local spellR = {
	range = 600
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

local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local tSelector = avada_lib.targetSelector
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Blitzcrank")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("rcombo", "Use R in Combo", true)
menu.combo:slider("hitr", " ^- If Hits X Enemies", 2, 1, 5, 1)

menu:menu("qset", "Q Settings")
menu.qset:keybind("grabq", "Semi-Q ", "T", nil)
menu.qset:boolean("autoq", "Auto Q on Dash", true)
menu.qset:slider("minq", "Min. Q Range", 300, 10, 400, 10)
menu.qset:slider("maxq", "Max. Q Range", 900, 500, 950, 10)

menu.qset:menu("blacklist", "Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.qset.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 233, 121, 121)

menu:menu("misc", "Misc.")
menu.misc:boolean("GapAS", "Use W for Anti-Gapclose", true)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("intr", "Use R to Interrupt", true)
menu.misc.interrupt:menu("interruptmenur", "R Interrupting")

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
menu.misc.interrupt:boolean("intq", "Use Q to Interrupt", true)
menu.misc.interrupt:menu("interruptmenuq", "Q Interrupting")

for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.misc.interrupt.interruptmenuq:boolean(
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

local function AutoInterrupt(spell)
	if menu.combo.ecombo:get() then
		if
			spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY and spell.owner == player and
				spell.target.type == TYPE_HERO
		 then
			if spell.name:find("BasicAttack") then
				player:castSpell("self", 2)
			end
		end
	end
	if menu.misc.interrupt.intr:get() and player:spellSlot(3).state == 0 then
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
							player.pos2D:dist(spell.owner.pos2D) < spellR.range and common.IsValidTarget(spell.owner) and
								player:spellSlot(3).state == 0
						 then
							player:castSpell("self", 3)
						end
					end
				end
			end
		end
	end
	if menu.misc.interrupt.intq:get() and player:spellSlot(0).state == 0 then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if
						menu.misc.interrupt.interruptmenuq[spell.owner.charName .. spellCheck.menuslot]:get() and
							string.lower(spell.name) == spellCheck.spellname
					 then
						if
							player.pos2D:dist(spell.owner.pos2D) < spellQ.range and common.IsValidTarget(spell.owner) and
								player:spellSlot(0).state == 0
						 then
							local pos = preds.linear.get_prediction(spellQ, spell.owner)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, spell.owner) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end
end
local function WGapcloser()
	if player:spellSlot(1).state == 0 and menu.misc.GapAS:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < 500
				 then
					if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
						player:castSpell("self", 1)
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

local TargetSelectionW = function(res, obj, dist)
	if dist < spellW.range then
		res.obj = obj
		return true
	end
end
local GetTargetW = function()
	return TS.get_result(TargetSelectionW).obj
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
	local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if menu.combo.qcombo:get() then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
					if not preds.collision.get_prediction(spellQ, pos, target) then
						if target.pos:dist(player.pos) >= menu.qset.minq:get() then
							if not menu.qset.blacklist[target.charName]:get() then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end

			if menu.combo.rcombo:get() then
				if #count_enemies_in_range(player.pos, spellR.range) >= menu.combo.hitr:get() then
					player:castSpell("self", 3)
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
			if dist <= spellQ.range and obj.path.isActive and obj.path.isDashing then --add invulnverabilty check
				res.obj = obj
				return true
			end
		end
	).obj
	if target then
		local pred_pos = preds.core.lerp(target.path, network.latency + spellQ.delay, target.path.dashSpeed)
		if pred_pos and pred_pos:dist(player.path.serverPos2D) <= spellQ.range then
			seg.startPos = player.path.serverPos2D
			seg.endPos = vec2(pred_pos.x, pred_pos.y)

			if not preds.collision.get_prediction(spellQ, seg, target.pos:to2D()) then
				player:castSpell("pos", 0, vec3(pred_pos.x, target.y, pred_pos.y))
			end
		end
	end
end
local function OnTick()
	spellQ.range = menu.qset.maxq:get()
	WGapcloser()
	if menu.qset.autoq:get() then
		AutoDash()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.qset.grabq:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local pos = preds.linear.get_prediction(spellQ, target)
				if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
					if not preds.collision.get_prediction(spellQ, pos, target) then
						if target.pos:dist(player.pos) >= menu.qset.minq:get() then
							if not menu.qset.blacklist[target.charName]:get() then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
	end
end

local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 100)
		end
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)

cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
