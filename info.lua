-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "utility"

-- Shamelessly stole most of this function from RedMew.
-- I also had no idea inventory-size could be set from create_entity.
-- https://github.com/Refactorio/RedMew/blob/develop/features/dump_offline_inventories.lua

function INFO_DumpInv(player, force)
    if not player then
        return false
    end
    if not player.valid then
        return false
    end

    if not force then
        if storage.PData[player.index].cleaned then
            if storage.PData[player.index].cleaned == true then
                return false
            end
        end
    end

    local inv_main = player.get_inventory(defines.inventory.character_main)
    local inv_trash = player.get_inventory(defines.inventory.character_trash)

    local inv_main_contents
    if inv_main and inv_main.valid then
        inv_main_contents = inv_main.get_contents()
    end

    local inv_trash_contents
    if inv_trash and inv_trash.valid then
        inv_trash_contents = inv_trash.get_contents()
    end

    local inv_corpse_size = 0
    if inv_main_contents then
        inv_corpse_size = inv_corpse_size + (#inv_main - inv_main.count_empty_stacks())
    end

    if inv_trash_contents then
        inv_corpse_size = inv_corpse_size + (#inv_trash - inv_trash.count_empty_stacks())
    end

    if inv_corpse_size <= 0 then
        return false
    end

    local position = player.position
    local corpse = player.surface.create_entity {
        name = "character-corpse",
        position = UTIL_GetDefaultSpawn(),
        inventory_size = inv_corpse_size,
        player_index = player.index
    }
    if not corpse then
        return false
    end

    corpse.active = true

    local inv_corpse = corpse.get_inventory(defines.inventory.character_corpse)

    if not inv_corpse then
        return false
    end

    if inv_main_contents then
        for _, item in pairs(inv_main_contents) do
            inv_corpse.insert(item)
        end

        if inv_main_contents then
            inv_main.clear()
        end
    end
    if inv_trash_contents then
        for _, item in pairs(inv_trash_contents) do
            inv_corpse.insert(item)
        end

        if inv_trash_contents then
            inv_trash.clear()
        end
    end


    -- Mark as cleaned up.
    storage.PData[player.index].cleaned = true

    return true
end

function INFO_CheckAbandoned()
    for _, player in pairs(game.players) do
        if not player.connected and UTIL_Is_New(player) then
            if game.tick - storage.PData[player.index].lastOnline > 1 * 60 * 60 * 60 then
                if INFO_DumpInv(player, false) then
                    UTIL_MsgAllSys("New player '" .. player.name ..
                        "' was not active long enough to become a member, and have been offline for some time. Their items are now considered abandoned, and have been placed at spawn.")
                end
            end
        end
    end
end

function INFO_MakeButton(player)
    if player.gui.top.m45_button then
        player.gui.top.m45_button.destroy()
    end
    if not player.gui.top.m45_button then
        local m45_32 = player.gui.top.add {
            type = "sprite-button",
            name = "m45_button",
            sprite = "file/img/buttons/m45-64.png",
            tooltip = "Opens the server-info window"
        }
        m45_32.style.size = { 64, 64 }
    end
end

-- M45 Info/Welcome window
function INFO_InfoWin(player)
    -- M45 Welcome--

    -- Auto close membership welcome window--
    if player then
        if player.gui.screen then
            if player.gui.screen.member_welcome then
                if not player.gui.screen.m45_info_window then
                    player.gui.screen.member_welcome.destroy()
                end
            end
        else
            return
        end
    else
        return
    end

    if player.gui.center then
        if player.gui.screen.m45_info_window then
            player.gui.screen.m45_info_window.destroy()
        end
        if not player.gui.screen.m45_info_window then
            local main_flow = player.gui.screen.add {
                type = "frame",
                name = "m45_info_window",
                direction = "vertical"
            }
            main_flow.style.horizontal_align = "center"
            main_flow.style.vertical_align = "center"
            main_flow.force_auto_center()

            -- Info Title Bar--
            local info_titlebar = main_flow.add {
                type = "flow",
                direction = "horizontal"
            }
            info_titlebar.drag_target = main_flow
            info_titlebar.style.horizontal_align = "center"
            info_titlebar.style.horizontally_stretchable = true

            if storage.SM_Store.serverName == "" then
                info_titlebar.add {
                    type = "label",
                    name = "online_title",
                    style = "frame_title",
                    caption = "Welcome to M45!"
                }
            else
                info_titlebar.add {
                    type = "label",
                    name = "online_title",
                    style = "frame_title",
                    caption = "You are playing on: " .. storage.SM_Store.serverName
                }
            end
            local pusher = info_titlebar.add {
                type = "empty-widget",
                style = "draggable_space_header"
            }
            pusher.style.vertically_stretchable = true
            pusher.style.horizontally_stretchable = true
            pusher.drag_target = main_flow

            info_titlebar.add {
                type = "sprite-button",
                name = "m45_info_close_button",
                sprite = "utility/close",
                style = "frame_action_button",
                tooltip = "Close this window"
            }

            local info_pane = main_flow.add {
                type = "tabbed-pane",
                name = "m45_info_window_tabs"
            }
            info_pane.style.minimal_width = 725

            local tab1 = info_pane.add {
                type = "tab",
                caption = "[entity=character] INFO-README"
            }
            local tab2 = info_pane.add {
                type = "tab",
                caption = "[item=automation-science-pack] FREE-MEMBERSHIP"
            }
            local tab3 = info_pane.add {
                type = "tab",
                caption = "[item=steel-plate] RULES"
            }
            local tab5 = info_pane.add {
                type = "tab",
                caption = "[item=advanced-circuit] Discord Link"
            }
            local tab6 = info_pane.add {
                type = "tab",
                caption = "[item=production-science-pack] Patreon"
            }
            local tab4 = info_pane.add {
                type = "tab",
                caption = "[virtual-signal=signal-info] Tips & Tricks"
            }

            -- Tab 1 -- Welcome
            local tab1_frame = info_pane.add {
                type = "flow",
                direction = "vertical"
            }
            tab1_frame.style.horizontal_align = "center"

            -- Tab 1 -- Main
            local tab1_main_frame = tab1_frame.add {
                type = "flow",
                direction = "horizontal"
            }

            -- Tab 1 left-frame logo-patreons
            local tab1_lframe = tab1_main_frame.add {
                type = "flow",
                direction = "vertical"
            }
            tab1_lframe.style.padding = 4
            tab1_lframe.add {
                type = "sprite",
                sprite = "file/img/info-win/m45-128.png",
                tooltip = ""
            }
            tab1_lframe.add {
                type = "label",
                caption = "[color=white][font=default-large-bold]M45[/font][/color]"
            }
            tab1_lframe.add {
                type = "label",
                caption = " "
            }

            -- PATREON
            if storage.SM_Store.patreonCredits[1] then
                tab1_lframe.add {
                    type = "label",
                    caption = "[color=purple]SUPPORTERS:[/color]"
                }
                local i = 1
                while storage.SM_Store.patreonCredits[i]  do
                    if storage.SM_Store.patreonCredits[i + 1]  then
                        tab1_lframe.add {
                            type = "label",
                            caption = "[color=purple]" .. storage.SM_Store.patreonCredits[i] .. ", " .. storage.SM_Store.patreonCredits[i+1] ..
                                "[/color]"
                        }
                        i = i + 1
                    else
                        tab1_lframe.add {
                            type = "label",
                            caption = "[color=purple]" .. storage.SM_Store.patreonCredits[i] .. "[/color]"
                        }
                    end
                    i = i + 1
                end
            end

            tab1_lframe.add {
                type = "label",
                caption = ""
            }

            -- NITRO
            if storage.SM_Store.nitroCredits[1]then
                tab1_lframe.add {
                    type = "label",
                    caption = "[color=cyan]DISCORD NITRO:[/color]"
                }
                local i = 1
                while storage.SM_Store.nitroCredits[i] do
                    if storage.SM_Store.nitroCredits[i + 1] then
                        tab1_lframe.add {
                            type = "label",
                            caption = "[color=cyan]" .. storage.SM_Store.nitroCredits[i] .. ", " .. storage.SM_Store.nitroCredits[i + 1] ..
                                "[/color]"
                        }
                        i = i + 1
                    else
                        tab1_lframe.add {
                            type = "label",
                            caption = "[color=cyan]" .. storage.SM_Store.nitroCredits[i] .. "[/color]"
                        }
                    end
                    i = i + 1
                end
            end
            tab1_lframe.add {
                type = "label",
                caption = ""
            }
            tab1_lframe.add {
                type = "button",
                caption = "Help Out!",
                style = "red_button",
                name = "patreon_button"
            }
            tab1_lframe.style.horizontal_align = "center"

            -- Tab 1 -- left/right divider line
            tab1_main_frame.add {
                type = "line",
                direction = "vertical"
            }

            -- Tab 1 right-frame
            local tab1_rframe = tab1_main_frame.add {
                type = "flow",
                direction = "vertical"
            }
            -- Tab 1 Center -- Info
            local tab1_info_center = tab1_main_frame.add {
                type = "flow",
                direction = "vertical"
            }
            tab1_info_center.style.horizontal_align = "center"

            tab1_info_center.style.horizontally_stretchable = true
            tab1_info_center.add {
                type = "label",
                caption = "[color=orange][font=default-large-bold]TROLLS or GRIEFERS?[/font][/color]"
            }
            tab1_info_center.add {
                type = "sprite",
                sprite = "file/img/info-win/tips/onetwothree.png"
            }
            tab1_info_center.add {
                type = "label",
                caption = "[color=orange][font=default-large-bold]JUST BANISH THEM![/font][/color]"
            }
            tab1_info_center.add {
                type = "label",
                caption = " "
            }
            tab1_info_center.add {
                type = "label",
                caption = "M45-SoftMod"
            }
            tab1_info_center.add {
                type = "label",
                caption = "v" .. storage.SM_Version
            }

            local tab1_cframe = { tab1_main_frame.add {
                type = "flow",
                direction = "vertical"
            } }
            tab1_rframe.style.horizontal_align = "right"
            tab1_rframe.style.vertical_align = "bottom"
            tab1_rframe.style.padding = 4

            -- Tab 1 Main -- New Player Warning
            local tab1_info_top = tab1_rframe.add {
                type = "flow",
                direction = "vertical"
            }
            tab1_info_top.style.horizontally_stretchable = true
            tab1_info_top.add {
                type = "label",
                caption = ""
            }
            if storage.SM_Store.resetDate and storage.SM_Store.resetDate ~= "" then
                local reset_warning = tab1_info_top.add {
                    type = "label",
                    caption = "[virtual-signal=signal-everything]  [color=orange][font=default-large-bold]Next map reset: " ..
                        string.upper(storage.SM_Store.resetDate) .. "[/font][/color]"
                }
            end
            if storage.SM_Store.resetDuration and storage.SM_Store.resetDuration ~= "" then
                local reset_warning = tab1_info_top.add {
                    type = "label",
                    caption = "[virtual-signal=signal-everything]  [color=orange][font=default-large-bold]Map will reset in: " ..
                        string.upper(storage.SM_Store.resetDuration) .. "[/font][/color]"
                }
            end
            tab1_info_top.style.horizontally_stretchable = true
            tab1_info_top.add {
                type = "label",
                caption = ""
            }
            local restrictions = tab1_info_top.add {
                type = "label",
                caption = "[entity=character]  [color=yellow][font=default-large-bold]NEW PLAYERS start with some restrictions![/font][/color]"
            }
            local friendly_fire = tab1_info_top.add {
                type = "label",
                caption = "[recipe=combat-shotgun] [font=default-large-bold]Friendly fire is OFF, for players and buildings.[/font]"
            }
            if storage.SM_Store.oneLifeMode then
                tab1_info_top.add {
                    type = "label",
                    caption = "[color=red][font=default-large-bold]THIS SERVER IS PERMA-DEATH. YOU HAVE ONE LIFE TO LIVE PER MAP![/font][/color]"
                }
            elseif storage.SM_Store.noBlueprints then
                tab1_info_top.add {
                    type = "label",
                    caption = "[color=cyan][font=default-large-bold]BLUEPRINTS ARE DISABLED! BUILD STUFF ON YOUR OWN![/font][/color]"
                }
            elseif storage.SM_Store.cheats then
                tab1_info_top.add {
                    type = "label",
                    caption = "[color=red][font=default-large-bold]CHEATS ARE ENABLED![/font][/color]"
                }
            else
                tab1_info_top.add {
                    type = "label",
                    caption = ""
                }
            end
            tab1_info_top.add {
                type = "label",
                caption = "[font=default-large-bold]Click the '[item=automation-science-pack] FREE-MEMBERSHIP' tab to learn more.[/font]"
            }
            tab1_info_top.add {
                type = "label",
                caption = ""
            }

            -- Contextual editing
            if player.force.friendly_fire then
                friendly_fire.caption = "Friendly fire is currently ON (normally off)."
            end
            if storage.SM_Store.restrictNew == false then
                restrictions.caption = ""
            end

            -- server list URL
            tab1_info_top.add {
                type = "label",
                caption = "[font=default-large]See our other Factorio servers:[/font]"
            }

            tab1_info_top.add {
                type = "text-box",
                name = "server_list",
                text = "http://factorio.go-game.net/?tag=M45",
                tooltip = "(if not selected), drag-select with mouse, control-c to copy."
            }
            tab1_info_top.server_list.style.font = "default-large"
            tab1_info_top.server_list.style.minimal_width = 350

            tab1_info_top.add {
                type = "label",
                caption = "  "
            }

            -- Tab 1 Main -- Discord
            local tab1_discord_frame = tab1_rframe.add {
                type = "frame",
                direction = "vertical"
            }
            tab1_discord_frame.style.horizontally_stretchable = true
            tab1_discord_frame.style.vertically_squashable = true
            local tab1_discord_sub1_frame = tab1_discord_frame.add {
                type = "flow",
                direction = "vertical"
            }


            -- Tab 1 Main -- Discord -- Info Text
            tab1_discord_sub1_frame.add {
                type = "label",
                caption = "[font=default-large-bold]See our [color=cyan]Discord Server[/color] for commands like vote-map![/font]"
            }
            tab1_discord_sub1_frame.add {
                type = "label",
                caption = "[font=default-large]Visit m45sci.xyz or copy-paste the Discord link below:[/font]"
            }

            -- Tab 1 Main -- Discord -- Logo/URL frame
            local tab1_discord_sub2_frame = tab1_discord_sub1_frame.add {
                type = "flow",
                direction = "horizontal"
            }
            tab1_discord_sub2_frame.style.vertical_align = "center"
            tab1_discord_sub2_frame.add {
                type = "sprite",
                name = "tab1_discord_logo",
                sprite = "file/img/info-win/discord-64.png",
                tooltip = ""
            }
            tab1_discord_sub2_frame.add {
                type = "text-box",
                name = "discord_url",
                text = "https://discord.gg/rQANzBheVh",
                tooltip = "(if not selected), drag-select with mouse, control-c to copy."
            }

            -- URL Style
            tab1_discord_sub2_frame.discord_url.style.font = "default-large"
            tab1_discord_sub2_frame.discord_url.style.minimal_width = 350

            tab1_discord_sub2_frame.add {
                type = "label",
                caption = "  "
            }

            -- Tab 1 Main -- Discord -- Bottom Info Text
            tab1_discord_sub2_frame.add {
                type = "button",
                caption = "Get QR Code",
                style = "rounded_button",
                name = "qr_button"
            }
            info_pane.add_tab(tab1, tab1_frame)

            ------------------------
            -- TAB 2 -- MEMBERSHIP --
            ------------------------
            local tab2_frame = info_pane.add {
                type = "flow",
                direction = "vertical"
            }
            tab2_frame.style.vertically_squashable = true
            tab2_frame.style.horizontal_align = "center"

            -- tab 2 -- Main
            local tab2_main_frame = tab2_frame.add {
                type = "scroll-pane",
                direction = "vertical"
            }
            tab2_main_frame.style.horizontal_align = "right"
            tab2_main_frame.style.padding = 4

            tab2_main_frame.style.horizontally_stretchable = true
            tab2_main_frame.add {
                type = "label",
                name = "tab2_score",
                caption = "[color=orange][font=default-large-bold]Current score: " ..
                    math.floor(storage.PData[player.index].score / 60 / 60) .. "[/font][/color]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = ""
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]Membership is automatic & free, and based on ACTIVITY. Your current activity score is listed above.[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large]The score is specific to this map, and does not carry over to other maps or servers.[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large]Once you achieve a specific level, the level persists between maps and servers (but the activity score does not).[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = ""
            }
            tab2_main_frame.add {
                type = "line",
                direction = "horizontal"
            }
            if UTIL_Is_New(player) then
                tab2_main_frame.add {
                    type = "label",
                    caption = "[recipe=burner-inserter]   [font=default-large-bold][color=red]Level 1: New[/color][/font]"
                }
            else
                tab2_main_frame.add {
                    type = "label",
                    caption = "[recipe=burner-inserter]   [font=default-large-bold]Level 1: New[/font]"
                }
            end
            tab2_main_frame.add {
                type = "label",
                caption = ""
            }

            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]New players DO NOT have the following permissions:[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large]deconstruction planner, landfill, speakers, launch rocket, cancel research, artillery remote or delete blueprints.[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]Level 3+ players can BANISH you with ONE vote point.[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = ""
            }
            tab2_main_frame.add {
                type = "line",
                direction = "horizontal"
            }

            if UTIL_Is_Member(player) then
                tab2_main_frame.add {
                    type = "label",
                    caption = "[recipe=inserter]   [font=default-large-bold][color=red]Level 2: Members[/color] (Score: 30)[/font]"
                }
            else
                tab2_main_frame.add {
                    type = "label",
                    caption = "[recipe=inserter]   [font=default-large-bold]Level 2: Members (Score: 30)[/font]"
                }
            end
            tab2_main_frame.add {
                type = "label",
                caption = ""
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large]Permissions restrictions are lifted.[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]Access to deconstruction planner (with warning msg).[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold][color=green]Access to members-only servers.[/color][/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = " "
            }
            tab2_main_frame.add {
                type = "line",
                direction = "horizontal"
            }

            if UTIL_Is_Regular(player) then
                tab2_main_frame.add {
                    type = "label",
                    caption = "[recipe=fast-inserter]   [font=default-large-bold][color=red]Level 3: Regulars[/color] (Score: 240)[/font]"
                }
            else
                tab2_main_frame.add {
                    type = "label",
                    caption = "[recipe=fast-inserter]   [font=default-large-bold]Level 3: Regulars (Score: 240)[/font]"
                }
            end
            tab2_main_frame.add {
                type = "label",
                caption = ""
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]Allowed to BANISH other players, and vote points needed to BANISH you increases to TWO.[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large]Deconstruction planner warning removed.[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large]Access to vote-map command on Discord (after registration).[/font]"
            }
            tab2_main_frame.add {
                type = "line",
                direction = "horizontal"
            }
            if UTIL_Is_Veteran(player) then
                tab2_main_frame.add {
                    type = "label",
                    caption = "[recipe=stack-inserter]   [font=default-large-bold][color=red]Level 4: Veteran[/color][/font]"
                }
            else
                tab2_main_frame.add {
                    type = "label",
                    caption = "[recipe=stack-inserter]   [font=default-large-bold]Level 4: Veteran[/font] "
                }
            end
            tab2_main_frame.add {
                type = "label",
                caption = ""
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]Long-standing members of the community. Vote points needed to BANISH you increases to four.[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]Your votes increase to two points each.[/font]"
            }
            tab2_main_frame.add {
                type = "label",
                caption = ""
            }
            -- Close Button Frame
            local tab2_close_frame = tab2_main_frame.add {
                type = "flow",
                direction = "vertical"
            }
            tab2_close_frame.style.horizontal_align = "right"

            info_pane.add_tab(tab2, tab2_frame)

            ------------------------
            -- tab 3 -- Rules --
            ------------------------
            local tab3_frame = info_pane.add {
                type = "flow",
                direction = "vertical"
            }
            tab3_frame.style.vertically_squashable = true
            tab3_frame.style.horizontal_align = "center"

            -- tab 3 -- Main
            local tab3_main_frame = tab3_frame.add {
                type = "scroll-pane",
                direction = "vertical"
            }
            tab3_main_frame.style.horizontal_align = "right"
            tab3_main_frame.style.padding = 4

            tab3_main_frame.style.horizontally_stretchable = true
            tab3_main_frame.add {
                type = "label",
                caption = ""
            }
            tab3_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]1: [recipe=cluster-grenade] No griefing, use common sense. Don't be toxic or annoying.[/font]"
            }
            tab3_main_frame.add {
                type = "label",
                caption = ""
            }
            tab3_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]2: [item=programmable-speaker] Don't advertise or link other servers.[/font]"
            }
            tab3_main_frame.add {
                type = "label",
                caption = ""
            }
            tab3_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]3: [item=blueprint-book] Read the INFO-README, RULES and FREE-MEMBERSHIP tabs before asking for help.[/font]"
            }
            tab3_main_frame.add {
                type = "label",
                caption = ""
            }
            tab3_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]4: [item=repair-pack] Use [/font][font=default-game]BANISH[/font] [font=default-large-bold]if there are problem-players.[/font]"
            }
            tab3_main_frame.add {
                type = "label",
                caption = ""
            }
            tab3_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]5: [fluid=steam] This is a multiplayer server, try to cooperate with other players.[/font]"
            }
            tab3_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]   If you want everything your way, go play single player.[/font]"
            }

            -- Close Button Frame
            local tab3_close_frame = tab3_main_frame.add {
                type = "flow",
                direction = "vertical"
            }
            tab3_close_frame.style.horizontal_align = "right"

            info_pane.add_tab(tab3, tab3_frame)

            ------------------------
            -- tab 4 -- Tips & Tricks --
            ------------------------
            local tab4_frame = info_pane.add {
                type = "flow",
                direction = "vertical"
            }
            tab4_frame.style.vertically_squashable = true
            tab4_frame.style.horizontal_align = "center"

            -- tab 4 -- Main
            local tab4_main_frame = tab4_frame.add {
                type = "scroll-pane",
                direction = "vertical"
            }
            tab4_main_frame.style.horizontal_align = "right"
            tab4_main_frame.style.padding = 4

            tab4_main_frame.style.horizontally_stretchable = true
            tab4_main_frame.add {
                type = "label",
                caption = ""
            }
            tab4_main_frame.add {
                type = "label",
                caption = "[font=default-large]You can bookmark servers, by clicking the gear icon in the server browser![/font]"
            }
            local tab4_img2_frame = tab4_main_frame.add {
                type = "frame",
                direction = "vertical"
            }
            tab4_img2_frame.add {
                type = "sprite",
                sprite = "file/img/info-win/tips/bookmark.png",
                tooltip = "The gear icon will turn orange, and the bookmarked servers appear first in the list."
            }
            tab4_main_frame.add {
                type = "label",
                caption = ""
            }

            tab4_main_frame.add {
                type = "label",
                caption = "[font=default-large]Map reset, but want to keep playing the old map?[/font]"
            }
            tab4_main_frame.add {
                type = "text-box",
                name = "old_maps",
                text = "https://m45sci.xyz/u/fact2/archive/1.1%20maps/?C=M;O=D",
                tooltip = "drag-select with mouse, control-c to copy."
            }
            tab4_main_frame.old_maps.style.font = "default-large"
            tab4_main_frame.old_maps.style.minimal_width = 550
            tab4_main_frame.add {
                type = "label",
                caption = ""
            }

            tab4_main_frame.add {
                type = "label",
                caption = "[font=default-large]Download a stand-alone copy of Factorio (no install)![/font]"
            }
            tab4_main_frame.add {
                type = "label",
                caption = "[font=default-large]It is a great way to have multiple versions, or mod-sets![/font]"
            }
            tab4_main_frame.add {
                type = "sprite",
                sprite = "file/img/info-win/tips/dl-fact.png",
                tooltip = "Place the unzipped folder wherever you want!"
            }
            tab4_main_frame.add {
                type = "text-box",
                name = "wube_dl",
                text = "https://factorio.com/download",
                tooltip = "drag-select with mouse, control-c to copy."
            }
            tab4_main_frame.wube_dl.style.font = "default-large"
            tab4_main_frame.wube_dl.style.minimal_width = 350

            info_pane.add_tab(tab4, tab4_frame)

            ---------------
            --- QR CODE ---
            ---------------
            local tab5_frame = info_pane.add {
                type = "flow",
                direction = "vertical"
            }

            local tab5_qr_frame = tab5_frame.add {
                type = "flow",
                direction = "vertical"
            }
            tab5_qr_frame.style.horizontally_stretchable = true
            tab5_qr_frame.style.vertically_stretchable = true
            tab5_qr_frame.style.horizontal_align = "center"
            tab5_qr_frame.style.vertical_align = "center"
            tab5_qr_frame.add {
                type = "sprite",
                name = "tab1_discord_logo",
                sprite = "file/img/info-win/discord-64.png",
                tooltip = ""
            }
            tab5_qr_frame.add {
                type = "label",
                caption = "Discord: M45-Science"
            }
            tab5_qr_frame.add {
                type = "label",
                caption = ""
            }
            local tab5_qr = tab5_qr_frame.add {
                type = "sprite",
                sprite = "file/img/info-win/m45-qr.png",
                tooltip = "Just open camera on a cellphone!"
            }
            tab5_qr_frame.add {
                type = "label",
                caption = ""
            }
            tab5_qr_frame.add {
                type = "label",
                caption = "(links to: https://discord.gg/rQANzBheVh)"
            }

            info_pane.add_tab(tab5, tab5_frame)

            --------------
            --- HELP    ---
            ---------------
            local tab6_frame = info_pane.add {
                type = "flow",
                direction = "vertical"
            }

            local tab6_main_frame = tab6_frame.add {
                type = "flow",
                direction = "vertical"
            }
            tab6_main_frame.add {
                type = "label",
                caption = ""
            }
            tab6_frame.style.horizontal_align = "center"
            tab6_frame.style.vertical_align = "center"
            tab6_main_frame.add {
                type = "sprite",
                sprite = "file/img/info-win/patreon-64.png"
            }
            tab6_main_frame.add {
                type = "label",
                caption = ""
            }
            tab6_main_frame.add {
                type = "label",
                caption = "[font=default-large-bold]Our patreons keep these servers online![/font]"
            }
            tab6_main_frame.add {
                type = "label",
                caption = "[font=default-large]Server: Dual Intel Xeon E5 2680 v4 28C/56T, 8 channels of DDR4 (64GB)[/font]"
            }
            tab6_main_frame.add {
                type = "label",
                caption = "(Rented in a datacenter, Southfield Michigan, USA)"
            }
            tab6_main_frame.add {
                type = "label",
                caption = ""
            }
            tab6_main_frame.add {
                type = "label",
                caption = "[font=default-large]Our server costs are $70/mo USD[/font]"
            }
            tab6_main_frame.add {
                type = "label",
                caption = "[font=default-large]See the link below to find out more:[/font]"
            }
            tab6_main_frame.add {
                type = "label",
                caption = ""
            }
            local tab6_patreon_url = tab6_main_frame.add {
                type = "text-box",
                text = "https://www.patreon.com/m45sci",
                name = "patreon_url"
            }
            tab6_patreon_url.style.font = "default-large"
            tab6_patreon_url.style.minimal_width = 300

            tab6_main_frame.add {
                type = "label",
                caption = ""
            }
            tab6_main_frame.add {
                type = "sprite",
                sprite = "file/img/info-win/patreon-qr.png"
            }
            tab6_main_frame.add {
                type = "label",
                caption = "(Or scan this QR Code, it links to the address above)"
            }

            info_pane.add_tab(tab6, tab6_frame)

            info_pane.selected_tab_index = 1
            tab1_discord_sub2_frame.discord_url.focus()
            tab1_discord_sub2_frame.discord_url.select_all()
        end
    end
