-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "banish" -- Banish system
require "commands" -- Slash commands
require "event" -- Event/tick handler
require "storage" -- Global variable init
require "info" -- Welcome/Info window
require "log" -- Action logging
require "logo" -- Spawn logo
require "online" -- Players online window
require "perms" -- Permissions system
require "todo" -- To-Do-list
require "utility" -- Widely used general utility
require "reset" -- Time until map reset


function RunSetup()

    --Handle first run
    if not storage.SM_Version then
        storage.SM_Version = "NewVersion"
    end
    if not storage.SM_OldVersion then
        storage.SM_OldVersion = "OldVersion"
    end

    --Only rerun on version change
    if not storage.SM_OldVersion or storage.SM_OldVersion ~= storage.SM_Version then
        storage.SM_OldVersion = storage.SM_Version

        STORAGE_CreateGlobal()
        TODO_Init()
        ONELIFE_Init()
        LOGO_DrawLogo(true)

        PERMS_MakeUserGroups()
        PERMS_SetPermissions()
        
        game.forces["player"].friendly_fire = false -- disable friendly fire
        game.disable_replay() -- Smaller saves, prevent desync on script upgrade
        game.surfaces[1].show_clouds = false
    end
end
