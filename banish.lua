-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
require "utility"

function make_banish_storages()
    if not storage.banishvotes then
        storage.banishvotes = {
            voter = {},
            victim = {},
            reason = {},
            tick = {},
            withdrawn = {},
            overruled = {}
        }
    end
    if not storage.thebanished then
        storage.thebanished = {}
    end
end

function g_report(player, report)
    if player and player.valid and report then
        -- Init limit list if needed
        if not storage.reportlimit then
            storage.reportlimit = {}
        end

        -- Add or init player's limit
        if storage.reportlimit[player.index] then
            storage.reportlimit[player.index] = storage.reportlimit[player.index] + 1
        else
            storage.reportlimit[player.index] = 1
        end

        -- Limit and list number of reports
        if storage.reportlimit[player.index] <= 5 then
            print("[REPORT] " .. player.name .. " " .. report)
            smart_print(player, "Report sent! You have now used " .. storage.reportlimit[player.index] ..
                " of your 5 available reports.")
        else
            smart_print("You are not allowed to send any more reports.")
        end
    else
        smart_print(player, "Usage: /report (your message to moderators here)")
    end
end

-- Process banish votes
function update_banished_votes()
    -- Reset banished list
    local banishedtemp = {}

    -- Init if needed
    if not storage.banishvotes then
        storage.banishvotes = {
            voter = {},
            victim = {},
            reason = {},
            tick = {},
            withdrawn = {},
            overruled = {}
        }
    end

    if not storage.thebanished then
        storage.thebanished = {}
    end

    -- Loop through votes, tally them
    for _, vote in pairs(storage.banishvotes) do
        -- only if everything seems to exist
        if vote and vote.voter and vote.victim then
            -- only if data exists
            if vote.voter.valid and vote.victim.valid then
                -- valid defendant
                if is_new(vote.victim) or is_member(vote.victim) then
                    -- valid voter
                    if is_regular(vote.voter) or is_veteran(vote.voter) or vote.voter.admin then
                        -- vote isn't overruled or withdrawn
                        if vote.withdrawn == false and vote.overruled == false then
                            local points = 1
                            
                            if vote.voter.admin then
                               points = 1000 -- Admins get single-vote banish
                            elseif is_veteran(vote.voter) then
                                points = 2 -- Veterans get extra votes
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
        local prevstate = is_banished(victim)

        -- Add votes to storage list, erase old votes
        if banishedtemp[victim.index] then
            storage.thebanished[victim.index] = banishedtemp[victim.index]
        else
            storage.thebanished[victim.index] = 0 -- Erase/init
        end

        -- Was banished, but not anymore
        if is_banished(victim) == false and prevstate == true then
            local msg = victim.name .. " is no longer banished."
            print("[REPORT] SYSTEM " .. msg)
            gsysmsg(msg)

            -- Kill them, so items are left behind
            if victim.character and victim.character.valid then
                victim.character.die("player")
            end
            if not storage.send_to_surface then
                storage.send_to_surface = {}
            end

            table.insert(storage.send_to_surface, {
                victim = victim,
                surface = "nauvis",
                position = get_default_spawn()
            })
        elseif is_banished(victim) == true and prevstate == false then
            -- Was not banished, but is now.
            local msg = victim.name .. " has been banished."
            gsysmsg(msg)
            print("[REPORT] SYSTEM " .. msg)
            showBanishedInform(false, victim)

            -- Create area if needed
            if game.surfaces["hell"] == nil then
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
                game.create_surface("hell", my_map_gen_settings)
            end

            -- Kill them, so items are left behind
            if victim.character and victim.character.valid then
                send_to_default_spawn(victim)
                victim.character.die("player")
            else
                dumpPlayerInventory(victim)
            end

            gsysmsg(victim.name .. "'s items have been dumped at spawn so they can be recovered.")

            if not storage.send_to_surface then
                storage.send_to_surface = {}
            end
            table.insert(storage.send_to_surface, {
                victim = victim,
                surface = "hell",
                position = {0, 0}
            })
        end
    end
end

