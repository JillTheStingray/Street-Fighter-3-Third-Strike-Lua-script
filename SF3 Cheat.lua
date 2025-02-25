local memory = require("memory")

if not memory then
    print("Memory library is not available. Run this script in a compatible emulator.")
    return
end

local cheats = {
    { name = "Auto Blocking PL1", address = {0x2026335, 0x2026337, 0x2026339, 0x2026346}, values = {0x06, 0x06, 0x06, 0x06}, default_values = {0x00, 0x00, 0x00, 0x00}, enabled = false },
    { name = "Select Grab Tech PL1", address = {0x2026328}, values = {0x00}, default_values = {0x00}, enabled = false },
    { name = "Infinite Time (Enabled by default)", address = {0x2011377}, values = {0x63}, default_values = {0x00}, enabled = true },
    { name = "No Selection Time (Enabled by default)", address = {0x20154FB}, values = {0x99}, default_values = {0x00}, enabled = true },
    { name = "All Universal Combos", address = {0x2068E8D}, values = {0x0F}, default_values = {0x00}, enabled = false },
    { name = "Infinite Power PL1", address = {0x20695B5}, values = {0xA0}, default_values = {0x00}, enabled = false },
    { name = "Infinite Gauge PL1", address = {0x20695BA, 0x20695BB, 0x20695BC, 0x20695BD, 0x20695BE, 0x20695BF}, values = {0x00, 0x03, 0x00, 0x03, 0x00, 0x03}, default_values = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00}, enabled = false },
    { name = "Infinite Energy PL1", address = {0x2068D0B}, values = {0xA0}, default_values = {0x00}, enabled = false },
    { name = "Special + Super", address = {0x2068E8D}, values = {0x60}, default_values = {0x00}, enabled = false },
    { name = "Select Stun Status Enemy", address = {0x2069611}, values = {0x60}, default_values = {0x00}, enabled = false },
    { name = "No Combo Damage Reduction PL1", address = {0x20694D6}, values = {0x00}, default_values = {0x00}, enabled = false },
    { name = "Semi Infinite Juggle PL1", address = {0x20694C9}, values = {0x00}, default_values = {0x00}, enabled = false },
    { name = "True Infinite Juggle PL1", address = {0x20694C6}, values = {0x00}, default_values = {0x00}, enabled = false },
    { name = "Select Stun Bar Length PL2", address = {0x206960B}, values = {0x38, 0x40, 0x48, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x50, 0x58, 0x60}, default_values = {0x00}, enabled = false,
      options = {
        { name = "Disabled", value = 0x00 }, { name = "56 (Small)", value = 0x38 }, { name = "64 (Medium)", value = 0x40 },
        { name = "72 (Large)", value = 0x48 }, { name = "8", value = 0x08 }, { name = "16 (Medium)", value = 0x10 },
        { name = "24", value = 0x18 }, { name = "32", value = 0x20 }, { name = "40", value = 0x28 },
        { name = "48", value = 0x30 }, { name = "80", value = 0x50 }, { name = "88", value = 0x58 },
        { name = "96", value = 0x60 }
      }
    },
    { name = "Select Character PL1", selected_character = 1,
      characters = {
        { name = "Disabled", address = {0x2011387}, values = {0x00} },
        { name = "Alex", address = {0x2011387}, values = {0x01} },
        { name = "Ryu", address = {0x2011387}, values = {0x02} },
        { name = "Yun", address = {0x2011387}, values = {0x03} },
        { name = "Dudley", address = {0x2011387}, values = {0x04} },
        { name = "Necro", address = {0x2011387}, values = {0x05} },
        { name = "Hugo", address = {0x2011387}, values = {0x06} },
        { name = "Ibuki", address = {0x2011387}, values = {0x07} },
        { name = "Elena", address = {0x2011387}, values = {0x08} },
        { name = "Oro", address = {0x2011387}, values = {0x09} },
        { name = "Yang", address = {0x2011387}, values = {0x0A} },
        { name = "Ken", address = {0x2011387}, values = {0x0B} },
        { name = "Sean", address = {0x2011387}, values = {0x0C} },
        { name = "Urien", address = {0x2011387}, values = {0x0D} },
        { name = "Akuma", address = {0x2011387}, values = {0x0E} },
        { name = "Chun-Li", address = {0x2011387}, values = {0x10} },
        { name = "Makoto", address = {0x2011387}, values = {0x11} },
        { name = "Q", address = {0x2011387}, values = {0x12} },
        { name = "Twelve", address = {0x2011387}, values = {0x13} },
        { name = "Remy", address = {0x2011387}, values = {0x14} },
        { name = "Gill", address = {0x201566B, 0x20154CF, 0x2011387}, values = {0x03, 0x01, 0x00} },
        { name = "Shin Akuma/SUV", address = {0x201566B, 0x20154CF, 0x2011387}, values = {0x00, 0x06, 0x0F} }
      }
    },
    { name = "Select Super Art PL1", selected_super_art = 1,
      super_arts = {
        { name = "SA-1", address = 0x201138B, value = 0x00 },
        { name = "SA-2", address = 0x201138B, value = 0x01 },
        { name = "SA-3", address = 0x201138B, value = 0x02 }
      }
    },
    { name = "Select Bonus Damage PL1", selected_bonus_damage = 1,
      bonus_damage = {
        { name = "Disabled", address = {0x20690A7}, values = {0x00} },
        { name = "1", address = {0x20690A7}, values = {0x01} },
        { name = "2", address = {0x20690A7}, values = {0x02} },
        { name = "3", address = {0x20690A7}, values = {0x03} },
        { name = "4", address = {0x20690A7}, values = {0x04} },
        { name = "5", address = {0x20690A7}, values = {0x05} },
        { name = "6", address = {0x20690A7}, values = {0x06} },
        { name = "7", address = {0x20690A7}, values = {0x07} },
        { name = "8", address = {0x20690A7}, values = {0x08} },
        { name = "9", address = {0x20690A7}, values = {0x09} },
        { name = "10", address = {0x20690A7}, values = {0x0A} },
        { name = "11", address = {0x20690A7}, values = {0x0B} },
        { name = "12", address = {0x20690A7}, values = {0x0C} },
        { name = "13", address = {0x20690A7}, values = {0x0D} },
        { name = "14 (GO)", address = {0x20690A7}, values = {0x0E} },
        { name = "15", address = {0x20690A7}, values = {0x0F} },
        { name = "16", address = {0x20690A7}, values = {0x10} },
        { name = "17", address = {0x20690A7}, values = {0x11} },
        { name = "18", address = {0x20690A7}, values = {0x12} },
        { name = "19", address = {0x20690A7}, values = {0x13} },
        { name = "20", address = {0x20690A7}, values = {0x14} },
        { name = "21", address = {0x20690A7}, values = {0x15} },
        { name = "22", address = {0x20690A7}, values = {0x16} },
        { name = "23", address = {0x20690A7}, values = {0x17} },
        { name = "24", address = {0x20690A7}, values = {0x18} },
        { name = "25", address = {0x20690A7}, values = {0x19} },
        { name = "26", address = {0x20690A7}, values = {0x1A} },
        { name = "27", address = {0x20690A7}, values = {0x1B} },
        { name = "28", address = {0x20690A7}, values = {0x1C} },
        { name = "29", address = {0x20690A7}, values = {0x1D} },
        { name = "30", address = {0x20690A7}, values = {0x1E} },
        { name = "31", address = {0x20690A7}, values = {0x1F} },
        { name = "32", address = {0x20690A7}, values = {0x20} },
        { name = "255", address = {0x20690A7}, values = {0xFF} }
      }
    }
}


