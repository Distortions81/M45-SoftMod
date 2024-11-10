-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

local function insWeapons(player, ammo_amount)
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
    RunSetup()
    storage.SM_Store.tickDiv = storage.SM_Store.tickDiv + 1

    --1 min
    if storage.SM_Store.tickDiv % 6 == 0 then
        ONLINE_UpdatePlayerList() -- online.lua
        UTIL_MapPin()             -- fix map pin if edit/delete
    end

    --15 mins
    if storage.SM_Store.tickDiv >= 90 then
        storage.SM_Store.tickDiv = 0
        INFO_CheckAbandoned()
        LOGO_DrawLogo(true)
    end


    -- Add time to connected players
    if storage.PData then
        for _, player in pairs(game.connected_players) do
            -- Banish if some mod eats respawn event
            BANISH_SendToSurface(player)

            -- Player active?
            if storage.PData[player.index].active then
                if storage.PData[player.index].active then
                    storage.PData[player.index].active = false -- Turn back off

                    if storage.PData[player.index].score then
                        -- Compensate for game speed
                        storage.PData[player.index].score =
                            storage.PData[player.index].score + (600.0 / game.speed) -- Same as loop time
                        if storage.PData[player.index].lastOnline then
                            storage.PData[player.index].lastOnline = game.tick
                        end
                    else
                        -- INIT
                        storage.PData[player.index].score = 0
                    end
                end
            else
                -- INIT
                storage.PData[player.index].active = false
            end

            -- Player moving?
            if storage.PData[player.index].moving then
                if storage.PData[player.index].moving then
                    storage.PData[player.index].moving = false -- Turn back off

                    if storage.PData[player.index].score then
                        -- Compensate for game speed
                        storage.PData[player.index].score =
                            storage.PData[player.index].score + (600.0 / game.speed) -- Same as loop time
                        if storage.PData[player.index].lastOnline then
                            storage.PData[player.index].lastOnline = game.tick
                        end
                    else
                        -- INIT
                        storage.PData[player.index].score = 0
                    end
                end
            else
                -- INIT
                storage.PData[player.index].moving = false
            end
        end
    end

    PERMS_AutoPromotePlayer() -- See if player qualifies now
end)


-- Handle killing, and teleporting users to other surfaces
function EVENT_Respawn(event)
    if not event or not event.player_index then
        return
    end

    local player = game.players[event.player_index]
    BANISH_SendToSurface(player) -- banish.lua

    -- Cutoff-point, just becomes annoying.
    if not player.force.technologies["military-science-pack"].researched then
        insWeapons(player, 10)
    end
end

local function makeUI(player)
    if player.gui and player.gui.top then
        INFO_MakeButton(player)
        ONLINE_MakeOnlineButton(player)
        ONELIFE_MakeButton(player)
        TODO_Setup(player)
        RESET_MakeClock(player)
    end
end

function EVENT_PlayerInit(player)
    STORAGE_MakePlayerStorage(player)
    PERMS_PromotePlayer(player)
    makeUI(player)
    ONLINE_UpdatePlayerList()

    if storage.PData then
        storage.PData[player.index].lastOnline = game.tick
    end
    if storage.SM_Store.cheats then
        player.cheat_mode = true
    end
end

-- Player connected, make variables, draw UI, set permissions, and game settings
function EVENT_Joined(event)
    if not event or not event.player_index then
        return
    end
    local player = game.players[event.player_index]

    EVENT_PlayerInit(player)
    BANISH_SendToSurface(player)
    ONLINE_UpdatePlayerList()
end

-- New player created, insert items set perms, show players online, welcome to map.
function EVENT_PlayerCreated(event)
    STORAGE_CreateGlobal()

    if not event or not event.player_index then
        return
    end
    local player = game.players[event.player_index]
    
    EVENT_PlayerInit(player)
    UTIL_SendToDefaultSpawn(player)
    INFO_InfoWin(player)
    ONLINE_UpdatePlayerList()

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

    insWeapons(player, 50) -- research-based

    UTIL_MsgAll("[color=green](SYSTEM) Welcome " .. player.name .. " to the map![/color]")
end

function EVENT_PlayerDied(event)
    if not event or not event.player_index then
        return
    end

    local player = game.players[event.player_index]

    -- Log to discord
    if event.cause and event.cause.valid then
        local cause = event.cause.name
        UTIL_MsgDiscord(player.name ..
            " was killed by " .. cause .. " at " .. UTIL_GPSPos(player))
    else
        UTIL_MsgDiscord(player.name .. " was killed at " .. UTIL_GPSPos(player))
    end
    ONELIFE_Main(event)
end

