-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

-- Create map tag -- log
function LOG_TagAdded(event)
    if not event or not event.player_index or not event.tag then
        return
    end
    local player = game.players[event.player_index]

    if event.tag.icon and event.tag.icon.name then
        UTIL_MsgAll(player.name .. " add-tag "
            .. UTIL_GPSPos(event.tag) .. " : " .. event.tag.icon.name .. " " .. event.tag.text)
    else
        UTIL_MsgAll(player.name .. " add-tag "
            .. UTIL_GPSPos(event.tag) .. " : " .. event.tag.text)
    end
end

-- Edit map tag -- log
function LOG_TagMod(event)
    if not event or not event.player_index or not event.tag then
        return
    end
    local player = game.players[event.player_index]
    if event.tag.icon and event.tag.icon.name then
        UTIL_MsgAll(player.name .. " edit-tag "
            .. UTIL_GPSPos(event.tag) .. " : " .. event.tag.icon.name .. " " .. event.tag.text)
    else
        UTIL_MsgAll(player.name .. " edit-tag "
            .. UTIL_GPSPos(event.tag) .. " : " .. event.tag.text)
    end
end

-- Delete map tag -- log
function LOG_TagDel(event)
    if not event or not event.player_index or not event.tag then
        return
    end
    local player = game.players[event.player_index]

    if event.tag.icon and event.tag.icon.name then
        UTIL_MsgAll(player.name .. " delete-tag "
            .. UTIL_GPSPos(event.tag) .. " : " .. event.tag.icon.name .. " " .. event.tag.text)
    else
        UTIL_MsgAll(player.name .. " delete-tag "
            .. UTIL_GPSPos(event.tag) .. " : " .. event.tag.text)
    end
end

-- Player disconnect messages, with reason (Fact >= v1.1)
function LOG_PlayerLeft(event)
    if not event or not event.player_index or not storage.PData then
        return
    end
    storage.PData[event.player_index].lastOnline = game.tick
    local player = game.players[event.player_index]

    if event.reason then
        local reason = { "(quit)", "(dropped)", "(reconnecting)", "(wrong input)", "(too many desync)",
            "(cannot keep up)", "(afk)", "(kicked)", "(kicked and deleted)", "(banned)",
            "(switching servers)", "(unknown reason)" }
        UTIL_MsgDiscord(player.name .. " disconnected. " .. reason[event.reason + 1])
    else
        UTIL_MsgDiscord(player.name .. " disconnected!")
    end

    ONLINE_UpdatePlayerList()
end

function LOG_Redo(event)
    if not event or not event.player_index or not event.actions then
        return
    end
    local player = game.players[event.player_index]

    local buf = ""
    for _, act in pairs(event.actions) do
        if buf ~= "" then
            buf = buf .. ", "
        end
        buf = buf .. act.type
    end
    UTIL_ConsolePrint("[ACT] " .. player.name .. " redo " .. buf .. player.character.gps_tag)
end

function LOG_Undo(event)
    if not event or not event.player_index or not event.actions then
        return
    end
    local player = game.players[event.player_index]

    local buf = ""
    for _, act in pairs(event.actions) do
        if buf ~= "" then
            buf = buf .. ", "
        end
        buf = buf .. act.type
    end
    UTIL_ConsolePrint("[ACT] " .. player.name .. " undo " .. buf .. player.character.gps_tag)
end

function LOG_TrainSchedule(event)
    if not event or not event.player_index or not event.train then
        return
    end
    local player = game.players[event.player_index]

    local msg = player.name ..
        " changed schedule on train ID " .. event.train.id .. " at " .. event.train.gps_tag

    if UTIL_Is_Regular(player) or UTIL_Is_Veteran(player) or player.admin then
        UTIL_ConsolePrint("[ACT] " .. msg)
    else
        UTIL_MsgAll(msg)
    end
end

function LOG_EntDied(event)
    if event and event.entity then
        if event.entity.name == "character" then
            return
        end
        UTIL_ConsolePrint(event.entity.name .. " died at " .. event.entity.gps_tag)
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
            UTIL_ConsolePrint("[ACT] " .. player.name .. " picked up " .. buf .. " at " .. player.character.gps_tag)
        end
    end
end