local menu_open = true
local current_cheat_index = 1
local input_counter = 0
local input_delay = 10

function toggle_cheat(cheat)
    cheat.enabled = not cheat.enabled
    if cheat.enabled then
        for i = 1, #cheat.address do
            memory.writebyte(cheat.address[i], cheat.values[i])
        end
    else
        for i = 1, #cheat.address do
            memory.writebyte(cheat.address[i], cheat.default_values[i])
        end
    end
end

function select_character(cheat, character_index)
    cheat.selected_character = character_index
    local character = cheat.characters[character_index]
    for i = 1, #character.address do
        memory.writebyte(character.address[i], character.values[i])
    end
end

function select_super_art(cheat, super_art_index)
    cheat.selected_super_art = super_art_index
    local super_art = cheat.super_arts[super_art_index]
    memory.writebyte(super_art.address, super_art.value)
end

function select_bonus_damage(cheat, bonus_damage_index)
    cheat.selected_bonus_damage = bonus_damage_index
    local bonus_damage = cheat.bonus_damage[bonus_damage_index]
    for i = 1, #bonus_damage.address do
        memory.writebyte(bonus_damage.address[i], bonus_damage.values[i])
    end
end

function toggle_bonus_damage(cheat)
    cheat.enabled = not cheat.enabled
    if cheat.enabled then
        for i = 1, #cheat.address do
            memory.writebyte(cheat.address[i], cheat.values[i])
        end
    else
        for i = 1, #cheat.address do
            memory.writebyte(cheat.address[i], cheat.default_values[i])
        end
    end
