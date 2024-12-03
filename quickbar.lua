-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

function ExportQuickbar(player, limit)
    if not player or not player.valid then
        return
    end

    local outbuf = ""
    local maxExport = 100
    if limit then
        maxExport = 20
    end

    for i = 1, maxExport do
        local slot = player.get_quick_bar_slot(i)
        if slot ~= nil then
            if outbuf ~= "" then
                outbuf = outbuf .. ","
            end
            outbuf = outbuf .. i .. ":" .. slot.name
        end
    end
    return outbuf
end

function ImportQuickbar(player, data)
    if not player or not player.valid then
        return
    end
    if data == nil or data == "" then
        return
    end

    --Clear all bars
    for i = 1, 100 do
        local slot = player.set_quick_bar_slot(i, nil)
    end

    --Restore from string
    local items = UTIL_SplitStr(data, ",")

    for i, item in ipairs(items) do
        local values = UTIL_SplitStr(item, ":")
        player.set_quick_bar_slot(values[1], values[2])
    end
end

function SaveQuickbar(player)
    if not player or not player.valid then
        return
    end
      print("[QBSAVE] " .. ExportQuickbar(player, true))
end

function LoadQuickbar(player)
    if not player or not player.valid or not player.name then
        return
    end
    print("[QBLOAD] " .. player.name)
end

function QUICKBAR_MakeExchangeButton(player)
    if player.gui.top.qb_exchange_button then
        player.gui.top.qb_exchange_button.destroy()
    end
    if not player.gui.top.qb_exchange_button then
        local ex_button= player.gui.top.add {
            type = "sprite-button",
            name = "qb_exchange_button",
            sprite = "file/img/buttons/exchange-64.png",
            tooltip = "Import or export a quickbar exchange string."
        }
        ex_button.style.size = { 64, 64 }
    end
end

function QUICKBAR_MakeExchangeWindow(player, text)
    if player.gui.screen.quickbar_exchange then
        player.gui.screen.quickbar_exchange.destroy()
    end
    local main_flow = player.gui.screen.add {
        type = "frame",
        name = "quickbar_exchange",
        direction = "vertical"
    }
    main_flow.style.horizontal_align = "center"
    main_flow.style.vertical_align = "center"
    main_flow.force_auto_center()

    -- Title Bar--
    local info_titlebar = main_flow.add {
        type = "flow",
        direction = "horizontal"
    }
    info_titlebar.drag_target = main_flow
    info_titlebar.style.horizontal_align = "center"
    info_titlebar.style.horizontally_stretchable = true

    info_titlebar.add {
        type = "label",
        name = "online_title",
        style = "frame_title",
        caption = "Quickbar Exchange String"
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
        name = "quickbar_exchange_close",
        sprite = "utility/close",
        style = "frame_action_button",
        tooltip = "Close this window"
    }

    main_flow.style.padding = 4
    local mframe = main_flow.add {
        type = "flow",
        direction = "horizontal"
    }
    mframe.style.minimal_height = 100
    mframe.style.horizontally_squashable = false

    mframe.add {
        type = "text-box",
        name = "quickbar_string",
        text = text,
        tooltip = "control-a then control-c to copy, control-a then control-v to paste.",
    }
    mframe.quickbar_string.style.minimal_width = 500
    mframe.quickbar_string.style.minimal_height= 50
end