function LOG_DroppedItem(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]

        UTIL_ConsolePrint("[ACT] " ..
            player.name .. " dropped " .. event.entity.name .. " at " .. player.character.gps_tag)
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
            if decon_size > 0 then
                local msg = ""
                if event.alt then
                    msg = "[ACT] " ..
                        player.name ..
                        " at " ..
                        player.character.gps_tag ..
                        " is unmarking for deconstruction " .. UTIL_Area(decon_size, event.area)
                else
                    msg = "[ACT] " ..
                        player.name ..
                        " at " .. player.character.gps_tag .. " is deconstructing " .. UTIL_Area(decon_size, event.area)

                    if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                        if not UTIL_Is_Banished(player) then              -- Don't let bansihed players use this to spam
                            UTIL_MsgAll(msg)
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
                    if UTIL_WarnOkay(event.player_index) then
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
                    if UTIL_WarnOkay(event.player_index) then
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
                    if UTIL_WarnOkay(event.player_index) then
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
                    if UTIL_WarnOkay(event.player_index) then
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
                " of " .. math.floor(event.amount) .. " " .. event.fluid .. " at " .. obj.gps_tag

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                UTIL_MsgAll(msg)
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
                    event.entity.name .. " at " .. event.entity.gps_tag
            else
                msg = "[ACT] " ..
                    player.name ..
                    " got out of a " ..
                    event.entity.name .. " at " .. event.entity.gps_tag
            end

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if UTIL_Is_New(player) or UTIL_Is_Member(player) then -- Dont bother with regulars/moderators
                UTIL_MsgAll(msg)
            end

            UTIL_ConsolePrint(msg)
        end
    end
end

function LOG_OrderLaunch(event)
    if event.player_index and event.rocket_silo then
        local player = game.players[event.player_index]

        local msg = "[ACT] " ..
            player.name .. " ordered a rocket launch at " .. event.rocket_silo.gps_tag
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
                    player.name .. " fast-transfered items to " .. obj.name .. " at " .. obj.gps_tag)
            else
                UTIL_ConsolePrint("[ACT] " ..
                    player.name .. " fast-transfered items from " .. obj.name .. " at " .. obj.gps_tag)
            end
        end
    end
end

function LOG_InvChanged(event)
    if event and event.player_index then
        local player = game.players[event.player_index]

        if player then
            UTIL_ConsolePrint("[ACT] " .. player.name .. " transfered some items at " .. player.character.gps_tag)
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
    if not event or not event.player_index or not event.entity then
        return
    end
    local player = game.players[event.player_index]
    local obj = event.entity

    if obj.name == "programmable-speaker" or
        (obj.name == "entity-ghost" and obj.ghost_name == "programmable-speaker") then
        UTIL_MsgAll(player.name .. " placed a speaker at " .. obj.gps_tag)
        return
    end

    if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
        if obj.name ~= "entity-ghost" then
            UTIL_ConsolePrint("[ACT] " .. player.name .. " placed " .. obj.name .. " " .. obj.gps_tag)
        else
            if UTIL_WarnOkay(event.player_index) then
                UTIL_ConsolePrint("[ACT] " ..
                    player.name .. " placed-ghost " .. obj.name .. " " .. obj.gps_tag ..
                    obj.ghost_name)
            end
        end
    end
end

function LOG_PreMined(event)
    if not event or not event.player_index or not event.entity then
        return
    end
    local player = game.players[event.player_index]
    local obj = event.entity

    if obj.force.name ~= "enemy" and obj.force.name ~= "neutral" then
        if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
            if obj.name ~= "entity-ghost" then
                -- log
                UTIL_ConsolePrint("[ACT] " .. player.name .. " mined " .. obj.name .. " " .. obj.gps_tag)

                -- Mark player as having picked up an item, and needing to be cleaned.
                if storage.PData[event.player_index].cleaned then
                    storage.PData[event.player_index].cleaned = false
                end
            else
                UTIL_ConsolePrint("[ACT] " ..
                    player.name .. " mined-ghost " .. obj.name .. " " .. obj.gps_tag ..
                    obj.ghost_name)
            end
        end
    else
        EVENT_Loot(event)
    end
end

function LOG_Rotated(event)
    if not event or not event.player_index or not event.previous_direction then
        return
    end

    local player = game.players[event.player_index]
    local obj = event.entity

    -- If player and object are valid
    if obj.name ~= "tile-ghost" and obj.name ~= "tile" then
        if obj.name ~= "entity-ghost" then
            UTIL_ConsolePrint("[ACT] " .. player.name .. " rotated " .. obj.name .. " " .. obj.gps_tag)
        else
            UTIL_ConsolePrint("[ACT] " ..
                player.name .. " rotated ghost " .. obj.name .. obj.gps_tag ..
                " " .. obj.ghost_name)
        end
    end
end

function LOG_Banned(event)
    if not event or not event.player_index then
        return
    end
    local player = game.players[event.player_index]
    INFO_DumpInv(player, true)
    UTIL_MsgAllSys(player.name .. "'s items have been left at spawn, so they can be recovered.")
end
