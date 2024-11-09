-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
-- Create storage, if needed
function STORAGE_CreateGlobal()
    if not storage.PData then
        storage.PData = {}
    end
    if not storage.SM_Store then
        storage.SM_Store = {}
    end

    --Map resets
    if not storage.SM_Store.resetDuration then
        storage.SM_Store.resetDuration = ""
    end
    if not storage.SM_Store.resetDuration then
        storage.SM_Store.resetDate = ""
    end

    --Perms
    if not storage.SM_Store.restrictNew then
        storage.SM_Store.restrictNew = false
    end

    --Credits
    if not storage.SM_Store.patreonCredits then
        storage.SM_Store.patreonCredits = {}
    end
    if not storage.SM_Store.nitroCredits then
        storage.SM_Store.nitroCredits = {}
    end

    --Banish
    if not storage.SM_Store.votes then
        storage.SM_Store.votes = {}
    end
    if not storage.SM_Store.sendToSurface then
        storage.SM_Store.sendToSurface = {}
    end

    --Game Modes
    if not storage.SM_Store.noBlueprints then
        storage.SM_Store.noBlueprints = false
    end
    if not storage.SM_Store.oneLifeMode then
        storage.SM_Store.oneLifeMode = false
    end
    if not storage.SM_Store.cheats then
        storage.SM_Store.cheats = false
    end

    --Players Online
    if not storage.SM_Store.onlineCache then
        storage.SM_Store.onlineCache = ""
    end
    if not storage.SM_Store.pcount then
        storage.SM_Store.pcount = 0
    end
    if not storage.SM_Store.tcount then
        storage.SM_Store.tcount = 0
    end
    if not storage.SM_Store.playerList then
        storage.SM_Store.playerList = {}
    end

    --Spawn Logo
    if not storage.SM_Store.redrawLogo then
        storage.SM_Store.redrawLogo = true
    end
    if not storage.SM_Store.serverName then
        storage.SM_Store.serverName = ""
    end

    --Tick divider
    if not storage.SM_Store.tickDiv then
        storage.SM_Store.tickDiv = 0
    end
end

-- Create player storage, if needed
function STORAGE_MakePlayerStorage(player)
    if not storage.PData[player.index] then
        storage.PData[player.index] = {}
    end
    --score
    if not storage.PData[player.index].active then
        storage.PData[player.index].active = false
    end
    if not storage.PData[player.index].moving then
        storage.PData[player.index].moving = false
    end
    if not storage.PData[player.index].score then
        storage.PData[player.index].score = 0
    end
    if not storage.PData[player.index].banished then
        storage.PData[player.index].banished = 0
    end
    if not storage.PData[player.index].lastOnline then
        storage.PData[player.index].lastOnline = game.tick
    end

    --prefs
    if not storage.PData[player.index].hideClock then
        storage.PData[player.index].hideClock = false
    end


    --state
    if not storage.PData[player.index].cleaned then
        storage.PData[player.index].cleaned = false
    end
    if not storage.PData[player.index].patreon then
        storage.PData[player.index].patreon = false
    end
    if not storage.PData[player.index].nitro then
        storage.PData[player.index].nitro = false
    end

    --throttle
    if not storage.PData[player.index].regAttempts then
        storage.PData[player.index].regAttempts = 0
    end
    if not storage.PData[player.index].lastWarned then
        storage.PData[player.index].lastWarned = 0
    end
    if not storage.PData[player.index].reports then
        storage.PData[player.index].reports = 0
    end
    if not storage.PData[player.index].permDeath then
        storage.PData[player.index].permDeath = 0
    end

    --online menu
    if not storage.PData[player.index].onlineBrief then
        storage.PData[player.index].online_brief = false
    end
    if not storage.PData[player.index].onlineShowOffline then
        storage.PData[player.index].online_show_offline = false
    end
    
end
