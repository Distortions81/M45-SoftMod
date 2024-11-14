-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

-- Add M45 Logo to spawn area
function LOGO_DrawLogo(force)
    if force then
        storage.SM_Store.redrawLogo = true
    end

    local msurf = game.surfaces["nauvis"]
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

        -- Only draw if needed
        if storage.SM_Store.redrawLogo then
            -- Destroy if already exists
            if storage.SM_Store.spawnLight then
                storage.SM_Store.spawnLight.destroy()
            end
            if storage.SM_Store.spawnText then
                storage.SM_Store.spawnText.destroy()
            end
            if storage.SM_Store.spawnLogo then
                storage.SM_Store.spawnLogo.destroy()
            end

            --Check if any buildings are on top of spawn
            local blocked = false
            local cpos = UTIL_GetDefaultSpawn()
            local entFound = msurf.find_entities({ { x = cpos.x - 10, y = cpos.y - 10 }, { x = cpos.x + 10, y = cpos.y + 10 } })
            for _, ent in pairs(entFound) do
                if string.find(ent.name, "tree") then
                    ent.destroy()
                elseif ent.name ~= "character" and ent.has_flag("player-creation") then
                    blocked = true
                end
            end

            --If needed, move spawn
            if blocked then
                local lpos = { x = 0, y = 0 }
                cpos = lpos
                local attempts = 0
                local stillBlocked = false
                while blocked do
                    for x = 0, 4000, 4 do
                        for y = 0, 4000, 4 do
                            for z = 0, 3, 1 do
                                if z == 0 then
                                    lpos.x = cpos.x + x
                                    lpos.y = cpos.y + y
                                elseif z == 1 then
                                    lpos.x = cpos.x - x
                                    lpos.y = cpos.y + y
                                elseif z == 2 then
                                    lpos.x = cpos.x + x
                                    lpos.y = cpos.y - y
                                else
                                    lpos.x = cpos.x - x
                                    lpos.y = cpos.y - y
                                end
                                local entFound = msurf.find_entities({ { lpos.x - 10, lpos.y - 10 }, { lpos.x + 10, lpos.y + 10 } })
                                attempts = attempts + 1
                                if attempts >= 10000 then
                                    return
                                end
                                stillBlocked = false
                                for _, ent in pairs(entFound) do
                                    if string.find(ent.name, "tree") then
                                        ent.destroy()
                                    elseif ent.name ~= "character" and ent.has_flag("player-creation") then
                                        stillBlocked = true
                                    end
                                end
                                if msurf.can_place_entity("crash-site-spaceship", lpos) then
                                    if not stillBlocked then
                                        blocked = false
                                        goto done
                                    else
                                        stillBlocked = false
                                        blocked = true
                                    end
                                end
                            end
                        end
                    end
                end


                ::done::
                if not blocked then
                    local pforce = game.forces["player"]
                    if pforce then
                        pforce.set_spawn_position(lpos, msurf)
                        UTIL_MapPin()
                        UTIL_MsgAllSys("Items placed on top of the spawn area, spawn moved to " .. UTIL_GPSPos(lpos))
                    else
                        UTIL_ConsolePrint("[ERROR] dodrawlogo: Player force not found.")
                    end
                else
                    UTIL_ConsolePrint("[ERROR] dodrawlogo: No suitable spawn location found!!!")
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
                target = { cpos.x - 0.125, cpos.y - 2.5 },
                scale = 3.0,
                color = { 1, 1, 1 },
                alignment = "center",
                scale_with_zoom = false
            }
        end
    end
end
