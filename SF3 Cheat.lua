---------------------------------------------------------------
--  SFIII: 3rd Strike Cyber Trainer (Polished UI Edition)
--
--  Addresses verified against:
--   * FBNeo official cheat file  (finalburnneo/FBNeo-cheats, sfiii3n.ini)
--   * Grouflon/3rd_training_lua  (src/gamestate.lua, memory_adresses.lua)
--   * peon2/fbneo-training-mode  (games/sfiii3/sfiii3.lua)
---------------------------------------------------------------

local memory = require("memory")
if not memory then
    print("Memory library unavailable. Must run in Fightcade FBNeo.")
    return
end

-- bit.bor with pure-Lua fallback if the library is missing
local bit = bit
local function safe_bor(a, b)
    if bit then return bit.bor(a, b) end
    local r, m = 0, 1
    while a > 0 or b > 0 do
        if (a % 2) + (b % 2) > 0 then r = r + m end
        a, b, m = math.floor(a/2), math.floor(b/2), m*2
    end
    return r
end

---------------------------------------------------------------
-- COLORS  (0xFFRRGGBB integers — FBNeo does not accept "#RRGGBB" strings)
---------------------------------------------------------------
local COLOR_BG        = 0xFF001820
local COLOR_BORDER    = 0xFF00E5FF
local COLOR_BORDER_DIM= 0xFF0088AA
local COLOR_TITLE_BAR = 0xFF002833
local COLOR_HIGHLIGHT1= 0xFF004860
local COLOR_HIGHLIGHT2= 0xFF007A99
local COLOR_TAB_ACTIVE= 0xFF00E5FF
local COLOR_TAB_INACT = 0xFF4C6E7A
local COLOR_FOOTER_BG = 0xFF001015
local COLOR_ACTIVE    = 0xFFFF6060
local COLOR_TEXT      = 0xFFE0F8FF
local COLOR_STATUS    = 0xFF7FE8FF

---------------------------------------------------------------
-- UI CONFIG
---------------------------------------------------------------
local MAX_VISIBLE = 14      -- max items before scroll
local ROW_HEIGHT  = 11      -- compact row spacing
local MENU_WIDTH = 280     -- slimmer, cleaner
local MENU_X_HIDDEN = -260
local MENU_X_SHOWN  = 5

---------------------------------------------------------------
-- SAFE MEMORY ACCESS
---------------------------------------------------------------
local function write(addr, val)
    return pcall(memory.writebyte, addr, val)
end

local function read(addr)
    local ok, v = pcall(memory.readbyte, addr)
    if ok then return v end
    return nil
end

---------------------------------------------------------------
-- OPTION LIST BUILDERS
-- Every option list starts with "Disabled", which writes nothing.
---------------------------------------------------------------
local function disabled_option()
    return {name="Disabled", address={}, values={}}
end

-- One option per value; each writes that value to every address in addrs.
-- labels maps a value to a custom display name.
local function value_options(addrs, list, labels)
    local t = {disabled_option()}
    for _, v in ipairs(list) do
        local vals = {}
        for i = 1, #addrs do vals[i] = v end
        local name = (labels and labels[v]) or tostring(v)
        table.insert(t, {name=name, address=addrs, values=vals})
    end
    return t
end

