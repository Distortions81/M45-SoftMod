-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "utility"

-- Create player groups if they don't exist, and create storage links to them
function create_groups()
    storage.defaultgroup = game.permissions.get_group("Default")
    storage.membersgroup = game.permissions.get_group("Members")
    storage.regularsgroup = game.permissions.get_group("Regulars")
    storage.veteransgroup = game.permissions.get_group("Veterans")
    storage.modsgroup = game.permissions.get_group("Moderators")

    if (not storage.defaultgroup) then
        game.permissions.create_group("Default")
    end

    if (not storage.membersgroup) then
        game.permissions.create_group("Members")
    end

    if (not storage.regularsgroup) then
        game.permissions.create_group("Regulars")
    end

    if (not storage.veteransgroup) then
        game.permissions.create_group("Veterans")
    end

    if (not storage.modsgroup) then
        game.permissions.create_group("Moderators")
    end

    storage.defaultgroup = game.permissions.get_group("Default")
    storage.membersgroup = game.permissions.get_group("Members")
    storage.regularsgroup = game.permissions.get_group("Regulars")
    storage.veteransgroup = game.permissions.get_group("Veterans")
    storage.modsgroup = game.permissions.get_group("Moderators")

end

function set_blueprints_enabled(group, option)
    if group ~= nil then
        group.set_allows_action(defines.input_action.alt_select_blueprint_entities, option)
        group.set_allows_action(defines.input_action.cancel_new_blueprint, option)
        group.set_allows_action(defines.input_action.copy_opened_blueprint, option)
        group.set_allows_action(defines.input_action.copy_opened_blueprint, option)
        group.set_allows_action(defines.input_action.cycle_blueprint_book_backwards, option)
        group.set_allows_action(defines.input_action.cycle_blueprint_book_forwards, option)
        group.set_allows_action(defines.input_action.delete_blueprint_library, option)
        group.set_allows_action(defines.input_action.delete_blueprint_record, option)
        group.set_allows_action(defines.input_action.drop_blueprint_record, option)
        group.set_allows_action(defines.input_action.edit_blueprint_tool_preview, option)
        group.set_allows_action(defines.input_action.export_blueprint, option)
        group.set_allows_action(defines.input_action.grab_blueprint_record, option)
        group.set_allows_action(defines.input_action.import_blueprint, option)
        group.set_allows_action(defines.input_action.import_blueprint_string, option)
        group.set_allows_action(defines.input_action.import_blueprints_filtered, option)
        group.set_allows_action(defines.input_action.open_blueprint_library_gui, option)
        group.set_allows_action(defines.input_action.open_blueprint_record, option)
        group.set_allows_action(defines.input_action.reassign_blueprint, option)
        group.set_allows_action(defines.input_action.select_blueprint_entities, option)
        group.set_allows_action(defines.input_action.setup_blueprint, option)
        group.set_allows_action(defines.input_action.setup_single_blueprint_record, option)
        group.set_allows_action(defines.input_action.upgrade_opened_blueprint_by_item, option)
        group.set_allows_action(defines.input_action.upgrade_opened_blueprint_by_record, option)
    end
end

-- Disable some permissions for new players, minimal mode
function set_perms()
    -- Auto set default group permissions

    if storage.defaultgroup then

        -- If new user restrictions are on, then disable all permissions
        -- Otherwise undo
        local option = true
        if storage.restrict then
            option = false
        end

        storage.defaultgroup.set_allows_action(defines.input_action.build_terrain, option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_programmable_speaker_alert_parameters, option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_programmable_speaker_circuit_parameters,
            option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_programmable_speaker_parameters, option)
        storage.defaultgroup.set_allows_action(defines.input_action.deconstruct, option)
        storage.defaultgroup.set_allows_action(defines.input_action.launch_rocket, option)
        storage.defaultgroup.set_allows_action(defines.input_action.cancel_research, option)
        storage.defaultgroup.set_allows_action(defines.input_action.cancel_upgrade, option)
        storage.defaultgroup.set_allows_action(defines.input_action.paste_entity_settings, option)
        storage.defaultgroup.set_allows_action(defines.input_action.upgrade, option)

        -- Added 1-2022
        storage.defaultgroup.set_allows_action(defines.input_action.delete_blueprint_library, option)
        storage.defaultgroup.set_allows_action(defines.input_action.drop_blueprint_record, option)
        storage.defaultgroup.set_allows_action(defines.input_action.import_blueprint, option)
        storage.defaultgroup.set_allows_action(defines.input_action.import_blueprint_string, option)
        storage.defaultgroup.set_allows_action(defines.input_action.import_blueprints_filtered, option)
        storage.defaultgroup.set_allows_action(defines.input_action.reassign_blueprint, option)
        storage.defaultgroup.set_allows_action(defines.input_action.cancel_deconstruct, option)
        storage.defaultgroup.set_allows_action(defines.input_action.send_spidertron, option)

        -- Wube removed this, great.
        -- storage.defaultgroup.set_allows_action(defines.input_action.activate_cut, false)
    end
end

