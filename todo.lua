-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

local loremipsum = "Lorem ipsum dolor sit amet"

local function markNoteIDRead(victim, id)
    --Note valid
    if not storage.todo_list or not storage.todo_list[id] then
        return
    end

    --Init list if needed
    if not storage.todo_unread then
        storage.todo_unread = {}
    end

    --Init player if needed
    if not storage.todo_unread[victim.index] then
        storage.todo_unread[victim.index] = {
            note = {}
        }
    end

    --Update
    storage.todo_unread[victim.index].note[id] = storage.todo_list[id].time
end


local function isUnreadVictim(victim, id)
    --Invalid victim
    if not victim or not victim.index then
        return false
    end

    --Invalid note
    if not storage.todo_list or not storage.todo_list[id] then
        return false
    end

    local note = storage.todo_list[id]

    --We've never seen a note
    if not storage.todo_unread then
        return false
    end

    --We've never seen a note
    if not storage.todo_unread[victim.index] then
        storage.todo_unread[victim.index] = {
            note = {}
        }
        return true
    end

    --We've never seen this note
    if not storage.todo_unread[victim.index].note[id] then
        return true
    end

    --We saw this note, but it was updated
    if storage.todo_unread[victim.index].note[id] < note.time then
        return true
    end

    --We've already seen the note
    return false
end

local function unreadCount(victim)
    --Invalid player
    if not victim or not victim.index then
        return 0
    end

    --No notes
    if not storage.todo_list then
        return 0
    end

    --Init unread list
    if not storage.todo_unread then
        storage.todo_unread = {}
    end

    --init player
    if not storage.todo_unread[victim.index] then
        storage.todo_unread[victim.index] = {
            note = {}
        }
    end

    --Count notes
    local count = 0
    for id, note in pairs(storage.todo_list) do
        if isUnreadVictim(victim, id) then
            count = count + 1
        end
    end

    if count == 0 then
        return nil
    end
    return count
end


local function updateTODOWindows()
    for _, player in pairs(game.connected_players) do
        -- Already handles destroying
        if player.gui and player.gui.screen then
            if player.gui.top and player.gui.top.todo_button then
                player.gui.top.todo_button.number = unreadCount(player)
            end
            if player.gui.screen.m45_todo then
                TODO_MakeWindow(player)
                if player.gui.screen.m45_todo_submenu then
                    player.gui.screen.m45_todo_submenu.bring_to_front()
                end
            end
        end
    end
end

local function todo_key(i)
    if storage.todo_list and storage.todo_list[i] then
        return storage.todo_list[i].id
    else
        return "ERROR"
    end
end

local function id_to_index(id)
    if storage.todo_list then
        for i, item in pairs(storage.todo_list) do
            if item and item.id then
                if item.id == id then
                    return i
                end
            end
        end
    end
    UTIL_ConsolePrint("[ERROR] todo_id_to_index: could not find note id: " .. id)
    return -1
end

