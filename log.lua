-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "utility"

function LOG_Init()
    if not storage.last_ghost_log then
        storage.last_ghost_log = {}
    end
end

-- Create map tag -- log
function LOG_TagAdded(event)
    if not event or not event.player_index then
        return
    end
    local player = game.players[event.player_index]

    if player and player.valid and event.tag then
        UTIL_MsgAll(player.name .. " add-tag" .. make_gps_str_obj(player, event.tag) .. event.tag.text)
    end
end

-- Edit map tag -- log
function LOG_TagMod(event)
    if not event or not event.player_index then
        return
    end
        local player = game.players[event.player_index]
        if player and player.valid and event.tag then
            UTIL_MsgAll(player.name .. " mod-tag" .. make_gps_str_obj(player, event.tag) .. event.tag.text)
        end
end

-- Delete map tag -- log
function LOG_TagDel(event)
    if not event or not event.player_index then
        return
    end
        local player = game.players[event.player_index]

        -- Because factorio will hand us an nil event... nice.
        if player and player.valid and event.tag then
            UTIL_MsgAll(player.name .. " del-tag" .. make_gps_str_obj(player, event.tag) .. event.tag.text)
        end
end

-- Player disconnect messages, with reason (Fact >= v1.1)
function LOG_PlayerLeft(event)
    UTIL_SendPlayers(nil)
    
    if not event or not event.player_index then
        return
    end
    local player = game.players[event.player_index]

    if event.reason then
        if storage.last_playtime then
            storage.last_playtime[event.player_index] = game.tick
        end

        local reason = { "(quit)", "(dropped)", "(reconnecting)", "(wrong input)", "(too many desync)",
            "(cannot keep up)", "(afk)", "(kicked)", "(kicked and deleted)", "(banned)",
            "(switching servers)", "(unknown reason)" }
        UTIL_MsgDiscord(player.name .. " disconnected. " .. reason[event.reason + 1])

        ONLINE_UpdatePlayerList() -- online.lua
        return
    end

    ONLINE_UpdatePlayerList() -- online.lua
    UTIL_MsgDiscord(player.name .. " disconnected!")
end

function LOG_Redo(event)
    if event and event.player_index and event.actions then
        local player = game.players[event.player_index]

        local buf = ""
        for _, act in pairs(event.actions) do
            if buf ~= "" then
                buf = buf .. ", "
            end
            buf = buf .. act.type
        end
        UTIL_ConsolePrint("[ACT] " .. player.name .. " redo " .. buf .. make_gps_str_player(player))
    end
end

function LOG_Undo(event)
    if event and event.player_index and event.actions then
        local player = game.players[event.player_index]

        local buf = ""
        for _, act in pairs(event.actions) do
            if buf ~= "" then
                buf = buf .. ", "
            end
            buf = buf .. act.type
        end
        UTIL_ConsolePrint("[ACT] " .. player.name .. " undo " .. buf .. make_gps_str_player(player))
    end
end

function LOG_TrainSchedule(event)
    if event and event.player_index and event.train then
        local player = game.players[event.player_index]

        local msg = player.name ..
            " changed schedule on train ID " .. event.train.id .. " at" .. make_gps_str(player, event.train.get_rails())

        if UTIL_Is_Regular(player) or UTIL_Is_Veteran(player) or player.admin then
            UTIL_ConsolePrint("[ACT] " .. msg)
        else
            UTIL_MsgAll(msg)
        end
    end
end

function LOG_EntDied(event)
    if event and event.entity then
        if event.entity.name == "character" then
            return
        end
        UTIL_ConsolePrint(event.entity.name .. " died at" .. make_gps_str(event.entity))
    end
end

