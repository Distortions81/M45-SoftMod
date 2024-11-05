-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
-- Safe console print

function ONELIFE_Main(event)
    if not storage.SM_Store.oneLifeMode then
        return
    end

    if not event or not event.player_index then
        return
    end
    local player = game.players[event.player_index]
    if not player or not player.valid then
        return
    end

    player.set_controller {
        type = defines.controllers.spectator
    }
    UTIL_SmartPrint(player, "Game over! you are now a spectator.")
    ONLINE_UpdatePlayerList()

    if not player.character or not player.character.valid then
        return
    end
    local character = player.character
    -- Stop player states, just in case
    character.walking_state = {
        walking = false,
        direction = defines.direction.south
    }
    character.riding_state = {
        acceleration = defines.riding.acceleration.braking,
        direction = defines.riding.direction.straight
    }
    character.shooting_state = {
        state = defines.shooting.not_shooting,
        position = character.position
    }
    character.mining_state = {
        mining = false
    }
    character.picking_state = false
    character.repair_state = {
        repairing = false,
        position = character.position
    }
end

function ONELIFE_Clicks(event)
    if not storage.SM_Store.oneLifeMode then
        return
    end

    if not event or not event.player_index then
        return
    end
    local player = game.players[event.player_index]
    if not player or not player.valid then
        return
    end
    if not player.character or not player.character.valid then
        UTIL_SmartPrint("You are already dead!")
        return
    end
    if event.element and event.element.valid and event.element.name == "spec_button" then
        -- Otherwise confirm
        if storage.PData[player.index].permDeath then
            if storage.PData[player.index].permDeath  >= 2 then
                storage.PData[player.index].permDeath = nil
                player.character.die("player")
                ONELIFE_Main(event)
                return
            elseif storage.PData[player.index].permDeath  < 2 then
                UTIL_SmartPrintColor(player,
                    "[color=red](NO UNDO, PERM-DEATH) -- click " .. 2 - storage.PData[player.index].permDeath  ..
                    " more times to confirm.[/color]")
            end

            storage.PData[player.index].permDeath  = storage.PData[player.index].permDeath  + 1
        end
    end
end

function ONELIFE_MakeButton(player)
    if not player then
        return
    end
    if player.gui.top.spec_button then
        player.gui.top.spec_button.destroy()
    end

    if not storage.SM_Store.oneLifeMode then
        if player.controller_type == defines.controllers.spectator then
            player.set_controller {
                type = defines.controllers.character,
                character = game.surfaces[1].create_entity({name = "character", position = game.surfaces[1].find_non_colliding_position("character", {0,0}, 10000, 1), force = game.forces.player})
            }
            UTIL_SmartPrint(player, "You have been revived!")
            ONLINE_UpdatePlayerList()
        end
        return
    end
    if not player.gui.top.spec_button then
        local m45_32 = player.gui.top.add {
            type = "sprite-button",
            name = "spec_button",
            sprite = "file/img/buttons/spectate.png",
            tooltip = "Kills you forever to become spectator (NO UNDO)"
        }
        m45_32.style.size = { 64, 64 }
    end
end