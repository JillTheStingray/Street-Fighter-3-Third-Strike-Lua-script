-- Street Fighter III: 3rd Strike cheat menu (FBNeo / Fightcade)
-- Made by JillTheStingray

if type(memory) ~= "table" or type(gui) ~= "table" or type(emu) ~= "table" then
    print("Memory/GUI library is not available. Run this script in a compatible emulator.")
    return
end

-- Cheat types:
--   Toggle: address/values are written every frame while enabled. If default_values
--           is set, those are written once when the cheat is turned off; otherwise
--           the cheat simply stops writing (so turning off "Infinite Energy" doesn't
--           zero your health or "Infinite Time" end the round).
--           Toggles that share a `group` are mutually exclusive.
--   Select: pick one of `options` with left/right. The chosen option is written once
--           when selected, and every frame too if the cheat is `continuous`.
--           An option without an address writes nothing ("Disabled").
local cheats = {
    { name = "Auto Blocking PL1", address = {0x2026335, 0x2026337, 0x2026339, 0x2026346}, values = {0x06, 0x06, 0x06, 0x06}, default_values = {0x00, 0x00, 0x00, 0x00} },
    { name = "Select Grab Tech PL1", address = {0x2026328}, values = {0x00}, default_values = {0x00} },
    { name = "Infinite Time", address = {0x2011377}, values = {0x63}, enabled = true },
    { name = "No Selection Time", address = {0x20154FB}, values = {0x99}, enabled = true },
    { name = "All Universal Combos", address = {0x2068E8D}, values = {0x0F}, default_values = {0x00}, group = "combo_mode" },
    { name = "Infinite Power PL1", address = {0x20695B5}, values = {0xA0} },
    { name = "Infinite Gauge PL1", address = {0x20695BA, 0x20695BB, 0x20695BC, 0x20695BD, 0x20695BE, 0x20695BF}, values = {0x00, 0x03, 0x00, 0x03, 0x00, 0x03} },
    { name = "Infinite Energy PL1", address = {0x2068D0B}, values = {0xA0} },
    { name = "Special + Super", address = {0x2068E8D}, values = {0x60}, default_values = {0x00}, group = "combo_mode" },
    { name = "Select Stun Status Enemy", address = {0x2069611}, values = {0x60}, default_values = {0x00} },
    { name = "No Combo Damage Reduction PL1", address = {0x20694D6}, values = {0x00}, default_values = {0x00} },
    { name = "Semi Infinite Juggle PL1", address = {0x20694C9}, values = {0x00}, default_values = {0x00} },
    { name = "True Infinite Juggle PL1", address = {0x20694C6}, values = {0x00}, default_values = {0x00} },
    { name = "Select Stun Bar Length PL2", continuous = true, options = {
        { name = "Disabled" },
        { name = "8",           address = {0x206960B}, values = {0x08} },
        { name = "16",          address = {0x206960B}, values = {0x10} },
        { name = "24",          address = {0x206960B}, values = {0x18} },
        { name = "32",          address = {0x206960B}, values = {0x20} },
        { name = "40",          address = {0x206960B}, values = {0x28} },
        { name = "48",          address = {0x206960B}, values = {0x30} },
        { name = "56 (Small)",  address = {0x206960B}, values = {0x38} },
        { name = "64 (Medium)", address = {0x206960B}, values = {0x40} },
        { name = "72 (Large)",  address = {0x206960B}, values = {0x48} },
        { name = "80",          address = {0x206960B}, values = {0x50} },
        { name = "88",          address = {0x206960B}, values = {0x58} },
        { name = "96",          address = {0x206960B}, values = {0x60} },
    } },
    { name = "Select Character PL1", options = {
        { name = "Disabled" },
        { name = "Alex",    address = {0x2011387}, values = {0x01} },
        { name = "Ryu",     address = {0x2011387}, values = {0x02} },
        { name = "Yun",     address = {0x2011387}, values = {0x03} },
        { name = "Dudley",  address = {0x2011387}, values = {0x04} },
        { name = "Necro",   address = {0x2011387}, values = {0x05} },
        { name = "Hugo",    address = {0x2011387}, values = {0x06} },
        { name = "Ibuki",   address = {0x2011387}, values = {0x07} },
        { name = "Elena",   address = {0x2011387}, values = {0x08} },
        { name = "Oro",     address = {0x2011387}, values = {0x09} },
        { name = "Yang",    address = {0x2011387}, values = {0x0A} },
        { name = "Ken",     address = {0x2011387}, values = {0x0B} },
        { name = "Sean",    address = {0x2011387}, values = {0x0C} },
        { name = "Urien",   address = {0x2011387}, values = {0x0D} },
        { name = "Akuma",   address = {0x2011387}, values = {0x0E} },
        { name = "Chun-Li", address = {0x2011387}, values = {0x10} },
        { name = "Makoto",  address = {0x2011387}, values = {0x11} },
        { name = "Q",       address = {0x2011387}, values = {0x12} },
        { name = "Twelve",  address = {0x2011387}, values = {0x13} },
        { name = "Remy",    address = {0x2011387}, values = {0x14} },
        { name = "Gill",    address = {0x201566B, 0x20154CF, 0x2011387}, values = {0x03, 0x01, 0x00} },
        { name = "Shin Akuma/SUV", address = {0x201566B, 0x20154CF, 0x2011387}, values = {0x00, 0x06, 0x0F} },
    } },
    { name = "Select Super Art PL1", options = {
        { name = "SA-1", address = {0x201138B}, values = {0x00} },
        { name = "SA-2", address = {0x201138B}, values = {0x01} },
        { name = "SA-3", address = {0x201138B}, values = {0x02} },
    } },
    { name = "Select Bonus Damage PL1", continuous = true, options = {} },
}

