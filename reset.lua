-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
-- Safe console print

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
            tooltip = "Map reset schdule. Control-right-click to minimize.",
            visible = false,
        }
        rclock.style.size = { 24, 24 }
    end
end
