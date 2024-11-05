-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

-- Create player groups if they don't exist, and create storage links to them
function PERMS_MakeUserGroups()
    storage.SM_Store.defGroup = game.permissions.get_group("Default")
    storage.SM_Store.memGroup = game.permissions.get_group("Members")
    storage.SM_Store.regGroup = game.permissions.get_group("Regulars")
    storage.SM_Store.vetGroup = game.permissions.get_group("Veterans")
    storage.SM_Store.modGroup = game.permissions.get_group("Moderators")

    if (not storage.SM_Store.defGroup) then
        game.permissions.create_group("Default")
    end

    if (not storage.SM_Store.memGroup) then
        game.permissions.create_group("Members")
    end

    if (not storage.SM_Store.regGroup) then
        game.permissions.create_group("Regulars")
    end

    if (not storage.SM_Store.vetGroup) then
        game.permissions.create_group("Veterans")
    end

    if (not storage.SM_Store.modGroup) then
        game.permissions.create_group("Moderators")
    end

    storage.SM_Store.defGroup  = game.permissions.get_group("Default")
    storage.SM_Store.memGroup = game.permissions.get_group("Members")
    storage.SM_Store.regGroup  = game.permissions.get_group("Regulars")
    storage.SM_Store.vetGroup = game.permissions.get_group("Veterans")
    storage.SM_Store.modGroup = game.permissions.get_group("Moderators")
end

function PERMS_SetBlueprintsAllowed(group, option)
    if group then
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
function PERMS_SetPermissions()
    -- Auto set default group permissions

    if storage.SM_Store.defGroup then
        -- If new user restrictions are on, then disable all permissions
        -- Otherwise undo
        local option = true
        if storage.newRestrict then
            option = false
        end

        storage.SM_Store.defGroup.set_allows_action(defines.input_action.change_programmable_speaker_alert_parameters, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.change_programmable_speaker_circuit_parameters,
            option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.change_programmable_speaker_parameters, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.launch_rocket, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.cancel_research, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.cancel_upgrade, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.upgrade, option)

        -- Added 1-2022
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.delete_blueprint_library, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.drop_blueprint_record, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.import_blueprint, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.import_blueprint_string, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.import_blueprints_filtered, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.reassign_blueprint, option)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.cancel_deconstruct, option)

        -- Added 10-2024
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.deconstruct, false)
        storage.SM_Store.defGroup.set_allows_action(defines.input_action.activate_paste, false)
    end
end

-- Flag player as currently moving
function PERMS_SetPlayerMoving(player)
    if (player and player.connected ) then
        -- banished players don't get move score
        if UTIL_Is_Banished(player) == false then
            storage.PData[player.index].moving = true
        end
    end
end

-- Flag player as currently active
function PERMS_SetPlayerActive(player)
    if (player and player.connected) then
        -- banished players don't get activity score
        if UTIL_Is_Banished(player) == false then
            storage.PData[player.index].active = true
        end
    end
end

function PERMS_PromotePlayer(player)
    -- Check if groups are valid
    if player.permission_group then
        -- (Moderators) Check if they are in the right group, including se-remote-view
        if (player.admin and player.permission_group.name ~= storage.modsgroup.name) then
            -- (REGULARS) Check if they are in the right group, including se-remote-view
            storage.modsgroup.add_player(player)
            UTIL_MsgAll(player.name .. " moved to moderators group")
        elseif (storage.PData[player.index].score and
                storage.PData[player.index].score > (4 * 60 * 60 * 60) and not player.admin) then
            -- Check if player has hours for regulars status, but isn't a in regulars group.
            if (player.permission_group.name ~= storage.regularsgroup.name and
                    player.permission_group.name ~= storage.veteransgroup.name) then
                storage.regularsgroup.add_player(player)
                UTIL_MsgAll(player.name .. " is now a regular!")
                PERMS_WelcomeMember(player)
            end
        elseif (storage.PData[player.index].score and
                storage.PData[player.index].score > (30 * 60 * 60) and not player.admin) then
            -- Check if player has hours for members status, but isn't a in member group.
            if UTIL_Is_Veteran(player) == false and UTIL_Is_Regular(player) == false and UTIL_Is_Member(player) ==
                false and UTIL_Is_New(player) == true then
                storage.membersgroup.add_player(player)
                UTIL_MsgAll(player.name .. " is now a member!")
                PERMS_WelcomeMember(player)
            end
        end
    end
end

-- Automatically promote users to higher levels
function PERMS_AutoPromotePlayer()
    -- Skip if permissions are disabled
    if game.connected_players and storage.disableperms == false then
        -- Check all connected players
        for _, player in pairs(game.connected_players) do
            if (player and player.valid) then
                PERMS_PromotePlayer(player)
            end
        end
    end
end



function PERMS_WelcomeMember(player)
    if player then
        if player.gui.screen then
            if player.gui.screen.member_welcome then
                player.gui.screen.member_welcome.destroy()
            else
                local tfont = "[font=default-large-bold]"
                local efont = "[/font]"

                local lname = "members"
                if UTIL_Is_Regular(player) then
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

                if UTIL_Is_Regular(player) then
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
                    online_32.style.size = { 64, 64 }
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
                m45_32.style.size = { 64, 64 }
            end
        end
    end
end
