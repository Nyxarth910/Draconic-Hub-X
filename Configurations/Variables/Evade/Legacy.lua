
local DConfiguration = {
  ESP = {
    Players = false,
    Nextbots = false,
    Objective = false,
  },

  Tracers = {
    Players = false,
    Nextbots = false,
    Objective = false,
  },

  Boxes = {
    Players = false,
    Nextbots = false,
    Objective = false,
  },

  Removalist = {
    CameraShake = false,
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
  },

  AFKFarm = false,
  FarmTokens = false,

  AntiNextbot = false,
  AntiNextbotRange = 15,
  AntiNextbotType = "Spawn",
  
  DefaultPlayerAdjustment = {
    Speed = 1500,
    JumpHeight = 3,
    AirStrafe = 182,
    GroundAcceleration = 1,
  },

  ModifyPlayerAdjustment = {
    Speed = 1500,
    JumpHeight = 3,
    AirStrafe = 182,
    GroundAcceleration = 1,
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

  GameAutomation = {
    MacroMode = false,
    SelectedEmotePrimary = 1,
  },

  MovementModification = {
    FakeEmoteDash = false,
    FakeEmoteDash2 = false,
    EmoteSpeed = 2000,
    GavityToggle = false,
    Gravity = 10,
    BHOPType = "Acceleration",
    BHOPAcceleration = 1,
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

  -- idk if the visual is fe in legacy
  Visual = {
    OriginalCosmetics = {
      [1] = "",
    }

    ModifyCosmetics = {
      [1] = "",
    }

    OriginalEmotes = {
      [1] = "",
    }

    ModifyEmotes = {
      [1] = "",
    }
  }

  
}


return DConfiguration
