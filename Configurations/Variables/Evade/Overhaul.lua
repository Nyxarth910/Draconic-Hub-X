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

  Removals = {
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
  
  PlayerAdjustment = {
  	Type = "Optimized",
  
      Default = {
      	Speed = 1500,
        JumpHeight = 3,
        JumpCap = 1,
        JumpAcceleration = 1.5,
        AirStrafe = 182,
        GroundAcceleration = 5,
      },
      
      Update = {
      	Speed = 1500,
        JumpHeight = 3,
        JumpCap = 1,
        JumpAcceleration = 1.5,
        AirStrafe = 182,
        GroundAcceleration = 5,
      },

	  Saved = {
      	Speed = 1500,
        JumpHeight = 3,
        JumpCap = 1,
        JumpAcceleration = 1.5,
        AirStrafe = 182,
        GroundAcceleration = 5,
      },
      
      Tick = {
      	Speed = 0,
        JumpHeight = 0,
        JumpCap = 0,
        JumpAcceleration = 0,
        AirStrafe = 0,
        GroundAcceleration = 0,
      },
      
      Debounce = {
      	Speed = false,
        JumpHeight = false,
        JumpCap = false,
        JumpAcceleration = false,
        AirStrafe = false,
        GroundAcceleration = false,
      },
  },

  Humanoids = {
    WalkspeedCF = false,
    OriginalJumpHeight = false,    
    CF = 5,
    JP = 20,
  },

  Utilities = {
    GetCurrentSpeed = 0,
    BounceModification = {
	    Enabled = false,
	    DefaultBounce = 80,
	    EmoteBounce = 120,
	    SuperBounce = false,
	    SuperBounceStrength = -50,
	},
	
	LagSwitch = {
		FPSMinimum = "1",
		Delay = 0.1,
	},
  },

  CameraAdjustment = {
    StretchX = 1,
    StretchY = 1,
  },

  GunAdjustment = {
    v = nil,
  },

  GameAutomation = {
    Revive = {
    	Enabled = false,
        FloatingButton = false,
        Keybind = false,
        WhileEmote = false,
        Delay = 0.1,
    },
    
    Carry = {
    	Enabled = false,
        FloatingButton = false,
        Keybind = false,
        WhileEmote = false,
    },
    
    Macro = {
    	SelectedEmote = "BoldMarch",
		FloatingButton = false,
		Keybind = false,
    },
  },

  MovementModification = {
    FakeEmoteDash = {
        Enabled = false,
    	Type = "Blatant",
        Speed = 3000,
        Acceleration = -2,
    },
    
    SlideModification = {
    	FloatingButton = false,
        Enabled = false,
        Acceleration = -3,
    },
    
    Gravity = {
	    FloatingButton = false,
	    Keybind = false,
	    Value = 10,
    },
    
    BHOP = {
        Enabled = false,
        FloatingButton = false,
        JumpButton = false,
	    HipHeight1 = 0,
	    HipHeight2 = 0,
		Type = "Acceleration",
		JumpType = "Simulated",
		Acceleration = -0.1,
		lastTick = 0.01,
		
		Crouch = {
	 	   FloatingButton = false,
			Type = "Ground",
			lastTick = 0.1,
			lastReleaseTick = 0.1,
		},
     },
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
  },

  Settings = {
    GuiScale = {
      SuperBounce = 0,
      AutoCarry = 0,
      InstantRevive = 0,
      AutoEmoteDash = 0,
      Gravity = 0,
      SprintSlide = 0,
      AutoJump = 0,
      AutoCrouch = 0,
      LagSwitch = 0,
    },
  }
}

return DConfiguration
