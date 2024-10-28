-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "antigrief"
require "info"
require "log"
require "todo"

local function insert_weapons(player, ammo_amount)
    if player.force.technologies["military"].researched then
        player.insert {
            name = "submachine-gun",
            count = 1
        }
    else
        player.insert {
            name = "pistol",
            count = 1
        }
    end

    if player.force.technologies["military-2"].researched then
        player.insert {
            name = "piercing-rounds-magazine",
            count = ammo_amount
        }
    else
        player.insert {
            name = "firearm-magazine",
            count = ammo_amount
        }
    end
end

-- Looping timer, 10 seconds
-- Check spawn area map pin
-- Add to player active time if needed
-- Refresh players online window

script.on_nth_tick(599, function(event)
    -- Tick divider, one minute
    if not storage.tickdiv then
        storage.tickdiv = 0
    end
    storage.tickdiv = storage.tickdiv + 1

    if storage.tickdiv >= 6 then
        storage.tickdiv = 0

        -- Set logo to be redrawn
        storage.drawlogo = false
        dodrawlogo()

        update_player_list() -- online.lua
    end

    -- Server tag
    if (storage.servertag and not storage.servertag.valid) then
        storage.servertag = nil
    end
    if (storage.servertag and storage.servertag.valid) then
        storage.servertag.destroy()
        storage.servertag = nil
    end
    if (not storage.servertag) then
        local label = "Spawn Area"
        local xpos = 0
        local ypos = 0

        if storage.servname and storage.servname ~= "" then
            label = storage.servname
        end

        local chartTag = {
            position = get_default_spawn(),
            icon = {
                type = "item",
                name = "heavy-armor"
            },
            text = label
        }
        local pforce = game.forces["player"]
        local psurface = game.surfaces[1]

        if pforce and psurface then
            storage.servertag = pforce.add_chart_tag(psurface, chartTag)
        end
    end

    -- Add time to connected players
    if storage.active_playtime then
        for _, player in pairs(game.connected_players) do
            -- Banish if some mod eats respawn event
            send_to_surface(player)

            -- Player active?
            if storage.playeractive[player.index] then
                if storage.playeractive[player.index] == true then
                    storage.playeractive[player.index] = false -- Turn back off

                    if storage.active_playtime[player.index] then
                        -- Compensate for game speed
                        storage.active_playtime[player.index] =
                            storage.active_playtime[player.index] + (600.0 / game.speed) -- Same as loop time
                        if storage.last_playtime then
                            storage.last_playtime[player.index] = game.tick
                        end
                    else
                        -- INIT
                        storage.active_playtime[player.index] = 0
                    end
                end
            else
                -- INIT
                storage.playeractive[player.index] = false
            end

            -- Player moving?
            if storage.playermoving[player.index] then
                if storage.playermoving[player.index] == true then
                    storage.playermoving[player.index] = false -- Turn back off

                    if storage.active_playtime[player.index] then
                        -- Compensate for game speed
                        storage.active_playtime[player.index] =
                            storage.active_playtime[player.index] + (600.0 / game.speed) -- Same as loop time
                        if storage.last_playtime then
                            storage.last_playtime[player.index] = game.tick
                        end
                    else
                        -- INIT
                        storage.active_playtime[player.index] = 0
                    end
                end
            else
                -- INIT
                storage.playermoving[player.index] = false
            end
        end
    end

    get_permgroup() -- See if player qualifies now

    if not storage.disableperms then
        check_character_abandoned()
    end
end)


