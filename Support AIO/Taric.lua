local version = "1.0"
local evade = module.seek("evade")
local avada_lib = module.lib("avada_lib")
local database = module.load("SupportAIO" .. player.charName, "SpellDatabase")
if not avada_lib then
	console.set_color(12)
	print("You need to have Avada Lib in your community_libs folder to run 'Bra by Kornis'!")
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
	range = 325
}

local spellW = {
	range = 800
}

local spellE = {
	range = 600,
	width = 50,
	speed = 3000,
	delay = 0.25,
	boundingRadiusMod = 1
}

local spellR = {
	range = 400
}

local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local tSelector = avada_lib.targetSelector
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Taric")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use E in Combo", true)
menu.combo:boolean("eally", " ^- Use E from Ally", true)
menu.combo:boolean("priorityme", "Priority E from Me", true)
menu.combo:keybind("semir", "Semi-R Key", "T", nil)
menu.combo:header("hello", " ^- Move Mouse on it to read what it does.")
menu.combo.semir:set("tooltip", "On Press finds the best Position to Ult the most with W.")

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use E in harass", true)
menu.harass:boolean("eally", " ^- Use E from Ally", true)
menu.harass:boolean("priorityme", "Priority E from Me", true)

menu:menu("wpriority", "Healing")
menu.wpriority:boolean("enable", "Enable Auto Q", true)
menu.wpriority:slider("mana", "Mana Manager", 20, 1, 100, 5)
menu.wpriority:header("uhhh", " -- Settings -- ")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	menu.wpriority:boolean(allies.charName, "Heal: " .. allies.charName, true)
	menu.wpriority:slider(allies.charName .. "hp", " ^- Health Percent: ", 50, 1, 100, 1)
end

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", false)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)

menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("draweally", "Draw E Range from Allies", true)
menu.draws:boolean("drawwmax", "Draw W Max Range", true)
menu:menu("miscc", "Misc.")
menu.miscc:menu("misc", "Anti-Gapclose Settings")
menu.miscc.misc:boolean("GapA", "Use E for Anti-Gapclose", true)
menu.miscc.misc:menu("blacklist", "Anti-Gapclose Blacklist")

local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.miscc.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("SpellsMenu", "Shielding")
menu.SpellsMenu:boolean("enable", "Enable Shielding", true)
menu.SpellsMenu:boolean("priority", "Priority Ally", true)
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
menu:header("hello", " -- Key Settings -- ")
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
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
local PSpells = {
	"CaitlynHeadshotMissile",
	"RumbleOverheatAttack",
	"JarvanIVMartialCadenceAttack",
	"ShenKiAttack",
	"MasterYiDoubleStrike",
	"sonahymnofvalorattackupgrade",
	"sonaariaofperseveranceupgrade",
	"sonasongofdiscordattackupgrade",
	"NocturneUmbraBladesAttack",
	"NautilusRavageStrikeAttack",
	"ZiggsPassiveAttack",
	"QuinnWEnhanced",
	"LucianPassiveAttack",
	"SkarnerPassiveAttack",
	"KarthusDeathDefiedBuff",
	"GarenQAttack",
	"KennenMegaProc",
	"MordekaiserQAttack",
	"MordekaiserQAttack2",
	"BlueCardPreAttack",
	"RedCardPreAttack",
	"GoldCardPreAttack",
	"XenZhaoThrust",
	"XenZhaoThrust2",
	"XenZhaoThrust3",
	"ViktorQBuff",
	"TrundleQ",
	"RenektonSuperExecute",
	"RenektonExecute",
	"GarenSlash2",
	"frostarrow",
	"SivirWAttack",
	"rengarnewpassivebuffdash",
	"YorickQAttack",
	"ViEAttack",
	"SejuaniBasicAttackW",
	"ShyvanaDoubleAttackHit",
	"ShenQAttack",
	"SonaEAttackUpgrade",
	"SonaWAttackUpgrade",
	"SonaQAttackUpgrade",
	"PoppyPassiveAttack",
	"NidaleeTakedownAttack",
	"NasusQAttack",
	"KindredBasicAttackOverrideLightbombFinal",
	"LeonaShieldOfDaybreakAttack",
	"KassadinBasicAttack3",
	"JhinPassiveAttack",
	"JayceHyperChargeRangedAttack",
	"JaycePassiveRangedAttack",
	"JaycePassiveMeleeAttack",
	"illaoiwattack",
	"hecarimrampattack",
	"DrunkenRage",
	"GalioPassiveAttack",
	"FizzWBasicAttack",
	"FioraEAttack",
	"EkkoEAttack",
	"ekkobasicattackp3",
	"MasochismAttack",
	"DravenSpinningAttack",
	"DianaBasicAttack3",
	"DariusNoxianTacticsONHAttack",
	"CamilleQAttackEmpowered",
	"CamilleQAttack",
	"PowerFistAttack",
	"AsheQAttack",
	"jinxqattack",
	"jinxqattack2",
	"KogMawBioArcaneBarrage"
}
local blade = {}
local function DeleteObj(object)
	if object and object.name:find("W_buff_indicator") then
		blade[object.ptr] = nil
	end
