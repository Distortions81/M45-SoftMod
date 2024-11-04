-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
-- Create storage, if needed
function STORAGE_CreateGlobal()
    storage.SM_Version = "624-11.02.2024-1043p"

    if not storage.PData then
        storage.PData = {}
    end
    if not storage.SM_Store then
        storage.SM_Store = {
            --Map resets
            resetDuration = "",
            resetDate = "",

            --Perms
            restrictNew = false,

            --Credits
            patreonCredits = {},
            nitroCredits = {},

            --Banish
            votes = {},
            sendToSurface = {},

            --Game Modes
            noBlueprints = false,
            oneLifeMode = false,
            cheats = false,

            --Player Groups
            defaultGroup = nil,
            membersGroup = nil,
            vetsGroup = nil,
            modsGroup = nil,

            --Players Online
            onlineCache = "",
            pcount = 0,
            tcount = 0,
            playerList = "",

            --Spawn Logo
            redrawLogo = true,
            spawnLogo = nil,
            spawnLight = nil,
            spawnText = nil,
            serverName = "",

            --Tick divider
            tickDiv = 0
        }
    end
end

-- Create player storage, if needed
function STORAGE_MakePlayerStorage(player)
    if not storage.PData[player.index] then
        storage.PData[player.index] = {
            --score
            active = false,
            moving = false,
            score = 0,
            banished = 0,
            lastOnline = game.tick,

            --prefs
            hideClock = false,

            --state
            cleaned = false,
            patreon = false,
            nitro = false,

            --throttle
            regAttempts = 0,
            lastWarned = 0,
            reports = 0,
            permDeath = 0,

            --online menu
            online_submenu_target = nil,
            online_brief = false,
            online_show_offline = false
        }
    end
end
