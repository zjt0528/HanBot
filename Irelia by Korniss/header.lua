return {
    id = 'IreliaKornis',
    name = 'Irelia',
    flag = {
      text = "Irelia by Kornis",
      color = {
        text = 0xFFEDD7E6,
        background1 = 0xFFFF69B4,
        background2 = 0x59000000,
      }
    },
    load = function()
      return player.charName == 'Irelia'
    end
}
