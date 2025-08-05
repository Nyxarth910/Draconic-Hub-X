
local DConfiguration = {
  ESP = {
    Players = false,
    Nextbots = false,
    Tickets = false,
    Objective = false,
  },

  Tracers = {
    Players = false,
    Nextbots = false,
    Tickets = false,
    Objective = false,
  },

  Boxes = {
    Players = false,
    Nextbots = false,
    Tickets = false,
    Objective = false,
  },

  Removalist = {
    CameraShake = false,
    ReducingRewards = false,
    DamageParts = false,
  },
  
  AntiAFK = true,
  AutoRespawn = false,
  RespawnType = "Spawnpoint",
  AutoWhistle = false,
  ShowTimer = false,
  Fly = false,
  FlySpeed = 20,
  Noclip = false,

  FarmingStates = {
    IsReviving = false,
    IsCollectingTickets = false,
  },

  AFKFarm = false,
  FarmTickets = false,
  FarmTokens = false,

  AntiNextbot = false,
  AntiNextbotRange = 15,
  AntiNextbotType = "Spawn",

  PlayerAdjustmentType = "Optimized",
  
  DefaultPlayerAdjustment = {
    Speed = 1500,
    JumpHeight = 3,
    JumpCap = 1,
    JumpAcceleration = 1.5,
    AirStrafe = 182,
    GroundAcceleration = 5,
  },

  ModifyPlayerAdjustment = {
    Speed = 1500,
    JumpHeight = 3,
    JumpCap = 1,
    JumpAcceleration = 1.5,
    AirStrafe = 182,
    GroundAcceleration = 5,
  },

  -- optimize pluh
  lastTick = {
    Speed = 0,
    JumpHeight = 0,
    JumpCap = 0,
    JumpAcceleration = 0,
    AirStrafe = 0,
    GroundAcceleration = 0,
  },

  Humanoids = {
    WalkspeedCF = false,
    OriginalJumpHeight = false,    
    CF = 5,
    JP = 20,
  },

  BounceAdjustment = {
    GetCurrentSpeed = 0,
    EnableBounce = false,
    DefaultBounce = 80,
    EmoteBounce = 120,
  },

  CameraAdjustment = {
    StretchX = 1,
    StretchY = 1,
  },

  GunAdjustment = {
    v = nil,
  },

  GameAutomation = {
    InstantRevive = false,
    ReviveWhileEmote = false,
    ReviveDelay = 0.1,
    AutoCarry = false,
    CarryWhileEmote = false,
    AutoCarryKey = false,
    MacroMode = false,
    MacroKey = false,
    SelectedEmote = "BoldMarch",
  },

  MovementModification = {
    FakeEmoteDash = false,
    EmoteSpeed = 2000,
    InfiniteSlide = false,
    SlideAcceleration = -3,
    GavityToggle = false,
    GravityKey = false,
    Gravity = 10,
    BHOPType = "Acceleration",
    BHOPAcceleration = -0.1,
    BHOPEnable = false,
    BHOPJumpButton = false,
    BHOPKeybind = false,
    BHOPDelay = 0.01,
    DisableBHOPUncap = false,
    HipHeight1 = 0,
    HipHeight2 = 0,
    LagSwitchFPSCap = "1",
    LagSwitchDelay = 0.1,
  },

  AntiLags = {
    Low = false,
    Moderate = false,
    High = false,
  },

  Visual = {
    OriginalCosmestics = {
      [1] = "",
      [2] = "",
      [3] = "",
      [4] = "",
    },

    ModifyCosmestics = {
      [1] = "",
      [2] = "",
      [3] = "",
      [4] = "",
    },

    OriginalEmotes = {
      [1] = "",
      [2] = "",
      [3] = "",
      [4] = "",
      [5] = "",
      [6] = "",
    },

    ModifyEmotes = {
      [1] = "",
      [2] = "",
      [3] = "",
      [4] = "",
      [5] = "",
      [6] = "",
    },
  }

  
}


return DConfiguration