-- Bonus damage options: "Disabled" (0), 1-32 ("14 (GO)" marked), and 255.
do
    local bonus = cheats[#cheats].options
    bonus[1] = { name = "Disabled", address = {0x20690A7}, values = {0x00} }
    for n = 1, 32 do
        bonus[#bonus + 1] = { name = n == 14 and "14 (GO)" or tostring(n), address = {0x20690A7}, values = {n} }
    end
    bonus[#bonus + 1] = { name = "255", address = {0x20690A7}, values = {0xFF} }
end

for _, cheat in ipairs(cheats) do
    cheat.selected = cheat.selected or 1
    cheat.enabled = cheat.enabled or false
end

local menu_open = true
local current_index = 1

local function write_bytes(addresses, values)
    if not addresses then return end
    for i = 1, #addresses do
        memory.writebyte(addresses[i], values[i])
    end
end

local function set_enabled(cheat, enabled)
    if cheat.enabled == enabled then return end
    cheat.enabled = enabled
    if enabled then
        if cheat.group then
            for _, other in ipairs(cheats) do
                if other ~= cheat and other.group == cheat.group then
                    other.enabled = false
                end
            end
        end
        write_bytes(cheat.address, cheat.values)
    elseif cheat.default_values then
        write_bytes(cheat.address, cheat.default_values)
    end
end

local function cycle_option(cheat, step)
    local count = #cheat.options
    cheat.selected = (cheat.selected - 1 + step) % count + 1
    local option = cheat.options[cheat.selected]
    write_bytes(option.address, option.values)
end

local function status_text(cheat)
    if cheat.options then
        return "< " .. cheat.options[cheat.selected].name .. " >"
    end
    return cheat.enabled and "Enabled" or "Disabled"
end

-- Input: actions fire on the frame a key is pressed. Holding up/down/left/right
-- repeats after a short delay, except on toggles (so holding doesn't flicker them).
local REPEAT_DELAY = 20
local REPEAT_RATE = 4
local held_frames = {}

local function pressed(keys, key, allow_repeat)
    if not keys[key] then
        held_frames[key] = 0
        return false
    end
    local frames = (held_frames[key] or 0) + 1
    held_frames[key] = frames
    if frames == 1 then return true end
    return allow_repeat and frames > REPEAT_DELAY and (frames - REPEAT_DELAY) % REPEAT_RATE == 0
end

local function handle_input()
    local keys = input.get()
    -- Poll every key every frame so the held-frame counters stay accurate.
    local m     = pressed(keys, "M", false)
    local up    = pressed(keys, "up", true)
    local down  = pressed(keys, "down", true)
    local cheat = cheats[current_index]
    local is_select = cheat.options ~= nil
    local left  = pressed(keys, "left", is_select)
    local right = pressed(keys, "right", is_select)

    if m then
        menu_open = not menu_open
        return
    end
    if not menu_open then return end

    if down then
        current_index = current_index % #cheats + 1
    elseif up then
        current_index = (current_index - 2) % #cheats + 1
    elseif is_select then
        if right then
            cycle_option(cheat, 1)
        elseif left then
            cycle_option(cheat, -1)
        end
    elseif right or left then
        set_enabled(cheat, not cheat.enabled)
    end
end

local TITLE = "Toggle Cheats (Press 'M' to hide)"
local CREDIT = "Made by JillTheStingray"
local LINE_HEIGHT = 11

local function shadow_text(x, y, text, color)
    gui.text(x + 1, y + 1, text, "black")
    gui.text(x, y, text, color)
end

local function draw_menu()
    if not menu_open then
        shadow_text(10, 10, "Press 'M' to open the menu.", "white")
        shadow_text(250, 10, CREDIT, "white")
        return
    end

    local bottom = 26 + #cheats * LINE_HEIGHT
    gui.box(4, 4, 269, bottom + 1, "black", "black")
    gui.box(6, 6, 268, bottom, "red")
    gui.box(7, 7, 267, bottom - 1, "lightgray")
    shadow_text(10, 10, TITLE, "white")
    shadow_text(170, 10, CREDIT, "white")

    for i, cheat in ipairs(cheats) do
        local color = i == current_index and "red" or "white"
        shadow_text(18, 16 + i * LINE_HEIGHT, string.format("%d. %s - %s", i, cheat.name, status_text(cheat)), color)
    end
end

local function apply_cheats()
    for _, cheat in ipairs(cheats) do
        if cheat.options then
            if cheat.continuous then
                local option = cheat.options[cheat.selected]
                write_bytes(option.address, option.values)
            end
        elseif cheat.enabled then
            write_bytes(cheat.address, cheat.values)
        end
    end
end

while true do
    draw_menu()
    handle_input()
    apply_cheats()
    emu.frameadvance()
end
