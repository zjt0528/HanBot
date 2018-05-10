local myAIOchampions = {
  Janna = true,
  Blitzcrank = true,
  Leona = true,
  Alistar = true,
  Nami = true,
  Soraka = true,
  Brand = true,
  Lulu = true,
  Rakan = true,
  Zilean = true,
  Karma = true,
  Nautilus = true,
  Bard = true
}

return {
  id = "SupportAIO" .. player.charName,
  name = "Support AIO - " .. player.charName,
  flag = {
    text = "Support AIO by Kornis",
    color = {
      text = 0xFFEDD7E6,
      background1 = 0xFFFF69B4,
      background2 = 0x59000000
    }
  },
  load = function()
    return myAIOchampions[player.charName]
  end
}
