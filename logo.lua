-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

-- Add M45 Logo to spawn area
function LOGO_DrawLogo(force)
    local msurf = game.surfaces[1]

    if msurf then
        -- Migrate old scripts
        if storage.m45logo then
            storage.m45logo.destroy()
        end
        if storage.m45logo_light then
            storage.m45logo_light.destroy()
        end
        if storage.servtext then
            storage.servtext.destroy()
        end

        local newPos = UTIL_GetDefaultSpawn()
        newPos.x = newPos.x + 20
        newPos.y = newPos.y - 20
        local cpos = msurf.find_non_colliding_position("crash-site-spaceship", newPos, 4096, 4, true)
        if not cpos then
            cpos = { x = 0, y = 0 }
        end

        local oldPos = UTIL_GetDefaultSpawn()
        local pforce = game.forces["player"]
        if pforce then
            pforce.set_spawn_position(cpos, msurf)
        end
        local newPos = UTIL_GetDefaultSpawn()

        --Just exit if position did not change, unless force redraw
        if not force and oldPos == newPos then
            return
        end

        -- Move map pin
        UTIL_MapPin()

        -- Destroy if already exists
        if storage.SM_Store.spawnLight then
            storage.SM_Store.spawnLight.destroy()
        end
        if storage.SM_Store.spawnText then
            storage.SM_Store.spawnText.destroy()
        end
        if storage.SM_Store.inviteText then
            storage.SM_Store.inviteText.destroy()
        end
        if storage.SM_Store.webText then
            storage.SM_Store.webText.destroy()
        end
        if storage.SM_Store.spawnLogo then
            storage.SM_Store.spawnLogo.destroy()
        end


        storage.SM_Store.spawnLogo = rendering.draw_sprite {
            sprite = "file/img/world/m45-pad-v6.png",
            render_layer = "floor",
            target = newPos,
            x_scale = 0.5,
            y_scale = 0.5,
            surface = msurf
        }
        storage.SM_Store.spawnLight = rendering.draw_light {
            sprite = "utility/light_medium",
            render_layer = "floor",
            target = newPos,
            scale = 8,
            surface = msurf,
            minimum_darkness = 0.1
        }
        if storage.SM_Store.serverName then
            storage.SM_Store.spawnText = rendering.draw_text {
                text = "Map: "..storage.SM_Store.serverName,
                draw_on_ground = true,
                surface = msurf,
                target = { newPos.x - 0.125, newPos.y - 1.0 },
                scale = 2.0,
                color = { 1, 1, 1 },
                alignment = "center",
                scale_with_zoom = false
            }
        end
        storage.SM_Store.inviteText = rendering.draw_text {
            text = "discord.gg/rQANzBheVh",
            draw_on_ground = true,
            surface = msurf,
            target = { newPos.x - 0.125, newPos.y + 1.5 },
            scale = 2.0,
            color = { 1, 1, 1 },
            alignment = "center",
            scale_with_zoom = false
        }
        storage.SM_Store.webText = rendering.draw_text {
            text = "m45sci.xyz",
            draw_on_ground = true,
            surface = msurf,
            target = { newPos.x - 0.125, newPos.y + 2.5 },
            scale = 2.0,
            color = { 1, 1, 1 },
            alignment = "center",
            scale_with_zoom = false
        }
    end
end
