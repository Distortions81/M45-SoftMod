function RESET_MakeClock(player)
    -- Online button--
    if player.gui.top.reset_clock then
        player.gui.top.reset_clock.destroy()
    end
    if not player.gui.top.reset_clock then
        local rclock = player.gui.top.add {
            type = "button",
            name = "reset_clock",
            style = "red_button",
            tooltip = "Map reset schdule. Control-right-click to minimize."
        }
    end
end
