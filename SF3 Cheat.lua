-- Check if the memory library is available
if not memory then
    print("Memory library is not available. Make sure to run this script in an emulator that supports Lua scripting.")
    return
end

-- Auto Blocking PL1
local auto_block_address = {0x2026335, 0x2026337, 0x2026339, 0x2026346}
local auto_block_values = {0x06, 0x06, 0x06, 0x06}
local auto_block_default_values = {0x00, 0x00, 0x00, 0x00} -- Assuming default is 0x00, adjust if needed
local auto_block_enabled = false

-- Infinite Gauge PL1
local infinite_gauge_address = {0x20695BA, 0x20695BB, 0x20695BC, 0x20695BD, 0x20695BE, 0x20695BF}
local infinite_gauge_values = {0x00, 0x03, 0x00, 0x03, 0x00, 0x03}
local infinite_gauge_default_values = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00} -- Assuming default is 0x00, adjust if needed
local infinite_gauge_enabled = false

-- Infinite Energy PL1
local infinite_energy_address = 0x2068D0B
local infinite_energy_value = 0xA0
local infinite_energy_default_value = 0x00 -- Assuming default is 0x00, adjust if needed
local infinite_energy_enabled = false

-- Special + Super
local special_super_address = 0x2068E8D
local special_super_value = 0x60
local special_super_default_value = 0x00 -- Assuming default is 0x00, adjust if needed
local special_super_enabled = false

function toggle_auto_block(state)
    auto_block_enabled = state
    if state then
        for i = 1, #auto_block_address do
            memory.writebyte(auto_block_address[i], auto_block_values[i])
        end
    else
        for i = 1, #auto_block_address do
            memory.writebyte(auto_block_address[i], auto_block_default_values[i])
        end
    end
end

function toggle_infinite_gauge(state)
    infinite_gauge_enabled = state
    if state then
        for i = 1, #infinite_gauge_address do
            memory.writebyte(infinite_gauge_address[i], infinite_gauge_values[i])
        end
    else
        for i = 1, #infinite_gauge_address do
            memory.writebyte(infinite_gauge_address[i], infinite_gauge_default_values[i])
        end
    end
end

function toggle_infinite_energy(state)
    infinite_energy_enabled = state
    if state then
        memory.writebyte(infinite_energy_address, infinite_energy_value)
    else
        memory.writebyte(infinite_energy_address, infinite_energy_default_value)
    end
end

function toggle_special_super(state)
    special_super_enabled = state
    if state then
        memory.writebyte(special_super_address, special_super_value)
    else
        memory.writebyte(special_super_address, special_super_default_value)
    end
end

-- Example toggles (Enable all cheats)
toggle_auto_block(true)
toggle_infinite_gauge(true)
toggle_infinite_energy(true)
toggle_special_super(true)

-- Example toggles (Disable all cheats)
--toggle_auto_block(false)
--toggle_infinite_gauge(false)
--toggle_infinite_energy(false)
--toggle_special_super(false)

-- Main loop to maintain cheat status
while true do
    if auto_block_enabled then
        for i = 1, #auto_block_address do
            memory.writebyte(auto_block_address[i], auto_block_values[i])
        end
    end
    if infinite_gauge_enabled then
        for i = 1, #infinite_gauge_address do
            memory.writebyte(infinite_gauge_address[i], infinite_gauge_values[i])
        end
    end
    if infinite_energy_enabled then
        memory.writebyte(infinite_energy_address, infinite_energy_value)
    end
    if special_super_enabled then
        memory.writebyte(special_super_address, special_super_value)
    end
    emu.frameadvance()
end
