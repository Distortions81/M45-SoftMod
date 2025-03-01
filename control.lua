-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "banish"   -- Banish system
require "commands" -- Slash commands
require "event"    -- Event/tick handler
require "info"     -- Welcome/Info window
require "log"      -- Action logging
require "logo"     -- Spawn logo
require "onelife"  -- Hardcore / one life to live mode
require "online"   -- Players online window
require "perms"    -- Permissions system
require "storage"  -- Global variable init
require "todo"     -- To-Do-list
require "utility"  -- Widely used general utility
require "quickbar" -- Save or Restore Quickbar
require "stash" -- Save or Restore Weapon/Ammo/Armor

function RunSetup()
    storage.SM_Version = "639-01.31.2025-0326"

    storage.SM_OldVersion = storage.SM_Version

    if not storage.SM_OldVersion then
        storage.SM_OldVersion = "OldVersion"
    end

    --Only rerun on version change
    if not storage.SM_Store or storage.SM_OldVersion ~= storage.SM_Version then
        STORAGE_CreateGlobal()
        BANISH_MakeJail()
        TODO_Init()
        LOGO_DrawLogo(true)
        UTIL_MapPin()

        PERMS_MakeUserGroups()
        PERMS_SetPermissions()

        game.forces["player"].friendly_fire = false -- disable friendly fire
        game.disable_replay()                       -- Smaller saves, prevent desync on script upgrade
        game.surfaces[1].show_clouds = false
    end
end