function LOG_PickedItem(event)
    if event and event.player_index and event.item_stack then
        local player = game.players[event.player_index]

        local buf = ""
        for _, item in pairs(event.item_stack) do
            if buf ~= "" then
                buf = buf .. " "
            end
            if item then
                buf = buf .. item
            end
        end

        if buf ~= "" then
            UTIL_ConsolePrint("[ACT] " .. player.name .. " picked up " .. buf .. " at" .. make_gps_str(player))
        end
    end
end

function LOG_DroppedItem(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]

        UTIL_ConsolePrint("[ACT] " .. player.name .. " dropped " .. event.entity.name .. " at" .. make_gps_str(player))
    end
end

-- Deconstruction planner warning
function LOG_Decon(event)
    if event and event.player_index and event.area then
        local player = game.players[event.player_index]
        local area = event.area

        if player and area and area.left_top then
            local decon_size = UTIL_Distance(area.left_top, area.right_bottom)

            -- Don't bother if selection is zero.
            if decon_size ~= 0 then
                local msg = ""
                if event.alt then
                    msg = "[ACT] " .. player.name .. " unmarking for deconstruction [gps=" ..
                        math.floor(area.left_top.x) .. "," .. math.floor(area.left_top.y) .. "] to [gps=" ..
                        math.floor(area.right_bottom.x) .. "," .. math.floor(area.right_bottom.y) .. "] AREA: " ..
                        math.floor(decon_size * decon_size) .. "sq"
                    if player.surface and player.surface.index ~= 1 then
                        msg = msg .. " (" .. player.surface.name .. ")"
                    end
                else
                    msg = "[ACT] " .. player.name .. " deconstructing [gps=" .. math.floor(area.left_top.x) .. "," ..
                        math.floor(area.left_top.y) .. "] to [gps=" .. math.floor(area.right_bottom.x) .. "," ..
                        math.floor(area.right_bottom.y) .. "] AREA: " .. math.floor(decon_size * decon_size) ..
                        "sq"
                    if player.surface and player.surface.index ~= 1 then
                        msg = msg .. " (" .. player.surface.name .. ")"
                    end

                    if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                        if not UTIL_Is_Banished(player) then              -- Don't let bansihed players use this to spam
                            if (storage.last_warning and game.tick - storage.last_warning >= 120) then
                                storage.last_warning = game.tick
                                UTIL_MsgAll(msg)
                            end
                        end
                    end
                end

                UTIL_ConsolePrint(msg)
            end
        end
    end
end

function LOG_MarkedUpgrade(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player then
            local msg = "[ACT] " .. player.name .. " marked for upgrade " .. obj.name

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                if not UTIL_Is_Banished(player) then              -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 120) then
                        storage.last_warning = game.tick
                        UTIL_MsgAll(msg)
                    end
                end
            end

            UTIL_ConsolePrint(msg)
        end
    end
end

function LOG_CancelUpgrade(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player then
            local msg = "[ACT] " .. player.name .. " cancelled upgrade " .. obj.name

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                if not UTIL_Is_Banished(player) then              -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 120) then
                        storage.last_warning = game.tick
                        UTIL_MsgAll(msg)
                    end
                end
            end

            UTIL_ConsolePrint(msg)
        end
    end
end

function LOG_MarkDecon(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player then
            local msg = "[ACT] " .. player.name .. " marked for deconstruction " .. obj.name

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                if not UTIL_Is_Banished(player) then              -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 120) then
                        storage.last_warning = game.tick
                        UTIL_MsgAll(msg)
                    end
                end
            end

            UTIL_ConsolePrint(msg)
        end
    end
end

function LOG_CancelDecon(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player then
            local msg = "[ACT] " .. player.name .. " cancelled deconstruction " .. obj.name

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                if not UTIL_Is_Banished(player) then              -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 120) then
                        storage.last_warning = game.tick
                        UTIL_MsgAll(msg)
                    end
                end
            end

            UTIL_ConsolePrint(msg)
        end
    end
end

