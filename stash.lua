-- Helper: Check if player is valid and controlling a character
local function is_player_valid(player)
    return player
       and player.valid
       and player.connected
       and player.character
       and player.character.valid
       and player.controller_type == defines.controllers.character
end

-- Helper: Check if inventory is empty using get_item_count()
local function is_inventory_empty(inventory)
    if not inventory then return true end
    return inventory.get_item_count() == 0
end

-- Ensure a particular stash is empty or create it fresh
local function ensure_empty_stash(player_index, stash_name, size)
    if storage.PData[player_index][stash_name] then
        local stash = storage.PData[player_index][stash_name]
        if not stash.is_empty() then
            return false -- It's not empty
        else
            return true
        end
    else
        storage.PData[player_index][stash_name] = game.create_inventory(size)
        return true
    end
end

-- Stash items from a source inventory into a target stash inventory, using can_insert()
local function stash_inventory(source_inv, stash_inv)
    if not source_inv or not stash_inv then return false, false end
    local stashed_anything = false
    local stash_full = false

    for i = 1, #source_inv do
        local stack = source_inv[i]
        if stack.valid_for_read then
            local stack_to_insert = { name = stack.name, count = stack.count }
            if stash_inv.can_insert(stack_to_insert) then
                local inserted_count = stash_inv.insert(stack_to_insert)
                if inserted_count > 0 then
                    if inserted_count < stack.count then
                        stack.count = stack.count - inserted_count
                        stash_full = true
                    else
                        stack.clear()
                    end
                    stashed_anything = true
                else
                    stash_full = true
                end
            else
                stash_full = true
            end
        end
    end
    return stashed_anything, stash_full
end

-- Unstash items from a stash inventory into a target player inventory, using can_insert()
local function unstash_inventory(stash_inv, target_inv)
    if not stash_inv or not target_inv then return false, false end
    local unstashed_anything = false
    local player_inventory_full = false

    for i = 1, #stash_inv do
        local stack = stash_inv[i]
        if stack.valid_for_read then
            local stack_to_insert = { name = stack.name, count = stack.count }
            if target_inv.can_insert(stack_to_insert) then
                local inserted_count = target_inv.insert(stack_to_insert)
                if inserted_count > 0 then
                    if inserted_count < stack.count then
                        stack.count = stack.count - inserted_count
                        player_inventory_full = true
                    else
                        stack.clear()
                    end
                    unstashed_anything = true
                else
                    player_inventory_full = true
                end
            else
                player_inventory_full = true
            end
        end
    end
    return unstashed_anything, player_inventory_full
end

-- Stash armor and its equipment, using can_insert
local function stash_armor(player)
    local armor_inventory = player.get_inventory(defines.inventory.character_armor)
    if not armor_inventory or armor_inventory.is_empty() then
        return false, false
    end

    local stashed_anything = false
    local stash_full = false

    for i = 1, #armor_inventory do
        local stack = armor_inventory[i]
        if stack.valid_for_read then
            -- If it's armor with equipment, store equipment data
            if stack.grid and stack.grid.valid then
                local equipment_data = {}
                for _, eq in pairs(stack.grid.equipment) do
                    table.insert(equipment_data, {
                        name = eq.name,
                        position = eq.position,
                        energy = eq.energy
                    })
                end
                storage.PData[player.index].armor_equipment_data = equipment_data
            else
                storage.PData[player.index].armor_equipment_data = nil
            end

            local armor_stash = storage.PData[player.index].armor_stash
            local stack_to_insert = { name = stack.name, count = stack.count }
            if armor_stash.can_insert(stack_to_insert) then
                local inserted_count = armor_stash.insert(stack_to_insert)
                if inserted_count > 0 then
                    if inserted_count < stack.count then
                        stack.count = stack.count - inserted_count
                        stash_full = true
                    else
                        stack.clear()
                    end
                    stashed_anything = true
                else
                    stash_full = true
                end
            else
                stash_full = true
            end
        end
    end

    return stashed_anything, stash_full
end

-- Unstash armor and restore equipment, using can_insert
local function unstash_armor(player)
    local armor_inventory = player.get_inventory(defines.inventory.character_armor)
    local armor_stash = storage.PData[player.index].armor_stash
    if not armor_stash then return false, false end

    local unstashed_anything = false
    local player_inventory_full = false

    for i = 1, #armor_stash do
        local stack = armor_stash[i]
        if stack.valid_for_read then
            local stack_to_insert = { name = stack.name, count = stack.count }
            if armor_inventory.can_insert(stack_to_insert) then
                local inserted_count = armor_inventory.insert(stack_to_insert)
                if inserted_count > 0 then
                    if inserted_count < stack.count then
                        stack.count = stack.count - inserted_count
                        player_inventory_full = true
                    else
                        stack.clear()
                    end
                    unstashed_anything = true

                    -- Restore equipment if we have any saved
                    if storage.PData[player.index].armor_equipment_data then
                        local new_armor_stack = armor_inventory[1] -- The inserted armor should be here
                        if new_armor_stack and new_armor_stack.valid_for_read and new_armor_stack.grid then
                            for _, eq_data in pairs(storage.PData[player.index].armor_equipment_data) do
                                local eq = new_armor_stack.grid.put({ name = eq_data.name, position = eq_data.position })
                                if eq then
                                    eq.energy = eq_data.energy
                                end
                            end
                        end
                        storage.PData[player.index].armor_equipment_data = nil
                    end
                else
                    player_inventory_full = true
                end
            else
                player_inventory_full = true
            end
        end
    end

    return unstashed_anything, player_inventory_full
