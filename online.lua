-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

local function update_online_windows()
    for _, player in pairs(game.connected_players) do
        if player.gui and player.gui.screen and player.gui.left.m45_online then
            ONLINE_Window(player)
        end
    end
end

function ONLINE_MakeOnlineButton(player)
    -- Online button--
    if player.gui.top.online_button then
        player.gui.top.online_button.destroy()
    end
    if not player.gui.top.online_button then
        local online_32 = player.gui.top.add {
            type = "sprite-button",
            name = "online_button",
            sprite = "file/img/buttons/online-64.png",
            tooltip = "See players online!"
        }
        online_32.style.size = { 64, 64 }
    end
end

-- Count online players, store
function ONLINE_UpdatePlayerList()
    -- Sort by active time
    local results = {}
    local count = 0
    local tcount = 0


    -- Make a table with active time, handle missing data
    for i, victim in pairs(game.players) do
        local utag

        -- Catch all
        if victim.permission_group then
            local gname = victim.permission_group.name
            utag = gname
        else
            utag = "none"
        end

        -- Normal groups
        if UTIL_Is_New(victim) then
            utag = "NEW"
        end
        if UTIL_Is_Member(victim) then
            utag = "Members"
        end
        if UTIL_Is_Regular(victim) then
            utag = "Regulars"
        end
        if UTIL_Is_Veteran(victim) then
            utag = "Veterans"
        end
        if UTIL_Is_Banished(victim) then
            utag = "BANISHED"
        end
        if victim.admin then
            utag = "Moderator"
        end

        if UTIL_Is_Patreon(victim) then
            utag = utag .. " (SUPPORTER)"
        end
        if UTIL_Is_Nitro(victim) then
            utag = utag .. " (NITRO)"
        end

        if victim.controller_type == defines.controllers.spectator then
            utag = "SPECTATOR"
        end

        -- Show last online in minutes
        local isafk = "   "

        if storage.PData[victim.index].lastOnline then
            local time = ((game.tick - storage.PData[victim.index].lastOnline) / 60)
            local days = math.floor(time / 60 / 60 / 24)
            local hours = math.floor(time / 60 / 60)
            local minutes = math.floor(time / 60)
            if days > 0 then
                isafk = string.format("%3.2fd", time / 60 / 60 / 24)
            elseif hours > 0 then
                isafk = string.format("%3.2fh", time / 60 / 60)
            elseif minutes > 2 then
                isafk = minutes .. "m"
            end
        end

        if storage.PData[victim.index].score then
            table.insert(results, {
                victim = victim,
                score = storage.PData[victim.index].score,
                time = victim.online_time,
                type = utag,
                afk = isafk
            })
        else
            table.insert(results, {
                victim = victim,
                score = 0,
                time = victim.online_time,
                type = utag,
                afk = isafk
            })
        end

        tcount = tcount + 1
        if victim.connected then
            count = count + 1
        end
    end

    table.sort(results, function(k1, k2)
        return k1.score > k2.score
    end)

    for _, item in pairs(results) do
        if item.victim.gui and item.victim.gui.top and item.victim.gui.top.online_button then
            item.victim.gui.top.online_button.number = count
        end
    end
    storage.SM_Store.pcount = count
    storage.SM_Store.tcount = tcount
    storage.SM_Store.playerList = results
    UTIL_SendPlayers(nil)
    update_online_windows()
end