local function makeTodoSubmenu(player, i, edit_mode)
    if player and player.valid then
        -- Always refresh when called
        if player.gui and player.gui.screen and player.gui.screen.m45_todo_submenu then
            player.gui.screen.m45_todo_submenu.destroy()
        end

        if storage.todo_list and storage.todo_list[i] then
            local target = storage.todo_list[i]

            local no_edit = false
            if not edit_mode or UTIL_Is_New(player) or
                (not player.admin and player.name ~= target.owner and not target.can_edit) then
                no_edit = true
            end

            --Mark read
            markNoteIDRead(player, i)
            updateTODOWindows()

            -- make todo root submenu
            if player and target and target.time then
                if player.gui and player.gui.screen then
                    if not player.gui.screen.m45_todo_submenu then
                        local main_flow = player.gui.screen.add {
                            type = "frame",
                            name = "m45_todo_submenu",
                            direction = "vertical"
                        }
                        main_flow.force_auto_center()
                        main_flow.style.horizontal_align = "center"
                        main_flow.style.vertical_align = "center"
                        main_flow.style.maximal_width = 600

                        -- Online Title Bar--
                        local todo_submenu_titlebar = main_flow.add {
                            type = "flow",
                            direction = "horizontal",
                            name = "titlebar"
                        }
                        todo_submenu_titlebar.drag_target = main_flow
                        todo_submenu_titlebar.style.horizontal_align = "center"
                        todo_submenu_titlebar.style.horizontally_stretchable = true

                        todo_submenu_titlebar.add {
                            type = "label",
                            style = "frame_title",
                            caption = "To-Do ID# " .. target.id
                        }
                        local pusher = todo_submenu_titlebar.add {
                            type = "empty-widget",
                            style = "draggable_space_header"
                        }
                        pusher.style.vertically_stretchable = true
                        pusher.style.horizontally_stretchable = true
                        pusher.drag_target = main_flow

                        todo_submenu_titlebar.add {
                            type = "sprite-button",
                            name = "m45_todo_submenu_close_button",
                            sprite = "utility/close",
                            style = "frame_action_button",
                            tooltip = "Close this window"
                        }

                        local todo_submenu_main = main_flow.add {
                            type = "flow",
                            name = "main",
                            direction = "horizontal"
                        }
                        todo_submenu_main.style.horizontal_align = "center"

                        todo_submenu_main.add {
                            type = "label",
                            caption = "[font=default-large-bold]Priority: [/font]"
                        }
                        local priority_textbox = todo_submenu_main.add {
                            type = "text-box",
                            text = target.priority,
                            name = "todo_priority_textbox"
                        }
                        priority_textbox.read_only = no_edit
                        if no_edit then
                            priority_textbox.selectable = false
                        end

                        priority_textbox.style.width = 100
                        todo_submenu_main.add {
                            type = "label",
                            caption = "[font=default-large-bold]Subject: [/font]"
                        }
                        local subject_textbox = todo_submenu_main.add {
                            type = "text-box",
                            text = target.subject,
                            name = "todo_subject_textbox"
                        }
                        subject_textbox.style.width = 200
                        subject_textbox.read_only = no_edit
                        if no_edit then
                            subject_textbox.selectable = false
                        end

                        local todo_submenu_body = main_flow.add {
                            type = "flow",
                            name = "todo_body",
                            direction = "vertical"
                        }
                        local lock_spacer = todo_submenu_main.add {
                            type = "empty-widget"
                        }
                        lock_spacer.style.width = 32

                        local is_owner = false
                        if target and target.owner and target.owner == player.name then
                            is_owner = true
                        end

                        local todo_lock = todo_submenu_main.add {
                            type = "checkbox",
                            caption = "Protected",
                            name = "todo_protected",
                            state = (not target.can_edit),
                            tooltip = "Toggles if other players can edit your todo item."
                        }
                        if (no_edit or not is_owner) and not player.admin then
                            todo_lock.enabled = false
                        end

                        todo_submenu_body.add {
                            type = "label",
                            caption = ""
                        }
                        todo_submenu_body.add {
                            type = "label",
                            caption = "[font=default-large-bold]Notes:   [/font]" .. "Owner: " .. target.owner ..
                                ",  Last Edit: " .. target.last_user
                        }

                        local notes_textbox = todo_submenu_body.add {
                            type = "text-box",
                            text = target.text,
                            name = "todo_text_textbox"
                        }
                        notes_textbox.style.minimal_width = 575
                        notes_textbox.style.minimal_height = 200
                        notes_textbox.style.maximal_height = 600
                        notes_textbox.read_only = no_edit
                        if no_edit then
                            notes_textbox.selectable = false
                        end

                        local todo_save_frame = todo_submenu_body.add {
                            type = "flow",
                            name = "save_frame",
                            direction = "horizontal"
                        }
                        todo_save_frame.style.horizontal_align = "right"
                        todo_save_frame.style.horizontally_stretchable = true

                        if edit_mode then
                            local whoedit = ""
                            local c = 0
                            for _, victim in pairs(game.players) do
                                if victim.index ~= player.index and storage.todo_player_editing_id[victim.index] ==
                                    storage.todo_player_editing_id[player.index] then
                                    c = c + 1
                                    if c > 1 then
                                        whoedit = whoedit .. ", "
                                    end
                                    whoedit = whoedit .. victim.name
                                end
                            end
                            if whoedit ~= "" then
                                local edit_note = todo_save_frame.add {
                                    type = "label",
                                    caption = "[font=default-large-bold][color=red]CURRENTLY BEING EDITED BY: " ..
                                        whoedit .. "[/color][/font]"
                                }
                                local lock_spacer = todo_save_frame.add {
                                    type = "empty-widget"
                                }
                                lock_spacer.style.width = 32
                            end
                            if target.hidden then
                                local delete_button = todo_save_frame.add {
                                    type = "button",
                                    caption = "Unhide",
                                    style = "red_button",
                                    name = "m45_todo_hide," .. storage.todo_player_editing_id[player.index]
                                }
                                if no_edit then
                                    delete_button.enabled = false
                                end
                            else
                                local delete_button = todo_save_frame.add {
                                    type = "button",
                                    caption = "Hide",
                                    style = "red_button",
                                    name = "m45_todo_hide," .. storage.todo_player_editing_id[player.index]
                                }
                                if no_edit then
                                    delete_button.enabled = false
                                end
                            end
                            local lock_spacer = todo_save_frame.add {
                                type = "empty-widget"
                            }
                            lock_spacer.style.width = 16
                            local save_button = todo_save_frame.add {
                                type = "button",
                                caption = "Save",
                                style = "green_button",
                                name = "m45_todo_save," .. storage.todo_player_editing_id[player.index]
                            }

                            if no_edit then
                                save_button.enabled = false
                            end
                        end
                    end
                end
            end
        end
    end
