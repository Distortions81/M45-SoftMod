-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

-- Add M45 Logo to spawn area
function LOGO_DrawLogo(force)
    if force then
        storage.SM_Store.redrawLogo = true
    end

    local msurf = game.surfaces[1]
    if msurf then
        -- Only draw if needed
        if not storage.SM_Store.redrawLogo then
            -- Destroy if already exists
            if storage.SM_Store.spawnLogo then
                storage.SM_Store.spawnLogo.destroy()
            end
            if storage.SM_Store.spawnLight then
                storage.SM_Store.spawnLight.destroy()
            end
            if storage.SM_Store.spawnText then
                storage.SM_Store.spawnText.destroy()
            end

            -- Get spawn position
            local cpos = UTIL_GetDefaultSpawn()

            -- Find nice clear area for spawn
            local newpos = msurf.find_non_colliding_position("crash-site-spaceship", cpos, 0, 10, true)
            -- Set spawn position if we found a better spot
            if newpos then
                cpos = newpos
                local pforce = game.forces["player"]
                if pforce then
                    pforce.set_spawn_position(cpos, msurf)
                else
                    UTIL_ConsolePrint("[ERROR] dodrawlogo: Player force not found.")
                end
            end

            -- Set drawn flag
            storage.SM_Store.redrawLogo = false
            storage.SM_Store.spawnLogo = rendering.draw_sprite {
                sprite = "file/img/world/m45-pad-v6.png",
                render_layer = "floor",
                target = cpos,
                x_scale = 0.5,
                y_scale = 0.5,
                surface = msurf
            }
            storage.SM_Store.spawnLight = rendering.draw_light {
                sprite = "utility/light_medium",
                render_layer = 148,
                target = cpos,
                scale = 8,
                surface = msurf,
                minimum_darkness = 0.5
            }
            if not storage.SM_Store.serverName then
                storage.SM_Store.serverName = ""
            end
            storage.SM_Store.spawnText = rendering.draw_text {
                text = storage.SM_Store.serverName,
                draw_on_ground = true,
                surface = msurf,
                target = {cpos.x - 0.125, cpos.y - 2.5},
                scale = 3.0,
                color = {1, 1, 1},
                alignment = "center",
                scale_with_zoom = false
            }
        end
    end
end
