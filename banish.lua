-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0

local function unbanishPlayer(victim)
    table.insert(storage.SM_Store.sendToSurface, {
        victim = victim,
        surface = "nauvis",
        position = UTIL_GetDefaultSpawn()
    })

    storage.PData[victim.index].banished = 0

    if victim and victim.permission_group.name ~= storage.SM_Store.defGroup.name then
        UTIL_MsgAll(victim.name .. " moved out of jailed group.")
    end
    storage.SM_Store.defGroup.add_player(victim)

    --Close banished window
    if victim and victim.gui and victim.gui.screen and victim.gui.screen.banished_inform then
        victim.gui.screen.banished_inform.destroy()
    end

    BANISH_SendToSurface(victim)
    ONLINE_UpdatePlayerList()
end

function BANISH_DoReport(player, report)
    if player and player.valid and report then
        if CMD_NoBanished(player) then
            return
        end

        storage.PData[player.index].reports = storage.PData[player.index].reports + 1

        -- Limit and list number of reports
        if storage.PData[player.index].reports <= 5 then
            print("[REPORT] " .. player.name .. " " .. report)
            UTIL_SmartPrint(player, "Report sent! You have now used " .. storage.PData[player.index].reports ..
                " of your 5 available reports.")
        else
            UTIL_SmartPrint("You are not allowed to send any more reports.")
        end
    else
        UTIL_SmartPrint(player, "Usage: /report (your message to moderators here)")
    end
end

function BANISH_UpdateVotes()
    -- Reset banished list
    local banishedtemp = {}

    -- Loop through votes, tally them
    for _, vote in pairs(storage.SM_Store.votes) do
        -- only if everything seems to exist
        if vote and vote.voter and vote.victim then
            -- only if data exists
            if vote.voter.valid and vote.victim.valid then
                -- valid defendant
                if not vote.victim.admin then
                    -- valid voter
                    if UTIL_Is_Regular(vote.voter) or UTIL_Is_Veteran(vote.voter) or vote.voter.admin then
                        -- vote isn't overruled or withdrawn
                        if not vote.withdrawn and not vote.overruled then
                            local points = 1

                            if vote.voter.admin then
                                points = 1000 -- Admins get single-vote banish
                            elseif UTIL_Is_Veteran(vote.voter) then
                                points = 2    -- Veterans get extra votes
                            end

                            --Add vote, or init if needed
                            if banishedtemp[vote.victim.index] then
                                banishedtemp[vote.victim.index] = banishedtemp[vote.victim.index] + points
                            else
                                -- was empty, init
                                banishedtemp[vote.victim.index] = points
                            end
                        end
                    end
                end
            end
        end
    end

    -- Loop though players, look for matches
    for _, victim in pairs(game.players) do
        local prevstate = 0
        local newstate = 0
        if storage.PData[victim.index].banished then
            prevstate = storage.PData[victim.index].banished
        end

        if banishedtemp[victim.index] then
            newstate = banishedtemp[victim.index]
        end

        -- Was banished, but not anymore
        if newstate == 0 and prevstate > 0 then
            local msg = victim.name .. " is no longer banished."
            print("[REPORT] SYSTEM " .. msg)
            UTIL_MsgAllSys(msg)

            unbanishPlayer(victim)
        elseif newstate > 0 and prevstate == 0 then
            -- Was not banished, but is now.
            local msg = victim.name .. " has been banished."
            UTIL_MsgAllSys(msg)
            print("[REPORT] SYSTEM " .. msg)

            BANISH_DoJail(victim)
        end

        --Apply new state
        if banishedtemp[victim.index] then
            storage.PData[victim.index].banished = banishedtemp[victim.index]
        else
            storage.PData[victim.index].banished = 0
        end
    end
end

