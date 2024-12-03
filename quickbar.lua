-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

function ExportQuickbar(player)
    if not player or not player.valid then
        return
    end

    local outbuf = ""
    local total = 0
    for i = 1, 100 do
        local slot = player.get_quick_bar_slot(i)
        if slot ~= nil then
            if outbuf ~= "" then
                outbuf = outbuf .. ","
            end
            outbuf = outbuf .. i .. ":" .. slot.name
            total = total + 1
            --Cap item count
            if total == 30 then
                return outbuf
            end
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
      print("[QBSAVE] " .. ExportQuickbar(player))
end