-- Global, called from control.lua
function ONLINE_MakeM45OnlineSub(player, target_name)
    local target = game.players[target_name]

    -- make online root submenu
    if player and target and target.valid then
        if player.gui and player.gui.screen then
            if player.gui and player.gui.screen and player.gui.screen.m45_info_window then
                player.gui.screen.m45_info_window.destroy()
            end

            if not player.gui.screen.m45_online_submenu then
                if not player.gui.screen.m45_online_submenu then
                    local main_flow = player.gui.screen.add {
                        type = "frame",
                        name = "m45_online_submenu",
                        direction = "vertical"
                    }
                    main_flow.force_auto_center()
                    main_flow.style.horizontal_align = "center"
                    main_flow.style.vertical_align = "center"

                    -- Online Title Bar--
                    local online_submenu_titlebar = main_flow.add {
                        type = "frame",
                        direction = "horizontal"
                    }
                    online_submenu_titlebar.drag_target = main_flow
                    online_submenu_titlebar.style.horizontal_align = "center"
                    online_submenu_titlebar.style.horizontally_stretchable = true

                    online_submenu_titlebar.add {
                        type = "label",
                        style = "frame_title",
                        caption = "Player: " .. target_name
                    }
                    local pusher = online_submenu_titlebar.add {
                        type = "empty-widget",
                        style = "draggable_space_header"
                    }
                    pusher.style.vertically_stretchable = true
                    pusher.style.horizontally_stretchable = true
                    pusher.drag_target = main_flow

                    online_submenu_titlebar.add {
                        type = "sprite-button",
                        name = "m45_online_submenu_close_button",
                        sprite = "utility/close",
                        style = "frame_action_button",
                        tooltip = "Close this window"
                    }

                    local online_submenu_main = main_flow.add {
                        type = "frame",
                        name = "main",
                        direction = "vertical"
                    }
                    online_submenu_main.style.horizontal_align = "center"

                    -- FIND ON MAP
                    local find_on_map_frame = online_submenu_main.add {
                        type = "flow",
                        direction = "vertical"
                    }
                    find_on_map_frame.style.horizontal_align = "center"
                    local find_on_map = find_on_map_frame.add {
                        type = "button",
                        caption = "[item=artillery-targeting-remote] Find On Map",
                        name = "find_on_map",
                        tooltip = "This shows the player on the map!"
                    }
                    find_on_map.style.horizontal_align = "center"

                    -- WHISPER
                    local whisper_frame = online_submenu_main.add {
                        type = "flow",
                        name = "whisper_frame",
                        direction = "vertical"
                    }
                    whisper_frame.style.horizontal_align = "center"
                    local whisper = whisper_frame.add {
                        type = "label",
                        caption = "[font=default-large-bold]Whisper To:[/font]",
                        name = "whisper"
                    }
                    local whisper_textbox = whisper_frame.add {
                        type = "text-box",
                        text = "",
                        name = "whisper_textbox"
                    }
                    whisper_frame.add {
                        type = "button",
                        caption = "Send",
                        name = "send_whisper",
                        style = "green_button",
                        tooltip = "Sends a private message to this player."
                    }
                    whisper_frame.add {
                        type = "label",
                        caption = " "
                    }
                    whisper_textbox.style.width = 500
                    whisper_textbox.style.height = 64
                    whisper_textbox.word_wrap = true
                    whisper_textbox.style.horizontal_align = "left"

                    -- BANISH
                    local banish_frame = online_submenu_main.add {
                        type = "flow",
                        direction = "vertical",
                        name = "banish_frame"
                    }
                    banish_frame.style.horizontal_align = "center"
                    local banish = banish_frame.add {
                        type = "label",
                        caption = "[font=default-large-bold]Banish Player: (REASON REQUIRED BELOW)[/font]",
                        name = "banish"
                    }
                    local banish_textbox = banish_frame.add {
                        type = "text-box",
                        text = "",
                        name = "banish_textbox"
                    }

                    banish_textbox.style.width = 500
                    banish_textbox.style.height = 64
                    banish_textbox.word_wrap = true
                    banish_textbox.style.horizontal_align = "center"

                    local banish_button = banish_frame.add {
                        type = "button",
                        caption = "VOTE TO BANISH",
                        style = "red_button",
                        name = "banish_player",
                        tooltip = "Vote to banish this player!"
                    }

                    if UTIL_Is_Regular(player) or UTIL_Is_Veteran(player) or player.admin then
                        if target.admin then
                            local banish_note = banish_frame.add {
                                type = "label",
                                caption = "(moderators cannot be banished)"
                            }
                            banish_note.enabled = false
                            banish.enabled = false
                            banish_textbox.enabled = false
                            banish_button.enabled = false
                        end
                    else
                        local banish_note = banish_frame.add {
                            type = "label",
                            caption = "(only regulars and moderators have banish privleges)"
                        }
                        banish_note.enabled = false
                        banish.enabled = false
                        banish_textbox.enabled = false
                        banish_button.enabled = false
                    end

                    banish_frame.add {
                        type = "label",
                        caption = " "
                    }
                end
            end
        end
    end