-- Disable some permissions for new players
function set_hperms()
    -- Auto set default group permissions

    if storage.defaultgroup then

        -- If new user restrictions are on, then disable all permissions
        -- Otherwise undo
        local option = true
        if storage.restrict then
            option = false
        end

        storage.defaultgroup.set_allows_action(defines.input_action.wire_dragging, option)
        storage.defaultgroup.set_allows_action(defines.input_action.add_train_station, option)
        storage.defaultgroup.set_allows_action(defines.input_action.build_terrain, option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_arithmetic_combinator_parameters, option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_decider_combinator_parameters, option)
        storage.defaultgroup.set_allows_action(defines.input_action.switch_constant_combinator_state, option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_programmable_speaker_alert_parameters, option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_programmable_speaker_circuit_parameters,
            option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_programmable_speaker_parameters, option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_train_stop_station, option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_train_wait_condition, option)
        storage.defaultgroup.set_allows_action(defines.input_action.change_train_wait_condition_data, option)
        storage.defaultgroup.set_allows_action(defines.input_action.connect_rolling_stock, option)
        storage.defaultgroup.set_allows_action(defines.input_action.deconstruct, option)
        storage.defaultgroup.set_allows_action(defines.input_action.disconnect_rolling_stock, option)
        storage.defaultgroup.set_allows_action(defines.input_action.drag_train_schedule, option)
        storage.defaultgroup.set_allows_action(defines.input_action.drag_train_wait_condition, option)
        storage.defaultgroup.set_allows_action(defines.input_action.launch_rocket, option)
        storage.defaultgroup.set_allows_action(defines.input_action.remove_cables, option)
        storage.defaultgroup.set_allows_action(defines.input_action.remove_train_station, option)
        storage.defaultgroup.set_allows_action(defines.input_action.set_auto_launch_rocket, option)
        storage.defaultgroup.set_allows_action(defines.input_action.set_circuit_condition, option)
        storage.defaultgroup.set_allows_action(defines.input_action.set_circuit_mode_of_operation, option)
        storage.defaultgroup.set_allows_action(defines.input_action.set_logistic_filter_item, option)
        storage.defaultgroup.set_allows_action(defines.input_action.set_logistic_filter_signal, option)
        storage.defaultgroup.set_allows_action(defines.input_action.set_request_from_buffers, option)
        storage.defaultgroup.set_allows_action(defines.input_action.set_signal, option)
        storage.defaultgroup.set_allows_action(defines.input_action.set_train_stopped, option)
        -- Added 12-2020
        storage.defaultgroup.set_allows_action(defines.input_action.cancel_research, option)
        storage.defaultgroup.set_allows_action(defines.input_action.cancel_upgrade, option)
        storage.defaultgroup.set_allows_action(defines.input_action.build_rail, option)
        storage.defaultgroup.set_allows_action(defines.input_action.activate_paste, option)
        storage.defaultgroup.set_allows_action(defines.input_action.flush_opened_entity_fluid, option)
        storage.defaultgroup.set_allows_action(defines.input_action.flush_opened_entity_specific_fluid, option)
        storage.defaultgroup.set_allows_action(defines.input_action.paste_entity_settings, option)
        storage.defaultgroup.set_allows_action(defines.input_action.use_artillery_remote, option)
        storage.defaultgroup.set_allows_action(defines.input_action.upgrade, option)

        -- Added 1-2022
        storage.defaultgroup.set_allows_action(defines.input_action.delete_blueprint_library, option)
        storage.defaultgroup.set_allows_action(defines.input_action.drop_blueprint_record, option)
        storage.defaultgroup.set_allows_action(defines.input_action.import_blueprint, option)
        storage.defaultgroup.set_allows_action(defines.input_action.import_blueprint_string, option)
        storage.defaultgroup.set_allows_action(defines.input_action.import_blueprints_filtered, option)
        storage.defaultgroup.set_allows_action(defines.input_action.reassign_blueprint, option)
        storage.defaultgroup.set_allows_action(defines.input_action.cancel_deconstruct, option)
        storage.defaultgroup.set_allows_action(defines.input_action.activate_copy, option)
        storage.defaultgroup.set_allows_action(defines.input_action.alternative_copy, option)
        storage.defaultgroup.set_allows_action(defines.input_action.send_spidertron, option)
    end
end

-- Flag player as currently moving
function set_player_moving(player)
    if (player and player.valid and player.connected and player.character and player.character.valid and
        storage.playermoving) then
        -- banished players don't get move score
        if is_banished(player) == false then
            storage.playermoving[player.index] = true
        end
    end
end

-- Flag player as currently active
function set_player_active(player)
    if (player and player.valid and player.connected and player.character and player.character.valid and
        storage.playeractive) then
        -- banished players don't get activity score
        if is_banished(player) == false then
            storage.playeractive[player.index] = true
        end
    end
end

-- Set our default game-settings
function game_settings(player)
    if player and player.valid and player.force and not storage.gset then
        storage.gset = true -- Only apply these once
        player.force.friendly_fire = false -- friendly fire
        game.disable_replay() -- Smaller saves, prevent desync on script upgrade
    end
end

