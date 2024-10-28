-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "utility"

function make_gps_str_obj(player, obj)
    if obj then
        if player and player.surface and player.surface.index ~= 1 then
            return " [gps=" .. math.floor(obj.position.x) .. "," ..
                math.floor(obj.position.y) .. "," .. player.surface.name .. "] "
        else
            return " [gps=" .. math.floor(obj.position.x) .. ","
                .. math.floor(obj.position.y) .. "] "
        end
    end
end

function make_gps_str_player(player)
    if player and player.surface and player.surface.index ~= 1 then
        return " [gps=" .. math.floor(player.position.x) .. "," ..
            math.floor(player.position.y) .. "," .. player.surface.name .. "] "
    else
        return " [gps=" .. math.floor(player.position.x) .. ","
            .. math.floor(player.position.y) .. "] "
    end
end

function make_gps_str(item)
    if item and item.position then
        return " [gps=" .. math.floor(item.position.x) .. ","
            .. math.floor(item.position.y) .. "] "
    end
end

-- Build stuff -- activity
function on_built_entity(event)
    local player = game.players[event.player_index]
    local obj = event.entity

    if player and player.valid then
        if obj and obj.valid then
            if not storage.last_speaker_warning then
                storage.last_speaker_warning = 0
            end

            if obj.name == "programmable-speaker" or
                (obj.name == "entity-ghost" and obj.ghost_name == "programmable-speaker") then
                if (storage.last_speaker_warning and game.tick - storage.last_speaker_warning >= 5) then
                    if player.admin == false then -- Don't bother with mods
                        gsysmsg(player.name .. " placed a speaker at" .. make_gps_str_obj(player, obj))
                        storage.last_speaker_warning = game.tick
                    end
                end
            end

            if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
                if obj.name ~= "entity-ghost" then
                    console_print("[ACT] " .. player.name .. " placed " .. obj.name .. make_gps_str_obj(player, obj))
                else
                    if not storage.last_ghost_log then
                        storage.last_ghost_log = {}
                    end
                    if storage.last_ghost_log[player.index] then
                        if game.tick - storage.last_ghost_log[player.index] > (60 * 2) then
                            console_print("[ACT] " ..
                                player.name .. " placed-ghost " .. obj.name .. make_gps_str_obj(player, obj) ..
                                obj.ghost_name)
                        end
                    end
                    storage.last_ghost_log[player.index] = game.tick
                end
            end
        else
            console_print("[ERROR] on_built_entity: invalid obj")
        end
    else
        console_print("[ERROR] on_built_entity: invalid player")
    end
end

-- Pre-Mined item
function on_pre_player_mined_item(event)
    -- Sanity check
    if event and event.entity and event.player_index then
        local player = game.players[event.player_index]
        local obj = event.entity

        if obj and obj.valid and player and player.valid then
            if obj.force.name ~= "enemy" and obj.force.name ~= "neutral" then
                if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
                    if obj.name ~= "entity-ghost" then
                        -- log
                        console_print("[ACT] " .. player.name .. " mined " .. obj.name .. make_gps_str_obj(player, obj))

                        -- Mark player as having picked up an item, and needing to be cleaned.
                        if storage.cleaned_players and player.index and storage.cleaned_players[player.index] then
                            storage.cleaned_players[player.index] = false
                        end
                    else
                        console_print("[ACT] " ..
                            player.name .. " mined-ghost " .. obj.name .. make_gps_str_obj(player, obj) ..
                            obj.ghost_name)
                    end
                end
            else
                clear_corpse_tag(event)
            end
        else
            console_print("[ERROR] pre_player_mined_item: invalid obj")
        end
    end
end

-- Rotated item, block some users
function on_player_rotated_entity(event)
    -- Sanity check
    if event and event.player_index and event.previous_direction then
        local player = game.players[event.player_index]
        local obj = event.entity

        -- If player and object are valid
        if player and player.valid then
            if obj and obj.valid then
                if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
                    if obj.name ~= "entity-ghost" then
                        console_print("[ACT] " .. player.name .. " rotated " .. obj.name .. make_gps_str_obj(player, obj))
                    else
                        console_print("[ACT] " ..
                            player.name .. " rotated ghost " .. obj.name .. make_gps_str_obj(player, obj) ..
                            obj.ghost_name)
                    end
                end
            else
                console_print("[ERROR] on_player_rotated_entity: invalid obj")
            end
        else
            console_print("[ERROR] on_player_rotated_entity: invalid player")
        end
    end
end

-- Banned -- kill player to return items
function on_player_banned(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        if player then
            dumpPlayerInventory(player)
            gsysmsg(player.name .. "'s items have been left at spawn, so they can be recovered.")
        end
    end
end