end
local function CreateObj(object)
	if object and object.name:find("W_buff_indicator") then
		local enemy = common.GetAllyHeroes()
		for i, allies in ipairs(enemy) do
			if allies then
				if allies.pos:dist(object.pos) < 50 then
					blade[object.ptr] = object
				end
			end
		end
	end
end
local function AutoInterrupt(spell)
	if menu.SpellsMenu.targeteteteteteed:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally then
				if not menu.SpellsMenu.blacklist[ally.charName]:get() then
					if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
						if not spell.name:find("crit") then
							if not spell.name:find("BasicAttack") then
								if menu.SpellsMenu.targeteteteteteed:get() then
									if ally.pos:dist(player.pos) <= spellW.range then
										player:castSpell("obj", 1, ally)
									end
								end
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
			if ally and ally.pos:dist(player.pos) <= spellW.range then
				if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					for i = 1, #PSpells do
						if spell.name:lower():find(PSpells[i]:lower()) then
							if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
								if not menu.SpellsMenu.blacklist[ally.charName]:get() then
									if ally.pos:dist(player.pos) <= spellW.range then
										player:castSpell("obj", 1, ally)
									end
								end
							end
						end
					end
					if spell.name:find("BasicAttack") then
						if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if ally.pos:dist(player.pos) <= spellW.range then
									player:castSpell("obj", 1, ally)
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
			if ally and ally.pos:dist(player.pos) <= spellW.range then
				if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if spell.name:find("crit") then
						if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.crithp:get() then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if ally.pos:dist(player.pos) <= spellW.range then
									player:castSpell("obj", 1, ally)
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
			if ally and ally.pos:dist(player.pos) <= spellE.range then
				if spell.owner.type == TYPE_MINION and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.minionhp:get() then
						if not menu.SpellsMenu.blacklist[ally.charName]:get() then
							if ally.pos:dist(player.pos) <= spellW.range then
								player:castSpell("obj", 1, ally)
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
			if ally and ally.pos:dist(player.pos) <= spellW.range then
				if spell.owner.type == TYPE_TURRET and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if not menu.SpellsMenu.blacklist[ally.charName]:get() then
						if ally.pos:dist(player.pos) <= spellW.range then
							player:castSpell("obj", 1, ally)
						end
					end
				end
			end
		end
	end
end

local TargetSelectionE = function(res, obj, dist)
	if dist < spellE.range then
		res.obj = obj
		return true
	end
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
end

local TargetSelectionE2 = function(res, obj, dist)
	if dist < spellE.range + 100 then
		res.obj = obj
		return true
	end
end
local GetTargetE2 = function()
	return TS.get_result(TargetSelectionE2).obj
end

