local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Rakan by Kornis'!")
	print("You can find it here:")
	console.set_color(11)
	print("https://gitlab.soontm.net/get_clear_zip.php?fn=avada_lib")
	console.set_color(15)
	return
elseif avada_lib.version < 1 then
	console.set_color(12)
	print("Your need to have Avada Lib updated to run 'Rakan by Kornis'!")
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
	range = 850,
	speed = 2000,
	width = 80,
	delay = 0.25,
	boundingRadiusMod = 0,
	collision = {
		hero = false,
		minion = true
	}
}

local spellW = {
	range = 650,
	speed = 1800,
	radius = 170,
	boundingRadiusMod = 0,
	delay = 0.25
}

local spellE = {
	range = 700
}

local spellR = {
	range = 900
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
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Rakan")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("wcancel", "Cancel W Animation with Q", true)
menu.combo:boolean("rcombo", "Use R in Combo", true)
menu.combo:slider("hitr", " ^- If X Near Enemies", 2, 1, 5, 1)
menu.combo:slider("hpr", " ^- If Enemy HP lower than X", 50, 1, 100, 1)
menu.combo:boolean("blockaa", "Block Auto Attacks while in W", true)

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("ecombo", "Use E > W > E Logic", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", false)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawengage", "Draw Engage Range", true)
menu.draws:boolean("drawflash", "Draw W - Flash Range", true)

menu:menu("flee", "Flee")
menu.flee:keybind("fleekey", "Flee Key", "G", nil)
menu.flee:boolean("eflee", "Use E to Flee", true)
menu.flee:boolean("rflee", "Use R to Flee", false)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
menu:menu("SpellsMenu", "Shielding")
menu.SpellsMenu:boolean("enable", "Enable Shielding", true)
menu.SpellsMenu:menu("blacklist", "Ally Shield Blacklist")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	menu.SpellsMenu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu.SpellsMenu:header("hello", " -- Enemy Skillshots -- ")
for _, i in pairs(database) do
	for l, k in pairs(common.GetEnemyHeroes()) do
		-- k = myHero
		if not database[_] then
			return
		end
		if i.charName == k.charName then
			if i.displayname == "" then
				i.displayname = _
			end
			if i.danger == 0 then
				i.danger = 1
			end
			if (menu.SpellsMenu[i.charName] == nil) then
				menu.SpellsMenu:menu(i.charName, i.charName)
			end
			menu.SpellsMenu[i.charName]:menu(_, "" .. i.charName .. " | " .. (str[i.slot] or "?") .. " " .. _)

			menu.SpellsMenu[i.charName][_]:boolean("Dodge", "Enable Block", true)

			menu.SpellsMenu[i.charName][_]:slider("hp", "HP to Dodge", 100, 1, 100, 5)
		end
	end
end
menu.SpellsMenu:header("hello", " -- Misc. -- ")
menu.SpellsMenu:boolean("targeteteteteteed", "Shield on Targeted Spells", true)
menu.SpellsMenu:boolean("cc", "Auto Shield on CC", true)
menu.SpellsMenu:menu("BasicAttack", "Basic Attack Sielding", true)
menu.SpellsMenu.BasicAttack:boolean("aa", "Shield on Basic attack", true)
menu.SpellsMenu.BasicAttack:slider("aahp", " ^- HP to Shield", 40, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("critaa", "Shield on Crit attack", true)
menu.SpellsMenu.BasicAttack:slider("crithp", " ^- HP to Shield", 40, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("minionaa", "Shield on Minion attack", true)
menu.SpellsMenu.BasicAttack:slider("minionhp", " ^- HP to Shield", 10, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("turret", "Shield on Turret attack", true)
menu:keybind("engage", "Engage E - W Combo", "T", nil)
menu:keybind("wflash", "W - Flash", "Z", nil)
menu:boolean("wf", " ^- Use R Meanwhile in R", true)
local objHolder = {}
local Pix = nil
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
local delayyyyyyyyy = 0
local meowmeow = 0
local meowdelay = 0
local cancelq = false
local TargetSelectionWflash = function(res, obj, dist)
	if dist < spellW.range + 410 then
		res.obj = obj
		return true
	end
end
local GetTargetWFlash = function()
	return TS.get_result(TargetSelectionWflash).obj
end
local function AutoInterrupt(spell)
	if spell and spell.owner and spell.owner == player and spell.name == "RakanQ" then
		cancelq = false
	end
	if menu.combo.wcancel:get() then
		if spell and spell.owner and spell.owner == player and spell.name == "RakanW" then
			cancelq = true
			meowmeow = game.time + 0.1
		end
	end
	if spell and spell.owner and spell.owner == player and spell.name == "RakanE" then
		delayyyyyyyyy = game.time + 1
	end
	if spell and spell.owner and spell.owner == player and spell.name == "RakanW" then
		meowdelay = game.time + 2.5
	end
	if menu.SpellsMenu.targeteteteteteed:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally then
				if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
					if
						spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally and
							not (spell.name:find("BasicAttack") or spell.name:find("crit"))
					 then
						if menu.SpellsMenu.targeteteteteteed:get() then
							if ally.charName == "Xayah" and ally.pos:dist(player.pos) <= 1000 then
								player:castSpell("obj", 2, ally)
							end
							if ally.pos:dist(player.pos) <= spellE.range then
								player:castSpell("obj", 2, ally)
							end
						end
					end
				end
			end
		end
	end
	if menu.SpellsMenu.BasicAttack.aa:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally then
				if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if spell.name:find("BasicAttack") then
						if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if ally.charName == "Xayah" and ally.pos:dist(player.pos) <= 1000 then
									player:castSpell("obj", 2, ally)
								end
								if ally.pos:dist(player.pos) <= spellE.range then
									player:castSpell("obj", 2, ally)
								end
							end
						end
					end
				end
			end
		end
	end
	if menu.SpellsMenu.BasicAttack.critaa:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally then
				if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if spell.name:find("crit") then
						if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.crithp:get() then
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if ally.charName == "Xayah" and ally.pos:dist(player.pos) <= 1000 then
									player:castSpell("obj", 2, ally)
								end
								if ally.pos:dist(player.pos) <= spellE.range then
									player:castSpell("obj", 2, ally)
								end
							end
						end
					end
				end
			end
		end
	end
	if menu.SpellsMenu.BasicAttack.minionaa:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally then
				if spell.owner.type == TYPE_MINION and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.minionhp:get() then
						if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
							if ally.charName == "Xayah" and ally.pos:dist(player.pos) <= 1000 then
								player:castSpell("obj", 2, ally)
							end
							if ally.pos:dist(player.pos) <= spellE.range then
								player:castSpell("obj", 2, ally)
							end
						end
					end
				end
			end
		end
	end
	if menu.SpellsMenu.BasicAttack.turret:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally then
				if spell.owner.type == TYPE_TURRET and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
						if ally.charName == "Xayah" and ally.pos:dist(player.pos) <= 1000 then
							player:castSpell("obj", 2, ally)
						end
						if ally.pos:dist(player.pos) <= spellE.range then
							player:castSpell("obj", 2, ally)
						end
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
local TargetSelectionQE = function(res, obj, dist)
	if dist < spellE.range + spellW.range then
		res.obj = obj
		return true
	end
end
local GetTargetQE = function()
	return TS.get_result(TargetSelectionQE).obj
end
local TargetSelectioXayah = function(res, obj, dist)
	if dist < 1000 + spellW.range then
		res.obj = obj
		return true
	end
end
local GetTargetXayah = function()
	return TS.get_result(TargetSelectioXayah).obj
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

local function Harass()
	if menu.harass.ecombo:get() then
		local target = GetTargetQE()
		local targets = GetTargetXayah()
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if
				ally and not ally.isDead and ally.isTargetable and ally ~= player and ally.isVisible and
					ally.pos:dist(player.pos) <= spellE.range + spellW.range
			 then
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						if (ally.pos:dist(player.pos) > spellE.range) then
							if player.mana > player.manaCost2 + player.manaCost1 then
								local seg = preds.circular.get_prediction(spellW, target)
								if seg and seg.startPos:dist(seg.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(seg.endPos.x, target.y, seg.endPos.y))
								end
								if ally.pos:dist(player.pos) < spellE.range and delayyyyyyyyy <= game.time then
									if player:spellSlot(1).state == 0 then
										player:castSpell("obj", 2, ally)
									end
									if (ally.buff["rakaneshield"]) then
										player:castSpell("obj", 2, ally)
									end
								end
							end
						end
						if (player.pos:dist(ally.pos) < spellE.range) then
							local seg = preds.circular.get_prediction(spellW, target, ally)
							if seg and seg.startPos:dist(seg.endPos) < spellW.range - 50 then
								if player.mana > player.manaCost2 + player.manaCost1 then
									local seg = preds.circular.get_prediction(spellW, target, ally)
									if seg and seg.startPos:dist(seg.endPos) < spellW.range then
										if delayyyyyyyyy <= game.time then
											if player:spellSlot(1).state == 0 then
												player:castSpell("obj", 2, ally)
											end
										end
										if player.buff["rakanerecast"] then
											local segs = preds.circular.get_prediction(spellW, target)
											if segs and seg.startPos:dist(segs.endPos) < spellW.range then
												player:castSpell("pos", 1, vec3(segs.endPos.x, target.y, segs.endPos.y))
											end
										end
										if ally.buff["rakaneshield"] and delayyyyyyyyy <= game.time then
											player:castSpell("obj", 2, ally)
										end
									end
								end
							end
						end
					end
				end
			end
		end
		for z, ally in ipairs(allies) do
			if
				ally and not ally.isDead and ally.isTargetable and ally ~= player and ally.isVisible and ally.charName == "Xayah" and
					ally.pos:dist(player.pos) <= 1000 + spellW.range
			 then
				if targets and targets.isVisible then
					if common.IsValidTarget(targets) then
						if (ally.pos:dist(player.pos) > 1000) then
							if player.mana > player.manaCost2 + player.manaCost1 then
								local seg = preds.circular.get_prediction(spellW, targets)
								if seg and seg.startPos:dist(seg.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(seg.endPos.x, targets.y, seg.endPos.y))
								end
								if ally.pos:dist(player.pos) < 1000 and delayyyyyyyyy <= game.time then
									if player:spellSlot(1).state == 0 then
										player:castSpell("obj", 2, ally)
									end
									if (ally.buff["rakaneshield"]) then
										player:castSpell("obj", 2, ally)
									end
								end
							end
						end
						if (player.pos:dist(ally.pos) < 1000) then
							local seg = preds.circular.get_prediction(spellW, targets, ally)
							if seg and seg.startPos:dist(seg.endPos) < spellW.range - 50 then
								if player.mana > player.manaCost2 + player.manaCost1 then
									local seg = preds.circular.get_prediction(spellW, targets, ally)
									if seg and seg.startPos:dist(seg.endPos) < spellW.range then
										if delayyyyyyyyy <= game.time then
											if player:spellSlot(1).state == 0 then
												player:castSpell("obj", 2, ally)
											end
										end
										if player.buff["rakanerecast"] then
											local segs = preds.circular.get_prediction(spellW, targets)
											if segs and seg.startPos:dist(segs.endPos) < spellW.range then
												player:castSpell("pos", 1, vec3(segs.endPos.x, targets.y, segs.endPos.y))
											end
										end
										if ally.buff["rakaneshield"] and delayyyyyyyyy <= game.time then
											player:castSpell("obj", 2, ally)
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
	if menu.harass.qcombo:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local seg = preds.linear.get_prediction(spellQ, target)
				if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
					if not preds.collision.get_prediction(spellQ, seg, target) then
						player:castSpell("pos", 0, vec3(seg.endPos.x, target.y, seg.endPos.y))
					end
				end
			end
		end
	end
end

local function Combo()
	if menu.combo.qcombo:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local seg = preds.linear.get_prediction(spellQ, target)
				if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
					if not preds.collision.get_prediction(spellQ, seg, target) then
						player:castSpell("pos", 0, vec3(seg.endPos.x, target.y, seg.endPos.y))
					end
				end
			end
		end
	end
	if menu.combo.wcombo:get() then
		local target = GetTargetQE()
		local targets = GetTargetXayah()
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if
				ally and not ally.isDead and ally.isTargetable and ally ~= player and ally.isVisible and
					ally.pos:dist(player.pos) <= spellE.range + spellW.range
			 then
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						if player.buff["rakanerecast"] and delayyyyyyyyy <= game.time then
							if target.pos:dist(ally.pos) < player.pos:dist(target.pos) then
								player:castSpell("obj", 2, ally)
							end
						end
						if (ally.pos:dist(player.pos) > spellE.range) then
							if player.mana > player.manaCost2 + player.manaCost1 then
								local seg = preds.circular.get_prediction(spellW, target)
								if seg and seg.startPos:dist(seg.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(seg.endPos.x, target.y, seg.endPos.y))
								end
								if meowdelay <= game.time and not player.buff["rakanerecast"] then
									if target.pos:dist(ally.pos) < player.pos:dist(target.pos) then
										if player:spellSlot(1).state == 0 then
											player:castSpell("obj", 2, ally)
										end
									end
								end
							end
						end
						if (player.pos:dist(ally.pos) < spellE.range) then
							local seg = preds.circular.get_prediction(spellW, target, ally)
							if seg and seg.startPos:dist(seg.endPos) < spellW.range - 50 then
								if player.mana > player.manaCost2 + player.manaCost1 then
									local seg = preds.circular.get_prediction(spellW, target, ally)
									if seg and seg.startPos:dist(seg.endPos) < spellW.range then
										if meowdelay <= game.time and not player.buff["rakanerecast"] then
											if target.pos:dist(ally.pos) < player.pos:dist(target.pos) then
												if player:spellSlot(1).state == 0 then
													player:castSpell("obj", 2, ally)
												end
											end
										end

										if player.buff["rakanerecast"] then
											local segs = preds.circular.get_prediction(spellW, target)
											if segs and seg.startPos:dist(segs.endPos) < spellW.range then
												player:castSpell("pos", 1, vec3(segs.endPos.x, target.y, segs.endPos.y))
											end
										end
									end
								end
							end
						end
						if target.pos:dist(ally.pos) > 580 then
							local seg = preds.circular.get_prediction(spellW, target)
							if seg and seg.startPos:dist(seg.endPos) < spellW.range then
								player:castSpell("pos", 1, vec3(seg.endPos.x, target.y, seg.endPos.y))
							end
						end
					end
				end
			end
		end
		for z, ally in ipairs(allies) do
			if
				ally and not ally.isDead and ally.isTargetable and ally ~= player and ally.charName == "Xayah" and ally.isVisible and
					ally.pos:dist(player.pos) <= 1000 + spellW.range
			 then
				if targets and targets.targets then
					if common.IsValidTarget(target) then
						if player.buff["rakanerecast"] and delayyyyyyyyy <= game.time then
							if targets.pos:dist(ally.pos) < player.pos:dist(targets.pos) then
								player:castSpell("obj", 2, ally)
							end
						end
						if (ally.pos:dist(player.pos) > 1000) then
							if player.mana > player.manaCost2 + player.manaCost1 then
								local seg = preds.circular.get_prediction(spellW, targets)
								if seg and seg.startPos:dist(seg.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(seg.endPos.x, targets.y, seg.endPos.y))
								end
								if meowdelay <= game.time and not player.buff["rakanerecast"] then
									if targets.pos:dist(ally.pos) < player.pos:dist(targets.pos) then
										if player:spellSlot(1).state == 0 then
											player:castSpell("obj", 2, ally)
										end
									end
								end
							end
						end
						if (player.pos:dist(ally.pos) < 1000) then
							local seg = preds.circular.get_prediction(spellW, targets, ally)
							if seg and seg.startPos:dist(seg.endPos) < spellW.range - 50 then
								if player.mana > player.manaCost2 + player.manaCost1 then
									local seg = preds.circular.get_prediction(spellW, targets, ally)
									if seg and seg.startPos:dist(seg.endPos) < spellW.range then
										if meowdelay <= game.time and not player.buff["rakanerecast"] then
											if targets.pos:dist(ally.pos) < player.pos:dist(targets.pos) then
												if player:spellSlot(1).state == 0 then
													player:castSpell("obj", 2, ally)
												end
											end
										end

										if player.buff["rakanerecast"] then
											local segs = preds.circular.get_prediction(spellW, targets)
											if segs and seg.startPos:dist(segs.endPos) < spellW.range then
												player:castSpell("pos", 1, vec3(segs.endPos.x, targets.y, segs.endPos.y))
											end
										end
									end
								end
							end
						end
						if targets.pos:dist(ally.pos) > 580 then
							local seg = preds.circular.get_prediction(spellW, targets)
							if seg and seg.startPos:dist(seg.endPos) < spellW.range then
								player:castSpell("pos", 1, vec3(seg.endPos.x, targets.y, seg.endPos.y))
							end
						end
					end
				end
			end
		end
		if target and target.isVisible then
			local seg = preds.circular.get_prediction(spellW, target)
			if seg and seg.startPos:dist(seg.endPos) < spellW.range then
				player:castSpell("pos", 1, vec3(seg.endPos.x, target.y, seg.endPos.y))
			end
		end
	end
	if menu.combo.rcombo:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if #count_enemies_in_range(player.pos, 1000) >= menu.combo.hitr:get() then
					if (target.health / target.maxHealth) * 100 <= menu.combo.hpr:get() then
						player:castSpell("self", 3)
					end
				end
			end
		end
	end
end

local allow = true
local timer = 0
local function OnTick()
	if menu.combo.blockaa:get() then
		if player.buff["rakanr"] then
			orb.core.set_pause_attack(math.huge)
		else
			orb.core.set_pause_attack(0)
		end
	end
	if menu.engage:get() then
		local target = GetTargetQE()
		local targets = GetTargetXayah()
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if
				ally and not ally.isDead and ally.isTargetable and ally ~= player and ally.isVisible and
					ally.pos:dist(player.pos) <= spellE.range + spellW.range
			 then
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						if (player.pos:dist(ally.pos) < spellE.range) then
							local seg = preds.circular.get_prediction(spellW, target, ally)
							if seg and seg.startPos:dist(seg.endPos) < spellW.range - 50 then
								if player.mana > player.manaCost2 + player.manaCost1 then
									local seg = preds.circular.get_prediction(spellW, target, ally)
									if seg and seg.startPos:dist(seg.endPos) < spellW.range then
										if delayyyyyyyyy <= game.time then
											player:castSpell("obj", 2, ally)
										end
										if player.buff["rakanerecast"] then
											local segs = preds.circular.get_prediction(spellW, target)
											if segs and seg.startPos:dist(segs.endPos) < spellW.range then
												player:castSpell("pos", 1, vec3(segs.endPos.x, target.y, segs.endPos.y))
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
		for z, ally in ipairs(allies) do
			if
				ally and not ally.isDead and ally.isTargetable and ally ~= player and ally.isVisible and ally.charName == "Xayah" and
					ally.pos:dist(player.pos) <= 1000 + spellW.range
			 then
				if targets and targets.isVisible then
					if common.IsValidTarget(targets) then
						if (player.pos:dist(ally.pos) < 1000) then
							local seg = preds.circular.get_prediction(spellW, targets, ally)
							if seg and seg.startPos:dist(seg.endPos) < spellW.range - 50 then
								if player.mana > player.manaCost2 + player.manaCost1 then
									local seg = preds.circular.get_prediction(spellW, targets, ally)
									if seg and seg.startPos:dist(seg.endPos) < spellW.range then
										if delayyyyyyyyy <= game.time then
											player:castSpell("obj", 2, ally)
										end
										if player.buff["rakanerecast"] then
											local segs = preds.circular.get_prediction(spellW, targets)
											if segs and seg.startPos:dist(segs.endPos) < spellW.range then
												player:castSpell("pos", 1, vec3(segs.endPos.x, targets.y, segs.endPos.y))
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
	if menu.wflash:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		local target = GetTargetWFlash()
		if target and target.isVisible then
			if (FlashSlot and player:spellSlot(FlashSlot).state and player:spellSlot(FlashSlot).state == 0) then
				if target.pos:dist(player.pos) > spellW.range then
					local direction = (target.pos - player.pos):norm()
					local extendedPos = player.pos + direction * 410
					local seg = preds.circular.get_prediction(spellW, target, vec2(extendedPos.x, extendedPos.z))
					if seg and seg.startPos:dist(seg.endPos) < spellW.range then
						player:castSpell("pos", FlashSlot, target.pos)

						player:castSpell("pos", 1, vec3(seg.endPos.x, target.y, seg.endPos.y))
						if menu.wf:get() then
							player:castSpell("self", 3)
						end
					end
				end
			end
		end
	end
	if meowmeow >= game.time and cancelq == true and menu.combo.wcancel:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				local seg = preds.linear.get_prediction(spellQ, target)
				if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
					if not preds.collision.get_prediction(spellQ, seg, target) then
						player:castSpell("pos", 0, vec3(seg.endPos.x, target.y, seg.endPos.y))
					end
				end
			end
		end
	end
	if menu.flee.fleekey:get() then
		player:move(vec3(mousePos.x, mousePos.y, mousePos.z))
		if menu.flee.eflee:get() then
			local allies = common.GetAllyHeroes()
			for z, ally in ipairs(allies) do
				if ally and ally ~= player and ally.pos:dist(mousePos) < 300 then
					player:castSpell("obj", 2, ally)
				end
			end
		end
		if menu.flee.rflee:get() then
			player:castSpell("self", 3)
		end
	end

	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end

	if not player.isRecalling then
		if menu.SpellsMenu.cc:get() then
			local allies = common.GetAllyHeroes()
			for z, ally in ipairs(allies) do
				if ally then
					if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
						if
							(ally.buff[5] or ally.buff[8] or ally.buff[24] or ally.buff[23] or ally.buff[11] or ally.buff[22] or ally.buff[8] or
								ally.buff[21])
						 then
							if ally.pos:dist(player.pos) <= spellE.range then
								if ally.charName == "Xayah" and ally.pos:dist(player.pos) <= 1000 then
									player:castSpell("obj", 2, ally)
								end
								player:castSpell("obj", 2, ally)
							end
						end
					end
				end
			end
		end
		if menu.SpellsMenu.enable:get() then
			for i = 1, #evade.core.active_spells do
				local spell = evade.core.active_spells[i]

				local allies = common.GetAllyHeroes()
				for z, ally in ipairs(allies) do
					if ally then
						if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
							if spell.data.spell_type == "Target" and spell.target == ally then
								if menu.SpellsMenu.targeteteteteteed:get() then
									if ally.charName == "Xayah" and ally.pos:dist(player.pos) <= 1000 then
										player:castSpell("obj", 2, ally)
									end
									if ally.pos:dist(player.pos) <= spellE.range then
										player:castSpell("obj", 2, ally)
									end
								end
							elseif
								spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0 and
									(not spell.data.collision or #spell.data.collision == 0)
							 then
								for _, k in pairs(database) do
									if
										spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
											menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
									 then
										if ally.charName == "Xayah" and ally.pos:dist(player.pos) <= 1000 then
											if spell.missile then
												if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.3) then
													if ally.pos:dist(player.pos) <= 1000 then
														player:castSpell("obj", 2, ally)
													end
												end
											end
											if k.speed == math.huge or spell.data.spell_type == "Circular" then
												if ally.pos:dist(player.pos) <= 1000 then
													player:castSpell("obj", 2, ally)
												end
											end
										end
										if ally.pos:dist(player.pos) <= spellE.range then
											if spell.missile then
												if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.3) then
													if ally.pos:dist(player.pos) <= spellE.range then
														player:castSpell("obj", 2, ally)
													end
												end
											end
											if k.speed == math.huge or spell.data.spell_type == "Circular" then
												if ally.pos:dist(player.pos) <= spellE.range then
													player:castSpell("obj", 2, ally)
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
end

local function OnDraw()
	--print("Drawing")
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
		if menu.draws.drawflash:get() then
			graphics.draw_circle(player.pos, spellW.range + 410, 2, graphics.argb(255, 255, 182, 193), 100)
		end
		if menu.draws.drawengage:get() then
			graphics.draw_circle(player.pos, spellW.range + spellE.range, 2, graphics.argb(255, 255, 182, 193), 100)
		end
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
