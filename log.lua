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
            console_print("[ACT] " .. player.name .. " add-tag" .. make_gps_str_obj(player, event.tag) .. event.tag.text)
        end
    end
end

-- Edit map tag -- log
function on_chart_tag_modified(event)
    if event and event.player_index then
        local player = game.players[event.player_index]
        if player and player.valid and event.tag then
            console_print("[ACT] " .. player.name .. " mod-tag" .. make_gps_str_obj(player, event.tag) .. event.tag.text)
        end
    end
end

-- Delete map tag -- log
function on_chart_tag_removed(event)
    if event and event.player_index then
        local player = game.players[event.player_index]

        -- Because factorio will hand us an nil event... nice.
        if player and player.valid and event.tag then
            console_print("[ACT] " .. player.name .. " del-tag" .. make_gps_str_obj(player, event.tag) .. event.tag.text)

            -- Delete corpse map tag and corpse_lamp
            for i, ctag in pairs(storage.corpselist) do
                if ctag.tag and ctag.tag.valid then
                    if event.tag.text == ctag.tag.text and ctag.pos.x == event.tag.position.x and ctag.pos.y ==
                        event.tag.position.y then
                        -- Destroy corpse lamp
                        ctag.corpse_lamp.destroy()

                        index = i
                        break
                    end
                end
            end

            -- Properly remove items
            if storage.corpselist and index then
                table.remove(storage.corpselist, index)
            end
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
            buf = buf .. act.type .. ", "
        end
        console_print("[ACT] " .. player.name .. " redo " .. buf .. make_gps_str_player(player))
    end
end

function on_undo_applied(event)
    if event and event.player_index and event.actions then
        local player = game.players[event.player_index]

        local buf = ""
        for _, act in pairs(event.actions) do
            buf = buf .. act.type .. ", "
        end
        console_print("[ACT] " .. player.name .. " undo " .. buf .. make_gps_str_player(player))
    end
end

function on_train_schedule_changed(event)
    if event and event.player_index and event.train then
        local player = game.players[event.player_index]

        console_print("[ACT] " ..
        player.name ..
        " changed schedule on train id#" .. event.train.id .. " at " .. make_gps_str_obj(player, event.train))
    end
end

function on_entity_died(event)
    if event and event.entity then
        if event.entity.surface then
            console_print("[ACT] " .. event.entity.name .. " died on " .. event.entity.surface.name .. " at " .. make_gps_str(event.entity))
        else
            console_print("[ACT] " .. event.entity.name .. " died at " .. make_gps_str(event.entity))
        end
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
                            if (storage.last_decon_warning and game.tick - storage.last_decon_warning >= 15) then
                                storage.last_decon_warning = game.tick
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