-- Handle killing, and teleporting users to other surfaces
function on_player_respawned(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        send_to_surface(player) -- banish.lua

        -- Cutoff-point, just becomes annoying.
        if not player.force.technologies["military-science-pack"].researched then
            insert_weapons(player, 10)
        end
    end
end

-- Player connected, make variables, draw UI, set permissions, and game settings
function on_player_joined_game(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        send_to_surface(player)
    end

    -- Set clock as NOT MINIMIZED on login
    if event and event.player_index then
        if storage.hide_clock and storage.hide_clock[event.player_index] then
            storage.hide_clock[event.player_index] = false
        end
    end

    if storage.cheatson then
        if event and event.player_index then
            local player = game.players[event.player_index]
            if player and player.valid then
                player.cheat_mode = true
            end
        end
    end

    -- Gui stuff
    if event and event.player_index then
        local player = game.players[event.player_index]
        if player then
            create_mystorage()
            create_player_storage(player)
            create_groups()
            game_settings(player)
            get_permgroup()

            dodrawlogo() -- logo.lua

            if player.gui and player.gui.top then
                make_info_button(player)   -- info.lua
                make_online_button(player) -- online.lua
                make_reset_clock(player)   -- clock.lua
            end

            if storage.last_playtime then
                storage.last_playtime[event.player_index] = game.tick
            end
            update_player_list() -- online.lua

            -- Always show to new players, everyone else at least once per map
            if is_new(player) or not storage.info_shown[player.index] then
                storage.info_shown[player.index] = true
                make_m45_online_window(player) -- online.lua
                make_m45_info_window(player)   -- info.lua
                -- make_m45_todo_window(player) --todo.lua
            end
        end
    end
end

-- New player created, insert items set perms, show players online, welcome to map.
function on_player_created(event)
    if event and event.player_index then
        local player = game.players[event.player_index]

        if player and player.valid then
            storage.drawlogo = false      -- set logo to be redrawn
            create_groups()
            dodrawlogo()                  -- redraw logo
            set_perms()
            send_to_default_spawn(player) -- incase spawn moved
            game_settings(player)

            -- Cutoff-point, just becomes annoying.
            if not player.force.technologies["military-2"].researched then
                player.insert {
                    name = "iron-plate",
                    count = 50
                }
                player.insert {
                    name = "copper-plate",
                    count = 50
                }
                player.insert {
                    name = "wood",
                    count = 50
                }
                player.insert {
                    name = "burner-mining-drill",
                    count = 2
                }
                player.insert {
                    name = "stone-furnace",
                    count = 2
                }
                player.insert {
                    name = "iron-chest",
                    count = 1
                }
            end
            player.insert {
                name = "light-armor",
                count = 1
            }

            insert_weapons(player, 50) -- research-based

            show_players(player)
            message_all("[color=green](SYSTEM) Welcome " .. player.name .. " to the map![/color]")
        end
    end
end

function on_pre_player_died(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        -- Log to discord
        if event.cause and event.cause.valid then
            cause = event.cause.name
            message_alld( player.name .. " was killed by " .. cause .. " at [gps=" .. math.floor(player.position.x) .. "," ..
                math.floor(player.position.y) .. "]")
        else
            message_alld(player.name .. " was killed at [gps=" .. math.floor(player.position.x) .. "," ..
                math.floor(player.position.y) .. "]")
        end
    end
end

-- Main event handler
script.on_event(
    {                                                                                                        -- Player join/leave respawn
        defines.events.on_player_created, defines.events.on_pre_player_died, defines.events.on_player_respawned, --
        defines.events.on_player_joined_game, defines.events.on_player_left_game,                            -- activity
        defines.events.on_player_changed_position, defines.events.on_console_chat, defines.events
        .on_player_repaired_entity,
        -- gui
        defines.events.on_gui_click, defines.events.on_gui_text_changed,    -- log
        defines.events.on_console_command, defines.events.on_chart_tag_removed, defines.events.on_chart_tag_modified,
        defines.events.on_chart_tag_added, defines.events.on_research_finished, -- clean up corpse tags
        defines.events.on_redo_applied, defines.events.on_undo_applied, defines.events
        .on_train_schedule_changed,
        defines.events.on_entity_died, defines.events.on_cancelled_upgrade, defines.events.on_picked_up_item, -- anti-grief
        defines.events.on_player_deconstructed_area, defines.events.on_player_banned, defines.events
        .on_player_rotated_entity,
        defines.events.on_pre_player_mined_item, defines.events.on_built_entity }, function(event)
        -- If no event, or event is a tick
        if not event or (event and event.name == defines.events.on_tick) then
            return
        end

        -- Mark player active
        if event.player_index then
            local player = game.players[event.player_index]
            if player and player.valid then
                -- Only mark active on movement if walking
                if event.name == defines.events.on_player_changed_position then
                    if player.walking_state then
                        if player.walking_state.walking == true and
                            (player.walking_state.direction == defines.direction.north or player.walking_state.direction ==
                                defines.direction.northeast or player.walking_state.direction == defines.direction.east or
                                player.walking_state.direction == defines.direction.southeast or
                                player.walking_state.direction == defines.direction.south or player.walking_state.direction ==
                                defines.direction.southwest or player.walking_state.direction == defines.direction.west or
                                player.walking_state.direction == defines.direction.northwest) then
                            set_player_moving(player)
                        end
                    end
                else
                    set_player_active(player)
                end
            end
        end

        -- Player join/leave respawn
        if event.name == defines.events.on_player_created then
            on_player_created(event)
        elseif event.name == defines.events.on_pre_player_died then
            on_pre_player_died(event)
        elseif event.name == defines.events.on_player_respawned then
            --
            on_player_respawned(event)
        elseif event.name == defines.events.on_player_joined_game then
            on_player_joined_game(event)
        elseif event.name == defines.events.on_player_left_game then
            -- activity
            -- changed-position
            -- console_chat
            -- repaired_entity
            --
            -- gui
            on_player_left_game(event)
        elseif event.name == defines.events.on_gui_click then
            on_gui_click(event)
            online_on_gui_click(event) -- online.lua
        elseif event.name == defines.events.on_gui_text_changed then
            -- log
            on_gui_text_changed(event)
        elseif event.name == defines.events.on_console_command then
            on_console_command(event)
        elseif event.name == defines.events.on_chart_tag_removed then
            on_chart_tag_removed(event)
        elseif event.name == defines.events.on_chart_tag_modified then
            on_chart_tag_modified(event)
        elseif event.name == defines.events.on_chart_tag_added then
            on_chart_tag_added(event)
        elseif event.name == defines.events.on_research_finished then
            -- clean up corspe tags
            on_research_finished(event)
        elseif event.name == defines.events.on_player_deconstructed_area then
            on_player_deconstructed_area(event)
        elseif event.name == defines.events.on_player_banned then
            on_player_banned(event)
        elseif event.name == defines.events.on_player_rotated_entity then
            on_player_rotated_entity(event)
        elseif event.name == defines.events.on_pre_player_mined_item then
            on_pre_player_mined_item(event)
        elseif event.name == defines.events.on_built_entity then
            on_built_entity(event)
        elseif event.name == defines.events.on_redo_applied then
            on_redo_applied(event)
        elseif event.name == defines.events.on_undo_applied then
            on_undo_applied(event)
        elseif event.name == defines.events.on_train_schedule_changed then
            on_train_schedule_changed(event)
        elseif event.name == defines.events.on_entity_died then
            on_entity_died(event)
        elseif event.name == defines.events.on_picked_up_item then
            on_picked_up_item(event)
        end

        -- To-Do--
        -- player_joined_game
        -- on_gui_click
        todo_event_handler(event)
    end)

function clear_corpse_tag(event)
    if event and event.entity and event.entity.valid then
        local ent = event.entity

        if ent and ent.type and ent.type == "character-corpse" then
            if ent and ent.character_corpse_player_index and event.player_index then
                player = game.players[event.player_index]
                victim = game.players[ent.character_corpse_player_index]

                if victim and victim.valid and player and player.valid then
                    local buf = player.name ..
                        " looted the body of " .. victim.name .. " at" .. make_gps_str_obj(player, victim)
                    if victim.name ~= player.name then
                        gsysmsg(buf)
                    else
                        message_all( buf)
                    end
                end
            end
        end
    end
end