local function informBanished(victim)
    if victim and victim.gui and victim.gui.screen then
        if victim.gui.screen.banished_inform then
            victim.gui.screen.banished_inform.destroy()
        end
        if not victim.gui.screen.banished_inform then
            local main_flow = victim.gui.screen.add {
                type = "frame",
                name = "banished_inform",
                direction = "vertical"
            }
            main_flow.force_auto_center()
            local banished_titlebar = main_flow.add {
                type = "frame",
                direction = "horizontal"
            }
            banished_titlebar.style.horizontal_align = "center"
            banished_titlebar.style.horizontally_stretchable = true

            banished_titlebar.add {
                type = "label",
                style = "frame_title",
                caption = "YOU HAVE BEEN BANISHED!"
            }

            local banished_main = main_flow.add {
                type = "frame",
                name = "main",
                direction = "vertical"
            }
            banished_main.style.horizontal_align = "center"

            banished_main.add {
                type = "sprite",
                sprite = "file/img/world/turd.png"
            }
            banished_main.add {
                type = "label",
                caption = ""
            }
            banished_main.add {
                type = "label",
                caption = "[font=default-large]Moderators will review the public action-logs on m45sci.xyz and perm-ban you if the vote-banish was for good a reason.[/font]"
            }
            banished_main.add {
                type = "label",
                caption = ""
            }
            banished_main.add {
                type = "label",
                caption = "[font=default-large]We share our ban list with many other factorio communities. We put the reason, date and a link to the log file in the ban.[/font]"
            }
            banished_main.add {
                type = "label",
                caption = ""
            }
            banished_main.add {
                type = "label",
                caption = "[font=default-large]Any items you took have been left at the spawn area so they can be retrieved.[/font]"
            }
            banished_main.add {
                type = "label",
                caption = ""
            }
            banished_main.add {
                type = "label",
                caption = "[font=default-large]Players can simply vote to rewind to the previous autosave... or moderators can do it with a single command.[/font]"
            }
            banished_main.add {
                type = "label",
                caption = ""
            }
            banished_main.add {
                type = "label",
                caption = "[font=default-large]If you were griefing, I hope you think carefully about why you were doing this.[/font]"
            }
            banished_main.add {
                type = "label",
                caption = ""
            }
            banished_main.add {
                type = "label",
                caption = "[font=default-large]It seems most of you are like a little kid kicking a sand castle... angry because you do not have the skills to contribute.[/font]"
            }
            banished_main.add {
                type = "label",
                caption = ""
            }
            banished_main.add {
                type = "label",
                caption = "[font=default-large]I hope you learn from this, and eventually become a functioning adult...[/font]"
            }
            banished_main.add {
                type = "label",
                caption = ""
            }
            banished_main.add {
                type = "label",
                caption = "[font=default-large]Before you suffer real-world consequences for this type of behavior elsewhere.[/font]"
            }
        end
    end
end

function BANISH_DoJail(victim)
    informBanished(victim)

    if victim then
        storage.SM_Store.jailGroup.add_player(victim)
        UTIL_MsgAll(victim.name .. " moved to jailed group.")
    end

    storage.PData[victim.index].playScore = 0
    INFO_DumpInv(victim, true)
    UTIL_MsgAllSys(victim.name .. "'s inventory has been dumped at "..UTIL_GPSObj(UTIL_GetDefaultSpawn()).." so the items can be recovered.")

    local newpos = game.surfaces["jail"].find_non_colliding_position("character", { x = 0, y = 0 }, 1024, 1, false)
    table.insert(storage.SM_Store.sendToSurface, {
        victim = victim,
        surface = "jail",
        position = newpos
    })
    BANISH_SendToSurface(victim)
    ONLINE_UpdatePlayerList()
end

function BANISH_MakeJail()
    --Migrate old maps
    if game.surfaces["hell"] ~= nil then
        game.delete_surface("hell")
    end
    -- Create area if needed
    if game.surfaces["jail"] == nil then
        local my_map_gen_settings = {
            width = 100,
            height = 100,
            default_enable_all_autoplace_controls = false,
            property_expression_names = {
                cliffiness = 0
            },
            autoplace_settings = {
                tile = {
                    settings = {
                        ["sand-1"] = {
                            frequency = "normal",
                            size = "normal",
                            richness = "normal"
                        }
                    }
                }
            },
            starting_area = "none"
        }
        game.create_surface("jail", my_map_gen_settings)
        game.surfaces["jail"].show_clouds = false
    end
end