function LOG_Flushed(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player and event.amount and event.fluid and event.amount >= 1 then
            local msg = "[ACT] " ..
                player.name ..
                " flushed " ..
                obj.name ..
                " of " .. math.floor(event.amount) .. " " .. event.fluid .. " at" .. make_gps_str_obj(player, obj)

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                if not UTIL_Is_Banished(player) then              -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 120) then
                        storage.last_warning = game.tick
                        UTIL_MsgAll(msg)
                    end
                end
            end

            UTIL_ConsolePrint(msg)
        end
    end
end

function LOG_PlayerDrive(event)
    if event.player_index and event.entity then
        local player = game.players[event.player_index]

        if player then
            local msg = ""
            if player.vehicle then
                msg = "[ACT] " ..
                    player.name ..
                    " got in of a " ..
                    event.entity.name .. " at" .. make_gps_str_obj(player, event.entity)
            else
                msg = "[ACT] " ..
                    player.name ..
                    " got out of a " ..
                    event.entity.name .. " at" .. make_gps_str_obj(player, event.entity)
            end

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                if not UTIL_Is_Banished(player) then              -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 120) then
                        storage.last_warning = game.tick
                        UTIL_MsgAll(msg)
                    end
                end
            end

            UTIL_ConsolePrint(msg)
        end
    end
end

function LOG_OrderLaunch(event)
    if event.player_index and event.rocket_silo then
        local player = game.players[event.player_index]

        local msg = "[ACT] " ..
            player.name .. " ordered a rocket launch at" .. make_gps_str_obj(player, event.rocket_silo)
        UTIL_ConsolePrint(msg)
        UTIL_MsgAll(msg)
    end
end

function LOG_FastTransfered(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player and obj then
            if event.from_player then
                UTIL_ConsolePrint("[ACT] " ..
                    player.name .. " fast-transfered items to " .. obj.name .. " at" .. make_gps_str_obj(player, obj))
            else
                UTIL_ConsolePrint("[ACT] " ..
                    player.name .. " fast-transfered items from " .. obj.name .. " at" .. make_gps_str_obj(player, obj))
            end
        end
    end
end

function LOG_InvChanged(event)
    if event and event.player_index then
        local player = game.players[event.player_index]

        if player then
            UTIL_ConsolePrint("[ACT] " .. player.name .. " transfered some items at" .. make_gps_str(player))
        end
    end
end

-- EVENTS--
-- Command logging
function LOG_ConsoleCmd(event)
    if event and event.command and event.parameters then
        local command = ""
        local args = ""

        if event.command then
            command = event.command
        end

        if event.parameters then
            args = event.parameters
        end

        if event.player_index then
            local player = game.players[event.player_index]
            print(string.format("[CMD] NAME: %s, COMMAND: %s, ARGS: %s", player.name, command, args))
        elseif command ~= "time" and command ~= "online" and command ~= "server-save" and command ~= "p" then -- Ignore spammy console commands
            print(string.format("[CMD] NAME: CONSOLE, COMMAND: %s, ARGS: %s", command, args))
        end
    end
end

-- Research Finished -- discord
function LOG_ResearchFinished(event)
    if event and event.research and not event.by_script then
        if event.research.level and event.research.level > 1 then
            UTIL_MsgDiscord("Research " ..
                event.research.name .. " (level " .. event.research.level - 1 .. ") completed.")
        else
            UTIL_MsgDiscord("Research " .. event.research.name .. " completed.")
        end
    end
end

function LOG_BuiltEnt(event)
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
                    
                    if storage.last_ghost_log[player.index] then
                        if game.tick - storage.last_ghost_log[player.index] > 120 then
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

function LOG_PreMined(event)
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

function LOG_Rotated(event)
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

function LOG_Flipped(event)
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

function LOG_Banned(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        if player then
            INFO_DumpInv(player, true)
            UTIL_MsgAllSys(player.name .. "'s items have been left at spawn, so they can be recovered.")
        end
    end
end
