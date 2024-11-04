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
    if not storage.lastVersion or storage.lastVersion ~= storage.svers then
        storage.lastVersion = storage.svers

        game.surfaces[1].show_clouds = false
        STORAGE_CreateGlobal()

        BANISH_Init()
        TODO_Init()
        LOG_Init()
        ONELIFE_Init()
        LOGO_Init()

        PERMS_MakeUserGroups()
        PERMS_SetPermissions()
        
        player.force.friendly_fire = false -- friendly fire
        game.disable_replay() -- Smaller saves, prevent desync on script upgrade
    end
end