end

-- Function to add the commands
function STASH_AddStashCommands()
    commands.add_command("stash", "Donator-only: Stash current weapon/ammo/armor (including equipment).",
        function(param)
            if not param or not param.player_index then return end
            local player = game.players[param.player_index]

            if not is_player_valid(player) then
                if player and player.valid then
                    player.print("You must be alive, connected, and controlling a character to use this command.")
                end
                return
            end

            if not UTIL_Is_Supporter(player) and not player.admin then
                UTIL_SmartPrint(player, "This command is only for supporters.")
                return
            end

            if not storage.PData then storage.PData = {} end
            if not storage.PData[player.index] then storage.PData[player.index] = {} end

            local can_stash_guns = ensure_empty_stash(player.index, "gun_stash", 10)
            local can_stash_ammo = ensure_empty_stash(player.index, "ammo_stash", 20)
            local can_stash_armor = ensure_empty_stash(player.index, "armor_stash", 5)

            if not (can_stash_guns and can_stash_ammo and can_stash_armor) then
                UTIL_SmartPrint(player, "You already have stashed equipment. Unstash or clear before stashing again.")
                return
            end

            local gun_inventory = player.get_inventory(defines.inventory.character_guns)
            local ammo_inventory = player.get_inventory(defines.inventory.character_ammo)

            local gun_stashed, gun_stash_full = stash_inventory(gun_inventory, storage.PData[player.index].gun_stash)
            local ammo_stashed, ammo_stash_full = stash_inventory(ammo_inventory, storage.PData[player.index].ammo_stash)
            local armor_stashed, armor_stash_full = stash_armor(player)

            local stashed_anything = gun_stashed or ammo_stashed or armor_stashed
            local stash_full = gun_stash_full or ammo_stash_full or armor_stash_full

            if stashed_anything then
                UTIL_SmartPrint(player, "Your guns, ammo, and armor (including equipment) have been successfully stashed!")
                if stash_full then
                    UTIL_SmartPrint(player, "Some items could not be stashed due to insufficient space.")
                end
            else
                if stash_full then
                    UTIL_SmartPrint(player, "No space to stash your equipment.")
                else
                    UTIL_SmartPrint(player, "You had no guns, ammo, or armor to stash.")
                end
            end
        end
    )

    commands.add_command("unstash", "Donator-only: Unstash weapon/ammo/armor (including equipment).",
        function(param)
            if not param or not param.player_index then return end
            local player = game.players[param.player_index]

            if not is_player_valid(player) then
                if player and player.valid then
                    player.print("You must be alive, connected, and controlling a character to use this command.")
                end
                return
            end

            if not UTIL_Is_Supporter(player) and not player.admin then
                UTIL_SmartPrint(player, "This command is only for supporters.")
                return
            end

            if not storage.PData or not storage.PData[player.index] then
                return
            end

            local gun_inventory = player.get_inventory(defines.inventory.character_guns)
            local ammo_inventory = player.get_inventory(defines.inventory.character_ammo)
            local armor_inventory = player.get_inventory(defines.inventory.character_armor)

            if not is_inventory_empty(gun_inventory) or not is_inventory_empty(ammo_inventory) or not is_inventory_empty(armor_inventory) then
                UTIL_SmartPrint(player, "You must clear your guns, ammo, and armor before unstashing.")
                return
            end

            local gun_stash = storage.PData[player.index].gun_stash
            local ammo_stash = storage.PData[player.index].ammo_stash
            local armor_stash = storage.PData[player.index].armor_stash

            if not (gun_stash or ammo_stash or armor_stash) then
                UTIL_SmartPrint(player, "No stashed equipment found to unstash.")
                return
            end

            local guns_unstashed, guns_full = unstash_inventory(gun_stash, gun_inventory)
            local ammo_unstashed, ammo_full = unstash_inventory(ammo_stash, ammo_inventory)
            local armor_unstashed, armor_full = unstash_armor(player)

            local unstashed_anything = guns_unstashed or ammo_unstashed or armor_unstashed
            local player_inventory_full = guns_full or ammo_full or armor_full

            if unstashed_anything then
                UTIL_SmartPrint(player, "Your stashed guns, ammo, and armor (with equipment) have been successfully restored!")
                if player_inventory_full then
                    UTIL_SmartPrint(player, "Some items could not be restored due to insufficient space.")
                end
            else
                UTIL_SmartPrint(player, "Your stashes were empty or could not be restored.")
            end
        end
    )
end