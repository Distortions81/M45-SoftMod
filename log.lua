-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "utility"

-- Create map tag -- log
function on_chart_tag_added(event)
    if event and event.player_index then
        local player = game.players[event.player_index]

        if player and player.valid and event.tag then
            message_all(player.name .. " add-tag" .. make_gps_str_obj(player, event.tag) .. event.tag.text)
        end
    end
end

-- Edit map tag -- log
function on_chart_tag_modified(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        if player and player.valid and event.tag then
            message_all(player.name .. " mod-tag" .. make_gps_str_obj(player, event.tag) .. event.tag.text)
        end
    end
end

-- Delete map tag -- log
function on_chart_tag_removed(event)
    if event and event.player_index then
        local player = game.players[event.player_index]

        -- Because factorio will hand us an nil event... nice.
        if player and player.valid and event.tag then
            message_all(player.name .. " del-tag" .. make_gps_str_obj(player, event.tag) .. event.tag.text)
        end
    end
end

-- Player disconnect messages, with reason (Fact >= v1.1)
function on_player_left_game(event)
    if event and event.player_index and event.reason then
        local player = game.players[event.player_index]
        if player then
            if storage.last_playtime then
                storage.last_playtime[event.player_index] = game.tick
            end

            local reason = { "(quit)", "(dropped)", "(reconnecting)", "(wrong input)", "(too many desync)",
                "(cannot keep up)", "(afk)", "(kicked)", "(kicked and deleted)", "(banned)",
                "(switching servers)", "(unknown reason)" }
            message_alld(player.name .. " disconnected. " .. reason[event.reason + 1])

            update_player_list() -- online.lua
            return
        end
    end

    local player = game.players[event.player_index]
    update_player_list() -- online.lua
    message_alld(player.name .. " disconnected!")
end

function on_redo_applied(event)
    if event and event.player_index and event.actions then
        local player = game.players[event.player_index]

        local buf = ""
        for _, act in pairs(event.actions) do
            if buf ~= "" then
                buf = buf .. ", "
            end
            buf = buf .. act.type
        end
        console_print("[ACT] " .. player.name .. " redo " .. buf .. make_gps_str_player(player))
    end
end

function on_undo_applied(event)
    if event and event.player_index and event.actions then
        local player = game.players[event.player_index]

        local buf = ""
        for _, act in pairs(event.actions) do
            if buf ~= "" then
                buf = buf .. ", "
            end
            buf = buf .. act.type
        end
        console_print("[ACT] " .. player.name .. " undo " .. buf .. make_gps_str_player(player))
    end
end

function on_train_schedule_changed(event)
    if event and event.player_index and event.train then
        local player = game.players[event.player_index]

        local msg = player.name ..
            " changed schedule on train ID " .. event.train.id .. " at" .. make_gps_str(player, event.train.get_rails())

        if is_regular(player) or is_veteran(player) or player.admin then
            console_print("[ACT] " .. msg)
        else
            message_all(msg)
        end
    end
end

function on_entity_died(event)
    if event and event.entity then
        if event.entity.name == "character" then
            return
        end
        message_all(event.entity.name .. " died at" .. make_gps_str(event.entity))
    end
end

function on_picked_up_item(event)
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
            console_print("[ACT] " .. player.name .. " picked up " .. buf .. " at" .. make_gps_str(player))
        end
    end
end

function on_player_dropped_item(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]

        console_print("[ACT] " .. player.name .. " dropped " .. event.entity.name .. " at" .. make_gps_str(player))
    end
end

-- Deconstruction planner warning
function on_player_deconstructed_area(event)
    if event and event.player_index and event.area then
        local player = game.players[event.player_index]
        local area = event.area

        if player and area and area.left_top then
            local decon_size = dist_to(area.left_top, area.right_bottom)

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

                    if is_new(player) or is_member(player) then -- Dont bother with regulars/moderators
                        if not is_banished(player) then         -- Don't let bansihed players use this to spam
                            if (storage.last_warning and game.tick - storage.last_warning >= 15) then
                                storage.last_warning = game.tick
                                message_all(msg)
                            end
                        end
                    end
                end

                console_print(msg)
            end
        end
    end
end

function on_marked_for_upgrade(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player then
            local msg = "[ACT] " .. player.name .. " marked for upgrade " .. obj.name

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if is_new(player) or is_member(player) then -- Dont bother with regulars/moderators
                if not is_banished(player) then         -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 15) then
                        storage.last_warning = game.tick
                        message_all(msg)
                    end
                end
            end

            console_print(msg)
        end
    end
end

function on_cancelled_upgrade(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player then
            local msg = "[ACT] " .. player.name .. " cancelled upgrade " .. obj.name

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if is_new(player) or is_member(player) then -- Dont bother with regulars/moderators
                if not is_banished(player) then         -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 15) then
                        storage.last_warning = game.tick
                        message_all(msg)
                    end
                end
            end

            console_print(msg)
        end
    end
end

function on_marked_for_deconstruction(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player then
            local msg = "[ACT] " .. player.name .. " marked for deconstruction " .. obj.name

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if is_new(player) or is_member(player) then -- Dont bother with regulars/moderators
                if not is_banished(player) then         -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 15) then
                        storage.last_warning = game.tick
                        message_all(msg)
                    end
                end
            end

            console_print(msg)
        end
    end
end

function on_cancelled_deconstruction(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player then
            local msg = "[ACT] " .. player.name .. " cancelled deconstruction " .. obj.name

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if is_new(player) or is_member(player) then -- Dont bother with regulars/moderators
                if not is_banished(player) then         -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 15) then
                        storage.last_warning = game.tick
                        message_all(msg)
                    end
                end
            end

            console_print(msg)
        end
    end
end

function on_player_flushed_fluid(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player then
            local msg = "[ACT] " ..
                player.name ..
                " flushed " ..
                obj.name .. " of " .. event.amount .. " " .. event.fluid .. " at" .. make_gps_str_obj(player, obj)

            if player.surface and player.surface.index ~= 1 then
                msg = msg .. " (" .. player.surface.name .. ")"
            end

            if is_new(player) or is_member(player) then -- Dont bother with regulars/moderators
                if not is_banished(player) then         -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 15) then
                        storage.last_warning = game.tick
                        message_all(msg)
                    end
                end
            end

            console_print(msg)
        end
    end
end

function on_player_driving_changed_state(event)
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

            if is_new(player) or is_member(player) then -- Dont bother with regulars/moderators
                if not is_banished(player) then         -- Don't let bansihed players use this to spam
                    if (storage.last_warning and game.tick - storage.last_warning >= 15) then
                        storage.last_warning = game.tick
                        message_all(msg)
                    end
                end
            end

            console_print(msg)
        end
    end
end

function on_rocket_launch_ordered(event)
    if event.player_index and event.rocket_silo then
        local msg = "[ACT] " ..
            player.name .. " ordered a rocket launch at" .. make_gps_str_obj(player, event.rocket_silo)
        console_print(msg)
        message_all(msg)
    end
end

function on_player_fast_transferred(event)
    if event and event.player_index and event.entity then
        local player = game.players[event.player_index]
        local obj = event.entity

        if player and obj then
            if event.from_player then
                console_print("[ACT] " ..
                player.name .. " fast-transfered items to " .. obj.name .. " at" .. make_gps_str_obj(player, obj))
            else
                console_print("[ACT] " ..
                player.name .. " fast-transfered items from " .. obj.name .. " at" .. make_gps_str_obj(player, obj))
            end
        end
    end
end

function on_player_main_inventory_changed(event)
    if event and event.player_index then
        local player = game.players[event.player_index]

        if player then
            console_print("[ACT] " .. player.name .. " transfered some items at" .. make_gps_str(player))
        end
    end
end

-- EVENTS--
-- Command logging
function on_console_command(event)
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
function on_research_finished(event)
    if event and event.research and not event.by_script then
        if event.research.level and event.research.level > 1 then
            message_alld("Research " .. event.research.name .. " (level " .. event.research.level - 1 .. ") completed.")
        else
            message_alld("Research " .. event.research.name .. " completed.")
        end
    end
end