end

-- M45 ToDo Window
function TODO_MakeWindow(player)
    if player.gui and player.gui.screen then
        if player.gui.screen.m45_todo then
            player.gui.screen.m45_todo.destroy()
        end
        if not player.gui.screen.m45_todo then
            local main_flow = player.gui.screen.add {
                type = "frame",
                name = "m45_todo",
                direction = "vertical"
            }
            main_flow.style.horizontal_align = "left"
            main_flow.style.vertical_align = "top"
            main_flow.style.minimal_width = 300
            main_flow.style.vertically_stretchable = true

            -- Todo Title Bar--
            local todo_titlebar = main_flow.add {
                type = "flow",
                direction = "horizontal"
            }
            todo_titlebar.style.horizontal_align = "center"
            todo_titlebar.style.horizontally_stretchable = true
            todo_titlebar.style.vertically_stretchable = false

            todo_titlebar.add {
                type = "label",
                name = "online_title",
                style = "frame_title",
                caption = "To-Do List:"
            }
            local pusher = todo_titlebar.add {
                type = "empty-widget"
            }
            pusher.style.horizontally_stretchable = true

            local state = false
            if storage.show_hidden_notes and storage.show_hidden_notes[player.index] then
                state = true
            end

            local show_hidden = todo_titlebar.add {
                type = "checkbox",
                caption = "Show hidden  ",
                name = "m45_todo_show_hidden",
                state = state,
                tooltip = "Toggle show hidden notes."
            }

            -- CLOSE BUTTON--
            local todo_close_button = todo_titlebar.add {
                type = "flow",
                direction = "horizontal"
            }
            todo_close_button.style.horizontal_align = "right"
            todo_close_button.style.horizontally_stretchable = false
            todo_close_button.add {
                type = "sprite-button",
                name = "m45_todo_close_button",
                sprite = "utility/close",
                style = "frame_action_button",
                tooltip = "Close this window"
            }

            local pframe = main_flow.add {
                type = "flow",
                direction = "horizontal"
            }
            pframe.style.vertically_stretchable = false
            pframe.style.horizontal_align = "right"

            local todo_main = main_flow.add {
                type = "scroll-pane",
                direction = "vertical"
            }

            pframe.style.horizontally_stretchable = true

            local submenu = pframe.add {
                type = "label",
                caption = "VIEW / EDIT"
            }
            submenu.style.width = 120

            pframe.add {
                type = "label",
                caption = " "
            }
            local id_label = pframe.add {
                type = "label",
                caption = " ID#"
            }
            id_label.style.width = 53
            local name_label = pframe.add {
                type = "label",
                caption = "Priority"
            }
            name_label.style.width = 100
            local time_label = pframe.add {
                type = "label",
                caption = "Subject"
            }
            time_label.style.width = 200
            local notes_label = pframe.add {
                type = "label",
                caption = " Notes"
            }

            if not storage.vis_todo_count or (storage.vis_todo_count and storage.vis_todo_count <= 0) then
                pframe.add {
                    type = "label",
                    caption = "Nothing here."
                }
            end

            if storage.vis_todo_count and storage.vis_todo_count > 0 then
                for i, target in pairs(storage.todo_list) do
                    -- Skip hidden items
                    if not target.hidden or (storage.show_hidden_notes and storage.show_hidden_notes[player.index]) then
                        todo_main.add {
                            type = "line",
                            direction = "horizontal"
                        }
                        local pframe = todo_main.add {
                            type = "flow",
                            direction = "horizontal"
                        }
                        if isUnreadVictim(player, i) then
                            local unread_label = pframe.add {
                                type = "label",
                                caption = "[NEW]"
                            }
                        end
                        pframe.style.horizontally_stretchable = true
                        pframe.style.vertically_stretchable = false
                        pframe.style.maximal_width = 1600
                        local submenu_view = pframe.add {
                            type = "sprite-button",
                            sprite = "utility/search",
                            style = "frame_action_button",
                            name = "m45_todo_submenu_view," .. i, -- pass-item
                            tooltip = "View this item"
                        }
                        submenu_view.style.size = { 36, 36 }
                        submenu_view.style.padding = 4

                        local submenu_edit = pframe.add {
                            type = "sprite-button",
                            sprite = "utility/rename_icon",
                            style = "frame_action_button",
                            name = "m45_todo_submenu_edit," .. i, -- pass-item
                            tooltip = "Edit this item"
                        }
                        submenu_edit.style.size = { 36, 36 }
                        submenu_edit.style.padding = 4
                        local can_edit = true
                        -- Disable button if we can't edit
                        if UTIL_Is_New(player) or (not player.admin and player.name ~= target.owner and not target.can_edit) then
                            submenu_edit.enabled = false
                            can_edit = false
                        end

                        local gps_spacer = pframe.add {
                            type = "empty-widget"
                        }
                        gps_spacer.style.width = 54
                        local id_label = pframe.add {
                            type = "label",
                            caption = target.id
                        }
                        id_label.style.width = 45
                        local pri_label = pframe.add {
                            type = "label",
                            caption = target.priority
                        }
                        pri_label.style.width = 100
                        local name_label = pframe.add {
                            type = "label",
                            caption = target.subject
                        }
                        name_label.style.width = 200

                        -- Show who owns item, who edited and if locked
                        local locked = ""
                        if not target.can_edit then
                            locked = " (locked)"
                        end
                        local notes_label = pframe.add {
                            type = "label",
                            caption = "  " .. target.text .. "  ",
                            tooltip = "Last User: " .. target.last_user .. ", Owner: " .. target.owner .. locked
                        }
                        local hidden = ""
                        if target.hidden then
                            local grayed = {
                                r = 0.66,
                                g = 0.66,
                                b = 0.66
                            }
                            id_label.style.font_color = grayed
                            pri_label.style.font_color = grayed
                            name_label.style.font_color = grayed
                            notes_label.style.font_color = grayed
                        end

                        notes_label.style.horizontally_stretchable = true
                        notes_label.style.horizontally_squashable = true
                        notes_label.style.minimal_width = 300
                        notes_label.style.horizontal_align = "left"
                        local spacer = pframe.add {
                            type = "empty-widget"
                        }
                        spacer.style.horizontally_stretchable = true

                        local move_ud_frame = pframe.add {
                            type = "flow",
                            direction = "vertical"
                        }

                        -- Invisible space for up arrow when hidden
                        if i == 1 then
                            local invis_space = move_ud_frame.add {
                                type = "label",
                                caption = " "
                            }
                            invis_space.style.height = 18
                        end

                        local moveup = move_ud_frame.add {
                            type = "sprite-button",
                            sprite = "file/img/todo/up.png",
                            name = "m45_todo_moveup," .. i, -- pass-item
                            style = "frame_action_button",
                            tooltip = "move up"
                        }
                        moveup.style.size = { 18, 18 }

                        local movedown = move_ud_frame.add {
                            type = "sprite-button",
                            sprite = "file/img/todo/down.png",
                            name = "m45_todo_movedown," .. i, -- pass-item
                            style = "frame_action_button",
                            tooltip = "move down"
                        }
                        movedown.style.size = { 18, 18 }

                        if UTIL_Is_New(player) then
                            movedown.visible = false
                            moveup.visible = false
                        end

                        -- Hide buttons that would do nothing, first item up, last item down
                        if i == 1 then
                            moveup.visible = false
                        end
                        if i == storage.vis_todo_count then
                            local invis_space = move_ud_frame.add {
                                type = "label",
                                caption = " "
                            }
                            invis_space.style.height = 18
                            movedown.visible = false
                        end

                        notes_label.style.rich_text_setting = defines.rich_text_setting.enabled
                        notes_label.style.horizontally_stretchable = false
                    end
                end
            end

            -- ADD LINE
            local add_frame = main_flow.add {
                type = "flow",
                direction = "horizontal"
            }

            add_frame.style.horizontal_align = "right"
            add_frame.style.horizontally_stretchable = false

            local add = add_frame.add {
                type = "sprite-button",
                sprite = "file/img/todo/add.png",
                name = "m45_todo_add"
            }
            if UTIL_Is_New(player) then
                add.enabled = false
            end
            local add_note = add_frame.add {
                type = "label",
                caption = "Add item"
            }
            add.style.size = { 24, 24 }
            notes_label.style.rich_text_setting = defines.rich_text_setting.highlight
            notes_label.style.horizontally_stretchable = true
        end
    end