local TargetSelectionWQ = function(res, obj, dist)
	if dist < spellW.range + spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetWQ = function()
	return TS.get_result(TargetSelectionWQ).obj
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
local TargetSelectionR = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end
local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
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
	if player.path.isActive then
		if menu.harass.priorityme:get() then
			if menu.harass.qcombo:get() then
				local target = GetTargetE2()
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						local pos = preds.linear.get_prediction(spellE, target)
						if target.pos:dist(player.path.point[1]) < target.pos:dist(player.path.point[0]) then
							if pos and pos.startPos:dist(pos.endPos) < spellE.range + 100 then
								if not evade.core.is_active() then
									player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
				if menu.harass.eally:get() then
					for i = 0, objManager.enemies_n - 1 do
						local enemies = objManager.enemies[i]
						if
							enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
								player.pos:dist(enemies) < 1200 + spellE.range and
								enemies.pos:dist(player.pos) > spellE.range
						 then
							local allies = common.GetAllyHeroes()
							for z, ally in ipairs(allies) do
								if ally then
									if ally.pos:dist(player.pos) < 1200 and ally.buff["taricwallybuff"] then
										local pos = preds.linear.get_prediction(spellE, enemies, ally)
										if target.pos:dist(player.path.point[1]) < target.pos:dist(player.path.point[0]) then
											if pos and pos.startPos:dist(pos.endPos) < spellE.range + 100 then
												player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
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
		if not menu.harass.priorityme:get() then
			if menu.harass.qcombo:get() then
				if menu.harass.eally:get() then
					for i = 0, objManager.enemies_n - 1 do
						local enemies = objManager.enemies[i]
						if
							enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
								player.pos:dist(enemies) < 1200 + spellE.range and
								enemies.pos:dist(player.pos) > spellE.range
						 then
							local allies = common.GetAllyHeroes()
							for z, ally in ipairs(allies) do
								if ally then
									if ally.pos:dist(player.pos) < 1200 and ally.buff["taricwallybuff"] then
										local pos = preds.linear.get_prediction(spellE, enemies, ally)
										if enemies.pos:dist(player.path.point[1]) < enemies.pos:dist(player.path.point[0]) then
											if pos and pos.startPos:dist(pos.endPos) < spellE.range + 100 then
												player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
							end
						end
					end
				end
				local target = GetTargetE2()
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						local pos = preds.linear.get_prediction(spellE, target)
						if target.pos:dist(player.path.point[1]) < target.pos:dist(player.path.point[0]) then
							if pos and pos.startPos:dist(pos.endPos) < spellE.range + 100 then
								if not evade.core.is_active() then
									player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end
	if menu.harass.priorityme:get() then
		if menu.harass.qcombo:get() then
			local target = GetTargetE()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					local pos = preds.linear.get_prediction(spellE, target)
					if pos and pos.startPos:dist(pos.endPos) < spellE.range then
						if not evade.core.is_active() then
							player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.harass.eally:get() then
				for i = 0, objManager.enemies_n - 1 do
					local enemies = objManager.enemies[i]
					if
						enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
							player.pos:dist(enemies) < 1200 + spellE.range and
							enemies.pos:dist(player.pos) > spellE.range
					 then
						local allies = common.GetAllyHeroes()
						for z, ally in ipairs(allies) do
							if ally then
								if ally.pos:dist(player.pos) < 1200 and ally.buff["taricwallybuff"] then
									local pos = preds.linear.get_prediction(spellE, enemies, ally)

									if pos and pos.startPos:dist(pos.endPos) < spellE.range then
										player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if not menu.harass.priorityme:get() then
		if menu.harass.qcombo:get() then
			if menu.harass.eally:get() then
				for i = 0, objManager.enemies_n - 1 do
					local enemies = objManager.enemies[i]
					if
						enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
							player.pos:dist(enemies) < 1200 + spellE.range and
							enemies.pos:dist(player.pos) > spellE.range
					 then
						local allies = common.GetAllyHeroes()
						for z, ally in ipairs(allies) do
							if ally then
								if ally.pos:dist(player.pos) < 1200 and ally.buff["taricwallybuff"] then
									local pos = preds.linear.get_prediction(spellE, enemies, ally)

									if pos and pos.startPos:dist(pos.endPos) < spellE.range then
										player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
			end
			local target = GetTargetE()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					local pos = preds.linear.get_prediction(spellE, target)
					if pos and pos.startPos:dist(pos.endPos) < spellE.range then
						if not evade.core.is_active() then
							player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
	end