end

local function destoryOnlineSub(player)
    if player.gui and player.gui.screen and player.gui.screen.m45_online_submenu then
        player.gui.screen.m45_online_submenu.destroy()
    end
end

local function handleOnlineSubmenu(player, target_name)
    if player and player.valid and target_name then
        storage.PData[player.index].onlineSub = target_name
        destoryOnlineSub(player)
        ONLINE_MakeM45OnlineSub(player, target_name)
    end
end

-- M45 Online Players Window
function ONLINE_Window(player)
    -- Auto close membership welcome window--
    if player then
        if player.gui.screen then
            if player.gui.screen.member_welcome then
                if not player.gui.left.m45_online then
                    player.gui.screen.member_welcome.destroy()
                end
            end
        else
            return
        end
    else
        return
    end

    if player.gui and player.gui.left then
        if player.gui.left.m45_online then
            player.gui.left.m45_online.destroy()
        end
        if not player.gui.left.m45_online then
            local main_flow = player.gui.left.add {
                type = "frame",
                name = "m45_online",
                direction = "vertical"
            }
            main_flow.style.horizontal_align = "left"
            main_flow.style.vertical_align = "top"
            main_flow.style.vertically_squashable = true
            main_flow.style.vertically_stretchable = true
            main_flow.style.horizontally_squashable = true
            main_flow.style.horizontally_stretchable = true

            -- Online Title Bar--
            local online_titlebar = main_flow.add {
                type = "flow",
                direction = "horizontal"
            }
            online_titlebar.style.horizontal_align = "center"
            online_titlebar.style.horizontally_stretchable = true

            local bcheckstate = false
            if storage.PData[player.index].onlineBrief then
                if storage.PData[player.index].onlineBrief == true then
                    bcheckstate = true
                else
                    bcheckstate = false
                end
            else
                storage.PData[player.index].onlineBrief = false
            end

            if not storage.PData[player.index].onlineBrief then
                online_titlebar.add {
                    type = "label",
                    name = "online_title",
                    style = "frame_title",
                    caption = "Players Online: " .. storage.SM_Store.pcount .. ", Total: " .. storage.SM_Store.tcount
                }
            else
                online_titlebar.add {
                    type = "label",
                    name = "online_title",
                    style = "frame_title",
                    caption = "Players:"
                }
            end

            -- CLOSE BUTTON--
            local online_close_button = online_titlebar.add {
                type = "flow",
                direction = "horizontal"
            }

            local checkstate = false
            if storage.PData[player.index].onlineShowOffline then
                if storage.PData[player.index].onlineShowOffline == true then
                    checkstate = true
                else
                    checkstate = false
                end
            else
                storage.PData[player.index].onlineShowOffline = false
            end

            if not storage.PData[player.index].brief then
                local show_offline = online_close_button.add {
                    type = "checkbox",
                    caption = "Show offline  ",
                    name = "m45_online_show_offline",
                    state = checkstate,
                    tooltip = "Toggle show offline players"
                }
            end

            local brief = online_close_button.add {
                type = "checkbox",
                caption = "Brief  ",
                name = "m45_online_brief",
                state = bcheckstate,
                tooltip = "Show names only."
            }

            online_close_button.style.horizontal_align = "right"
            online_close_button.style.horizontally_stretchable = true
            online_close_button.add {
                type = "sprite-button",
                name = "m45_online_close_button",
                style = "frame_action_button",
                sprite = "utility/close",
                tooltip = "Close this window"
            }


            local online_main = main_flow.add {
                type = "scroll-pane",
                direction = "vertical"
            }

            if not storage.PData[player.index].onlineBrief then
                local pframe = online_main.add {
                    type = "frame",
                    direction = "horizontal"
                }
                local submenu = pframe.add {
                    type = "label",
                    caption = "MENU"
                }
                submenu.style.width = 45

                pframe.add {
                    type = "label",
                    caption = "  "
                }
                pframe.add {
                    type = "line",
                    direction = "vertical"
                }
                local name_label = pframe.add {
                    type = "label",
                    caption = "  Name:"
                }
                name_label.style.width = 200
                pframe.add {
                    type = "line",
                    direction = "vertical"
                }
                local time_label = pframe.add {
                    type = "label",
                    caption = " Time:"
                }
                time_label.style.width = 100
                pframe.add {
                    type = "line",
                    direction = "vertical"
                }
                local time_label = pframe.add {
                    type = "label",
                    caption = " Score:"
                }
                time_label.style.width = 100
                pframe.add {
                    type = "line",
                    direction = "vertical"
                }
                local score_label = pframe.add {
                    type = "label",
                    caption = "  Level:"
                }
                score_label.style.width = 200
                local score_label = pframe.add {
                    type = "label",
                    caption = "  (AFK)"
                }
            end

            for i, target in pairs(storage.SM_Store.playerList) do
                local skip = false
                local is_offline = false

                if not target.victim.connected then
                    skip = true
                end

                if skip and storage.PData[player.index].onlineBrief and storage.show_offline_state[player.index] then
                    skip = false
                    is_offline = true
                end

                if not skip then
                    local victim = target.victim

                    local pframe
                    if not storage.PData[player.index].onlineBrief then
                        pframe = online_main.add {
                            type = "frame",
                            direction = "horizontal"
                        }
                    else
                        pframe = online_main.add {
                            type = "flow",
                            direction = "horizontal"
                        }
                    end

                    if not storage.PData[player.index].onlineBrief then
                        local submenu
                        -- Yeah don't need this menu for ourself
                        if victim.name == player.name then
                            submenu = pframe.add {
                                type = "sprite-button",
                                sprite = "utility/player_force_icon",
                                tooltip = "This is you!"
                            }
                            submenu.enabled = false
                        else
                            submenu = pframe.add {
                                type = "sprite-button",
                                sprite = "utility/expand",
                                name = "m45_online_submenu_open," .. victim.name, -- Pass name
                                tooltip = "Additional options, such as whisper, banish and find-on-map."
                            }
                        end
                        submenu.style.size = { 24, 24 }

                        local gps_spacer = pframe.add {
                            type = "empty-widget"
                        }
                        gps_spacer.style.width = 16

                        pframe.add {
                            type = "label",
                            caption = "  "
                        }
                        pframe.add {
                            type = "line",
                            direction = "vertical"
                        }
                    end
                    local name_label
                    name_label = pframe.add {
                        type = "label",
                        caption = "  " .. victim.name
                    }
                    local newcolor = {
                        r = 1,
                        g = 1,
                        b = 1
                    }
                    if UTIL_Is_Banished(victim) then
                        newcolor = {
                            r = 0,
                            g = 0,
                            b = 0
                        }
                    elseif UTIL_Is_Patreon(victim) then
                        newcolor = {
                            r = 1.0,
                            g = 0.0,
                            b = 1.0
                        }
                    elseif UTIL_Is_Nitro(victim) then
                        newcolor = {
                            r = 0.0,
                            g = 0.5,
                            b = 1.0
                        }
                    elseif victim.admin then
                        newcolor = {
                            r = 1,
                            g = 0,
                            b = 0
                        }
                    elseif UTIL_Is_Veteran(victim) then
                        newcolor = {
                            r = 1,
                            g = 0.5,
                            b = 0
                        }
                    elseif UTIL_Is_Regular(victim) then
                        newcolor = {
                            r = 1,
                            g = 1,
                            b = 0
                        }
                    elseif UTIL_Is_Member(victim) then
                        newcolor = {
                            r = 0,
                            g = 1,
                            b = 0
                        }
                    end

                    if not storage.PData[player.index].onlineBrief then
                        name_label.style.font = "default-bold"
                        name_label.style.width = 200
                    end

                    -- Darker if offline
                    if is_offline then
                        newcolor = {
                            r = (newcolor.r / 4) + 0.15,
                            g = (newcolor.g / 4) + 0.15,
                            b = (newcolor.b / 4) + 0.15
                        }
                    end

                    -- Set font color
                    name_label.style.font_color = newcolor

                    if not storage.PData[player.index].onlineBrief then
                        local name_label = pframe.add {
                            type = "line",
                            direction = "vertical"
                        }
                        local time = victim.online_time / 60
                        local tmsg = ""
                        local months = math.floor(time / 60 / 60 / 24 / 30)
                        local days = math.floor(time / 60 / 60 / 24)
                        local hours = math.floor(time / 60 / 60)
                        local minutes = math.floor(time / 60)
                        local seconds = math.floor(time)
                        if months > 0 then
                            tmsg = string.format("%3.2fd", time / 60 / 60 / 24 / 30)
                        elseif days > 0 then
                            tmsg = string.format("%3.2fd", time / 60 / 60 / 24)
                        elseif hours > 0 then
                            tmsg = string.format("%3.2fh", time / 60 / 60)
                        elseif minutes > 0 then
                            tmsg = minutes .. "m"
                        elseif seconds > 0 then
                            tmsg = seconds .. "s"
                        else
                            tmsg = "0s"
                        end

                        local time_label = pframe.add {
                            type = "label",
                            caption = " " .. tmsg,
                            tooltip = "Total time player has been connected on this map."
                        }
                        time_label.style.width = 100
                        local name_label = pframe.add {
                            type = "line",
                            direction = "vertical"
                        }
                        local time_label = pframe.add {
                            type = "label",
                            caption = " " .. math.floor(target.score / 60.0 / 60.0),
                            tooltip = "Player activity score."
                        }
                        time_label.style.width = 100
                        local name_label = pframe.add {
                            type = "line",
                            direction = "vertical"
                        }
                        local utag = ""
                        if UTIL_Is_New(victim) then
                            utag = "[color=white]NEW[/color]"
                        end
                        if UTIL_Is_Member(victim) then
                            utag = "[color=green]Members[/color]"
                        end
                        if UTIL_Is_Regular(victim) then
                            utag = "[color=yellow]Regulars[/color]"
                        end
                        if UTIL_Is_Veteran(victim) then
                            utag = "[color=orange]Veterans[/color]"
                        end
                        if UTIL_Is_Banished(victim) then
                            utag = "[color=red]BANISHED[/color]"
                        end
                        if victim.admin then
                            utag = "[color=red]Moderators[/color]"
                        end

                        if UTIL_Is_Nitro(victim) then
                            utag = utag .. " [color=cyan](NITRO)[/color]"
                        end
                        if UTIL_Is_Patreon(victim) then
                            utag = utag .. " [color=purple](SUPPORTER)[/color]"
                        end

                        if victim.controller_type == defines.controllers.spectator then
                            utag = "SPECTATOR"
                        end

                        local score_label = pframe.add {
                            type = "label",
                            caption = "  " .. utag,
                            tooltip = "Current level, see membership tab for more info."
                        }
                        score_label.style.width = 200

                        local afk_label = pframe.add {
                            type = "label",
                            caption = target.afk,
                            tooltip = "Time AFK or offline (map time)"
                        }
                    end
                end
            end
            -- end
        end
    end
