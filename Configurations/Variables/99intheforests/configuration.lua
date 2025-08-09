local DConfiguration = {
  ESP = {
    Players = false,
    Enemies = false,
    Childrens = false,
    Items = false,
    Chest = false,
  },

  Tracers = {}, -- lazy to finish it >:(
  
  AntiAFK = true,
  
  Humanoids = {
    WalkSpeed = 18,
    JumpPower = 50,
    InfiniteJump = false,
  },

  GameModification = {
    HitboxEnemies = false,
    HitboxSize = 10,
    FullBright = false,
    NoFog = false,
  },

  ScriptCaches = {
    Tree = {}
    Enemies = {}
  },
  
  GameAutomation = {
    KillAura = false,
    KillAuraRadius = 25,
    TreeAura = false,
    TreeAuraRadius = 25,
    AutoFeed = false,
    BringItem = false,
    BringItemType = "",
  }
}

return DConfiguration