end

local function Combo()
	if player.path.isActive then
		if menu.combo.priorityme:get() then
			if menu.combo.qcombo:get() then
				local target = GetTargetE2()
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						local pos = preds.linear.get_prediction(spellE, target)
						if target.pos:dist(player.path.point[1]) < target.pos:dist(player.path.point[0]) then
							if pos and pos.startPos:dist(pos.endPos) < spellE.range + 100 then
								if not evade.core.is_active() then
									player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
				if menu.combo.eally:get() then
					for i = 0, objManager.enemies_n - 1 do
						local enemies = objManager.enemies[i]
						if
							enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
								player.pos:dist(enemies) < 1200 + spellE.range and
								enemies.pos:dist(player.pos) > spellE.range
						 then
							local allies = common.GetAllyHeroes()
							for z, ally in ipairs(allies) do
								if ally then
									if ally.pos:dist(player.pos) < 1200 and ally.buff["taricwallybuff"] then
										local pos = preds.linear.get_prediction(spellE, enemies, ally)
										if target.pos:dist(player.path.point[1]) < target.pos:dist(player.path.point[0]) then
											if pos and pos.startPos:dist(pos.endPos) < spellE.range + 100 then
												player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
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
		if not menu.combo.priorityme:get() then
			if menu.combo.qcombo:get() then
				if menu.combo.eally:get() then
					for i = 0, objManager.enemies_n - 1 do
						local enemies = objManager.enemies[i]
						if
							enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
								player.pos:dist(enemies) < 1200 + spellE.range and
								enemies.pos:dist(player.pos) > spellE.range
						 then
							local allies = common.GetAllyHeroes()
							for z, ally in ipairs(allies) do
								if ally then
									if ally.pos:dist(player.pos) < 1200 and ally.buff["taricwallybuff"] then
										local pos = preds.linear.get_prediction(spellE, enemies, ally)
										if enemies.pos:dist(player.path.point[1]) < enemies.pos:dist(player.path.point[0]) then
											if pos and pos.startPos:dist(pos.endPos) < spellE.range + 100 then
												player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
											end
										end
									end
								end
							end
						end
					end
				end
				local target = GetTargetE2()
				if target and target.isVisible then
					if common.IsValidTarget(target) then
						local pos = preds.linear.get_prediction(spellE, target)
						if target.pos:dist(player.path.point[1]) < target.pos:dist(player.path.point[0]) then
							if pos and pos.startPos:dist(pos.endPos) < spellE.range + 100 then
								if not evade.core.is_active() then
									player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end
	if menu.combo.priorityme:get() then
		if menu.combo.qcombo:get() then
			local target = GetTargetE()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					local pos = preds.linear.get_prediction(spellE, target)
					if pos and pos.startPos:dist(pos.endPos) < spellE.range then
						if not evade.core.is_active() then
							player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.combo.eally:get() then
				for i = 0, objManager.enemies_n - 1 do
					local enemies = objManager.enemies[i]
					if
						enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
							player.pos:dist(enemies) < 1200 + spellE.range and
							enemies.pos:dist(player.pos) > spellE.range
					 then
						local allies = common.GetAllyHeroes()
						for z, ally in ipairs(allies) do
							if ally then
								if ally.pos:dist(player.pos) < 1200 and ally.buff["taricwallybuff"] then
									local pos = preds.linear.get_prediction(spellE, enemies, ally)

									if pos and pos.startPos:dist(pos.endPos) < spellE.range then
										player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if not menu.combo.priorityme:get() then
		if menu.combo.qcombo:get() then
			if menu.combo.eally:get() then
				for i = 0, objManager.enemies_n - 1 do
					local enemies = objManager.enemies[i]
					if
						enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and
							player.pos:dist(enemies) < 1200 + spellE.range and
							enemies.pos:dist(player.pos) > spellE.range
					 then
						local allies = common.GetAllyHeroes()
						for z, ally in ipairs(allies) do
							if ally then
								if ally.pos:dist(player.pos) < 1200 and ally.buff["taricwallybuff"] then
									local pos = preds.linear.get_prediction(spellE, enemies, ally)

									if pos and pos.startPos:dist(pos.endPos) < spellE.range then
										player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									end
								end
							end
						end
					end
				end
			end
			local target = GetTargetE()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					local pos = preds.linear.get_prediction(spellE, target)
					if pos and pos.startPos:dist(pos.endPos) < spellE.range then
						if not evade.core.is_active() then
							player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
	end