function BANISH_DoBanish(player, victim, reason)
    if player and player.valid then
        if CMD_NoBanished(player) then
            return
        end

        -- Regulars/mods only
        if UTIL_Is_Regular(player) or UTIL_Is_Veteran(player) or player.admin then
            -- Must have arguments
            if victim and reason then
                if victim.index == player.index then
                    UTIL_SmartPrint(player, "You can't banish yourself. Have you considered therapy?")
                    return
                end
                if UTIL_Is_Banished(player) then
                    UTIL_SmartPrint(player, "You are banished, you can't vote.")
                    return
                end

                if string.len(reason) < 4 then
                    UTIL_SmartPrint(player, "You must supply a more descriptive complaint.")
                    return
                else
                    -- Must have valid victim
                    if victim and victim.valid then
                        -- Victim can not be an moderator
                        if not victim.admin then
                            -- Check if we already voted against them
                            if storage.SM_Store.votes and storage.SM_Store.votes ~= {} then
                                local votecount = 1
                                for _, vote in pairs(storage.SM_Store.votes) do
                                    if vote and vote.voter and vote.victim then
                                        -- Count player's total votes, cap them
                                        if vote.voter == player then
                                            votecount = votecount + 1
                                        end
                                        -- Limit number of votes player gets
                                        if not vote.voter.admin and votecount >= 5 then
                                            UTIL_SmartPrint(player,
                                                "You have exhausted your voting privilege for this map.")
                                            return
                                        end

                                        -- Can't vote twice
                                        if vote.voter == player and vote.victim == victim then
                                            UTIL_SmartPrint(player, "You already voted against them!")
                                            UTIL_SmartPrint(player, "/unbanish <player> to withdraw your vote.")
                                            UTIL_SmartPrint(player,
                                                "[color=red](WARNING) If you withdraw a vote, you CAN NOT reintroduce it.[/color]")
                                            return
                                        end
                                    end
                                end

                                -- Send report to discord and add to vote list
                                local message = player.name .. " voted to banish: " .. victim.name .. " for: " .. reason
                                UTIL_MsgAllSys(message)
                                print("[REPORT] " .. message)
                                UTIL_SmartPrint(player, "(SYSTEM): Your vote has been added, and posted on Discord!")
                                UTIL_SmartPrint(player, "/unbanish <player> to withdraw your vote.")
                                UTIL_SmartPrint(player,
                                    "[color=red](WARNING) If you withdraw a vote, you CAN NOT reintroduce it.[/color]")
                                UTIL_SmartPrint(player, "You have used " .. votecount .. " of your 5 available votes.")
                            end

                            table.insert(storage.SM_Store.votes, 0, {
                                voter = player,
                                victim = victim,
                                reason = reason,
                                tick = game.tick,
                                withdrawn = false,
                                overruled = false
                            })
                            BANISH_UpdateVotes() -- Must do this to add to tally
                        else
                            UTIL_SmartPrint(player, "Moderators can not be banished.")
                        end
                    else
                        UTIL_SmartPrint(player, "There are no players by that name.")
                    end
                end
            else
                UTIL_SmartPrint(player, "Usage: /banish <player> <reason for banishment>")
            end
        else
            UTIL_SmartPrint(player, "This command is for regulars/veterans (level 3+) players and moderators only!")
            return
        end
    else
        UTIL_SmartPrint(nil, "The console can't vote.")
    end
end

function BANISH_SendToSurface(player)
    -- Anything queued?
    if storage.SM_Store.sendToSurface then
        -- Valid player?
        if player and player.valid and player.character and player.character.valid then
            local index = nil
            -- Check list
            for i, item in pairs(storage.SM_Store.sendToSurface) do
                -- Check if item is valid
                if item and item.victim and item.victim.character then
                    -- Check if names match
                    if item.victim.index == player.index then
                        -- If surface is valid
                        local surf = game.surfaces[item.surface]
                        if not surf then
                            UTIL_ConsolePrint(
                                "[ERROR] send_to_surface(respawn): INVALID SURFACE")

                            index = i
                            break
                        end
                        if item.position then
                            local newpos = surf.find_non_colliding_position("character", item.position, 1024, 1,
                                false)
                            if newpos then
                                player.teleport(newpos, surf)
                            else
                                player.teleport(item.position, surf) -- screw it
                                UTIL_ConsolePrint(
                                    "[ERROR] send_to_surface(respawn): unable to find non_colliding_position.")
                            end
                            index = i
                            break
                        else
                            player.teleport({ x = 0, y = 0 }, surf) -- screw it
                            UTIL_ConsolePrint(
                                "[ERROR] send_to_surface(respawn): invalid position!")
                            index = i
                            break
                        end
                    end
                end
            end
            -- Remove item we processed
            if index then
                UTIL_ConsolePrint("[ERROR] send_to_surface: item removed: " .. index)
                table.remove(storage.SM_Store.sendToSurface, index)
            end
        end
    end
end

