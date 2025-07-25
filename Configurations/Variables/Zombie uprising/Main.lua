local DConfiguration = {

  GunMods = {
    FastFire = false,
    Firerate = 1000,
    NoReload = false,
    InstantReload = false,
    NoRecoil = false,
  }

  KnifeMods = {
    FastSwinging = false,    
  }

  GameAutomations = {
    AutoRestoreAmmo = false,
    SelectRestoreSection = "Primary",
    AutoUpgrade = false,
    AutoRevivePlayers = false,
  }

  AntiAFK = true,

  Humanoids = {
    GodMode = false,
    Walkspeed = 16,
    JumpPower = 50,
  }

  Fly = false,
  FlySpeed = 20,
  NoClip = false,

  AutoFarm = {
    Height = 5,
    Zombies = false,
    Boss = false,
    Hordes = false,
    PowerUps = false,
    CarePackage = false,
    EventRewards = false,
    
    AutoCases = {
      OpenCases = false,
      SelectedCases = "Bronze Cases",
      Amount = "One",
    }    
  }

  GameplayModification = {
    KillAura = false,
    KillAuraRange = 500,
    SilentAim = {
      Zombies = false,
      Bosses = false,
      Tertiary = false,
      Wallbang = false,
      FOVSize = 250,
    }

    HitPart = {
      Enabled = false,
      Zombies = false,
      Bosses = false,
      Ranges = 30,
    }

    ESP = {
      Zombies = false,
      Bosses = false,
      Players = false,
    }

    Tracers = {
      Zombies = false,
      Bosses = false,
      Players = false,
    }

    Boxes = {
      Zombies = false,
      Bosses = false,
      Players = false,
    }
  }

  DataModification = {
    Loadout = {
      Primary = "",
      Secondary = "",
      Tertiary = "",
      Melee = "",
      Perks = "",
      Grenade = "",
    }
  }

   Attachments = {
     LoadoutSections = 1,
     Ammunition = "",
     Optics = "",
     Side = "",
     Capacity = "",
     Barrel = "",
     Grip = "",
   }

   GunSkinChanger = {
    GunName = "",
    Skin1 = "",
    Skin2 = "",
   }

   AvatarModification = {
     AvatarSection = 1,
     Waist = 0,
     Hat = 0,
     Shoulder = 0,
     Neck = 0,
   } 

}

return DConfiguration