end

function handle_input()
    input_counter = input_counter + 1
    local input = input.get()

    if input_counter > input_delay then
        if input.M then
            menu_open = not menu_open
            input_counter = 0
            return
        end

        if menu_open then
            local current_cheat = cheats[current_cheat_index]

            if current_cheat.name == "Select Character PL1" then
                if input.right then
                    current_cheat.selected_character = current_cheat.selected_character % #current_cheat.characters + 1
                    select_character(current_cheat, current_cheat.selected_character)
                    input_counter = 0
                elseif input.left then
                    current_cheat.selected_character = (current_cheat.selected_character - 2 + #current_cheat.characters) % #current_cheat.characters + 1
                    select_character(current_cheat, current_cheat.selected_character)
                    input_counter = 0
                end
            elseif current_cheat.name == "Select Super Art PL1" then
                if input.right then
                    current_cheat.selected_super_art = current_cheat.selected_super_art % #current_cheat.super_arts + 1
                    select_super_art(current_cheat, current_cheat.selected_super_art)
                    input_counter = 0
                elseif input.left then
                    current_cheat.selected_super_art = (current_cheat.selected_super_art - 2 + #current_cheat.super_arts) % #current_cheat.super_arts + 1
                    select_super_art(current_cheat, current_cheat.selected_super_art)
                    input_counter = 0
                end
            elseif current_cheat.name == "Select Bonus Damage PL1" then
                if input.right then
                    current_cheat.selected_bonus_damage = current_cheat.selected_bonus_damage % #current_cheat.bonus_damage + 1
                    select_bonus_damage(current_cheat, current_cheat.selected_bonus_damage)
                    input_counter = 0
                elseif input.left then
                    current_cheat.selected_bonus_damage = (current_cheat.selected_bonus_damage - 2 + #current_cheat.bonus_damage) % #current_cheat.bonus_damage + 1
                    select_bonus_damage(current_cheat, current_cheat.selected_bonus_damage)
                    input_counter = 0
                end
            else
                if input.right then
                    toggle_cheat(current_cheat)
                    input_counter = 0
                end
            end

            if input.down then
                current_cheat_index = current_cheat_index % #cheats + 1
                input_counter = 0
            end
            
            if input.up then
                current_cheat_index = (current_cheat_index - 2 + #cheats) % #cheats + 1
                input_counter = 0
            end
        end
    end
end

while true do
    if menu_open then
        gui.box(5, 5, 100, 220, "white", "black")  
        gui.box(6, 6, 271, 221, "black", "black")  
        gui.box(4, 4, 269, 219, "black", "black")  
        gui.box(6, 6, 268, 218, "red")             
        gui.box(7, 7, 267, 217, "lightgray")       
        gui.text(11, 11, "Toggle Cheats (Press 'M' to hide.       Made by JillTheStingray", "black")
        gui.text(10, 10, "Toggle Cheats (Press 'M' to hide.       Made by JillTheStingray", "white")
       

        for i, cheat in ipairs(cheats) do
            local status
            if cheat.name == "Select Character PL1" then
                status = cheat.characters[cheat.selected_character].name
            elseif cheat.name == "Select Super Art PL1" then
                status = cheat.super_arts[cheat.selected_super_art].name
            elseif cheat.name == "Select Bonus Damage PL1" then
                status = cheat.bonus_damage[cheat.selected_bonus_damage].name
            else
                status = cheat.enabled and "Enabled" or "Disabled"
            end
            local color = i == current_cheat_index and "red" or "white"
            
            gui.text(19, 17 + i * 11, string.format("%d. %s - %s", i, cheat.name, status), "black")
            gui.text(18, 16 + i * 11, string.format("%d. %s - %s", i, cheat.name, status), color)
        end
    else
        gui.text(11, 11, "Press 'M' to open the menu.                                 Made by JillTheStingray", "black")
        gui.text(10, 10, "Press 'M' to open the menu.                                 Made by JillTheStingray", "white")
    end
    handle_input()
    
    for _, cheat in ipairs(cheats) do
        if cheat.enabled then
            for i = 1, #cheat.address do
                memory.writebyte(cheat.address[i], cheat.values[i])
            end
        end
        if cheat.name == "Select Bonus Damage PL1" then
            local bonus_damage = cheat.bonus_damage[cheat.selected_bonus_damage]
            for i = 1, #bonus_damage.address do
                memory.writebyte(bonus_damage.address[i], bonus_damage.values[i])
            end
        end
    end
    
    emu.frameadvance()
end
