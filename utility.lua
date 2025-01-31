-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
-- Safe console print

function UTIL_CheckAbandoned()
    for _, player in pairs(game.players) do
        if not player.connected and UTIL_Is_New(player) then
            if game.tick - storage.PData[player.index].lastOnline > 1 * 60 * 60 * 60 then
                if UTIL_DumpInv(player, false) then
                    UTIL_MsgAllSys("New player '" .. player.name ..
                        "' was not active long enough to become a member, and have been offline for some time. Their items are now considered abandoned, and have been placed at spawn.")
                end
            end
        end
    end
end


function UTIL_DumpInv(player, force)
    if not player then
        return false
    end

    if not force then
        if storage.PData[player.index].cleaned then
            if storage.PData[player.index].cleaned then
                return false
            end
        end
    end

    local inv_main = player.get_inventory(defines.inventory.character_main)
    local inv_trash = player.get_inventory(defines.inventory.character_trash)

    local inv_main_contents
    if inv_main and inv_main.valid then
        inv_main_contents = inv_main.get_contents()
    end

    local inv_trash_contents
    if inv_trash and inv_trash.valid then
        inv_trash_contents = inv_trash.get_contents()
    end

    local inv_corpse_size = 0
    if inv_main_contents then
        inv_corpse_size = inv_corpse_size + (#inv_main - inv_main.count_empty_stacks())
    end

    if inv_trash_contents then
        inv_corpse_size = inv_corpse_size + (#inv_trash - inv_trash.count_empty_stacks())
    end

    if inv_corpse_size <= 0 then
        return false
    end

    local position = player.position
    local corpse = game.surfaces[1].create_entity {
        name = "character-corpse",
        position = game.surfaces[1].find_non_colliding_position("character", UTIL_GetDefaultSpawn(), 1024, 1, false),
        inventory_size = inv_corpse_size,
        player_index = player.index
    }
    if not corpse then
        return false
    end

    corpse.active = true

    local inv_corpse = corpse.get_inventory(defines.inventory.character_corpse)

    if not inv_corpse then
        return false
    end

    if inv_main_contents then
        for _, item in pairs(inv_main_contents) do
            inv_corpse.insert(item)
        end

        if inv_main_contents then
            inv_main.clear()
        end
    end
    if inv_trash_contents then
        for _, item in pairs(inv_trash_contents) do
            inv_corpse.insert(item)
        end

        if inv_trash_contents then
            inv_trash.clear()
        end
    end


    -- Mark as cleaned up.
    storage.PData[player.index].cleaned = true

    return true
end

function UTIL_MapPin()
    --Migrate old maps
    if (storage.servertag and storage.servertag.valid) then
        storage.servertag.destroy()
        storage.servertag = nil
    end

    -- Server tag
    if (storage.SM_Store.mapPin and not storage.SM_Store.mapPin.valid) then
        storage.SM_Store.mapPin = nil
    end
    if (storage.SM_Store.mapPin and storage.SM_Store.mapPin.valid) then
        storage.SM_Store.mapPin.destroy()
        storage.SM_Store.mapPin = nil
    end
    if (not storage.SM_Store.mapPin) then
        local label = "https://discord.gg/rQANzBheVh"

        local chartTag = {
            position = UTIL_GetDefaultSpawn(),
            icon = {
                type = "item",
                name = "programmable-speaker"
            },
            text = label
        }
        local pforce = game.forces["player"]
        local psurface = game.surfaces[1]

        if pforce and psurface then
            storage.SM_Store.mapPin = pforce.add_chart_tag(psurface, chartTag)
        end
    end
end

function UTIL_WarnOkay(player_index)
    if (storage.PData[player_index].lastWarned and game.tick ~= storage.PData[player_index].lastWarned) then
        storage.PData[player_index].lastWarned = game.tick
        return true
    end
    return false
end

function UTIL_GPSPos(pos)
    if pos and pos.x and pos.y then
    return "[gps=" .. math.floor(pos.x) .. ","
                .. math.floor(pos.y) .. "] "
    else
        return "[Invalid position]"
    end
end

function UTIL_GPSXY(x, y)
    if x and y then
    return "[gps=" .. math.floor(x) .. ","
                .. math.floor(y) .. "] "
    else
        return "[Invalid xy]"
    end
end

function UTIL_Area(size, area)
    if size and area and area.left_top and area.right_bottom then
    return "from: " ..
        UTIL_GPSXY(area.left_top.x, area.left_top.y) ..
        " to " .. UTIL_GPSXY(area.right_bottom.x, area.right_bottom.y) ..
        " AREA: " .. math.floor(size) .. "sq"
    else
        return "[Invalid area]"
    end
end

function UTIL_GPSObj(item)
    if item and item.position then
        local sName = ""
        if item and item.surface then
            sName = item.surface.name
        end

        if sName then
            return "[gps=" .. math.floor(item.position.x) .. ","
                .. math.floor(item.position.y) .. "," .. sName .. "]"
        else
            return "[gps=" .. math.floor(item.position.x) .. ","
                .. math.floor(item.position.y) .. "] "
        end
    end
    return "[Invalid Object]"
end 

function UTIL_ConsolePrint(message)
    if message then
        print(message)
    end
end

-- Smart/safe Print
function UTIL_SmartPrint(player, message)
    if message then
        if player then
            player.print(message)
        else
            rcon.print(message)
        end
    end
end

-- Global messages (game/discord)
function UTIL_MsgAll(message)
    if message then
        game.print(message)
        print("[MSG] " .. message)
    end
end

-- System messages (game/discord)
function UTIL_MsgAllSys(message)
    if message then
        game.print("[color=orange](SYSTEM)[/color] [color=red]" .. message .. "[/color]")
        print("[MSG] " .. message)
    end
end

-- Global messages (game only)
function UTIL_MsgPlayers(message)
    if message then
        game.print(message)
    end
end

-- Global messages (discord only)
function UTIL_MsgDiscord(message)
    if message then
        print("[MSG] " .. message)
    end
end

-- Calculate distance between two points
function UTIL_Distance(pos_a, pos_b)
    if pos_a and pos_b and pos_a.x and pos_a.y and pos_b.x and pos_b.y then
        local axbx = pos_a.x - pos_b.x
        local ayby = pos_a.y - pos_b.y
        return (axbx * axbx + ayby * ayby) ^ 0.5
    else
        return 10000000
    end
end

-- Show players online to a player
function UTIL_SendPlayers(victim)
    local buf = ""
    local count = 0

    -- For console use
    if not victim then
        buf = "[ONLINE2] "
        if storage.SM_Store.playerList then
            for i, target in pairs(storage.SM_Store.playerList) do
                if target and target.victim and target.victim.connected then
                    buf = buf .. target.victim.name .. "," .. math.floor(target.score / 60 / 60) .. "," ..
                        math.floor(target.time / 60 / 60) .. "," .. target.type .. "," .. target.afk .. ";"
                end
            end
        end

        -- Don't send unless there is a change
        if storage.SM_Store.onlineCache ~= buf then
            storage.SM_Store.onlineCache = buf
            print(buf)
        end
        return
    end

    if storage.SM_Store.playerList then
        for i, target in pairs(storage.SM_Store.playerList) do
            if target and target.victim and target.victim.connected then
                buf = buf ..
                    string.format("~%16s: - Score: %4d - Online: %4dm - (%s)%s\n", target.victim.name,
                        math.floor(target.score / 60 / 60), math.floor(target.time / 60 / 60), target.type, target.afk)
            end
        end
    end

    -- No one is online
    if not storage.SM_Store.pcount or storage.SM_Store.pcount == 0 then
        UTIL_SmartPrint(victim, "No players online.")
    else
        UTIL_SmartPrint(victim, "Players Online: " .. storage.SM_Store.pcount .. "\n" .. buf)
    end
end

-- Split strings
function UTIL_SplitStr(inputstr, sep)
    if inputstr and sep and inputstr ~= "" then
        local t = {}
        local x = 0

        -- Handle nil/empty strings
        if not sep or not inputstr then
            return t
        end
        if sep == "" or inputstr == "" then
            return t
        end

        for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
            x = x + 1
            if x > 100 then -- Max 100 args
                break
            end

            table.insert(t, str)
        end
        return t
    end
    return { "" }
end

-- Quickly turn tables into strings
function UTIL_Dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. UTIL_Dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

-- Cut off extra precision
function UTIL_Quantize(number, precision)
    local fmtStr = string.format("%%0.%sf", precision)
    number = string.format(fmtStr, number)
    return number
end

-- Check if player is flagged patreon
function UTIL_Is_Supporter(victim)
    if victim and storage.PData[victim.index] and storage.PData[victim.index].patreon then
        return storage.PData[victim.index].patreon
    else
        return false
    end
end

-- Check if player is flagged nitro
function UTIL_Is_Nitro(victim)
    if victim and storage.PData[victim.index]and storage.PData[victim.index].nitro then
        return storage.PData[victim.index].nitro
    else
        return false
    end
end

-- permissions system
-- Check if player should be considered a veteran
function UTIL_Is_Veteran(victim)
    if victim and not victim.admin then
        -- If in group
        if victim.permission_group and storage.SM_Store.vetGroup then
            if victim.permission_group.name == storage.SM_Store.vetGroup.name then
                return true
            end
        end
    end

    --Workaround for mods that screw with permisison groups
    if not UTIL_Is_Banished(victim) then
        if storage and storage.PData[victim.index] then
            local level = storage.PData[victim.index].level
            if level == 3 then
                return true
            end
        end
    end

    return false
end

-- permissions system
-- Check if player should be considered a regular
function UTIL_Is_Regular(victim)
    if victim and not victim.admin then
        -- If in group
        if victim.permission_group and storage.SM_Store.regGroup then
            if victim.permission_group.name == storage.SM_Store.regGroup.name then
                return true
            end
        end
    end

    --Workaround for mods that screw with permisison groups
    if not UTIL_Is_Banished(victim) then
        if storage and storage.PData[victim.index] then
            local level = storage.PData[victim.index].level
            if level == 2 then
                return true
            end
        end
    end

    return false
end

-- Check if player should be considered a member
function UTIL_Is_Member(victim)
    if victim and not victim.admin then
        -- If in group
        if victim.permission_group and storage.SM_Store.memGroup then
            if victim.permission_group.name == storage.SM_Store.memGroup.name then
                return true
            end
        end
    end

    --Workaround for mods that screw with permisison groups
    if not UTIL_Is_Banished(victim) then
        if storage and storage.PData[victim.index] then
            local level = storage.PData[victim.index].level
            if level == 1 then
                return true
            end
        end
    end

    return false
end

-- Check if player should be considered new
function UTIL_Is_New(victim)
    if victim and not victim.admin then
        if not UTIL_Is_Member(victim) and not UTIL_Is_Regular(victim) and not UTIL_Is_Veteran(victim) then
            return true
        end
    end

    return false
end

function UTIL_SmartPrintColor(victim, message)
    UTIL_SmartPrint(victim, "[color=red]" .. message .. "[/color]")
    UTIL_SmartPrint(victim, "[color=cyan]" .. message .. "[/color]")
    UTIL_SmartPrint(victim, "[color=black]" .. message .. "[/color]")
end

-- Check if player should be considered banished
function UTIL_Is_Banished(victim)
    --Not Invalid
    if not victim then
        return false
    end

    --Not admin
    if victim.admin then
        return false
    end

    --Physically in jail
    if victim.physical_surface and victim.physical_surface.name == "jail" then
        return true
    end

    --In jailed group
    if victim.permission_group and storage.SM_Store.jailGroup then
        if victim.permission_group.name == storage.SM_Store.jailGroup.name then
            return true
        end
    end

    
    if storage and storage.PData[victim.index] then
        local pointsNeeded = 1
        local level = storage.PData[victim.index].level

        if level == 2 then
            pointsNeeded = 2
        end
        if level == 3  then
            pointsNeeded = 4
        end
    
        --Has enough votes against them
        if storage.PData and storage.PData[victim.index] and storage.PData[victim.index].banished and storage.PData[victim.index].banished > pointsNeeded then
           return true
        else
            return false
        end
    end

    return false
end

function UTIL_SendToDefaultSpawn(victim)
    if victim and victim.character then
        local nsurf = game.surfaces[1] -- Find default surface

        if nsurf then
            local pforce = victim.force
            local spawnpos = { 0, 0 }
            if pforce then
                spawnpos = pforce.get_spawn_position(nsurf)
            else
                UTIL_ConsolePrint("[ERROR] send_to_default_spawn: victim does not have a valid force.")
            end
            local newpos = nsurf.find_non_colliding_position("character", spawnpos, 1024, 1, false)
            if newpos then
                victim.teleport(newpos, nsurf)
            else
                victim.teleport({ 0, 0 }, nsurf)
            end
        else
            UTIL_ConsolePrint("[ERROR] send_to_default_spawn: The surface 1 does not exist, could not teleport victim.")
        end
    else
        UTIL_ConsolePrint("[ERROR] send_to_default_spawn: victim invalid or dead")
    end
end

function UTIL_SendToSpawn(victim)
    if victim and victim.character then
        local nsurf = victim.physical_surface
        if nsurf then
            local pforce = victim.force
            local spawnpos = { 0, 0 }
            if pforce then
                spawnpos = pforce.get_spawn_position(nsurf)
            else
                UTIL_ConsolePrint("[ERROR] send_to_surface_spawn: victim force invalid")
            end
            local newpos = nsurf.find_non_colliding_position("character", spawnpos, 1024, 1, false)
            if newpos then
                victim.teleport(newpos, nsurf)
            else
                victim.teleport({ 0, 0 }, nsurf)
            end
        else
            UTIL_ConsolePrint("[ERROR] send_to_surface_spawn: The surface does not exist, could not teleport victim.")
        end
    else
        UTIL_ConsolePrint("[ERROR] send_to_surface_spawn: victim invalid or dead")
    end
end

function UTIL_GetDefaultSpawn()
    local nsurf = game.surfaces[1]
    if nsurf then
        local pforce = game.forces["player"]
        if pforce then
            local spawnpos = pforce.get_spawn_position(nsurf)
            return spawnpos
        else
            UTIL_ConsolePrint("[ERROR] get_default_spawn: Couldn't find force 'player'")
            return { 0, 0 }
        end
    else
        UTIL_ConsolePrint("[ERROR] get_default_spawn: Couldn't find default surface 1.")
        return { 0, 0 }
    end
end