-- Automatically promote users to higher levels
function get_permgroup()

    -- Skip if permissions are disabled
    if game.connected_players and storage.disableperms == false then
        -- Check all connected players
        for _, player in pairs(game.connected_players) do
            if (player and player.valid) then
                -- Check if groups are valid
                if (storage.defaultgroup and storage.membersgroup and storage.regularsgroup and storage.modsgroup) then
                    if player.permission_group then
                        -- (Moderators) Check if they are in the right group, including se-remote-view
                        if (player.admin and player.permission_group.name ~= storage.modsgroup.name and
                            player.permission_group.name ~= storage.modsgroup.name .. "_satellite") then
                            -- (REGULARS) Check if they are in the right group, including se-remote-view
                            storage.modsgroup.add_player(player)
                            message_all(player.name .. " moved to moderators group")
                        elseif (storage.active_playtime and storage.active_playtime[player.index] and
                            storage.active_playtime[player.index] > (4 * 60 * 60 * 60) and not player.admin) then
                            -- Check if player has hours for regulars status, but isn't a in regulars group.
                            if (player.permission_group.name ~= storage.regularsgroup.name and
                                player.permission_group.name ~= storage.veteransgroup.name and
                                player.permission_group.name ~= storage.regularsgroup.name .. "_satellite" and
                                player.permission_group.name ~= storage.veteransgroup.name .. "_satellite") then
                                storage.regularsgroup.add_player(player)
                                message_all(player.name .. " is now a regular!")
                                show_member_welcome(player)
                            end
                        elseif (storage.active_playtime and storage.active_playtime[player.index] and
                            storage.active_playtime[player.index] > (30 * 60 * 60) and not player.admin) then
                            -- Check if player has hours for members status, but isn't a in member group.
                            if is_veteran(player) == false and is_regular(player) == false and is_member(player) ==
                                false and is_new(player) == true then
                                storage.membersgroup.add_player(player)
                                message_all(player.name .. " is now a member!")
                                show_member_welcome(player)
                            end
                        end
                    end
                end
            end
        end
    end
end

function show_member_welcome(player)
    if player then
        if player.gui.screen then
            if player.gui.screen.member_welcome then
                player.gui.screen.member_welcome.destroy()
            else
                local tfont = "[font=default-large-bold]"
                local efont = "[/font]"

                local lname = "members"
                if is_regular(player) then
                    lname = "regulars"
                end

                local main_flow = player.gui.screen.add {
                    type = "frame",
                    name = "member_welcome",
                    direction = "vertical"
                }

                local info_titlebar = main_flow.add {
                    type = "flow",
                    direction = "horizontal"
                }

                info_titlebar.drag_target = main_flow
                info_titlebar.add {
                    type = "label",
                    name = "member_welcome_title",
                    style = "frame_title",
                    caption = "Congratulations!"
                }

                local pusher = info_titlebar.add {
                    type = "empty-widget",
                    style = "draggable_space_header"
                }

                pusher.style.vertically_stretchable = true
                pusher.style.horizontally_stretchable = true
                pusher.drag_target = main_flow

                info_titlebar.add {
                    type = "sprite-button",
                    name = "m45_member_welcome_close",
                    sprite = "utility/close",
                    style = "frame_action_button",
                    tooltip = "Close this window"
                }

                main_flow.style.padding = 4
                local mframe = main_flow.add {
                    type = "flow",
                    direction = "horizontal"
                }
                local lframe = mframe.add {
                    type = "flow",
                    direction = "vertical"
                }
                lframe.style.padding = 4
                lframe.add {
                    type = "sprite",
                    sprite = "file/img/info-win/m45-128.png",
                    tooltip = ""
                }

                local rframe = mframe.add {
                    type = "flow",
                    direction = "vertical"
                }
                rframe.add {
                    type = "label",
                    caption = tfont .. "You have been active enough, that you have automatically been promoted to the '" ..
                        lname .. "' group!" .. efont
                }
                rframe.add {
                    type = "label",
                    caption = tfont .. "You can now access members-only servers and have increased permissions!" ..
                        efont
                }

                if is_regular(player) then
                    rframe.add {
                        type = "label",
                        caption = tfont .. "You now also have access to BANISH in the players-online window:" .. efont
                    }
                    local online_32 = rframe.add {
                        type = "sprite-button",
                        name = "online_button",
                        sprite = "file/img/buttons/online-64.png",
                        tooltip = "See players online!"
                    }
                    online_32.style.size = {64, 64}
                    rframe.add {
                        type = "label",
                        caption = tfont .. "You can also vote to rewind, reset, or skip-reset the map on Discord." ..
                            efont
                    }
                end

                rframe.add {
                    type = "label",
                    caption = ""
                }

                rframe.add {
                    type = "label",
                    caption = tfont .. "To find out more, click the SERVER-INFO button here: " .. efont
                }
                local m45_32 = rframe.add {
                    type = "sprite-button",
                    name = "m45_button",
                    sprite = "file/img/buttons/m45-64.png",
                    tooltip = "Opens the server-info window"
                }
                m45_32.style.size = {64, 64}
            end
        end
    end
end
