
local avada_lib = module.lib("avada_lib")
if not avada_lib then
	print("")
	console.set_color(79)
	print("                                                                                        ")
	print("-----------  " .. player.charName .. " - ( Support AIO by Kornis )  ------------        ")
	print("You need to have Avada Lib in your community_libs folder to run this script!            ")
	print("You can find it here:                                                                   ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                               ")
	console.set_color(79)
	print("                                                                                        ")
	console.set_color(12)
	local menuerror = menu("SupportAIO" .. player.charName, "Support AIO - " .. player.charName)
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
elseif avada_lib.version < 1 then
	print("")
	console.set_color(79)
	print("                                                                                        ")
	print("-----------  " .. player.charName .. " - ( Support AIO by Kornis )  ------------        ")
	print("You need to have Avada Lib in your community_libs folder to run this script!            ")
	print("You can find it here:                                                                   ")
	console.set_color(78)
	print("https://git.soontm.net/avada/avada_lib/archive/master.zip                               ")
	console.set_color(79)
	print("                                                                                        ")
	console.set_color(12)
	local menuerror = menu("SupportAIO" .. player.charName, "Support AIO - " .. player.charName)
	menuerror:header("error", "ERROR: You need Avada Lib! Check Console.")
	return
end

if player.charName == "Janna" then
	module.load("SupportAIO" .. player.charName, "Janna")
end
if player.charName == "Blitzcrank" then
	module.load("SupportAIO" .. player.charName, "Blitzcrank")
end
if player.charName == "Leona" then
	module.load("SupportAIO" .. player.charName, "Leona")
end
if player.charName == "Alistar" then
	module.load("SupportAIO" .. player.charName, "Alistar")
end
if player.charName == "Nami" then
	module.load("SupportAIO" .. player.charName, "Nami")
end
if player.charName == "Soraka" then
	module.load("SupportAIO" .. player.charName, "Soraka")
end
if player.charName == "Brand" then
	module.load("SupportAIO" .. player.charName, "Brand")
end
if player.charName == "Lulu" then
	module.load("SupportAIO" .. player.charName, "Lulu")
end
if player.charName == "Rakan" then
	module.load("SupportAIO" .. player.charName, "Rakan")
end
if player.charName == "Zilean" then
	module.load("SupportAIO" .. player.charName, "Zilean")
end
if player.charName == "Karma" then
	module.load("SupportAIO" .. player.charName, "Karma")
end
if player.charName == "Nautilus" then
	module.load("SupportAIO" .. player.charName, "Nautilus")
end
if player.charName == "Bard" then
	module.load("SupportAIO" .. player.charName, "Bard")
end
if player.charName == "Braum" then
	module.load("SupportAIO" .. player.charName, "Braum")
end
if player.charName == "Taric" then
	module.load("SupportAIO" .. player.charName, "Taric")
end