function BANISH_AddBanishCommands()
    commands.add_command("jail", "<player> (/unjail to unjail)",
        function(param)
            local player
            if param and param.player_index then
                player = game.players[param.player_index]
            end
            if CMD_ModsOnly(param) then
                return
            end

            -- Only if name provided
            if param.parameter then
                local victim = game.players[param.parameter]

                if (victim) then
                    if victim.index == player.index then
                        UTIL_SmartPrint(player, "You can't put yourself in jail. Seek therapy.")
                        return
                    end
                    if not UTIL_Is_Banished(victim) then
                        storage.PData[victim.index].banished = 1000
                        BANISH_DoJail(victim)
                        UTIL_SmartPrint(player, "Jailed player.")
                    else
                        UTIL_SmartPrint(player, "They are already in jail.")
                    end
                else
                    UTIL_SmartPrint(player, "Couldn't find that player.")
                end
            else
                UTIL_SmartPrint(player, "Who do you want to jail?")
            end
        end)
        commands.add_command("unjail", "<player>",
        function(param)
            local player
            if param and param.player_index then
                player = game.players[param.player_index]
            end
            if CMD_ModsOnly(param) then
                return
            end

            -- Only if name provided
            if param.parameter then
                local victim = game.players[param.parameter]

                if (victim) then
                    if victim.index == player.index then
                        UTIL_SmartPrint(player, "You can't unjail yourself.")
                        return
                    end
                    if UTIL_Is_Banished(victim) then
                        storage.PData[victim.index].banished = 0
                        for _, vote in pairs(storage.SM_Store.votes) do
                            if vote and vote.victim then
                                if vote.victim.index == victim.index then
                                    vote.overruled = true
                                    break
                                end
                            end
                        end
                        UTIL_SmartPrint(player, "Unjailed player.")
                        unbanishPlayer(victim)
                    else
                        UTIL_SmartPrint(player, "They aren't in jail.")
                    end
                else
                    UTIL_SmartPrint(player, "Couldn't find that player.")
                end
            else
                UTIL_SmartPrint(player, "Who do you want unjail?")
            end
        end)
    -- Mod vote overrrule
    commands.add_command("overrule",
        "Moderators only: <defendant>\n(overrule votes against defendant)\n<clear>\n(clear all votes, will unbanish all)",
        function(param)
            local player
            if param and param.player_index then
                player = game.players[param.player_index]
            end
            if CMD_ModsOnly(param) then
                return
            end

            -- Moderator only
            if storage.SM_Store and storage.SM_Store.votes then
                -- get arguments
                local args = UTIL_SplitStr(param.parameter, " ")

                -- Must have arguments
                if args ~= {} and args[1] then
                    if args[1] == "clear" then
                        storage.SM_Store.votes = {}
                        UTIL_SmartPrint(player, "All votes cleared.")
                        BANISH_UpdateVotes()
                        return
                    end
                    local victim = game.players[args[1]]

                    -- If victim found
                    if victim and victim.valid then
                        local count = 0
                        for _, vote in pairs(storage.SM_Store.votes) do
                            if vote and vote.victim and vote.victim.valid then
                                if vote.victim == victim and not vote.overruled then
                                    vote.overruled = true
                                    count = count + 1
                                end
                            end
                        end
                        if count > 0 then
                            UTIL_SmartPrint(player, "Overruled " .. count .. " votes against " .. victim.name)
                        else
                            for _, vote in pairs(storage.SM_Store.votes) do
                                if vote and vote.victim and vote.victim.valid then
                                    if vote.victim == victim and vote.overruled then
                                        vote.overruled = false
                                        count = count + 1
                                    end
                                end
                            end
                            UTIL_SmartPrint(player,
                                "Withdrew " .. count .. " overrulings, against " .. victim.name)
                        end
                        BANISH_UpdateVotes()
                        return
                    else
                        UTIL_SmartPrint(player, "Couldn't find a player by that name.")
                    end
                else
                    UTIL_SmartPrint(player,
                        "Who do you want to overrule votes against? <player> or <clear> (clears/unbanishes all)")
                end
            else
                UTIL_SmartPrint(player, "There are no votes to overrule.")
            end
        end)

    -- Print votes
    commands.add_command("votes", "(Shows banish votes)", function(param)
        if param and param.player_index then
            local player = game.players[param.player_index]

            if CMD_NoBanished(player) then
                return
            end

            -- Only if banish data found
            if storage.SM_Store and storage.SM_Store.votes then
                -- Print votes
                local pcount = 0
                for _, vote in pairs(storage.SM_Store.votes) do
                    if vote and vote.voter and vote.voter.valid and vote.victim and vote.victim.valid then
                        local notes = ""
                        if vote.withdrawn then
                            notes = "(WITHDRAWN) "
                        end
                        if vote.overruled then
                            notes = "(OVERRULED) "
                        end
                        pcount = pcount + 1
                        UTIL_SmartPrint(player, notes .. "plaintiff: " .. vote.voter.name .. ", defendant: " ..
                            vote.victim.name .. ", complaint:\n" .. vote.reason)
                    end
                end

                -- Tally votes before proceeding
                BANISH_UpdateVotes()

                -- Print accused
                if storage.PData then
                    for _, victim in pairs(game.players) do
                        if storage.PData[victim.index].banished and storage.PData[victim.index].banished > 0 then
                            UTIL_SmartPrint(player, victim.name .. " has had " .. storage.PData[victim.index].banished ..
                                " complaints against them.")
                            pcount = pcount + 1
                        end
                    end
                end
                -- Show summery of votes against them
                if storage.SM_Store.votes then
                    for _, victim in pairs(game.players) do
                        local votecount = 0
                        for _, vote in pairs(storage.SM_Store.votes) do
                            if victim == vote.voter then
                                votecount = votecount + 1
                            end
                        end
                        if votecount > 2 then
                            UTIL_SmartPrint(player, victim.name .. " has voted against " .. votecount .. " players.")
                            pcount = pcount + 1
                        end
                    end
                end
                -- Nothing found, report it
                if pcount <= 0 then
                    UTIL_SmartPrint(player, "The docket is clean.")
                end
                return
            else
                -- No vote data
                UTIL_SmartPrint(player, "The docket is clean.")
                BANISH_UpdateVotes()
                return
            end
        end
    end)

    -- Banish command
    commands.add_command("unbanish", "<player>\n(Withdraws a banish vote)", function(param)
        if param and param.player_index then
            local player = game.players[param.player_index]
            if CMD_NoBanished(player) then
                return
            end

            if player and param.parameter then
                -- regulars/moderators players only
                if UTIL_Is_Regular(player) or UTIL_Is_Veteran(player) or player.admin then
                    -- get arguments
                    local args = UTIL_SplitStr(param.parameter, " ")

                    -- Must have arguments
                    if args ~= {} and args[1] then
                        local victim = game.players[args[1]]

                        -- Must have valid victim
                        if victim and victim.valid and victim.character and victim.character.valid then
                            -- Check if we voted against them
                            if storage.SM_Store.votes and storage.SM_Store.votes ~= {} then
                                for _, vote in pairs(storage.SM_Store.votes) do
                                    if vote and vote.voter and vote.victim then
                                        if vote.voter == player and vote.victim == victim then
                                            if vote.withdrawn then
                                                UTIL_SmartPrint(player, "You've already withdrawn your vote.")
                                                return
                                            end
                                            -- Send report to discord and withdraw vote
                                            local message = player.name .. " WITHDREW their vote to banish: " ..
                                                victim.name
                                            UTIL_MsgAllSys(message)
                                            print("[REPORT] " .. message)
                                            UTIL_SmartPrint(player,
                                                "Your vote has been withdrawn, and posted on Discord.")
                                            vote.withdrawn = true
                                            BANISH_UpdateVotes() -- Must do this to delete from tally
                                            return
                                        end
                                    end
                                end
                                UTIL_SmartPrint(player, "I don't see a vote from you, against that player, to withdraw.")
                            end
                        else
                            UTIL_SmartPrint(player, "There are no players online by that name.")
                        end
                    else
                        UTIL_SmartPrint(player, "Usage: /unbanish <player>")
                    end
                else
                    UTIL_SmartPrint(player, "Only regulars/moderator status players can vote.")
                    return
                end
            else
                UTIL_SmartPrint(player, "Usage: /unbanish <player>")
            end
        else
            UTIL_SmartPrint(nil, "The console can't vote.")
        end
    end)

    -- Banish command
    commands.add_command("banish", "<player> <reason for banishment>\n(Sends player to a confined area, off-map)",
        function(param)
            if param and param.player_index then
                local player = game.players[param.player_index]

                if not param.parameter then
                    UTIL_SmartPrint(player, "Banish who?")
                    return
                end
                local args = UTIL_SplitStr(param.parameter, " ")
                if not args[2] then
                    UTIL_SmartPrint(player, "You must specify a reason.")
                    return
                end
                local victim = game.players[args[1]]

                -- Quick arg combine
                local reason = args[2]
                for n, arg in pairs(args) do
                    if n > 2 and n < 100 then -- at least two words, max 100
                        reason = reason .. " " .. args[n]
                    end
                end

                if UTIL_Is_Banished(victim) then
                    UTIL_SmartPrint(player, "They are already banished!")
                    return
                end

                BANISH_DoBanish(player, victim, reason)
            end
        end)

    -- User report command
    commands.add_command("report", "<detailed report here>\n(Sends in a report to the moderators)", function(param)
        if param and param.player_index then
            local player = game.players[param.player_index]
            if CMD_NoBanished(player) then
                return
            end
            BANISH_DoReport(player, param.parameter)
        else
            UTIL_SmartPrint(nil, "The console doesn't need to send in reports this way.")
        end
    end)
end

