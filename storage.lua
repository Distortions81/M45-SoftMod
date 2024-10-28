-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
-- Create storage, if needed
function create_mystorage()
    storage.svers = "622-10.27.2024-1114p"

    -- Adjust look
    game.surfaces[1].show_clouds = false

    -- This mod complely screws player permissions
    if script.active_mods["RemoteConfiguration"] then
        storage.disableperms = true
    else
        storage.disableperms = false
    end

    if not storage.resetdur then
        storage.resetdur = ""
    end
    if not storage.resetint then
        storage.resetint = ""
    end
    if not storage.restrict == nil then
        storage.restrict = true
    end
    if not storage.playeractive then
        storage.playeractive = {}
    end
    if not storage.playermoving then
        storage.playermoving = {}
    end
    if not storage.active_playtime then
        storage.active_playtime = {}
    end
    if not storage.last_playtime then
        storage.last_playtime = {}
    end

    if not storage.patreons then
        storage.patreons = {}
    end
    if not storage.nitros then
        storage.nitros = {}
    end

    if not storage.patreonlist then
        storage.patreonlist = {}
    end
    if not storage.nitrolist then
        storage.nitrolist = {}
    end

    if not storage.last_speaker_warning then
        storage.last_speaker_warning = 1
    end
    if not storage.last_decon_warning then
        storage.last_decon_warning = 1
    end
    if not storage.last_ghost_log then
        storage.last_decon_warning = 1
    end

    make_banish_storage()

    if not storage.info_shown then
        storage.info_shown = {}
    end

    if not storage.hide_clock then
        storage.hide_clock = {}
    end

    if not storage.lastonlinestring then
        storage.lastonlinestring = ""
    end

    if not storage.cleaned_players then
        storage.cleaned_players = {}
    end
end

-- Create player storage, if needed
function create_player_storage(player)
    if player and player.valid then
        if storage.playeractive and player and player.index then
            if not storage.playeractive[player.index] then
                storage.playeractive[player.index] = false
            end
            if not storage.playermoving[player.index] then
                storage.playermoving[player.index] = false
            end

            if not storage.active_playtime[player.index] then
                storage.active_playtime[player.index] = 0
            end

            if not storage.thebanished[player.index] then
                storage.thebanished[player.index] = 0
            end

            if not storage.hide_clock[player.index] then
                storage.hide_clock[player.index] = false
            end

            if not storage.last_playtime[player.index] then
                storage.last_playtime[player.index] = false
            end

            if not storage.cleaned_players[player.index] then
                storage.cleaned_players[player.index] = true
            end

        end
    end
end