local function range(from, to, extra)
    local t = {}
    for i = from, to do t[#t+1] = i end
    for _, e in ipairs(extra or {}) do t[#t+1] = e end
    return t
end

-- Character IDs (confirmed by FBNeo cheat file and the user's memory sheet)
local CHARACTER_IDS = {
    {"Alex",0x01}, {"Ryu",0x02}, {"Yun",0x03}, {"Dudley",0x04},
    {"Necro",0x05}, {"Hugo",0x06}, {"Ibuki",0x07}, {"Elena",0x08},
    {"Oro",0x09}, {"Yang",0x0A}, {"Ken",0x0B}, {"Sean",0x0C},
    {"Urien",0x0D}, {"Akuma",0x0E}, {"Chun-Li",0x10}, {"Makoto",0x11},
    {"Q",0x12}, {"Twelve",0x13}, {"Remy",0x14},
}

-- id_addr: character id, col/row: character select cursor (needed for Gill/Shin)
local function character_options(id_addr, col_addr, row_addr)
    local t = {disabled_option()}
    for _, c in ipairs(CHARACTER_IDS) do
        table.insert(t, {name=c[1], address={id_addr}, values={c[2]}})
    end
    table.insert(t, {name="Gill",       address={col_addr,row_addr,id_addr}, values={0x03,0x01,0x00}})
    table.insert(t, {name="Shin Akuma", address={col_addr,row_addr,id_addr}, values={0x00,0x06,0x0F}})
    -- Unused IDs from the memory sheet; not playable characters
    table.insert(t, {name="CAR (may crash)",   address={id_addr}, values={0x15}})
    table.insert(t, {name="BBALL (may crash)", address={id_addr}, values={0x16}})
    return t
end

local function colour_options(addr)
    local t = {disabled_option()}
    for i, n in ipairs({"LP","MP","HP","LK","MK","HK","EX"}) do
        table.insert(t, {name=n, address={addr}, values={i-1}})
    end
    return t
end

local function super_art_options(addr)
    return {
        disabled_option(),
        {name="SA-1", address={addr}, values={0x00}},
        {name="SA-2", address={addr}, values={0x01}},
        {name="SA-3", address={addr}, values={0x02}},
    }
end

local function stun_status_options(addr)
    return {
        disabled_option(),
        {name="Always Stunned", address={addr}, values={0x60}},
        {name="Never Stunned",  address={addr}, values={0x00}},
    }
end

local STUN_BAR_LABELS = {[0x38]="56 (Small)", [0x40]="64 (Medium)", [0x48]="72 (Large)"}
local function stun_bar_options(addr)
    local list = {}
    for v = 8, 96, 8 do list[#list+1] = v end
    return value_options({addr}, list, STUN_BAR_LABELS)
end

local STUN_RECOVERY_LABELS = {[10]="10 (IB OR YA YU)", [11]="11 (most chars)", [12]="12 (HU MA RE UR)"}
local function stun_recovery_options(addr)
    return value_options({addr}, range(0, 30, {35, 40, 45, 50, 255}), STUN_RECOVERY_LABELS)
end

local function bonus_options(addr, labels)
    return value_options({addr}, range(1, 32, {255}), labels)
end

-- Facing byte is the object's flip_x at base+0xA: 0 = facing left, 1 = facing right
local function direction_options(addr)
    return {
        disabled_option(),
        {name="Face Right", address={addr}, values={0x01}},
        {name="Face Left",  address={addr}, values={0x00}},
    }
end

local function max_stock_options(addrs)
    return value_options(addrs, {1, 2, 3}, {[1]="1 Stock", [2]="2 Stocks", [3]="3 Stocks"})
end

-- Universal cancel options carry a plain value; they are OR'd per address.
local function cancel_options_1()
    return {
        {name="Disabled",                value=0x00},
        {name="Special",                 value=0x20},
        {name="Super",                   value=0x40},
        {name="Special + Super",         value=0x60},
        {name="Crazy Cancel",            value=0x10},
        {name="Special+Super+Crazy",     value=0xC0},
    }
end

local function cancel_options_2()
    return {
        {name="Disabled",                value=0x00},
        {name="Super Jump",              value=0x01},
        {name="Dash",                    value=0x02},
        {name="Normals",                 value=0x04},
        {name="Allow Chains",            value=0x08},
        {name="SJump + Dash",            value=0x03},
        {name="SJump + Normals",         value=0x05},
        {name="SJump + Chains",          value=0x09},
        {name="Dash + Normals",          value=0x06},
        {name="Dash + Chains",           value=0x0A},
        {name="SJump + Dash + Normals",  value=0x07},
        {name="SJump + Dash + Chains",   value=0x0B},
        {name="Dash + Normals + Chains", value=0x0E},
        {name="All",                     value=0x0F},
    }
end

-- Keeps super stocks at the character's max (Grouflon's refill logic):
-- master count, slave count, max count, and the HUD update flag.
local function fill_stocks(master, slave, max_addr, update_flag)
    local max = read(max_addr)
    if not max or max == 0 then return end
    if read(master) ~= max and read(slave) ~= max then
        write(master, max)
        write(update_flag, 0x01)
    end
end

-- Charge-move gauges are words at base + {0x00,0x1C,0x38,0x54,0x70}; 0xFFFF = fully charged
local function charge_addresses(base)
    local t = {}
    for _, off in ipairs({0x00, 0x1C, 0x38, 0x54, 0x70}) do
        t[#t+1] = base + off
        t[#t+1] = base + off + 1
    end
    return t
end

local function filled(n, v)
    local t = {}
    for i = 1, n do t[i] = v end
    return t
end

local CHARGE_P1 = charge_addresses(0x020259D8)
local CHARGE_P2 = charge_addresses(0x02025FF8)

---------------------------------------------------------------
-- CHEAT DEFINITIONS
--   toggle:   address + values (+ default_values written when switched off)
--   function: on_frame, run every frame while enabled
--   selector: options (first entry "Disabled" writes nothing)
--   cancel:   uc_addr + options with value (OR'd together per address)
---------------------------------------------------------------
local cheats = {

    -----------------------------------------------------------
    -- P1 TAB
    -----------------------------------------------------------
    { name="Infinite Energy PL1", category="P1",
      address={0x2068D0B}, values={0xA0}, default_values={0x00}, enabled=false },
    { name="Drain All Energy PL1", category="P1",
      address={0x2068D0B}, values={0x00}, default_values={0xA0}, enabled=false },
    { name="Infinite Power PL1", category="P1",
      address={0x20695B5}, values={0xA0}, default_values={0x00}, enabled=false },
    { name="Infinite Gauge PL1", category="P1", enabled=false,
      on_frame=function() fill_stocks(0x20695BF, 0x20286AB, 0x20695BD, 0x20157C8) end },
    { name="Max Super Stocks PL1", category="P1", selected_option=1,
      options=max_stock_options({0x20695BB, 0x20695BD}) },

    { name="Select Stun Status PL1", category="P1", selected_option=1,
      options=stun_status_options(0x20695FD) },
    { name="Stun Bar Length PL1", category="P1", selected_option=1,
      options=stun_bar_options(0x20695F7) },
    { name="Stun Recovery Rate PL1", category="P1", selected_option=1,
      options=stun_recovery_options(0x2069602) },

    { name="No Combo Damage Reduction PL1", category="P1",
      address={0x206903E}, values={0x00}, default_values={0x00}, enabled=false },
    { name="Semi Infinite Juggle PL1", category="P1",
      address={0x2069031}, values={0x00}, default_values={0x00}, enabled=false },
    { name="True Infinite Juggle PL1", category="P1",
      address={0x206902E}, values={0x00}, default_values={0x00}, enabled=false },
    { name="Infinite Fireballs PL1", category="P1",
      address={0x2068FB8}, values={0xFF}, default_values={0x00}, enabled=false },
    { name="Infinite Charge Moves PL1", category="P1",
      address=CHARGE_P1, values=filled(#CHARGE_P1, 0xFF),
      default_values=filled(#CHARGE_P1, 0x00), enabled=false },

    { name="Bonus Damage PL1", category="P1", selected_option=1,
      options=bonus_options(0x20690A7, {[14]="14 (Akuma)"}) },
    { name="Bonus Stun PL1", category="P1", selected_option=1,
      options=bonus_options(0x20690AB, {[9]="9 (Akuma)"}) },
    { name="Bonus Defense PL1", category="P1", selected_option=1,
      options=bonus_options(0x20690AD) },

    { name="Direction Lock PL1", category="P1", selected_option=1,
      options=direction_options(0x2068C76) },

    { name="Select Character PL1", category="P1", selected_option=1,
      options=character_options(0x2011387, 0x201566B, 0x20154CF) },
    { name="Select Super Art PL1", category="P1", selected_option=1,
      options=super_art_options(0x201138B) },
    { name="Select Colour PL1", category="P1", selected_option=1,
      options=colour_options(0x2015683) },

    -----------------------------------------------------------
    -- P2 TAB
    -----------------------------------------------------------
    { name="Infinite Energy PL2", category="P2",
      address={0x20691A3}, values={0xA0}, default_values={0x00}, enabled=false },
    { name="Drain All Energy PL2", category="P2",
      address={0x20691A3}, values={0x00}, default_values={0xA0}, enabled=false },
    { name="Infinite Power PL2", category="P2",
      address={0x20695E1}, values={0xA0}, default_values={0x00}, enabled=false },
    { name="Infinite Gauge PL2", category="P2", enabled=false,
      on_frame=function() fill_stocks(0x20695EB, 0x20286DF, 0x20695E9, 0x20157C9) end },
    { name="Max Super Stocks PL2", category="P2", selected_option=1,
      options=max_stock_options({0x20695E7, 0x20695E9}) },

    { name="Select Stun Status Enemy", category="P2", selected_option=1,
      options=stun_status_options(0x2069611) },
    { name="Stun Bar Length PL2", category="P2", selected_option=1,
      options=stun_bar_options(0x206960B) },
    { name="Stun Recovery Rate PL2", category="P2", selected_option=1,
      options=stun_recovery_options(0x2069616) },

    { name="No Combo Damage Reduction PL2", category="P2",
      address={0x20694D6}, values={0x00}, default_values={0x00}, enabled=false },
    { name="Semi Infinite Juggle PL2", category="P2",
      address={0x20694C9}, values={0x00}, default_values={0x00}, enabled=false },
    { name="True Infinite Juggle PL2", category="P2",
      address={0x20694C6}, values={0x00}, default_values={0x00}, enabled=false },
    { name="Infinite Fireballs PL2", category="P2",
      address={0x2069450}, values={0xFF}, default_values={0x00}, enabled=false },
    { name="Infinite Charge Moves PL2", category="P2",
      address=CHARGE_P2, values=filled(#CHARGE_P2, 0xFF),
      default_values=filled(#CHARGE_P2, 0x00), enabled=false },

    { name="Bonus Damage PL2", category="P2", selected_option=1,
      options=bonus_options(0x206953F, {[14]="14 (Akuma)"}) },
    { name="Bonus Stun PL2", category="P2", selected_option=1,
      options=bonus_options(0x2069543, {[9]="9 (Akuma)"}) },
    { name="Bonus Defense PL2", category="P2", selected_option=1,
      options=bonus_options(0x2069545) },

    { name="Direction Lock PL2", category="P2", selected_option=1,
      options=direction_options(0x206910E) },

    { name="Select Character PL2", category="P2", selected_option=1,
      options=character_options(0x2011388, 0x201566D, 0x20154D1) },
    { name="Select Super Art PL2", category="P2", selected_option=1,
      options=super_art_options(0x201138C) },
    { name="Select Colour PL2", category="P2", selected_option=1,
      options=colour_options(0x2015684) },

    -----------------------------------------------------------
    -- SYSTEM TAB
    -----------------------------------------------------------
    -- No default_values: switching these off leaves the game's value alone
    { name="Infinite Credits", category="System",
      address={0x2007CE0}, values={0x09}, enabled=false },
    { name="Infinite Match Time", category="System",
      address={0x2011377}, values={0x63}, enabled=true },
    { name="Infinite Selection Time", category="System",
      address={0x20154FB}, values={0x99}, enabled=true },
    { name="Finish This Round Now", category="System",
      address={0x2011377}, values={0x01}, default_values={0x63}, enabled=false },
    { name="Pause Game", category="System",
      address={0x201136F}, values={0xFF}, default_values={0x00}, enabled=false },

    { name="Stage Select", category="System", selected_option=1,
      options={
          disabled_option(),
          {name="Alex",       address={0x2026BB0}, values={0x01}},
          {name="Ryu",        address={0x2026BB0}, values={0x02}},
          {name="Yun",        address={0x2026BB0}, values={0x03}},
          {name="Dudley",     address={0x2026BB0}, values={0x04}},
          {name="Necro",      address={0x2026BB0}, values={0x05}},
          {name="Hugo",       address={0x2026BB0}, values={0x06}},
          {name="Ibuki",      address={0x2026BB0}, values={0x07}},
          {name="Elena",      address={0x2026BB0}, values={0x08}},
          {name="Oro",        address={0x2026BB0}, values={0x09}},
          {name="Yang",       address={0x2026BB0}, values={0x0A}},
          {name="Ken",        address={0x2026BB0}, values={0x0B}},
          {name="Sean",       address={0x2026BB0}, values={0x0C}},
          {name="Urien",      address={0x2026BB0}, values={0x0D}},
          {name="Akuma",      address={0x2026BB0}, values={0x0E}},
          {name="Shin Akuma", address={0x2026BB0}, values={0x0F}},
          {name="Chun-Li",    address={0x2026BB0}, values={0x10}},
          {name="Makoto",     address={0x2026BB0}, values={0x11}},
          {name="Q (Dudley stage)", address={0x2026BB0}, values={0x12}},
          {name="Twelve",     address={0x2026BB0}, values={0x13}},
          {name="Remy",       address={0x2026BB0}, values={0x14}},
          {name="Gill",       address={0x2026BB0}, values={0x00}},
      } },

    -- Game stores volume * 8; 10 is the normal level
    { name="Music Volume", category="System", selected_option=1,
      options=value_options({0x2078D06}, {0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0x40, 0x48, 0x50},
          {[0x00]="Mute", [0x08]="1", [0x10]="2", [0x18]="3", [0x20]="4", [0x28]="5",
           [0x30]="6", [0x38]="7", [0x40]="8", [0x48]="9", [0x50]="10 (Normal)"}) },

    { name="Screen X Lock", category="System",
      address={0x2026CB1}, values={0x10}, default_values={0x00}, enabled=false },

    { name="Select Region", category="System", selected_option=1,
      options={
          disabled_option(),
          {name="Japan",    address={0x001FECB}, values={0x01}},
          {name="Asia",     address={0x001FECB}, values={0x02}},
          {name="Europe",   address={0x001FECB}, values={0x03}},
          {name="USA",      address={0x001FECB}, values={0x04}},
          {name="Hispanic", address={0x001FECB}, values={0x05}},
          {name="Brazil",   address={0x001FECB}, values={0x06}},
          {name="Oceania",  address={0x001FECB}, values={0x07}},
      } },

    -----------------------------------------------------------
    -- PARRY TAB  (P2 parry block is P1 + 0x406)
    -----------------------------------------------------------
    { name="Auto Blocking PL1", category="Parry",
      address={0x2026335,0x2026337,0x2026339,0x2026346}, values={0x06,0x06,0x06,0x06},
      default_values={0,0,0,0}, enabled=false },
    { name="Auto Parry High PL1", category="Parry",
      address={0x2026335}, values={0x0A}, default_values={0x00}, enabled=false },
    { name="Auto Parry Low PL1", category="Parry",
      address={0x2026337}, values={0x0A}, default_values={0x00}, enabled=false },
    { name="Auto Anti-Air Parry PL1", category="Parry",
      address={0x2026347}, values={0x0A}, default_values={0x00}, enabled=false },
    { name="Auto Air Parry PL1", category="Parry",
      address={0x2026339}, values={0x0A}, default_values={0x00}, enabled=false },
    { name="Auto Grab Tech PL1", category="Parry",
      address={0x2026328}, values={0x01}, default_values={0x00}, enabled=false },

    { name="Auto Blocking PL2", category="Parry",
      address={0x202673B,0x202673D,0x202673F,0x202674C}, values={0x06,0x06,0x06,0x06},
      default_values={0,0,0,0}, enabled=false },
    { name="Auto Parry High PL2", category="Parry",
      address={0x202673B}, values={0x0A}, default_values={0x00}, enabled=false },
    { name="Auto Parry Low PL2", category="Parry",
      address={0x202673D}, values={0x0A}, default_values={0x00}, enabled=false },
    { name="Auto Anti-Air Parry PL2", category="Parry",
      address={0x202674D}, values={0x0A}, default_values={0x00}, enabled=false },
    { name="Auto Air Parry PL2", category="Parry",
      address={0x202673F}, values={0x0A}, default_values={0x00}, enabled=false },
    { name="Auto Grab Tech PL2", category="Parry",
      address={0x202672E}, values={0x01}, default_values={0x00}, enabled=false },

    -----------------------------------------------------------
    -- UNIVERSAL TAB
    -----------------------------------------------------------
    { name="Universal Cancel #1 PL1", category="Universal", selected_option=1,
      uc_addr=0x2068E8D, options=cancel_options_1() },
    { name="Universal Cancel #2 PL1", category="Universal", selected_option=1,
      uc_addr=0x2068E8D, options=cancel_options_2() },
    { name="Universal Cancel #1 PL2", category="Universal", selected_option=1,
      uc_addr=0x2069325, options=cancel_options_1() },
    { name="Universal Cancel #2 PL2", category="Universal", selected_option=1,
      uc_addr=0x2069325, options=cancel_options_2() },
}

---------------------------------------------------------------
-- TAB + NAVIGATION SYSTEM
---------------------------------------------------------------
local tabs = {"P1","P2","System","Parry","Universal"}
local current_tab_index = 1
local current_cheat_index = 1

local menu_open   = true
local menu_target = 1.0
local menu_anim   = 1.0
local menu_speed  = 0.20

local input_counter = 0
local input_delay   = 10
local frame_counter = 0


local function visible_cheats()
    local tab = tabs[current_tab_index]
    local t = {}
    for _,c in ipairs(cheats) do
        if c.category == tab then
            table.insert(t,c)
        end
    end
    return t
end

local function clamp_selection(list)
    if #list == 0 then
        current_cheat_index = 1
        return
    end
    if current_cheat_index < 1 then current_cheat_index = 1 end
    if current_cheat_index > #list then current_cheat_index = #list end
end

---------------------------------------------------------------
-- OPTION / CHEAT APPLY HELPERS
---------------------------------------------------------------

-- When enabling a cheat, disable any other enabled cheat that writes
-- to the same address to avoid silent conflicts.
local function disable_conflicts(target)
    if not target.address then return end
    for _, c in ipairs(cheats) do
        if c ~= target and c.enabled and c.address then
            local hit = false
            for _, ta in ipairs(target.address) do
                for _, ca in ipairs(c.address) do
                    if ca == ta then hit = true break end
                end
                if hit then break end
            end
            if hit then
                c.enabled = false
                if c.default_values then
                    for i = 1, #c.address do
                        write(c.address[i], c.default_values[i] or 0)
                    end
                end
            end
        end
    end
end

local function toggle_cheat(c)
    if c.on_frame then
        c.enabled = not c.enabled
        return
    end
    if not c.address or not c.values then return end
    c.enabled = not c.enabled
    if c.enabled then disable_conflicts(c) end
    local src = c.enabled and c.values or c.default_values
    if not src then return end
    for i=1,#c.address do
        write(c.address[i], src[i] or 0)
    end
end

local function apply_normal_cheat(c)
    if not c.enabled then return end
    if c.on_frame then
        pcall(c.on_frame)
        return
    end
    if not c.address or not c.values then return end
    for i=1,#c.address do
        write(c.address[i], c.values[i] or 0)
    end
end

local function apply_option_cheat(c)
    local o = c.options[c.selected_option or 1]
    if not o or not o.address then return end
    for i=1,#o.address do
        write(o.address[i], o.values[i])
    end
end

local function select_option(c, idx)
    c.selected_option = idx
    if not c.uc_addr then apply_option_cheat(c) end
end

local function is_active(c)
    if c.options then return (c.selected_option or 1) ~= 1 end
    return c.enabled
end

---------------------------------------------------------------
-- UNIVERSAL CANCEL BITWISE COMBINE
-- Both selectors for a player share one byte, so their values are OR'd.
-- When both go back to Disabled the byte is cleared once, then left alone.
---------------------------------------------------------------
local uc_written = {}

local function apply_universal_cancel()
    local combined = {}
    for _, c in ipairs(cheats) do
        if c.uc_addr then
            local o = c.options[c.selected_option or 1]
            combined[c.uc_addr] = safe_bor(combined[c.uc_addr] or 0, (o and o.value) or 0)
        end
    end
    for addr, v in pairs(combined) do
        if v ~= 0 then
            write(addr, v)
            uc_written[addr] = true
        elseif uc_written[addr] then
            write(addr, 0)
            uc_written[addr] = nil
        end
    end
end

---------------------------------------------------------------
-- INPUT HANDLING
---------------------------------------------------------------
local function handle_input()
    local inp = input.get()
    if not inp then return end
    input_counter = input_counter + 1

    -- Toggle menu (M)
    if input_counter > input_delay and inp.M then
        menu_open  = not menu_open
        menu_target = menu_open and 1 or 0
        input_counter = 0
        return
    end

    if not menu_open then return end
    if input_counter <= input_delay then return end

    -- Tab switching
    if inp.Q then
        current_tab_index = (current_tab_index - 2 + #tabs) % #tabs + 1
        current_cheat_index = 1
        input_counter = 0
        return
    elseif inp.E then
        current_tab_index = (current_tab_index % #tabs) + 1
        current_cheat_index = 1
        input_counter = 0
        return
    end

    local list = visible_cheats()
    clamp_selection(list)
    local c = list[current_cheat_index]
    if not c then return end

    -- Scroll list
    if inp.down then
        current_cheat_index = (current_cheat_index % #list) + 1
        input_counter = 0
        return
    elseif inp.up then
        current_cheat_index = (current_cheat_index - 2 + #list) % #list + 1
        input_counter = 0
        return
    end

    -- Adjust values
    if inp.left or inp.right then
        if c.options then
            local dir = inp.right and 1 or -1
            local total = #c.options
            local idx = (((c.selected_option or 1) - 1 + dir + total) % total) + 1
            select_option(c, idx)
        else
            toggle_cheat(c)
        end

        input_counter = 0
        return
    end
end

---------------------------------------------------------------
-- DRAW MENU (auto size + scroll + compact layout)
---------------------------------------------------------------
local function draw_menu()
    -- animation
    menu_anim = menu_anim + (menu_target - menu_anim) * menu_speed
    if menu_anim < 0.001 then menu_anim = 0 end
    if menu_anim > 0.999 then menu_anim = 1 end

    local x = MENU_X_HIDDEN + (MENU_X_SHOWN - MENU_X_HIDDEN) * menu_anim
    frame_counter = (frame_counter + 1) % 60

    if menu_anim <= 0 then
        gui.text(10, 10, "Press M for Cyber Trainer", COLOR_BORDER)
        return
    end

    local list = visible_cheats()
    clamp_selection(list)

    -- adaptive height
    local visible_count = math.min(#list, MAX_VISIBLE)
    local menu_height = 60 + (visible_count * ROW_HEIGHT)

    local y = 5

    -- outer box + inner panel (gui.line not available in all FBNeo builds)
    gui.box(x, y, x+MENU_WIDTH, y+menu_height, COLOR_BG, COLOR_BORDER_DIM)
    gui.box(x+2, y+2, x+MENU_WIDTH-2, y+menu_height-2, COLOR_BG, COLOR_BORDER)

    -- title bar (smaller now)
    gui.box(x+4, y+3, x+MENU_WIDTH-4, y+15, COLOR_TITLE_BAR, COLOR_BORDER)
    gui.text(x+10, y+5, "SF3 Cyber Trainer", COLOR_BORDER)
    gui.text(x+MENU_WIDTH-70, y+5, "[M] Hide", 0xFF80F5FF)

    -- tabs
    local tab_y = y + 19
    local tx = x + 10
    for i, name in ipairs(tabs) do
        local active_tab = (i == current_tab_index)
        local label = active_tab and (">"..name.."<") or name
        local color = active_tab and COLOR_TAB_ACTIVE or COLOR_TAB_INACT
        gui.text(tx, tab_y, label, color)
        tx = tx + (#label * 4 + 12)
    end

    -- cheat list w/ scroll
    local base_y = y + 30
    local pulse_on = (frame_counter % 30) < 15
    local highlight_color = pulse_on and COLOR_HIGHLIGHT2 or COLOR_HIGHLIGHT1

    local total = #list
    local half  = math.floor(MAX_VISIBLE / 2)
    local start_index = math.max(1, current_cheat_index - half)
    local end_index   = math.min(total, start_index + MAX_VISIBLE - 1)

    if end_index - start_index < MAX_VISIBLE - 1 then
        start_index = math.max(1, end_index - MAX_VISIBLE + 1)
    end

    for i = start_index, end_index do
        local c = list[i]
        local row_y = base_y + ((i - start_index) * ROW_HEIGHT)

        -- highlight
        if i == current_cheat_index then
            gui.box(x+6, row_y-1, x+MENU_WIDTH-6, row_y+ROW_HEIGHT+1, highlight_color, 0x00000000)
        end

        -- status
        local status
        if c.options then status = c.options[c.selected_option or 1].name
        elseif c.enabled then status = "On"
        else status = "Off" end

        gui.text(x+10, row_y, c.name, is_active(c) and COLOR_ACTIVE or COLOR_TEXT)
        gui.text(x+MENU_WIDTH-120, row_y, status, COLOR_STATUS)
    end

    -- scroll bar (minimal)
    if #list > MAX_VISIBLE then
        local bar_x = x + MENU_WIDTH - 4
        local bar_y1 = base_y
        local bar_y2 = base_y + (MAX_VISIBLE * ROW_HEIGHT)

        gui.box(bar_x-1, bar_y1, bar_x+1, bar_y2, 0xFF004466, 0xFF004466)

        local pos = (current_cheat_index - 1) / (#list - 1)
        local handle_y = bar_y1 + pos * (MAX_VISIBLE * ROW_HEIGHT - 6)

        gui.box(bar_x-1, handle_y, bar_x+1, handle_y+6, 0xFF00E5FF, 0xFF00AACC)
    end

    gui.box(x+4, y+menu_height-14, x+MENU_WIDTH-4, y+menu_height-3, COLOR_FOOTER_BG, COLOR_BORDER_DIM)
    gui.text(x+10, y+menu_height-12, "Up/Down Select  Left/Right Change  Q/E Tabs", COLOR_STATUS)
end

---------------------------------------------------------------
-- MAIN LOOP
---------------------------------------------------------------
while true do
    handle_input()

    for _, c in ipairs(cheats) do
        if c.uc_addr then
            -- handled by apply_universal_cancel
        elseif c.options then
            apply_option_cheat(c)
        else
            apply_normal_cheat(c)
        end
    end

    apply_universal_cancel()
    draw_menu()
    emu.frameadvance()
end
