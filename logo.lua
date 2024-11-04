-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
-- Add M45 Logo to spawn area
function LOGO_DrawLogo()
    local msurf = game.surfaces["nauvis"]
    if msurf then
        -- Only draw if needed
        if not storage.drawlogo then
            -- Destroy if already exists
            if storage.m45logo then
               storage.m45logo.destroy()
            end
            if storage.m45logo_light then
               storage.m45logo_light.destroy()
            end
            if storage.servtext then
               storage.servtext.destroy()
            end

            -- Get spawn position
            local cpos = get_default_spawn()

            -- Find nice clear area for spawn
            local newpos = msurf.find_non_colliding_position("crash-site-spaceship", cpos, 8192, 10, false)
            -- Set spawn position if we found a better spot
            if newpos then
                cpos = newpos
                local pforce = game.forces["player"]
                if pforce then
                    pforce.set_spawn_position(cpos, msurf)
                else
                    console_print("[ERROR] dodrawlogo: Player force not found.")
                end
            end

            -- Set drawn flag
            storage.drawlogo = true
            storage.m45logo = rendering.draw_sprite {
                sprite = "file/img/world/m45-pad-v6.png",
                render_layer = "floor",
                target = cpos,
                x_scale = 0.5,
                y_scale = 0.5,
                surface = msurf
            }
            storage.m45logo_light = rendering.draw_light {
                sprite = "utility/light_medium",
                render_layer = 148,
                target = cpos,
                scale = 8,
                surface = msurf,
                minimum_darkness = 0.5
            }
            if not storage.servname then
                storage.servname = ""
            end
            storage.servtext = rendering.draw_text {
                text = storage.servname,
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