end

-- GUI clicks
function ONLINE_Clicks(event)
    if event and event.element and event.element.valid and event.player_index then
        local player = game.players[event.player_index]

        local args = UTIL_SplitStr(event.element.name, ",")

        if player and player.valid then
            -- Grab target if we have one
            local victim_name
            local victim
            if storage.PData[player.index].onlineSub then
                victim_name = storage.PData[player.index].onlineSub
                victim = game.players[victim_name]
            end

            if args and args[1] == "m45_online_submenu_open" then
                ----------------------------------------------------------------
                -- Online sub-menu
                handleOnlineSubmenu(player, args[2])
            elseif event.element.name == "m45_online_submenu_close_button" then
                ----------------------------------------------------------------
                -- Close online submenu
                if player.gui and player.gui.screen and player.gui.screen.m45_online_submenu then
                    player.gui.screen.m45_online_submenu.destroy()
                    if storage.PData and storage.PData[player.index] then
                        storage.PData[player.index].onlineSub = nil
                    end
                end
            elseif event.element.name == "send_whisper" then
                ----------------------------------------------------------------
                if player.gui and player.gui.screen and player.gui.screen.m45_online_submenu and
                    player.gui.screen.m45_online_submenu.main and
                    player.gui.screen.m45_online_submenu.main.whisper_frame and
                    player.gui.screen.m45_online_submenu.main.whisper_frame.whisper_textbox then
                    if victim and victim.valid then
                        local text = player.gui.screen.m45_online_submenu.main.whisper_frame.whisper_textbox.text
                        if text and string.len(text) > 0 then
                            -- Remove newlines if there are any
                            if string.match(text, "\n") then
                                text = string.gsub(text, "\n", " ")
                            end
                            UTIL_SmartPrint(player, player.name .. " (whisper): " .. text)
                            UTIL_SmartPrint(victim, player.name .. " (whisper): " .. text)
                        end
                        player.gui.screen.m45_online_submenu.main.whisper_frame.whisper_textbox.text = ""

                        if not victim.connected then
                            UTIL_SmartPrint(player,
                                "They aren't online right now, but message will appear in chat history.")
                        end
                    else
                        UTIL_SmartPrint(player, "(SYSTEM) That player does not exist.")
                    end
                else
                    UTIL_ConsolePrint("[ERROR] send_whisper: text-box not found")
                end
            elseif event.element.name == "banish_player" then
                ----------------------------------------------------------------
                if player.gui and player.gui.screen and player.gui.screen.m45_online_submenu and
                    player.gui.screen.m45_online_submenu.main and player.gui.screen.m45_online_submenu.main.banish_frame and
                    player.gui.screen.m45_online_submenu.main.banish_frame.banish_textbox then
                    if victim and victim.valid then
                        local reason = player.gui.screen.m45_online_submenu.main.banish_frame.banish_textbox.text
                        if reason and string.len(reason) > 0 then
                            -- Remove newlines if there are any
                            if string.match(reason, "\n") then
                                reason = string.gsub(reason, "\n", " ")
                            end
                            BANISH_DoBanish(player, victim, reason)
                        else
                            UTIL_SmartPrint(player, "(SYSTEM) You must enter a reason!")
                        end
                        player.gui.screen.m45_online_submenu.main.banish_frame.banish_textbox.text = ""
                    else
                        UTIL_SmartPrint(player, "(SYSTEM) That player does not exist.")
                    end
                else
                    UTIL_ConsolePrint("[ERROR] send_whisper: text-box not found")
                end
            elseif event.element.name == "report_player" then
                ----------------------------------------------------------------
                if player.gui and player.gui.screen and player.gui.screen.m45_online_submenu and
                    player.gui.screen.m45_online_submenu.main and player.gui.screen.m45_online_submenu.main.report_frame and
                    player.gui.screen.m45_online_submenu.main.report_frame.report_textbox then
                    if victim and victim.valid then
                        local reason = player.gui.screen.m45_online_submenu.main.report_frame.report_textbox.text
                        if reason and string.len(reason) > 0 then
                            -- Remove newlines if there are any
                            if string.match(reason, "\n") then
                                reason = string.gsub(reason, "\n", " ")
                            end
                            BANISH_DoReport(player, ": " .. victim.name .. ": " .. reason)
                        end
                        player.gui.screen.m45_online_submenu.main.report_frame.report_textbox.text = ""
                    else
                        UTIL_SmartPrint(player, "(SYSTEM) That player does not exist.")
                    end
                else
                    UTIL_ConsolePrint("[ERROR] send_whisper: text-box not found")
                end
            elseif event.element.name == "find_on_map" then
                if victim and victim.valid then
                    player.set_controller { type = defines.controllers.remote, position = victim.position }
                else
                    UTIL_SmartPrint(player, "Invalid target.")
                end
            elseif event.element.name == "online_button" then
                    ONLINE_Window(player)
            elseif event.element.name == "m45_online_close_button" then
                if player.gui and player.gui.left and player.gui.left.m45_online then
                    player.gui.left.m45_online.destroy()
                end
            elseif event.element.name == "m45_online_show_offline" then
                storage.PData[player.index].onlineShowOffline = event.element.state
                ONLINE_Window(player)
            elseif event.element.name == "m45_online_brief" then
                storage.PData[player.index].onlineBrief = event.element.state
                ONLINE_Window(player)
            elseif event.element.name == "m45_member_welcome_close" then
                if player and player.gui and player.gui.screen and player.gui.screen.member_welcome then
                    player.gui.screen.member_welcome.destroy()
                end
            end
        end
    end
end