end

local function updateTodoCount()
    storage.vis_todo_count = 0
    for _, item in pairs(storage.todo_list) do
        if not item.hidden then
            storage.vis_todo_count = storage.vis_todo_count + 1
        end
    end
end

function TODO_Setup(player)
    if player and player.index then
        return
    end
    -- To-Do button--
    if player.gui.top.todo_button then
        player.gui.top.todo_button.destroy()
    end
    if not player.gui.top.todo_button then
        local todo_64 = player.gui.top.add {
            type = "sprite-button",
            name = "todo_button",
            sprite = "file/img/buttons/todo2-64.png",
            tooltip = "Read or edit the To-Do list."
        }
        todo_64.style.size = { 64, 64 }
        if not storage.todo_unread then
            storage.todo_unread = {}
        end
        if not storage.todo_unread[player.index] then
            storage.todo_unread[player.index] = {}
        end
    end
end

-- GUI clicks
local function guiClick(event)
    if event and event.element and event.element.valid and event.player_index then
        local player = game.players[event.player_index]
        local args = UTIL_SplitStr(event.element.name, ",")

        if player and player.valid then
            if UTIL_Is_Banished(player) then
                return
            end

            -- Grab target if we have one
            if event.element.name == "m45_todo_submenu_close_button" then
                ----------------------------------------------------------------
                -- Close online submenu
                if player.gui and player.gui.screen and player.gui.screen.m45_todo_submenu then
                    player.gui.screen.m45_todo_submenu.destroy()

                    if storage.todo_player_editing_id and storage.todo_player_editing_id[player.index] then
                        local id = storage.todo_player_editing_id[player.index]
                        storage.todo_player_editing_id[player.index] = nil
                    end
                end
            elseif event.element.name == "m45_todo_show_hidden" then
                storage.show_hidden_notes[player.index] = event.element.state
                TODO_MakeWindow(player)
            elseif args and args[2] and args[1] == "m45_todo_moveup" then
                ----------------------------------------------------------------
                local i = tonumber(args[2])
                if i > 1 then
                    table.insert(storage.todo_list, i - 1, table.remove(storage.todo_list, i))
                    updateTODOWindows()
                else
                    UTIL_SmartPrint(player, "It is already the first item!")
                end
                local moved_item = todo_key(i)
                UTIL_ConsolePrint("[TODO] " .. player.name .. " moved item " .. todo_key(i) .. " up.")
            elseif args and args[2] and args[1] == "m45_todo_movedown" then
                ----------------------------------------------------------------
                local i = tonumber(args[2])
                local count = 0
                for _, _ in pairs(storage.todo_list) do
                    count = count + 1
                end
                if i < count then
                    table.insert(storage.todo_list, i + 1, table.remove(storage.todo_list, i))
                    updateTODOWindows()
                else
                    UTIL_SmartPrint(player, "It is already at the end of the list.")
                end
                UTIL_ConsolePrint("[TODO] " .. player.name .. " moved item " .. todo_key(i) .. " down.")
            elseif args and args[2] and args[1] == "m45_todo_submenu_edit" then
                ----------------------------------------------------------------
                if player and player.valid and player.character and player.character.valid then
                    local i = tonumber(args[2])
                    if storage.todo_list and storage.todo_list[i] then
                        -- Save what ID we are editing for updates
                        local item = storage.todo_list[i]
                        storage.todo_player_editing_id[player.index] = storage.todo_list[i].id
                        makeTodoSubmenu(player, i, true)
                    else
                        local error = "[ERROR] m45_todo_submenu_edit: Unable to find item: " .. i
                        UTIL_SmartPrint(player, error)
                        UTIL_ConsolePrint(error)
                    end
                end
            elseif args and args[2] and args[1] == "m45_todo_submenu_view" then
                ----------------------------------------------------------------
                if player and player.valid and player.character and player.character.valid then
                    local i = tonumber(args[2])
                    if storage.todo_list and storage.todo_list[i] then
                        makeTodoSubmenu(player, i, false)
                    end
                end
            elseif event.element.name == "m45_todo_add" then
                ----------------------------------------------------------------
                ---
                -- edit/create throttle
                if storage.todo_throttle[player.index] then
                    if game.tick - storage.todo_throttle[player.index] < (60 * 5) then -- 10 seconds
                        UTIL_SmartPrint(player, "(SYSTEM) Please wait 5 seconds before attempting to make a new item.")
                        -- storage.todo_throttle[player.index] = game.tick --Reset timer, prevent spamming
                        return
                    end
                end
                storage.todo_throttle[player.index] = game.tick

                if not storage.todo_max then
                    storage.todo_max = {}
                end
                if storage.todo_max[player.index] then
                    if storage.todo_max[player.index] < 25 then
                        storage.todo_max[player.index] = storage.todo_max[player.index] + 1
                    else
                        UTIL_SmartPrint(player, "You have personally created 25 todo items, limit reached.")
                        return
                    end
                else
                    storage.todo_max[player.index] = 1
                end

                storage.todo_list_id = storage.todo_list_id + 1
                table.insert(storage.todo_list, {
                    priority = 0,
                    subject = "new",
                    text = loremipsum,
                    time = game.tick,
                    owner = player.name,
                    last_user = player.name,
                    can_edit = true,
                    id = storage.todo_list_id,
                    hidden = false
                })

                updateTodoCount()
                updateTODOWindows()
                UTIL_ConsolePrint("[TODO] " .. player.name .. " added a new todo item: " .. storage.todo_list_id)
            elseif args and args[2] and args[1] == "m45_todo_hide" then
                ----------------------------------------------------------------
                local id = tonumber(args[2]) -- Grab passed ID
                local i = id_to_index(id)    -- Find by ID, index can change
                if i > 0 then                -- If we found the note
                    -- Sanity check
                    if storage.todo_list and storage.todo_list[i] and player and player.valid and player.gui and
                        player.gui.screen and player.gui.screen.m45_todo_submenu and
                        player.gui.screen.m45_todo_submenu.todo_body and
                        player.gui.screen.m45_todo_submenu.todo_body.todo_text_textbox and
                        player.gui.screen.m45_todo_submenu.todo_body.todo_text_textbox.text then
                        if not storage.todo_throttle then
                            storage.todo_throttle = {}
                        end
                        if storage.todo_throttle[player.index] then
                            if game.tick - storage.todo_throttle[player.index] < (60 * 5) then -- 10 seconds
                                UTIL_SmartPrintColor(player,
                                    "(SYSTEM) CHANGES NOT SAVED, PLEASE WAIT 5 SECONDS BEFORE TRYING TO SAVE AGAIN.")

                                return
                            end
                        else
                            -- init
                            storage.todo_throttle[player.index] = game.tick
                        end

                        -- Set timer, hide, update count
                        storage.todo_throttle[player.index] = game.tick
                        storage.todo_list[i].hidden = (not storage.todo_list[i].hidden)
                        updateTodoCount()

                        -- Log action
                        UTIL_ConsolePrint("[TODO] " .. player.name .. " hid todo item: " .. storage.todo_list_id)

                        -- Destroy window
                        player.gui.screen.m45_todo_submenu.destroy()

                        -- Update windows
                        updateTODOWindows()

                        -- We are no longer editing, clear
                        storage.todo_player_editing_id[player.index] = nil
                    else
                        -- Something is broken
                        UTIL_SmartPrint(player,
                            "Sorry, something went wrong, unable to delete. Please report this issue.")
                    end
                else
                    UTIL_SmartPrint(player, "Error: Could not find note id: " .. id)
                end
            elseif args and args[2] and args[1] == "m45_todo_save" then
                ----------------------------------------------------------------
                local id = tonumber(args[2]) -- Grab passed ID
                local i = id_to_index(id)    -- Find by ID, index can change
                if i > 0 then                -- If we found the note
                    -- Sanity check
                    if storage.todo_list and storage.todo_list[i] and player and player.valid and player.gui and
                        player.gui.screen and player.gui.screen.m45_todo_submenu and
                        player.gui.screen.m45_todo_submenu.todo_body and
                        player.gui.screen.m45_todo_submenu.todo_body.todo_text_textbox and
                        player.gui.screen.m45_todo_submenu.todo_body.todo_text_textbox.text then
                        -- Store current state
                        local prev_priority = storage.todo_list[i].priority
                        local prev_subject = storage.todo_list[i].subject
                        local prev_can_edit = storage.todo_list[i].can_edit
                        local prev_text = storage.todo_list[i].text

                        -- Save new state
                        local priority = player.gui.screen.m45_todo_submenu.main.todo_priority_textbox.text
                        local subject = player.gui.screen.m45_todo_submenu.main.todo_subject_textbox.text
                        local can_edit = (not player.gui.screen.m45_todo_submenu.main.todo_protected.state)
                        local text = player.gui.screen.m45_todo_submenu.todo_body.todo_text_textbox.text

                        -- Only save & archive if something was changed
                        if prev_priority ~= priority or prev_subject ~= subject or prev_can_edit ~= can_edit or
                            prev_text ~= text then
                            if storage.todo_throttle[player.index] then
                                if game.tick - storage.todo_throttle[player.index] < (60 * 5) then -- 5 seconds
                                    UTIL_SmartPrintColor(player,
                                        "(SYSTEM) CHANGES NOT SAVED, PLEASE WAIT 5 SECONDS BEFORE TRYING TO SAVE AGAIN.")
                                    return
                                end
                            else
                                -- init
                                storage.todo_throttle[player.index] = game.tick
                            end

                            -- Init if needed
                            if not storage.todo_list[i].history then
                                storage.todo_list[i].history = {}
                            end
                            -- Save previous version
                            table.insert(storage.todo_list[i].history, {
                                priority = storage.todo_list[i].priority,
                                subject = storage.todo_list[i].subject,
                                text = storage.todo_list[i].text,
                                last_user = storage.todo_list[i].last_user,
                                time = storage.todo_list[i].time
                            })

                            -- Update & save
                            storage.todo_list[i].priority = priority
                            storage.todo_list[i].subject = subject
                            storage.todo_list[i].can_edit = can_edit
                            storage.todo_list[i].text = text
                            storage.todo_list[i].last_user = player.name
                            storage.todo_list[i].time = game.tick

                            storage.todo_throttle[player.index] = game.tick

                            -- Log action
                            UTIL_ConsolePrint("[TODO] " .. player.name .. " editied todo item: " .. todo_key(i))

                            -- Destroy window
                            player.gui.screen.m45_todo_submenu.destroy()

                            -- Update windows
                            updateTODOWindows()

                            -- We are no longer editing, clear
                            storage.todo_player_editing_id[player.index] = nil
                        else
                            -- Nothing changed
                            UTIL_SmartPrint(player, "No changes to save.")
                        end
                    else
                        -- Something is broken
                        UTIL_SmartPrint(player, "Sorry, something went wrong, unable to save. Please report this issue.")
                    end
                else
                    UTIL_SmartPrint(player, "Error: Could not find note id: " .. id)
                end
            elseif event.element.name == "m45_todo_close_button" then
                ----------------------------------------------------------------
                if player.gui and player.gui.screen then
                    if player.gui.screen.m45_todo then
                        if storage.todo_player_editing_id and storage.todo_player_editing_id[player.index] then
                            local id = storage.todo_player_editing_id[player.index]
                            storage.todo_player_editing_id[player.index] = nil
                        end
                        player.gui.screen.m45_todo.destroy()
                    end
                end
            elseif event.element.name == "todo_button" then
                ----------------------------------------------------------------
                -- todo window close
                if player.gui and player.gui.left and player.gui.left.m45_todo then
                    player.gui.left.m45_todo.destroy()
                else
                    TODO_MakeWindow(player)
                end
            end
        end
    end