-- Main event handler
script.on_event(
    {
        defines.events.on_player_created, defines.events.on_pre_player_died, defines.events.on_player_respawned, defines
        .events.on_player_joined_game, defines.events.on_player_left_game, defines.events
        .on_player_main_inventory_changed, defines.events.on_player_changed_position, defines.events.on_console_chat,
        defines.events.on_player_repaired_entity, defines.events.on_gui_click, defines.events.on_gui_text_changed,
        defines.events.on_player_fast_transferred, defines.events.on_console_command, defines.events
        .on_chart_tag_removed, defines.events.on_chart_tag_modified, defines.events.on_chart_tag_added, defines.events
        .on_research_finished, defines.events.on_redo_applied, defines.events.on_undo_applied, defines.events
        .on_train_schedule_changed, defines.events.on_entity_died, defines.events.on_cancelled_upgrade, defines.events
        .on_picked_up_item, defines.events.on_player_dropped_item, defines.events.on_player_deconstructed_area, defines
        .events.on_marked_for_upgrade, defines.events.on_rocket_launch_ordered, defines.events.on_cancelled_upgrade,
        defines.events.on_marked_for_deconstruction, defines.events.on_cancelled_deconstruction, defines.events
        .on_player_flushed_fluid, defines.events.on_player_driving_changed_state, defines.events.on_player_banned,
        defines.events.on_player_rotated_entity, defines.events.on_player_flipped_entity, defines.events
        .on_pre_player_mined_item, defines.events.on_built_entity }, function(event)
        -- If no event, or event is a tick
        if not event or (event and event.name == defines.events.on_tick) then
            return
        end

        -- Mark player active
        if event.player_index then
            local player = game.players[event.player_index]
            if player and player.valid and player.connected and storage.PData and storage.PData[event.player_index] then
                -- Only mark active on movement if walking
                if event.name == defines.events.on_player_changed_position then
                    if player.walking_state then
                        if player.walking_state.walking and
                            (player.walking_state.direction == defines.direction.north or player.walking_state.direction ==
                                defines.direction.northeast or player.walking_state.direction == defines.direction.east or
                                player.walking_state.direction == defines.direction.southeast or
                                player.walking_state.direction == defines.direction.south or player.walking_state.direction ==
                                defines.direction.southwest or player.walking_state.direction == defines.direction.west or
                                player.walking_state.direction == defines.direction.northwest) then
                            PERMS_SetPlayerMoving(player)
                        end
                    end
                else
                    PERMS_SetPlayerActive(player)
                end
            end
        end

        -- Player join/leave respawn
        if event.name == defines.events.on_player_created then
            EVENT_PlayerCreated(event)
        elseif event.name == defines.events.on_pre_player_died then
            EVENT_PlayerDied(event)
        elseif event.name == defines.events.on_player_respawned then
            --
            EVENT_Respawn(event)
        elseif event.name == defines.events.on_player_joined_game then
            EVENT_Joined(event)
        elseif event.name == defines.events.on_player_left_game then
            -- activity
            -- changed-position
            -- console_chat
            -- repaired_entity
            --
            -- gui
            LOG_PlayerLeft(event)
        elseif event.name == defines.events.on_gui_click then
            INFO_Click(event)
            ONLINE_Clicks(event)  -- online.lua
            ONELIFE_Clicks(event) --onelife.lua
        elseif event.name == defines.events.on_gui_text_changed then
            -- log
            INFO_TextChanged(event)
        elseif event.name == defines.events.on_console_command then
            LOG_ConsoleCmd(event)
        elseif event.name == defines.events.on_chart_tag_removed then
            LOG_TagDel(event)
        elseif event.name == defines.events.on_chart_tag_modified then
            LOG_TagMod(event)
        elseif event.name == defines.events.on_chart_tag_added then
            LOG_TagAdded(event)
        elseif event.name == defines.events.on_research_finished then
            -- clean up corspe tags
            LOG_ResearchFinished(event)
        elseif event.name == defines.events.on_player_deconstructed_area then
            LOG_Decon(event)
        elseif event.name == defines.events.on_player_banned then
            LOG_Banned(event)
        elseif event.name == defines.events.on_player_rotated_entity then
            LOG_Rotated(event)
        elseif event.name == defines.events.on_player_flipped_entity then
            LOG_Rotated(event)
        elseif event.name == defines.events.on_pre_player_mined_item then
            LOG_PreMined(event)
        elseif event.name == defines.events.on_built_entity then
            LOG_BuiltEnt(event)
        elseif event.name == defines.events.on_redo_applied then
            LOG_Redo(event)
        elseif event.name == defines.events.on_undo_applied then
            LOG_Undo(event)
        elseif event.name == defines.events.on_train_schedule_changed then
            LOG_TrainSchedule(event)
        elseif event.name == defines.events.on_entity_died then
            LOG_EntDied(event)
        elseif event.name == defines.events.on_picked_up_item then
            LOG_PickedItem(event)
        elseif event.name == defines.events.on_player_dropped_item then
            LOG_DroppedItem(event)
        elseif event.name == defines.events.on_marked_for_upgrade then
            LOG_MarkedUpgrade(event)
        elseif event.name == defines.events.on_cancelled_upgrade then
            LOG_CancelUpgrade(event)
        elseif event.name == defines.events.on_marked_for_deconstruction then
            LOG_MarkDecon(event)
        elseif event.name == defines.events.on_cancelled_deconstruction then
            LOG_CancelDecon(event)
        elseif event.name == defines.events.on_player_flushed_fluid then
            LOG_Flushed(event)
        elseif event.name == defines.events.on_player_driving_changed_state then
            LOG_PlayerDrive(event)
        elseif event.name == defines.events.on_rocket_launch_ordered then
            LOG_OrderLaunch(event)
        elseif event.name == defines.events.on_player_fast_transferred then
            LOG_FastTransfered(event)
        elseif event.name == defines.events.on_player_main_inventory_changed then
            LOG_InvChanged(event)
        end

        -- To-Do--
        -- player_joined_game
        -- on_gui_click
        TODO_EventHandler(event)
    end)

function EVENT_Loot(event)
    if not event or not event.entity then
        return
    end
    local ent = event.entity

    if ent and ent.type and ent.type == "character-corpse" then
        if ent and ent.character_corpse_player_index and event.player_index then
            if event.character_corpse_player_index == event.player_index then
                return -- Dont warn if it is ours
            end
            local player = game.players[event.player_index]
            local victim = game.players[ent.character_corpse_player_index]

            if victim and victim.valid and player and player.valid then
                local buf = player.name ..
                    " looted the body of " .. victim.name .. " at " .. UTIL_GPSPos(ent)
                if victim.index ~= player.index then
                    UTIL_MsgAll(buf)
                end
            end
        end
    end
end