end

-- GUI clicks
function INFO_Click(event)
    if event and event.element and event.element.valid and event.player_index then
        local player = game.players[event.player_index]

        local args = UTIL_SplitStr(event.element.name, ",")

        if player and player.valid then
            -- debug
            UTIL_ConsolePrint("[ACT] GUI_CLICK: " .. player.name .. ": " .. event.element.name)

            -- Info window close
            if event.element.name == "m45_info_close_button" and player.gui and player.gui.center and
                --Info Window
                player.gui.screen.m45_info_window then
                player.gui.screen.m45_info_window.destroy()
            elseif event.element.name == "patreon_button" and player.gui and player.gui.center and
                player.gui.screen.m45_info_window then
                -- QR changetab button (info window)
                player.gui.screen.m45_info_window.m45_info_window_tabs.selected_tab_index = 6
            elseif event.element.name == "qr_button" and player.gui and player.gui.center and
                player.gui.screen.m45_info_window then
                -- QR Discord button
                player.gui.screen.m45_info_window.m45_info_window_tabs.selected_tab_index = 5
            elseif event.element.name == "m45_button" then
                -- Online window toggle
                if player.gui and player.gui.center and player.gui.screen.m45_info_window then
                    player.gui.screen.m45_info_window.destroy()
                else
                    INFO_InfoWin(player)
                end
            elseif event.element.name == "reset_clock" then
                -- reset-clock-close
                if player.gui and player.gui.top and player.gui.top.reset_clock then
                    if storage.PData then
                        if storage.PData[player.index].hideClock == true and
                            storage.SM_Store.resetDuration ~= "" then
                                storage.PData[player.index].hideClock  = false
                            player.gui.top.reset_clock.caption = "Map reset: " .. storage.SM_Store.resetDuration
                            player.gui.top.reset_clock.style = "red_button"
                        else
                            if event.button and event.button == defines.mouse_button_type.right and event.control then
                                storage.PData[player.index].hideClock  = true
                                player.gui.top.reset_clock.caption = ">"
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Auto-Fix text-boxes (no-edit text boxes feel odd)
function INFO_TextChanged(event)
    -- Automatically fix URLs, because read-only/selectable text is confusing to players --
    if event and event.element and event.player_index and event.text and event.element.name then
        local args = UTIL_SplitStr(event.element.name, ",")
        local player = game.players[event.player_index]

        if event.element.name == "discord_url" then
            event.element.text = "https://discord.gg/rQANzBheVh"
        elseif event.element.name == "server_list" then
            event.element.text = "http://factorio.go-game.net/?tag=M45"
        elseif event.element.name == "old_maps" then
            event.element.text = "https://m45sci.xyz/u/fact2/archive/1.1%20maps/?C=M;O=D"
        elseif event.element.name == "patreon_url" then
            event.element.text = "https://www.patreon.com/m45sci"
        elseif event.element.name == "wube_dl" then
            event.element.text = "https://factorio.com/download"
        end
    end
end