end


local function updateWindowEvent(event)
    local player = game.players[event.player_index]
    -- Refresh window if open
    if player.gui.screen.m45_todo then
        player.gui.screen.m45_todo.destroy()
        TODO_MakeWindow(player)
    end
end

function TODO_EventHandler(event)
    if event.name == defines.events.on_player_joined_game then
        updateWindowEvent(event)
    elseif event.name == defines.events.on_gui_click then
        guiClick(event)
    end
end

function TODO_Init()
    if not storage.todo_player_editing_id then
        storage.todo_player_editing_id = {}
    end
    if not storage.show_hidden_notes then
        storage.show_hidden_notes = {}
    end
    if not storage.todo_list_id then
        storage.todo_list_id = 0
    end
    if not storage.vis_todo_count then
        storage.vis_todo_count = 1
    end
    if not storage.todo_throttle then
        storage.todo_throttle = {}
    end
    if not storage.todo_unread then
        storage.todo_unread = {}
    end
    if not storage.todo_list then
        storage.todo_list = { {
            priority = 10000,
            subject = "Use the TO-DO list",
            text = "Use the TO-DO list",
            time = 0,
            last_user = "System",
            can_edit = false,
            owner = "System",
            id = 0,
            hidden = false
        } }
    end
    updateTodoCount()
end