function g_banish(player, victim, reason)
    if player and player.valid then
        -- Regulars/mods only
        if is_regular(player) or is_veteran(player) or player.admin then
            -- Must have arguments
            if victim and reason then
                if victim.name == player.name then
                    smart_print(player, "You can't banish yourself. Have you considered therapy?")
                    return
                end
                if is_banished(player) then
                    smart_print(player, "You are banished, you can't vote.")
                    return
                end

                if string.len(reason) < 4 then
                    smart_print(player, "You must supply a more descriptive complaint.")
                    return
                else
                    -- Must have valid victim
                    if victim and victim.valid then
                        -- Victim can not be an moderator
                        if not victim.admin then
                            -- Check if we already voted against them
                            if storage.banishvotes and storage.banishvotes ~= {} then
                                local votecount = 1
                                for _, vote in pairs(storage.banishvotes) do
                                    if vote and vote.voter and vote.victim then
                                        -- Count player's total votes, cap them
                                        if vote.voter == player then
                                            votecount = votecount + 1
                                        end
                                        -- Limit number of votes player gets
                                        if not vote.voter.admin and votecount >= 5 then
                                            smart_print(player, "You have exhausted your voting privilege for this map.")
                                            return
                                        end

                                        -- Can't vote twice
                                        if vote.voter == player and vote.victim == victim then
                                            smart_print(player, "You already voted against them!")
                                            smart_print(player, "/unbanish <player> to withdraw your vote.")
                                            smart_print(player,
                                                "[color=red](WARNING) If you withdraw a vote, you CAN NOT reintroduce it.[/color]")
                                            return
                                        end
                                    end
                                end

                                -- Send report to discord and add to vote list
                                local message = player.name .. " voted to banish: " .. victim.name .. " for: " .. reason
                                gsysmsg(message)
                                print("[REPORT] " .. message)
                                smart_print(player, "(SYSTEM): Your vote has been added, and posted on Discord!")
                                smart_print(player, "/unbanish <player> to withdraw your vote.")
                                smart_print(player,
                                    "[color=red](WARNING) If you withdraw a vote, you CAN NOT reintroduce it.[/color]")
                                smart_print(player, "You have used " .. votecount .. " of your 5 available votes.")
                            end

                            -- Init if needed
                            if not storage.banishvotes then
                                storage.banishvotes = {
                                    voter = {},
                                    victim = {},
                                    reason = {},
                                    tick = {},
                                    withdrawn = {},
                                    overruled = {}
                                }
                            end
                            table.insert(storage.banishvotes, {
                                voter = player,
                                victim = victim,
                                reason = reason,
                                tick = game.tick,
                                withdrawn = false,
                                overruled = false
                            })
                            update_banished_votes() -- Must do this to add to tally
                        else
                            smart_print(player, "Moderators can not be banished.")
                        end
                    else
                        smart_print(player, "There are no players by that name.")
                    end
                end
            else
                smart_print(player, "Usage: /banish <player> <reason for banishment>")
            end
        else
            smart_print(player, "This command is for regulars/veterans (level 3+) players and moderators only!")
            return
        end
    else
        smart_print(nil, "The console can't vote.")
    end
end

function send_to_surface(player)
    -- Anything queued?
    if storage.send_to_surface then
        -- Valid player?
        if player and player.valid and player.character and player.character.valid then
            local index = nil
            -- Check list
            for i, item in pairs(storage.send_to_surface) do
                -- Check if item is valid
                if item and item.victim and item.victim.valid and item.victim.character and item.victim.character.valid and
                    item.position and item.surface then
                    -- Check if names match
                    if item.victim.name == player.name then
                        -- If surface is valid
                        local surf = game.surfaces[item.surface]
                        if surf and surf.valid then
                            local newpos = surf.find_non_colliding_position("character", item.position, 100, 0.1, false)
                            if newpos then
                                player.teleport(newpos, surf)
                            else
                                player.teleport(item.position, surf) -- screw it
                                console_print("error: send_to_surface(respawn): unable to find non_colliding_position.")
                            end
                            index = i
                            break
                        end
                    end
                end
            end
            -- Remove item we processed
            if index then
                console_print("send_to_surface: item removed: " .. index)
                table.remove(storage.send_to_surface, index)
            end
        end
    end
end

