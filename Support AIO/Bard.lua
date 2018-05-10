local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Nami by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Nami by Kornis'!")
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
	range = 900,
	delay = 0.25,
	speed = 1400,
	width = 60,
	boundingRadiusMod = 1,
	collision = {hero = true, minion = true, wall = true}
}

local spellW = {
	range = 800
}

local spellE = {
	range = 0
}

local spellR = {
	range = 0
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
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Bard")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("qstun", " ^- Only if Stuns", true)
menu.combo:slider("maxstun", "Extended Q Range", 310, 300, 370, 1)
menu:menu("wpriority", "Healing")

menu.wpriority:header("something", " -- W Settings -- ")
menu.wpriority:boolean("enablew", "Enable Auto W", true)
menu.wpriority:slider("mana", "Don't W if Mana <= X", 30, 1, 100, 1)
menu.wpriority:header("uhhh", "0 - Disabled, 1 - Biggest Priority, 5 - Lowest Priority")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	menu.wpriority:slider(allies.charName, "Priority: " .. allies.charName, 1, 0, 5, 1)
	menu.wpriority:slider(allies.charName .. "hp", " ^- Health Percent: ", 50, 1, 100, 1)
end

menu:menu("we", "W Boost Settings")
menu.we:keybind("wekey", "W Boost Ally", "G", nil)
menu.we:header("uhhh", "0 - Disabled, 1 - Biggest Priority, 5 - Lowest Priority")
for i = 0, objManager.allies_n - 1 do
	local allies = objManager.allies[i]

	if
		allies.charName ~= "Twitch" and allies.charName ~= "KogMaw" and allies.charName ~= "Tristana" and
			allies.charName ~= "Ashe" and
			allies.charName ~= "Vayne" and
			allies.charName ~= "Varus" and
			allies.charName ~= "Xayah" and
			allies.charName ~= "Lucian" and
			allies.charName ~= "Sivir" and
			allies.charName ~= "Draven" and
			allies.charName ~= "Kalista" and
			allies.charName ~= "Caitlyn" and
			allies.charName ~= "Jinx" and
			allies.charName ~= "Ezreal"
	 then
		menu.we:slider(allies.charName, "Priority: " .. allies.charName, 0, 0, 5, 1)
	end
	if
		allies.charName == "Twitch" or allies.charName == "KogMaw" or allies.charName == "Tristana" or
			allies.charName == "Ashe" or
			allies.charName == "Vayne" or
			allies.charName == "Varus" or
			allies.charName == "Xayah" or
			allies.charName == "Lucian" or
			allies.charName == "Sivir" or
			allies.charName == "Draven" or
			allies.charName == "Kalista" or
			allies.charName == "Caitlyn" or
			allies.charName == "Jinx" or
			allies.charName == "Ezreal"
	 then
		menu.we:slider(allies.charName, "Priority: " .. allies.charName, 1, 0, 5, 1)
	end
end

menu:menu("harass", "Harass")

menu.harass:boolean("qcombo", "Use Q in Combo", true)
menu.harass:boolean("qstun", " ^- Only if Stuns", true)
menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawr", "Draw R Range Minimap", false)
menu.draws:color("colorr", "  ^- Color", 255, 255, 255, 255)

menu:menu("flee", "Flee")
menu.flee:keybind("fleekey", "Flee Key", "Z", nil)
menu.flee:boolean("fleew", "Use W to Flee", true)
menu:menu("misc", "Misc.")
menu.misc:boolean("autow", "Auto W if Ally Slowed", true)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("intq", "Use Q to Interrupt", true)
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

local function PrioritizedAllyW()
	if menu.wpriority.enablew:get() and (player.mana / player.maxMana) * 100 >= menu.wpriority.mana:get() then
		local heroTarget = nil
		for i = 0, objManager.allies_n - 1 do
			local hero = objManager.allies[i]
			if not player.isRecalling then
				if
					hero.team == TEAM_ALLY and not hero.isDead and menu.wpriority[hero.charName]:get() > 0 and
						hero.pos:dist(player.pos) <= spellW.range and
						not hero.isRecalling and
						menu.wpriority[hero.charName .. "hp"]:get() >= (hero.health / hero.maxHealth) * 100
				 then
					if heroTarget == nil then
						heroTarget = hero
					elseif menu.wpriority[hero.charName]:get() < menu.wpriority[heroTarget.charName]:get() then
						heroTarget = hero
					end
				end
			end
		end
		return heroTarget
	end
end

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
							local pos = preds.linear.get_prediction(spellQ, spell.owner)
							if not preds.collision.get_prediction(spellQ, pos, spell.owner) then
							else
								if table.getn(preds.collision.get_prediction(spellQ, pos, spell.owner)) == 1 then
									local collision = preds.collision.get_prediction(spellQ, pos, spell.owner)
									for i = 1, #collision do
										local obj = collision[i]
										if
											obj and not obj.isDead and obj.type and (obj.type == TYPE_MINION or obj.type == TYPE_HERO) and
												obj.pos:dist(player.pos) > 150 and
												obj.pos:dist(target.pos) < menu.combo.maxstun:get()
										 then
											player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
										end
									end
								end
							end
							for k = 1, menu.combo.maxstun:get(), 20 do
								local possss = spell.owner.pos + k * (spell.owner.pos - player.pos):norm()
								if navmesh.isWall(possss) then
									local pos = preds.linear.get_prediction(spellQ, spell.owner)

									if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
								for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
									local minion = objManager.minions[TEAM_NEUTRAL][i]
									if
										minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
											minion.pos:dist(player.pos) < spellQ.range
									 then
										if possss:dist(minion.pos) <= 25 + minion.boundingRadius then
											local pos = preds.linear.get_prediction(spellQ, spell.owner)
											if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
												player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
								for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
									local minion = objManager.minions[TEAM_ENEMY][i]
									if
										minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
											minion.pos:dist(player.pos) < spellQ.range
									 then
										if possss:dist(minion.pos) <= 25 + minion.boundingRadius then
											local pos = preds.linear.get_prediction(spellQ, spell.owner)
											if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
												player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
								for i = 0, objManager.enemies_n - 1 do
									local enemies = objManager.enemies[i]
									if
										enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
											player.pos:dist(enemies) < spellQ.range + 300
									 then
										if possss:dist(enemies.pos) <= 25 + enemies.boundingRadius and enemies.ptr ~= spell.owner.ptr then
											local pos = preds.linear.get_prediction(spellQ, spell.owner)
											if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
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

local TargetSelectionE = function(res, obj, dist)
	if dist < spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
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

local function Combo()
	if menu.combo.qcombo:get() then
		local target = GetTargetE()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if target.pos:dist(player.pos) < spellQ.range then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						if not preds.collision.get_prediction(spellQ, pos, target) then
							if not menu.combo.qstun:get() then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						else
							if table.getn(preds.collision.get_prediction(spellQ, pos, target)) > 1 then
								local collision = preds.collision.get_prediction(spellQ, pos, target)
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and not obj.isDead and obj.type and obj.type == TYPE_HERO and obj.pos:dist(player.pos) > 150 and
											obj.pos:dist(target.pos) < menu.combo.maxstun:get()
									 then
										for i = 0, objManager.enemies_n - 1 do
											local enemies = objManager.enemies[i]
											if
												enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
													player.pos:dist(enemies) < spellQ.range and
													enemies.ptr ~= target.ptr and
													enemies.ptr ~= obj.ptr and
													(enemies.pos:dist(obj.pos) < menu.combo.maxstun:get() or
														enemies.pos:dist(target.pos) < menu.combo.maxstun:get())
											 then
												player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
							end
							if table.getn(preds.collision.get_prediction(spellQ, pos, target)) == 1 then
								local collision = preds.collision.get_prediction(spellQ, pos, target)
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and not obj.isDead and obj.type and (obj.type == TYPE_MINION or obj.type == TYPE_HERO) and
											obj.pos:dist(player.pos) > 150 and
											obj.pos:dist(target.pos) < menu.combo.maxstun:get()
									 then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
						if not preds.collision.get_prediction(spellQ, pos, target) then
							for k = 1, menu.combo.maxstun:get(), 20 do
								local possss = target.pos + k * (target.pos - player.pos):norm()
								if navmesh.isWall(possss) then
									local pos = preds.linear.get_prediction(spellQ, target)

									if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
								for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
									local minion = objManager.minions[TEAM_NEUTRAL][i]
									if
										minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
											minion.pos:dist(player.pos) < spellQ.range
									 then
										if possss:dist(minion.pos) <= 25 + minion.boundingRadius then
											local pos = preds.linear.get_prediction(spellQ, target)
											if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
												player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
								for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
									local minion = objManager.minions[TEAM_ENEMY][i]
									if
										minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
											minion.pos:dist(player.pos) < spellQ.range
									 then
										if possss:dist(minion.pos) <= 25 + minion.boundingRadius then
											local pos = preds.linear.get_prediction(spellQ, target)
											if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
												player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
								for i = 0, objManager.enemies_n - 1 do
									local enemies = objManager.enemies[i]
									if
										enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
											player.pos:dist(enemies) < spellQ.range + 300
									 then
										if possss:dist(enemies.pos) <= 25 + enemies.boundingRadius and enemies.ptr ~= target.ptr then
											local pos = preds.linear.get_prediction(spellQ, target)
											if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
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
		end
	end
end
local function Harass()
	if menu.harass.qcombo:get() then
		local target = GetTargetE()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if target.pos:dist(player.pos) < spellQ.range then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						if not preds.collision.get_prediction(spellQ, pos, target) then
							if not menu.harass.qstun:get() then
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						else
							if table.getn(preds.collision.get_prediction(spellQ, pos, target)) > 1 then
								local collision = preds.collision.get_prediction(spellQ, pos, target)
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and not obj.isDead and obj.type and obj.type == TYPE_HERO and obj.pos:dist(player.pos) > 150 and
											obj.pos:dist(target.pos) < menu.combo.maxstun:get()
									 then
										for i = 0, objManager.enemies_n - 1 do
											local enemies = objManager.enemies[i]
											if
												enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
													player.pos:dist(enemies) < spellQ.range and
													enemies.ptr ~= target.ptr and
													enemies.ptr ~= obj.ptr and
													(enemies.pos:dist(obj.pos) < menu.combo.maxstun:get() or
														enemies.pos:dist(target.pos) < menu.combo.maxstun:get())
											 then
												player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
							end
							if table.getn(preds.collision.get_prediction(spellQ, pos, target)) == 1 then
								local collision = preds.collision.get_prediction(spellQ, pos, target)
								for i = 1, #collision do
									local obj = collision[i]
									if
										obj and not obj.isDead and obj.type and (obj.type == TYPE_MINION or obj.type == TYPE_HERO) and
											obj.pos:dist(player.pos) > 150 and
											obj.pos:dist(target.pos) < menu.combo.maxstun:get()
									 then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
						if not preds.collision.get_prediction(spellQ, pos, target) then
							for k = 1, 310, 20 do
								local possss = target.pos + k * (target.pos - player.pos):norm()
								if navmesh.isWall(possss) then
									local pos = preds.linear.get_prediction(spellQ, target)

									if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
										player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
								for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
									local minion = objManager.minions[TEAM_NEUTRAL][i]
									if
										minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
											minion.pos:dist(player.pos) < spellQ.range
									 then
										if possss:dist(minion.pos) <= 25 + minion.boundingRadius then
											local pos = preds.linear.get_prediction(spellQ, target)
											if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
												player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
								for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
									local minion = objManager.minions[TEAM_ENEMY][i]
									if
										minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
											minion.pos:dist(player.pos) < spellQ.range
									 then
										if possss:dist(minion.pos) <= 25 + minion.boundingRadius then
											local pos = preds.linear.get_prediction(spellQ, target)
											if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
												player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
								for i = 0, objManager.enemies_n - 1 do
									local enemies = objManager.enemies[i]
									if
										enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
											player.pos:dist(enemies) < spellQ.range + 300
									 then
										if possss:dist(enemies.pos) <= 25 + enemies.boundingRadius and enemies.ptr ~= target.ptr then
											local pos = preds.linear.get_prediction(spellQ, target)
											if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
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
		end
	end
end
local function PrioritizedAllyWE()
	local heroTarget = nil
	for i = 0, objManager.allies_n - 1 do
		local hero = objManager.allies[i]
		if not player.isRecalling then
			if
				hero.team == TEAM_ALLY and not hero.isDead and menu.we[hero.charName]:get() > 0 and
					hero.pos:dist(player.pos) <= spellW.range
			 then
				if heroTarget == nil then
					heroTarget = hero
				elseif menu.we[hero.charName]:get() < menu.we[heroTarget.charName]:get() then
					heroTarget = hero
				end
			end
		end
	end

	return heroTarget
end

local function OnTick()
	if menu.we.wekey:get() then
		if PrioritizedAllyWE() then
			player:castSpell("obj", 1, PrioritizedAllyWE())
		end
	end
	if menu.keys.combokey:get() then
		Combo()
	end

	if menu.flee.fleekey:get() then
		if menu.flee.fleew:get() then
			player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
			player:castSpell("self", 1)
		end
	end
	if PrioritizedAllyW() then
		player:castSpell("obj", 1, PrioritizedAllyW())
	end
	if menu.misc.autow:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally and ally.pos:dist(player.pos) <= spellW.range then
				if
					(ally.buff[5] or ally.buff[8] or ally.buff[24] or ally.buff[23] or ally.buff[11] or ally.buff[22] or ally.buff[8] or
						ally.buff[10] or
						ally.buff[21])
				 then
					player:castSpell("pos", 1, ally.pos)
				end
			end
		end
	end

	if menu.keys.harasskey:get() then
		Harass()
	end
end
local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawr:get() then
			if player:spellSlot(3).level > 0 then
				minimap.draw_circle(player.pos, 3400, 2, menu.draws.colorr:get(), 30)
			end
		end
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 100)
		end
	end
end

TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)

cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
