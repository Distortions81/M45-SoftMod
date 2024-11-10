-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

-- Custom commands
script.on_load(function()
    -- Only add if no commands yet
    if (not commands.commands.server_interface) then
        BANISH_AddBanishCommands()
        -- banish.lua

        -- Reset interval message
        commands.add_command("resetdur", "server use only", function(param)
            local player
            local victim

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "moderators only.")
                    return
                end
            end

            local input = ""
            if param.parameter then
                input = param.parameter
            end

            for _, target in pairs(game.connected_players) do
                if target.valid and target.gui and target.gui.top and target.gui.top.reset_clock then
                    if storage.PData and storage.PData[target.index].hideClock == true or input == "" then
                        target.gui.top.reset_clock.visible = false
                    else
                        target.gui.top.reset_clock.caption = "MAP RESET: " .. input
                        target.gui.top.reset_clock.style = "red_button"
                        target.gui.top.reset_clock.style.size = {350,24}
                        target.gui.top.reset_clock.visible = true
                    end
                end
            end
            -- Refresh open info windows
            if storage.SM_Store.resetDuration ~= input then
                storage.SM_Store.resetDuration = input
                for _, victim in pairs(game.connected_players) do
                    if victim and victim.valid and victim.gui and victim.gui.screen and
                        victim.gui.screen.m45_info_window then
                        INFO_InfoWin(victim)
                    end
                end
            end
        end)

        -- Reset interval message
        commands.add_command("resetint", "server use only", function(param)
            local player
            local victim

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end

            local input = ""
            if param.parameter then
                input = param.parameter
            end
            storage.SM_Store.resetDate = input
        end)

        -- Enable / disable friendly fire
        commands.add_command("friendlyfire", "on/off", function(param)
            local player
            local victim

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end


            if param and param.parameter then
                local pforce = game.forces["player"]

                if pforce then
                    if string.lower(param.parameter) == "off" then
                        pforce.friendly_fire = false
                        UTIL_SmartPrint(player, "friendly fire disabled.")
                    elseif string.lower(param.parameter) == "on" then
                        pforce.friendly_fire = true
                        UTIL_SmartPrint(player, "friendly fire enabled.")
                    end
                end
            else
                UTIL_SmartPrint(player, "on or off?")
            end
        end)

        -- Enable / disable blueprints
        commands.add_command("blueprints", "on/off", function(param)
            local player
            local victim

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end


            if param and param.parameter then
                local pforce = game.forces["player"]

                if pforce then
                    if string.lower(param.parameter) == "off" then
                        storage.SM_Store.noBlueprints = false
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.defGroup, false)
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.memGroup, false)
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.regGroup, false)
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.vetGroup, false)
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.modGroup, false)
                        UTIL_SmartPrint(player, "blueprints disabled...")
                    elseif string.lower(param.parameter) == "on" then
                        storage.SM_Store.noBlueprints = true
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.defGroup, true)
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.memGroup, true)
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.regGroup, true)
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.vetGroup, true)
                        PERMS_SetBlueprintsAllowed(storage.SM_Store.modGroup, true)
                        UTIL_SmartPrint(player, "blueprints enabled...")
                    end
                end
            else
                UTIL_SmartPrint(player, "on or off?")
            end
        end)

        -- Enable / disable cheat mode
        commands.add_command("enablecheats", "on/off", function(param)
            local player
            local victim

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end


            if param and param.parameter then
                local pforce = game.forces["player"]

                if pforce then
                    if string.lower(param.parameter) == "off" then
                        storage.SM_Store.cheats = false
                        for _, player in pairs(game.players) do
                            player.cheat_mode = false
                        end
                        UTIL_SmartPrint(player, "cheats disabled...")
                    elseif string.lower(param.parameter) == "on" then
                        storage.SM_Store.cheats = true
                        for _, player in pairs(game.players) do
                            player.cheat_mode = true
                        end
                        pforce.research_all_technologies()
                        UTIL_SmartPrint(player, "cheats enabled...")
                    end
                end
            else
                UTIL_SmartPrint(player, "on or off?")
            end
        end)

        -- Enable / disable cheat mode
        commands.add_command("onelife", "One life mode on/off or <playerName>", function(param)
            local player
            local victim

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end

            if param and param.parameter then
                if param.parameter == "on" and not storage.SM_Store.oneLifeMode then
                    storage.SM_Store.oneLifeMode = true
                    UTIL_SmartPrint(player, "One-life mode enabled.")
                    UTIL_MsgAll("One-life mode enabled.")
                    for _, victim in pairs(game.players) do
                        ONELIFE_MakeButton(victim)
                    end
                elseif param.parameter == "off" and storage.SM_Store.oneLifeMode then
                    storage.SM_Store.oneLifeMode = false
                    UTIL_SmartPrint(player, "One-life mode disabled.")
                    UTIL_MsgAll("One-life mode disabled.")
                    for _, victim in pairs(game.players) do
                        ONELIFE_MakeButton(victim)
                    end
                elseif storage.SM_Store.oneLifeMode then
                    local victim = game.players[param.parameter]

                    if victim then
                        if storage.PData[victim.index].permDeath then
                            storage.SM_Store.oneLifeMode = false
                            ONELIFE_MakeButton(victim)
                            storage.SM_Store.oneLifeMode = true
                            ONELIFE_MakeButton(victim)

                            UTIL_MsgAll(victim.name .. " was revived!")
                            UTIL_SmartPrint(player, victim.name .. " was revived!")
                        else
                            UTIL_SmartPrint(player, victim.name .. " is already alive!!!")
                        end
                    else
                        UTIL_SmartPrint(player, "I don't see a player by that name.")
                    end
                end
            end
        end)

        -- adjust run speed
        commands.add_command("run", "speed: -1 to 100, 0 = normal speed", function(param)
            local player
            local victim

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end

            if player and player.valid then
                if player.character and player.character.valid then
                    if tonumber(param.parameter) then
                        local speed = tonumber(param.parameter)

                        -- Factorio doesn't like speeds less than -1
                        if speed < -0.99 then
                            speed = -0.99
                        end

                        -- Cap to reasonable amount
                        if speed > 1000 then
                            speed = 1000
                        end

                        player.character.character_running_speed_modifier = speed
                    else
                        UTIL_SmartPrint(player, "Numbers only.")
                    end
                else
                    UTIL_SmartPrint(player, "Can't set walk speed, because you don't have a body.")
                end
            else
                UTIL_SmartPrint(player, "The console can't walk...")
            end
        end)

        -- turn invincible
        commands.add_command("immortal", "optional: <name> (toggle player immortality, default self)", function(param)
            local player
            local victim

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end

            local target = player

            if param and param.parameter then
                victim = game.players[param.parameter]
            end

            if victim and victim.valid then
                target = victim
            end

            if target and target.valid then
                if target.character and target.character.valid then
                    if target.character.destructible then
                        target.character.destructible = false
                        UTIL_SmartPrint(player, target.name .. " is now immortal.")
                    else
                        target.character.destructible = true
                        UTIL_SmartPrint(player, target.name .. " is now mortal.")
                    end
                else
                    UTIL_SmartPrint(player, "They don't have a body right now.")
                end
            else
                UTIL_SmartPrint(player, "Couldn't find a player by that name.")
            end
        end)

        -- change new player restrictions
        commands.add_command("restrict", "change player restrictions: on/off", function(param)
            local player

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end


            -- Process argument
            if not param.parameter then
                UTIL_SmartPrint(player, "options: on, off")
                return
            elseif string.lower(param.parameter) == "off" then
                storage.SM_Store.restrictNew = false
                PERMS_SetPermissions()
                UTIL_SmartPrint(player, "New player restrictions disabled.")
                return
            elseif string.lower(param.parameter) == "on" then
                storage.SM_Store.restrictNew = true
                PERMS_SetPermissions()
                UTIL_SmartPrint(player, "New player restrictions enabled.")
                return
            end
            STORAGE_MakePlayerStorage()
        end)

        -- game tick
        commands.add_command("gt", "Show current game tick number", function(param)
            local player

            if param and param.player_index then
                player = game.players[param.player_index]
            end

            if player then
                UTIL_SmartPrint(player, "Game tick: " .. game.tick)
                return
            else
                print("[GT] " .. game.tick)
            end

            if param.parameter == "debug" then
                print(die.debug) --intentional bug
            end
        end)

        -- register command
        commands.add_command("register", "<code> (Requires a registration code from discord)", function(param)
            -- This command is disabled
            if param and param.player_index then
                local player = game.players[param.player_index]

                -- Only if arguments
                if param.parameter and player and player.valid then
                    -- Init player if needed, else add to

                    if storage.PData[player.index].regAttempts > 3 then
                        UTIL_SmartPrint(player, "You have exhausted your registration attempts.")
                        return
                    end
                    storage.PData[player.index].regAttempts = storage.PData[player.index].regAttempts + 1

                    local ptype = "Error"

                    if player.admin then
                        ptype = "moderator"
                    elseif UTIL_Is_Veteran(player) then
                        ptype = "veteran"
                    elseif UTIL_Is_Regular(player) then
                        ptype = "regular"
                    elseif UTIL_Is_Member(player) then
                        ptype = "member"
                    else
                        ptype = "normal"
                    end

                    -- Send to ChatWire
                    print("[ACCESS] " .. ptype .. " " .. player.name .. " " .. param.parameter)
                    UTIL_SmartPrint(player, "Sending registration code...")
                    return
                end
                UTIL_SmartPrint(player, "You need to provide a registration code!")
                return
            end
            UTIL_SmartPrint(nil, "I don't think the console needs to use this command...")
        end)

        -- softmod version
        commands.add_command("sversion", "server use only", function(param)
            local player

            RunSetup()

            if param and param.player_index then
                player = game.players[param.player_index]
            end

            if player then
                UTIL_SmartPrint(player, "[SVERSION] " .. storage.SM_Version)
            else
                print("[SVERSION] " .. storage.SM_Version)
            end
        end)

        -- Server name
        commands.add_command("cname", "server use only", function(param)
            -- Moderators only
            if param and param.player_index then
                local player = game.players[param.player_index]
                if not player.admin then
                    UTIL_SmartPrint(player, "This command is for system and moderator use only.")
                    return
                end
            end


            if param.parameter then
                storage.SM_Store.serverName = param.parameter

                LOGO_DrawLogo(true)
            end
        end)

        -- Server chat
        commands.add_command("cchat", "server use only", function(param)
            -- Console only, no players
            if param and param.player_index then
                local player = game.players[param.player_index]
                UTIL_SmartPrint(player, "This command is for system use only.")
                return
            end

            if param.parameter then
                UTIL_MsgPlayers(param.parameter)
            end
        end)

        -- Server whisper
        commands.add_command("cwhisper", "server use only", function(param)
            -- Console only, no players
            if param and param.player_index then
                local player = game.players[param.player_index]
                UTIL_SmartPrint(player, "This command is for system use only.")
                return
            end

            -- Must have arguments
            if param.parameter then
                local args = UTIL_SplitStr(param.parameter, " ")

                -- Require two args
                if args ~= {} and args[1] and args[2] then
                    -- Find player
                    for _, player in pairs(game.connected_players) do
                        if player.name == args[1] then
                            args[1] = ""
                            UTIL_SmartPrint(player, table.concat(args, " "))
                            return
                        end
                    end
                end
            end
        end)

        -- Reset players's time and status
        commands.add_command("reset", "<player> -- (Set player to NEW)", function(param)
            local player

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end

            -- Argument needed
            if param.parameter then
                local victim = game.players[param.parameter]

                if victim and victim.valid then
                    storage.PData[victim.index].playScore = 0
                    if victim and victim.valid and storage.SM_Store.defGroup then
                        storage.SM_Store.defGroup.add_player(victim)
                    end
                    if player then
                        UTIL_SmartPrint(player, "Player set to 0.")
                        UTIL_MsgAll(victim.name .. " is now reset!")
                    end
                    return
                end
            end
            UTIL_SmartPrint(player, "Player not found.")
        end)

        -- Trust player
        commands.add_command("member", "<player> -- (Makes the player a member)", function(param)
            local player

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end

            -- Argument required
            if param.parameter then
                local victim = game.players[param.parameter]

                if (victim) then
                    if victim and victim.valid and storage.membersgroup then
                        if player then
                            UTIL_SmartPrint(player, "Player given members status.")
                            UTIL_MsgAll(victim.name .. " is now a member!")
                        end
                        storage.membersgroup.add_player(victim)
                        ONLINE_UpdatePlayerList() -- online.lua
                        return
                    end
                end
            end
            UTIL_SmartPrint(player, "Player not found.")
        end)

        -- Set player to veteran
        commands.add_command("veteran", "<player> -- (Makes the player a veteran)", function(param)
            local player

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end

            -- Argument required
            if param.parameter then
                local victim = game.players[param.parameter]

                if (victim) then
                    if victim and victim.valid and storage.veteransgroup then
                        if player then
                            UTIL_SmartPrint(player, "Player given veterans status.")
                            UTIL_MsgAll(victim.name .. " is now a veteran!")
                        end
                        storage.veteransgroup.add_player(victim)
                        ONLINE_UpdatePlayerList() -- online.lua
                        return
                    end
                end
            end
            UTIL_SmartPrint(player, "Player not found.")
        end)

        -- Set player to regular
        commands.add_command("regular", "<player> -- (Makes the player a regular)", function(param)
            local player

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end

            -- Argument required
            if param.parameter then
                local victim = game.players[param.parameter]

                if (victim) then
                    if victim and victim.valid and storage.regularsgroup then
                        if player then
                            UTIL_SmartPrint(player, "Player given regulars status.")
                            UTIL_MsgAll(victim.name .. " is now a regular!")
                        end
                        storage.regularsgroup.add_player(victim)
                        ONLINE_UpdatePlayerList() -- online.lua
                        return
                    end
                end
            end
            UTIL_SmartPrint(player, "Player not found.")
        end)

        -- Set player to patreon
        commands.add_command("patreon", "server use only", function(param)
            local player

            -- Moderators only
            if param and param.player_index then
                return
            end

            -- Argument required
            if param.parameter then
                local victim = game.players[param.parameter]

                if (victim) then
                    if victim and victim.valid then
                        if not storage.patreons[victim.index] then
                            storage.patreons[victim.index] = true
                            UTIL_SmartPrint(player, "Player given patreon status.")
                            ONLINE_UpdatePlayerList() -- online.lua
                        else
                            UTIL_SmartPrint(player, "Player already has patreon status.")
                        end

                        return
                    end
                end
            end
            UTIL_SmartPrint(player, "Player not found.")
        end)

        -- Set player to nitro
        commands.add_command("nitro", "<player> -- (Makes the player a nitro booster)", function(param)
            local player

            -- Moderators only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end
            end

            -- Argument required
            if param.parameter then
                local victim = game.players[param.parameter]

                if (victim) then
                    if victim and victim.valid then
                        if not storage.nitros then
                            storage.nitros = {}
                        end
                        if not storage.nitros[victim.index] then
                            storage.nitros[victim.index] = true
                            UTIL_SmartPrint(player, "Player given nitro status.")
                            ONLINE_UpdatePlayerList() -- online.lua
                        else
                            UTIL_SmartPrint(player, "Player already has nitro status.")
                        end

                        return
                    end
                end
            end
            UTIL_SmartPrint(player, "Player not found.")
        end)

        -- Add player to patreon credits
        commands.add_command("patreonlist", "server use only", function(param)
            local player

            -- Console only, no players
            if param and param.player_index then
                local player = game.players[param.player_index]
                UTIL_SmartPrint(player, "This command is for system use only.")
                return
            end

            -- Argument required
            if param.parameter then
                storage.patreonList = UTIL_SplitStr(param.parameter, ",")
            end
        end)

        -- Add player to nitro credits
        commands.add_command("nitrolist", "server use only", function(param)
            local player

            -- Console only, no players
            if param and param.player_index then
                local player = game.players[param.player_index]
                UTIL_SmartPrint(player, "This command is for system use only.")
                return
            end

            -- Argument required
            if param.parameter then
                storage.nitroList = UTIL_SplitStr(param.parameter, ",")
            end
        end)

        -- Change default spawn point
        commands.add_command("cspawn", "<x,y> -- (OPTIONAL) (Sets spawn point to <x,y>, or where you stand by default)",
            function(param)
                local victim
                local new_pos_x
                local new_pos_y

                -- Moderators only
                if param and param.player_index then
                    victim = game.players[param.player_index]

                    if victim and victim.admin == false then
                        UTIL_SmartPrint(victim, "Moderators only.")
                        return
                    end
                end

                local psurface = game.surfaces[1]
                local pforce = game.forces["player"]

                -- use mods's force and position if available.
                if victim and victim.valid then
                    pforce = victim.force

                    new_pos_x = victim.position.x
                    new_pos_y = victim.position.y
                end

                -- Location supplied
                if param.parameter then
                    local xytable = UTIL_SplitStr(param.parameter, ",")
                    if xytable ~= {} and tonumber(xytable[1]) and tonumber(xytable[2]) then
                        new_pos_x = tonumber(xytable[1])
                        new_pos_y = tonumber(xytable[2])
                    else
                        UTIL_SmartPrint(victim, "Invalid argument. /cspawn x,y. No argument uses your current location.")
                        return
                    end
                end

                -- Set new spawn spot
                if pforce and psurface and new_pos_x and new_pos_y then
                    pforce.set_spawn_position({ new_pos_x, new_pos_y }, psurface)
                    UTIL_SmartPrint(victim, string.format("New spawn point set: %d,%d", math.floor(new_pos_x),
                        math.floor(new_pos_y)))
                    UTIL_SmartPrint(victim, string.format("Force: %s", pforce.name))

                    LOGO_DrawLogo(true)
                else
                    UTIL_SmartPrint(victim, "Couldn't find force...")
                end
            end)

        -- Reveal map
        commands.add_command("reveal",
            "<size> -- (OPTIONAL) Reveals <size> units of the map from map center, or 1024 by default. Min 128, Max 8192)",
            function(param)
                local victim
                local size = tonumber(1024)

                -- Moderators only
                if param and param.player_index then
                    victim = game.players[param.player_index]
                    if victim and victim.admin == false then
                        UTIL_SmartPrint(victim, "Moderators only.")
                        return
                    end
                end

                -- Get surface and force
                local psurface = game.surfaces[1]
                local pforce = game.forces["player"]

                -- Use mods's surface and force if possible
                if victim and victim.valid then
                    psurface = victim.surface
                    pforce = victim.force
                end

                -- If size specified
                if param.parameter then
                    if tonumber(param.parameter) then
                        local rsize = tonumber(param.parameter)

                        -- Limit size of area
                        if rsize > 0 then
                            if rsize < 128 then
                                rsize = 128
                            else
                                if rsize > 8192 then
                                    rsize = 8192
                                end
                                size = rsize
                            end
                        end
                    else
                        UTIL_SmartPrint(victim, "Numbers only.")
                        return
                    end
                end

                -- Chart the area
                if psurface and pforce and size then
                    pforce.chart(psurface, {
                        lefttop = {
                            x = -size / 2,
                            y = -size / 2
                        },
                        rightbottom = {
                            x = size / 2,
                            y = size / 2
                        }
                    })
                    local sstr = math.floor(size)
                    UTIL_SmartPrint(victim, "Revealing " .. sstr .. "x" .. sstr .. " tiles")
                else
                    UTIL_SmartPrint(victim, "Invalid force or surface.")
                end
            end)

        -- Rechart map
        commands.add_command("rechart", "Refreshes all chunks that exist", function(param)
            local victim

            -- Moderators only
            if param and param.player_index then
                victim = game.players[param.player_index]
                if victim and victim.admin == false then
                    UTIL_SmartPrint(victim, "Moderators only.")
                    return
                end
            end

            local pforce = game.forces["player"]

            -- Use admin's force
            if victim and victim.valid then
                pforce = victim.force
            end

            if pforce then
                pforce.clear_chart()
                UTIL_SmartPrint(victim, "Recharting map...")
            else
                UTIL_SmartPrint(victim, "Couldn't find force.")
            end
        end)

        -- Online
        commands.add_command("online", "See who is online", function(param)
            local victim

            if param and param.player_index then
                victim = game.players[param.player_index]
            end

            -- Sends updated list of players to server
            ONLINE_UpdatePlayerList()

            -- Already sent if console
            if victim then
                UTIL_SendPlayers(victim)
            end
        end)

        -- Game speed, without walk speed mod
        commands.add_command("aspeed", "<x.x> -- Set game UPS, and do not adjust walk speed.", function(param)
            local player

            if param and param.player_index then
                player = game.players[param.player_index]
            end

            -- Moderators only
            if player and player.admin == false then
                UTIL_SmartPrint(player, "Moderators only.")
                return
            end

            -- Need argument
            if (not param.parameter) then
                UTIL_SmartPrint(player, "But what speed? 4 to 1000")
                return
            end

            -- Decode arg
            if tonumber(param.parameter) then
                local value = tonumber(param.parameter)

                -- Limit speed range
                if (value >= 4 and value <= 1000) then
                    game.speed = (value / 60.0)
                else
                    UTIL_SmartPrint(player, "That doesn't seem like a good idea...")
                end
            else
                UTIL_SmartPrint(player, "Numbers only.")
            end
        end)

        -- Game speed
        commands.add_command("gspeed",
            "<x.x> -- Changes game speed. Default speed: 1.0 (60 UPS), Min 0.01 (0.6 UPS), Max  10.0 (600 UPS)",
            function(param)
                local player

                if param and param.player_index then
                    player = game.players[param.player_index]
                end

                -- Moderators only
                if player and player.admin == false then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end

                -- Need argument
                if (not param.parameter) then
                    UTIL_SmartPrint(player, "But what speed? 0.01 to 10")
                    return
                end

                -- Decode arg
                if tonumber(param.parameter) then
                    local value = tonumber(param.parameter)

                    -- Limit speed range
                    if (value >= 0.01 and value <= 10.0) then
                        game.speed = value

                        -- Get default force
                        local pforce = game.forces["player"]

                        -- Use admin's force
                        if player and player.valid then
                            pforce = player.force
                        end

                        -- If force found
                        if pforce then
                            -- Calculate walk speed for UPS
                            pforce.character_running_speed_modifier = ((1.0 / value) - 1.0)
                            UTIL_SmartPrint(player, "Game speed: " .. value .. " Walk speed: " ..
                                pforce.character_running_speed_modifier)

                            -- Don't show message if run via console (ChatWire)
                            if (player) then
                                UTIL_MsgAll("Game speed set to " .. (game.speed * 100.00) .. "%")
                            end
                        else
                            UTIL_SmartPrint(player, "Couldn't find a valid force")
                        end
                    else
                        UTIL_SmartPrint(player, "That doesn't seem like a good idea...")
                    end
                else
                    UTIL_SmartPrint(player, "Numbers only.")
                end
            end)

        -- Teleport to
        commands.add_command("tto", "<player> -- teleport to <player>", function(param)
            -- No console :P
            if not param.player_index then
                UTIL_SmartPrint(nil, "You want me to teleport a remote console somewhere???")
                return
            end
            local player = game.players[param.player_index]

            -- Moderator only
            if (player and player.valid and player.connected and player.character and player.character.valid) then
                if (player.admin == false) then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end

                -- Argument required
                if param.parameter then
                    local victim = game.players[param.parameter]

                    if (victim and victim.valid) then
                        local newpos = victim.surface.find_non_colliding_position("character", victim.position, 1024,
                            1, false)
                        if (newpos) then
                            player.teleport(newpos, victim.surface)
                            UTIL_SmartPrint(player, "*Poof!*")
                        else
                            UTIL_SmartPrint(player, "Area appears to be full.")
                            UTIL_ConsolePrint("[ERROR] tto: unable to find non_colliding_position.")
                        end
                        return
                    end
                end
                UTIL_SmartPrint(player, "Teleport to who?")
            end
        end)

        -- Teleport x,y
        commands.add_command("tp", "<x,y> -- teleport to <x,y> or <surface>", function(param)
            -- No console :P
            if not param.player_index then
                UTIL_SmartPrint(nil, "You want me to teleport a remote console somewhere???")
                return
            end
            local player = game.players[param.player_index]

            -- Moderators only
            if (player and player.valid and player.connected and player.character and player.character.valid) then
                if (player.admin == false) then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end

                local surface = player.surface

                -- Argument required
                if param.parameter then
                    local str = param.parameter
                    local xpos = "0.0"
                    local ypos = "0.0"

                    -- Find surface from argument
                    local n = game.surfaces[param.parameter]
                    if n then
                        surface = n
                        local position = {
                            x = xpos,
                            y = ypos
                        }
                        local newpos = surface.find_non_colliding_position("character", position, 1024, 1, false)
                        if newpos then
                            player.teleport(newpos, surface)
                            return
                        else
                            player.teleport(position, surface)
                            UTIL_ConsolePrint("[ERROR] tp: unable to find non_colliding_position.")
                        end
                    end

                    -- Find x/y from argument
                    -- Matches two potentially negative numbers separated by a comma, gps compatible
                    -- str could be "-353.5,19.3" or "[gps=80,-20]" or "[gps=5,3,jail]"
                    xpos, ypos = str:match("(%-?%d+)%.?%d*,%s*(%-?%d+)")
                    if tonumber(xpos) and tonumber(ypos) then
                        local position = {
                            x = xpos,
                            y = ypos
                        }

                        if position then
                            if position.x and position.y then
                                local newpos = surface.find_non_colliding_position("character", position, 1024, 1,
                                    false)
                                if (newpos) then
                                    player.teleport(newpos, surface)
                                    UTIL_SmartPrint(player, "*Poof!*")
                                else
                                    UTIL_SmartPrint(player, "Area appears to be full.")
                                    UTIL_ConsolePrint("[ERROR] tp: unable to find non_colliding_position.")
                                end
                            else
                                UTIL_SmartPrint(player, "Invalid location.")
                            end
                        end
                        return
                    else
                        UTIL_SmartPrint(player, "Numbers only.")
                    end
                end
                UTIL_SmartPrint(player, "Teleport where? x,y or surface name")
            end
        end)

        -- Teleport player to me
        commands.add_command("tfrom", "<player> -- teleport <player> to me", function(param)
            -- No console :P
            if not param.player_index then
                UTIL_SmartPrint(nil, "You want me to teleport a remote console somewhere???")
                return
            end
            local player = game.players[param.player_index]

            -- Moderators only
            if (player and player.valid and player.connected and player.character and player.character.valid) then
                if (player.admin == false) then
                    UTIL_SmartPrint(player, "Moderators only.")
                    return
                end

                -- Argument required
                if param.parameter then
                    local victim = game.players[param.parameter]

                    if (victim and victim.valid) then
                        local newpos = player.surface.find_non_colliding_position("character", player.position, 1024,
                            1, false)
                        if (newpos) then
                            victim.teleport(newpos, player.surface)
                            UTIL_SmartPrint(player, "*Poof!*")
                        else
                            UTIL_SmartPrint(player, "Area appears to be full.")
                            UTIL_ConsolePrint("[ERROR] tfrom: unable to find non_colliding_position.")
                        end
                    else
                        UTIL_SmartPrint(player, "Who do you want to teleport to you?")
                    end
                end
            end
        end)
    end
end)