function add_banish_commands()
    -- Damn them!
    commands.add_command("damn", "<player>\n(sends player to hell, tfrom <player> to teleport them back out.)",
        function(param)
            local player

            -- Mods only
            if param and param.player_index then
                player = game.players[param.player_index]
                if player and player.admin == false then
                    smart_print(player, "Moderators only.")
                    return
                end
            end

            -- Handle console too
            if (player and player.admin) or (not player) then
                if game.surfaces["hell"] == nil then
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
                    game.create_surface("hell", my_map_gen_settings)
                end

                -- Only if name provided
                if param.parameter then
                    local victim = game.players[param.parameter]

                    if (victim and victim.valid) then
                        -- If they have a character, kill it to release items
                        if victim.character and victim.character.valid then
                            victim.character.die("player")
                        end
                        if not storage.send_to_surface then
                            storage.send_to_surface = {}
                        end
                        table.insert(storage.send_to_surface, {
                            victim = victim,
                            surface = "hell",
                            position = {0, 0}
                        })
                    else
                        smart_print(player, "Couldn't find that player.")
                    end
                end
            else
                smart_print(player, "Moderators only.")
            end
        end)
    -- Mod vote overrrule
    commands.add_command("overrule",
        "<defendant>\n(overrule votes against defendant)\n<clear>\n(clear all votes, will unbanish all)",
        function(param)
            if param and param.player_index then
                local player = game.players[param.player_index]

                -- Moderator only
                if (player and player.admin) then
                    if storage.banishvotes then
                        -- get arguments
                        local args = mysplit(param.parameter, " ")

                        -- Must have arguments
                        if args ~= {} and args[1] then
                            if args[1] == "clear" then
                                storage.banishvotes = nil
                                smart_print(player, "All votes cleared.")
                                update_banished_votes()
                                return
                            end
                            local victim = game.players[args[1]]

                            -- If victim found
                            if victim and victim.valid then
                                local count = 0
                                for _, vote in pairs(storage.banishvotes) do
                                    if vote and vote.victim and vote.victim.valid then
                                        if vote.victim == victim and vote.overruled == false then
                                            vote.overruled = true
                                            count = count + 1
                                        end
                                    end
                                end
                                if count > 0 then
                                    smart_print(player, "Overruled " .. count .. " votes against " .. victim.name)
                                else
                                    for _, vote in pairs(storage.banishvotes) do
                                        if vote and vote.victim and vote.victim.valid then
                                            if vote.victim == victim and vote.overruled == true then
                                                vote.overruled = false
                                                count = count + 1
                                            end
                                        end
                                    end
                                    smart_print(player, "Withdrew " .. count .. " overrulings, against " .. victim.name)
                                end
                                update_banished_votes()
                                return
                            else
                                smart_print(player, "Couldn't find a player by that name.")
                            end
                        else
                            smart_print(player,
                                "Who do you want to overrule votes against? <player> or <clear> (clears/unbanishes all)")
                        end
                    else
                        smart_print(player, "There are no votes to overrule.")
                    end
                else
                    smart_print(player, "Moderators only.")
                end
            end
        end)

    -- Print votes
    commands.add_command("votes", "(Shows banish votes)", function(param)
        if param and param.player_index then
            local player = game.players[param.player_index]

            -- Only if banish data found
            if storage.banishvotes then
                -- Print votes
                local pcount = 0
                for _, vote in pairs(storage.banishvotes) do
                    if vote and vote.voter and vote.voter.valid and vote.victim and vote.victim.valid then
                        local notes = ""
                        if vote.withdrawn then
                            notes = "(WITHDRAWN) "
                        end
                        if vote.overruled then
                            notes = "(OVERRULED) "
                        end
                        pcount = pcount + 1
                        smart_print(player, notes .. "plaintiff: " .. vote.voter.name .. ", defendant: " ..
                            vote.victim.name .. ", complaint:\n" .. vote.reason)
                    end
                end

                -- Tally votes before proceeding
                update_banished_votes()

                -- Print accused
                if storage.thebanished then
                    for _, victim in pairs(game.players) do
                        if storage.thebanished[victim.index] and storage.thebanished[victim.index] > 1 then
                            smart_print(player, victim.name .. " has had " .. storage.thebanished[victim.index] ..
                                " complaints against them.")
                            pcount = pcount + 1
                        end
                    end
                end
                -- Show summery of votes against them
                if storage.banishvotes then
                    for _, victim in pairs(game.players) do
                        local votecount = 0
                        for _, vote in pairs(storage.banishvotes) do
                            if victim == vote.voter then
                                votecount = votecount + 1
                            end
                        end
                        if votecount > 2 then
                            smart_print(player, victim.name .. " has voted against " .. votecount .. " players.")
                            pcount = pcount + 1
                        end
                    end
                end
                -- Nothing found, report it
                if pcount <= 0 then
                    smart_print(player, "The docket is clean.")
                end
                return
            else
                -- No vote data
                smart_print(player, "The docket is clean.")
                update_banished_votes()
                return
            end
        end
    end)

    -- Banish command
    commands.add_command("unbanish", "<player>\n(Withdraws a banish vote)", function(param)
        if param and param.player_index then
            local player = game.players[param.player_index]
            if player and param.parameter then
                -- regulars/moderators players only
                if is_regular(player) or is_veteran(player) or player.admin then
                    -- get arguments
                    local args = mysplit(param.parameter, " ")

                    -- Must have arguments
                    if args ~= {} and args[1] then
                        local victim = game.players[args[1]]

                        -- Must have valid victim
                        if victim and victim.valid and victim.character and victim.character.valid then
                            -- Check if we voted against them
                            if storage.banishvotes and storage.banishvotes ~= {} then
                                for _, vote in pairs(storage.banishvotes) do
                                    if vote and vote.voter and vote.victim then
                                        if vote.voter == player and vote.victim == victim then
                                            -- Send report to discord and withdraw vote
                                            local message = player.name .. " WITHDREW their vote to banish: " ..
                                                                victim.name
                                            gsysmsg(message)
                                            print("[REPORT] " .. message)
                                            smart_print(player, "Your vote has been withdrawn, and posted on Discord.")
                                            vote.withdrawn = true
                                            update_banished_votes() -- Must do this to delete from tally
                                            return
                                        end
                                    end
                                end
                                smart_print(player, "I don't see a vote from you, against that player, to withdraw.")
                            end
                        else
                            smart_print(player, "There are no players online by that name.")
                        end
                    else
                        smart_print(player, "Usage: /unbanish <player>")
                    end
                else
                    smart_print(player, "Only regulars/moderator status players can vote.")
                    return
                end
            else
                smart_print(player, "Usage: /unbanish <player>")
            end
        else
            smart_print(nil, "The console can't vote.")
        end
    end)

    -- Banish command
    commands.add_command("banish", "<player> <reason for banishment>\n(Sends player to a confined area, off-map)",
        function(param)
            if param and param.player_index then
                local player = game.players[param.player_index]

                if not param.parameter then
                    smart_print(player, "Banish who?")
                    return
                end
                local args = mysplit(param.parameter, " ")
                if not args[2] then
                    smart_print(player, "You must specify a reason.")
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

                if is_banished(victim) then
                    smart_print(player, "They are already banished!")
                    return
                end

                g_banish(player, victim, reason)
            end
        end)

    -- User report command
    commands.add_command("report", "<detailed report here>\n(Sends in a report to the moderators)", function(param)
        if param and param.player_index then
            local player = game.players[param.player_index]
            g_report(player, param.parameter)
        else
            smart_print(nil, "The console doesn't need to send in reports this way.")
        end
    end)
end

function showBanishedInform(close, victim)

    if victim and victim.gui and victim.gui.screen then
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
            banished_titlebar.drag_target = main_flow
            banished_titlebar.style.horizontal_align = "center"
            banished_titlebar.style.horizontally_stretchable = true

            banished_titlebar.add {
                type = "label",
                style = "frame_title",
                caption = "YOU HAVE BEEN BANISHED!"
            }

            local pusher = banished_titlebar.add {
                type = "empty-widget",
                style = "draggable_space_header"
            }
            pusher.style.vertically_stretchable = true
            pusher.style.horizontally_stretchable = true
            pusher.drag_target = main_flow

            banished_titlebar.add {
                type = "sprite-button",
                name = "banished_inform_close",
                sprite = "utility/close",
                style = "frame_action_button",
                tooltip = "Close this window"
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
        else
            -- Close button
            if close then
                victim.gui.screen.banished_inform.destroy()
            end
        end
    end
end