end
local function PrioritizedAllyLow()
	local besttarget = nil
	local meow = 0
	local heroTarget = nil
	for i = 0, objManager.allies_n - 1 do
		local hero = objManager.allies[i]
		if not player.isRecalling then
			if
				hero.team == TEAM_ALLY and not hero.isDead and hero.pos:dist(player.pos) <= spellW.range and
					hero.charName ~= "Taric"
			 then
				if #count_allies_in_range(hero.pos, 400) > meow then
					heroTarget = hero
					meow = #count_allies_in_range(hero.pos, 400)
				end
			end
		end
	end
	return heroTarget
end

local function OnTick()
	if menu.combo.semir:get() then
		if PrioritizedAllyLow() then
			player:castSpell("obj", 1, PrioritizedAllyLow())
			player:castSpell("self", 3)
		end
	end
	if (player.mana / player.maxMana) * 100 > menu.wpriority.mana:get() then
		if menu.wpriority.enable:get() then
			local enemy = common.GetAllyHeroes()
			for i, enemies in ipairs(enemy) do
				if
					enemies and not enemies.isDead and
						menu.wpriority[enemies.charName .. "hp"]:get() >= (enemies.health / enemies.maxHealth) * 100 and
						not enemies.isRecalling and
						menu.wpriority[enemies.charName] and
						menu.wpriority[enemies.charName]:get() and
						enemies.pos:dist(player.pos) <= spellQ.range
				 then
					player:castSpell("self", 0)
				end
			end
			for _, objsq in pairs(blade) do
				if objsq then
					local enemy = common.GetAllyHeroes()
					for i, enemies in ipairs(enemy) do
						if
							enemies and not enemies.isDead and
								menu.wpriority[enemies.charName .. "hp"]:get() >= (enemies.health / enemies.maxHealth) * 100 and
								not enemies.isRecalling and
								menu.wpriority[enemies.charName] and
								menu.wpriority[enemies.charName]:get() and
								enemies.pos:dist(objsq.pos) <= spellQ.range
						 then
							player:castSpell("self", 0)
						end
					end
				end
			end
		end
	end
	if not evade then
		print(" ")
		console.set_color(79)
		print("-----------Support AIO--------------")
		print("You need to have enabled 'Premium Evade' for Shielding Champions.")
		print("If you don't want Evade to dodge, disable dodging but keep Module enabled. :>")
		print("------------------------------------")
		console.set_color(12)
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
							if ally.pos:dist(player.pos) <= spellW.range then
								player:castSpell("obj", 1, ally)
							end
						end
					end
				end
			end
		end
		if menu.SpellsMenu.enable:get() then
			for i = 1, #evade.core.active_spells do
				local spell = evade.core.active_spells[i]
				if menu.SpellsMenu.priority:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally and ally.pos:dist(player.pos) <= spellW.range and ally ~= player then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if (spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0) then
									allow = false
								else
									allow = true
								end

								if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
									if not spell.name:find("crit") then
										if not spell.name:find("basicattack") then
											if menu.SpellsMenu.targeteteteteteed:get() then
												if ally.pos:dist(player.pos) <= spellW.range then
													player:castSpell("obj", 1, ally)
												end
											end
										end
									end
								elseif
									spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0 and
										(not spell.data.collision or #spell.data.collision == 0)
								 then
									for _, k in pairs(database) do
										if menu.SpellsMenu[k.charName] then
											if
												spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
													menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
											 then
												if ally.pos:dist(player.pos) <= spellW.range then
													if ally ~= player then
														if spell.missile then
															if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																if ally.pos:dist(player.pos) <= spellW.range then
																	player:castSpell("obj", 1, ally)
																end
															end
														end
														if spell.name:find(_:lower()) then
															if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																if ally.pos:dist(player.pos) <= spellW.range then
																	player:castSpell("obj", 1, ally)
																end
															end
														end
														if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
															if ally.pos:dist(player.pos) <= spellW.range then
																player:castSpell("obj", 1, ally)
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
					for z, ally in ipairs(allies) do
						if ally and ally == player and allow then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
									if not spell.name:find("crit") then
										if not spell.name:find("basicattack") then
											if menu.SpellsMenu.targeteteteteteed:get() then
												if ally.pos:dist(player.pos) <= spellW.range then
													player:castSpell("obj", 1, ally)
												end
											end
										end
									end
								elseif
									spell.polygon and spell.polygon:Contains(player.path.serverPos) ~= 0 and
										(not spell.data.collision or #spell.data.collision == 0)
								 then
									for _, k in pairs(database) do
										if ally == player then
											if menu.SpellsMenu[k.charName] then
												if
													spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
														menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
												 then
													if player.pos:dist(player.pos) <= spellW.range then
														if spell.missile then
															if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																player:castSpell("obj", 1, player)
															end
														end
														if spell.name:find(_:lower()) then
															if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																player:castSpell("obj", 1, player)
															end
														end
														if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
															player:castSpell("obj", 1, player)
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

				if not menu.SpellsMenu.priority:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
									if not spell.name:find("crit") then
										if not spell.name:find("basicattack") then
											if menu.SpellsMenu.targeteteteteteed:get() then
												if ally.pos:dist(player.pos) <= spellW.range then
													player:castSpell("obj", 1, ally)
												end
											end
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
											if ally.pos:dist(player.pos) <= spellW.range then
												if spell.missile then
													if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
														if ally.pos:dist(player.pos) <= spellW.range then
															player:castSpell("obj", 1, ally)
														end
													end
												end
												if spell.name:find(_:lower()) then
													if k.speeds == math.huge or spell.data.spell_type == "Circular" then
														if ally.pos:dist(player.pos) <= spellW.range then
															player:castSpell("obj", 1, ally)
														end
													end
												end
												if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
													if ally.pos:dist(player.pos) <= spellW.range then
														player:castSpell("obj", 1, ally)
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

	if menu.miscc.misc.GapA:get() then
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
				seg.startPos = player.path.serverPos2D
				seg.endPos = vec2(pred_pos.x, pred_pos.y)

				if menu.miscc.misc.blacklist[target.charName] and not menu.miscc.misc.blacklist[target.charName]:get() then
					player:castSpell("pos", 2, vec3(pred_pos.x, target.y, pred_pos.y))
				end
			end
		end
	end

	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
end
local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end

		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 100)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 100)
		end
		if menu.draws.drawwmax:get() then
			graphics.draw_circle(player.pos, 1200, 2, menu.draws.colorw:get(), 100)
		end
		if menu.draws.draweally:get() then
			local enemy = common.GetAllyHeroes()
			for i, enemies in ipairs(enemy) do
				if enemies and not enemies.isDead and enemies.buff["taricwallybuff"] and enemies.pos:dist(player.pos) < 1200 then
					graphics.draw_circle(enemies.pos, spellE.range, 2, menu.draws.colore:get(), 100)
				end
			end
		end
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
cb.add(cb.createobj, CreateObj)
cb.add(cb.deleteobj, DeleteObj)
