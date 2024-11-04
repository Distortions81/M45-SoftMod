-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "utility"



-- Build stuff -- activity
function ANTIGRIEF_BuiltEnt(event)
    local player = game.players[event.player_index]
    local obj = event.entity

    if player and player.valid then
        if obj and obj.valid then
            if not storage.last_speaker_warning then
                storage.last_speaker_warning = 0
            end

            if obj.name == "programmable-speaker" or
                (obj.name == "entity-ghost" and obj.ghost_name == "programmable-speaker") then
                if (storage.last_speaker_warning and game.tick - storage.last_speaker_warning >= 120) then
                    if player.admin == false then -- Don't bother with mods
                        UTIL_MsgAll(player.name .. " placed a speaker at" .. UTIL_GPSObj(player, obj))
                        storage.last_speaker_warning = game.tick
                    end
                end
            end

            if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
                if obj.name ~= "entity-ghost" then
                    UTIL_ConsolePrint("[ACT] " .. player.name .. " placed " .. obj.name .. UTIL_GPSObj(player, obj))
                else
                    if not storage.last_ghost_log then
                        storage.last_ghost_log = {}
                    end
                    if storage.last_ghost_log[player.index] then
                        if game.tick - storage.last_ghost_log[player.index] > (60 * 2) then
                            UTIL_ConsolePrint("[ACT] " ..
                                player.name .. " placed-ghost " .. obj.name .. UTIL_GPSObj(player, obj) ..
                                obj.ghost_name)
                        end
                    end
                    storage.last_ghost_log[player.index] = game.tick
                end
            end
        else
            UTIL_ConsolePrint("[ERROR] on_built_entity: invalid obj")
        end
    else
        UTIL_ConsolePrint("[ERROR] on_built_entity: invalid player")
    end
end

-- Pre-Mined item
function ANTIGRIEF_PreMined(event)
    -- Sanity check
    if event and event.entity and event.player_index then
        local player = game.players[event.player_index]
        local obj = event.entity

        if obj and obj.valid and player and player.valid then
            if obj.force.name ~= "enemy" and obj.force.name ~= "neutral" then
                if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
                    if obj.name ~= "entity-ghost" then
                        -- log
                        UTIL_ConsolePrint("[ACT] " .. player.name .. " mined " .. obj.name .. UTIL_GPSObj(player, obj))

                        -- Mark player as having picked up an item, and needing to be cleaned.
                        if storage.cleaned_players and player.index and storage.cleaned_players[player.index] then
                            storage.cleaned_players[player.index] = false
                        end
                    else
                        UTIL_ConsolePrint("[ACT] " ..
                            player.name .. " mined-ghost " .. obj.name .. UTIL_GPSObj(player, obj) ..
                            obj.ghost_name)
                    end
                end
            else
                EVENT_Loot(event)
            end
        else
            UTIL_ConsolePrint("[ERROR] pre_player_mined_item: invalid obj")
        end
    end
end

-- Rotated item, block some users
function ANTIGRIEF_Rotated(event)
    -- Sanity check
    if event and event.player_index and event.previous_direction then
        local player = game.players[event.player_index]
        local obj = event.entity

        -- If player and object are valid
        if player and player.valid then
            if obj and obj.valid then
                if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
                    if obj.name ~= "entity-ghost" then
                        UTIL_ConsolePrint("[ACT] " .. player.name .. " rotated " .. obj.name .. UTIL_GPSObj(player, obj))
                    else
                        UTIL_ConsolePrint("[ACT] " ..
                            player.name .. " rotated ghost " .. obj.name .. UTIL_GPSObj(player, obj) ..
                            obj.ghost_name)
                    end
                end
            else
                UTIL_ConsolePrint("[ERROR] on_player_rotated_entity: invalid obj")
            end
        else
            UTIL_ConsolePrint("[ERROR] on_player_rotated_entity: invalid player")
        end
    end
end

function ANTIGRIEF_Flipped(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        local obj = event.entity
        
        -- If player and object are valid
        if player and player.valid then
            if obj and obj.valid then
                if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
                    if obj.name ~= "entity-ghost" then
                        UTIL_ConsolePrint("[ACT] " .. player.name .. " flipped " .. obj.name .. UTIL_GPSObj(player, obj))
                    else
                        UTIL_ConsolePrint("[ACT] " ..
                            player.name .. " flipped ghost " .. obj.name .. UTIL_GPSObj(player, obj) ..
                            obj.ghost_name)
                    end
                end
            else
                UTIL_ConsolePrint("[ERROR] on_player_flipped_entity: invalid obj")
            end
        else
            UTIL_ConsolePrint("[ERROR] on_player_flipped_entity: invalid player")
        end
    end
end

-- Banned -- kill player to return items
function ANTIGRIEF_Banned(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        if player then
            INFO_DumpInv(player, true)
            UTIL_MsgAllSys(player.name .. "'s items have been left at spawn, so they can be recovered.")
        end
    end
end
