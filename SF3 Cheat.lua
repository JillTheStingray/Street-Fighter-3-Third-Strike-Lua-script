---------------------------------------------------------------
--  SFIII: 3rd Strike Cyber Trainer (Polished UI Edition)
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

---------------------------------------------------------------
-- UI CONFIG
---------------------------------------------------------------
local MAX_VISIBLE = 14      -- max items before scroll
local ROW_HEIGHT  = 11      -- compact row spacing
local MENU_WIDTH = 280     -- slimmer, cleaner
local MENU_X_HIDDEN = -260
local MENU_X_SHOWN  = 5

---------------------------------------------------------------
-- WRITE SAFE
---------------------------------------------------------------
local function write(addr, val)
    return pcall(memory.writebyte, addr, val)
end

---------------------------------------------------------------
-- CHEAT DEFINITIONS
-- (Your full cheat list + added cheats, categorized cleanly)
---------------------------------------------------------------
local cheats = {

    -----------------------------------------------------------
    -- PLAYER TAB
    -----------------------------------------------------------

    {
        name = "Infinite Power PL1",
        category = "Player",
        address = {0x20695B5},
        values = {0xA0},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Infinite Gauge PL1",
        category = "Player",
        address = {0x20695B5, 0x20695BE},
        values = {0xA0, 0x03},
        default_values = {0x00, 0x00},
        enabled = false
    },
    {
        name = "Infinite Energy PL1",
        category = "Player",
        address = {0x2068D0B},
        values = {0xA0},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Drain All Energy PL1",
        category = "Player",
        address = {0x2068D0B},
        values = {0x00},
        default_values = {0xA0},
        enabled = false
    },

    {
        name = "No Combo Damage Reduction PL1",
        category = "Player",
        address = {0x20694D6},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Semi Infinite Juggle PL1",
        category = "Player",
        address = {0x20694C9},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "True Infinite Juggle PL1",
        category = "Player",
        address = {0x20694C6},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },

    -- Global juggle versions from your list
    {
        name = "Semi Infinite Juggle (Global)",
        category = "Player",
        address = {0x2069031},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "True Infinite Juggle (Global)",
        category = "Player",
        address = {0x206902E},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },

    {
        name = "Select Stun Status Enemy",
        category = "Player",
        address = {0x2069611},
        values = {0x60},
        default_values = {0x00},
        enabled = false
    },

    -- Stun Bar Length PL1 (from your cheat list)
    {
        name = "Stun Bar Length PL1",
        category = "Player",
        selected_option = 1,
        options = {
            {name="Disabled", address={}, values={}},
            {name="Small",    address={0x20695F7}, values={0x38}},
            {name="Medium",   address={0x20695F7}, values={0x40}},
            {name="Large",    address={0x20695F7}, values={0x48}},
        }
    },

    {
        name = "Stun Bar Length PL2",
        category = "Player",
        selected_option = 1,
        options = {
            {name="Disabled", address={}, values={}},
            {name="Small",    address={0x0206960B}, values={0x38}},
            {name="Medium",   address={0x0206960B}, values={0x40}},
            {name="Large",    address={0x0206960B}, values={0x48}},
        }
    },

    {
        name = "Stun Recovery Rate PL1",
        category = "Player",
        selected_option = 1,
        options = {
            {name="Disabled", address={}, values={}},
            {name="Slow",     address={0x2069602}, values={0x0A}},
            {name="Medium",   address={0x2069602}, values={0x0B}},
            {name="Fast",     address={0x2069602}, values={0x0C}},
        }
    },

    {
        name = "Stun Recovery Rate PL2",
        category = "Player",
        selected_option = 1,
        options = {
            {name="Disabled", address={}, values={}},
            {name="Slow",     address={0x2069616}, values={0x0A}},
            {name="Medium",   address={0x2069616}, values={0x0B}},
            {name="Fast",     address={0x2069616}, values={0x0C}},
        }
    },

    -------------------------------------------------------------------
    -- PLAYER 2 CHEATS
    -------------------------------------------------------------------

    {
        name = "Infinite Energy PL2",
        category = "Player",
        address = {0x020691A3},
        values = {0xA0},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Drain All Energy PL2",
        category = "Player",
        address = {0x020691A3},
        values = {0x00},
        default_values = {0xA0},
        enabled = false
    },
    {
        name = "Infinite Power PL2",
        category = "Player",
        address = {0x020695E1},
        values = {0xA0},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Infinite Gauge PL2",
        category = "Player",
        address = {0x020695E1, 0x020695EB},
        values = {0xA0, 0x03},
        default_values = {0x00, 0x00},
        enabled = false
    },
    {
        name = "No Combo Damage Reduction PL2",
        category = "Player",
        address = {0x206953E},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Semi Infinite Juggle PL2",
        category = "Player",
        address = {0x2069531},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "True Infinite Juggle PL2",
        category = "Player",
        address = {0x206952E},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },

    -- Fills all charge-move gauges (Urien, Remy, Chun-Li, Q, Oro, Alex)
    {
        name = "Infinite Charge Moves PL1",
        category = "Player",
        address = {0x020259D8, 0x020259F4, 0x02025A10, 0x02025A2C, 0x02025A48},
        values = {0x7F, 0x7F, 0x7F, 0x7F, 0x7F},
        default_values = {0x00, 0x00, 0x00, 0x00, 0x00},
        enabled = false
    },
    {
        name = "Infinite Charge Moves PL2",
        category = "Player",
        address = {0x02025FF8, 0x02026014, 0x02026030, 0x0202604C, 0x02026068},
        values = {0x7F, 0x7F, 0x7F, 0x7F, 0x7F},
        default_values = {0x00, 0x00, 0x00, 0x00, 0x00},
        enabled = false
    },

    {
        name = "Stun PL1 Now",
        category = "Player",
        address = {0x020695FD},
        values = {0x60},
        default_values = {0x00},
        enabled = false
    },

    {
        name = "Direction Lock PL1",
        category = "Player",
        selected_option = 1,
        options = {
            {name="Disabled",   address={}, values={}},
            {name="Face Right", address={0x2068C76}, values={0x01}},
            {name="Face Left",  address={0x2068C76}, values={0x02}},
        }
    },
    {
        name = "Direction Lock PL2",
        category = "Player",
        selected_option = 1,
        options = {
            {name="Disabled",   address={}, values={}},
            {name="Face Right", address={0x2068C77}, values={0x01}},
            {name="Face Left",  address={0x2068C77}, values={0x02}},
        }
    },

    {
        name = "Max Bar Size PL1",
        category = "Player",
        selected_option = 1,
        options = {
            {name="Disabled", address={}, values={}},
            {name="x1 Bar",   address={0x20695B3}, values={0x80}},
            {name="x2 Bars",  address={0x20695B3}, values={0xA0}},
            {name="x3 Bars",  address={0x20695B3}, values={0xC0}},
        }
    },
    {
        name = "Max Bar Size PL2",
        category = "Player",
        selected_option = 1,
        options = {
            {name="Disabled", address={}, values={}},
            {name="x1 Bar",   address={0x20695DF}, values={0x80}},
            {name="x2 Bars",  address={0x20695DF}, values={0xA0}},
            {name="x3 Bars",  address={0x20695DF}, values={0xC0}},
        }
    },

    {
        name = "Infinite Fireballs",
        category = "Player",
        address = {0x2068FB8},
        values = {0xFF},
        default_values = {0x00},
        enabled = false
    },

    {
        name = "No Combo Damage Reduction (Global)",
        category = "Player",
        address = {0x206903E},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },

    -------------------------------------------------------------------
    -- Character + SA + Color Select
    -------------------------------------------------------------------
    {
        name = "Select Character PL1",
        category = "Player",
        selected_character = 1,
        characters = {
            {name="Disabled", address={0x2011387}, values={0x00}},
            {name="Alex",     address={0x2011387}, values={0x01}},
            {name="Ryu",      address={0x2011387}, values={0x02}},
            {name="Yun",      address={0x2011387}, values={0x03}},
            {name="Dudley",   address={0x2011387}, values={0x04}},
            {name="Necro",    address={0x2011387}, values={0x05}},
            {name="Hugo",     address={0x2011387}, values={0x06}},
            {name="Ibuki",    address={0x2011387}, values={0x07}},
            {name="Elena",    address={0x2011387}, values={0x08}},
            {name="Oro",      address={0x2011387}, values={0x09}},
            {name="Yang",     address={0x2011387}, values={0x0A}},
            {name="Ken",      address={0x2011387}, values={0x0B}},
            {name="Sean",     address={0x2011387}, values={0x0C}},
            {name="Urien",    address={0x2011387}, values={0x0D}},
            {name="Akuma",    address={0x2011387}, values={0x0E}},
            {name="Chun-Li",  address={0x2011387}, values={0x10}},
            {name="Makoto",   address={0x2011387}, values={0x11}},
            {name="Q",        address={0x2011387}, values={0x12}},
            {name="Twelve",   address={0x2011387}, values={0x13}},
            {name="Remy",     address={0x2011387}, values={0x14}},
            {name="Gill",     address={0x201566B,0x20154CF,0x2011387}, values={0x03,0x01,0x00}},
            {name="Shin Akuma/SUV", address={0x201566B,0x20154CF,0x2011387}, values={0x00,0x06,0x0F}},
        }
    },

    {
        name = "Select Character PL2",
        category = "Player",
        selected_character = 1,
        characters = {
            {name="Disabled",       address={0x2011389}, values={0x00}},
            {name="Alex",           address={0x2011389}, values={0x01}},
            {name="Ryu",            address={0x2011389}, values={0x02}},
            {name="Yun",            address={0x2011389}, values={0x03}},
            {name="Dudley",         address={0x2011389}, values={0x04}},
            {name="Necro",          address={0x2011389}, values={0x05}},
            {name="Hugo",           address={0x2011389}, values={0x06}},
            {name="Ibuki",          address={0x2011389}, values={0x07}},
            {name="Elena",          address={0x2011389}, values={0x08}},
            {name="Oro",            address={0x2011389}, values={0x09}},
            {name="Yang",           address={0x2011389}, values={0x0A}},
            {name="Ken",            address={0x2011389}, values={0x0B}},
            {name="Sean",           address={0x2011389}, values={0x0C}},
            {name="Urien",          address={0x2011389}, values={0x0D}},
            {name="Akuma",          address={0x2011389}, values={0x0E}},
            {name="Chun-Li",        address={0x2011389}, values={0x10}},
            {name="Makoto",         address={0x2011389}, values={0x11}},
            {name="Q",              address={0x2011389}, values={0x12}},
            {name="Twelve",         address={0x2011389}, values={0x13}},
            {name="Remy",           address={0x2011389}, values={0x14}},
            {name="Gill",           address={0x201566B,0x20154CF,0x2011389}, values={0x03,0x01,0x00}},
            {name="Shin Akuma/SUV", address={0x201566B,0x20154CF,0x2011389}, values={0x00,0x06,0x0F}},
        }
    },

    {
        name = "Select Super Art PL1",
        category = "Player",
        selected_super_art = 1,
        super_arts = {
            { name="Disabled", address=0x201138B, value=nil  },
            { name="SA-1",     address=0x201138B, value=0x00 },
            { name="SA-2",     address=0x201138B, value=0x01 },
            { name="SA-3",     address=0x201138B, value=0x02 },
        }
    },

    {
        name = "Select Super Art PL2",
        category = "Player",
        selected_super_art = 1,
        super_arts = {
            { name="Disabled", address=0x201138D, value=nil  },
            { name="SA-1",     address=0x201138D, value=0x00 },
            { name="SA-2",     address=0x201138D, value=0x01 },
            { name="SA-3",     address=0x201138D, value=0x02 },
        }
    },

    {
        name = "Select Colour PL1",
        category = "Player",
        selected_option = 1,
        options = {
            { name="Disabled", address={},          values={}     },
            { name="LP",       address={0x2015683}, values={0x00} },
            { name="MP",       address={0x2015683}, values={0x01} },
            { name="HP",       address={0x2015683}, values={0x02} },
            { name="LK",       address={0x2015683}, values={0x03} },
            { name="MK",       address={0x2015683}, values={0x04} },
            { name="HK",       address={0x2015683}, values={0x05} },
            { name="EX",       address={0x2015683}, values={0x06} },
        }
    },

    {
        name = "Select Bonus Damage PL1",
        category = "Player",
        selected_bonus_damage = 1,
        bonus_damage = (function()
            local t = {}
            for i=0,32 do
                table.insert(t,{ name=tostring(i), address={0x20690A7}, values={i} })
            end
            table.insert(t,{ name="255", address={0x20690A7}, values={0xFF} })
            return t
        end)()
    },


    -----------------------------------------------------------
    -- SYSTEM TAB
    -----------------------------------------------------------

    {
        name = "Infinite Credits",
        category = "System",
        address = {0x2007CE0},
        values = {0x09},
        default_values = {0x00},
        enabled = false
    },

    {
        name = "Infinite Match Time",
        category = "System",
        address = {0x2011377},
        values = {0x63},
        default_values = {0x00},
        enabled = true  -- your original default behavior
    },

    {
        name = "Infinite Selection Time",
        category = "System",
        address = {0x20154FB},
        values = {0x99},
        default_values = {0x00},
        enabled = true
    },

    {
        name = "Finish This Round Now",
        category = "System",
        address = {0x2011377},
        values = {0x01},
        default_values = {0x63},
        enabled = false
    },

    {
        name = "Stage Select",
        category = "System",
        selected_option = 1,
        options = {
            {name="Disabled", address={}, values={}},
            {name="Alex", address={0x2026BB0}, values={0x01}},
            {name="Ryu",  address={0x2026BB0}, values={0x02}},
            {name="Yun",  address={0x2026BB0}, values={0x03}},
            {name="Dudley", address={0x2026BB0}, values={0x04}},
            {name="Dudley (Q's Music)", address={0x2026BB0}, values={0x12}},
            {name="Necro", address={0x2026BB0}, values={0x05}},
            {name="Hugo", address={0x2026BB0}, values={0x06}},
            {name="Ibuki", address={0x2026BB0}, values={0x07}},
            {name="Elena", address={0x2026BB0}, values={0x08}},
            {name="Oro", address={0x2026BB0}, values={0x09}},
            {name="Chun Li", address={0x2026BB0}, values={0x10}},
            {name="Makoto", address={0x2026BB0}, values={0x11}},
            {name="Twelve", address={0x2026BB0}, values={0x13}},
            {name="Remy", address={0x2026BB0}, values={0x14}},
            {name="Yang", address={0x2026BB0}, values={0x0A}},
            {name="Ken", address={0x2026BB0}, values={0x0B}},
            {name="Sean", address={0x2026BB0}, values={0x0C}},
            {name="Urien", address={0x2026BB0}, values={0x0D}},
            {name="Akuma", address={0x2026BB0}, values={0x0E}},
            {name="Shin Akuma", address={0x2026BB0}, values={0x0F}},
            {name="Gill", address={0x2026BB0}, values={0x00}},
        }
    },

    {
        name = "No Background Music",
        category = "System",
        address = {0x2078D06},
        values = {0x00},
        default_values = {0x00},
        enabled = false
    },

    {
        name = "Set P1 Win Counter",
        category = "System",
        selected_option = 1,
        options = (function()
            local t = {{name="Disabled", address={}, values={}}}
            for i=0,9 do
                table.insert(t, {name=tostring(i), address={0x02011383}, values={i}})
            end
            return t
        end)()
    },

    {
        name = "Set P2 Win Counter",
        category = "System",
        selected_option = 1,
        options = (function()
            local t = {{name="Disabled", address={}, values={}}}
            for i=0,9 do
                table.insert(t, {name=tostring(i), address={0x02011385}, values={i}})
            end
            return t
        end)()
    },

    {
        name = "Screen X Lock",
        category = "System",
        address = {0x2026CB1},
        values = {0x10},
        default_values = {0x00},
        enabled = false
    },

    {
        name = "Select Region",
        category = "System",
        selected_option = 1,
        options = {
            {name="Disabled", address={}, values={}},
            {name="Japan",    address={0x001FECB}, values={0x01}},
            {name="Asia",     address={0x001FECB}, values={0x02}},
            {name="Europe",   address={0x001FECB}, values={0x03}},
            {name="USA",      address={0x001FECB}, values={0x04}},
            {name="Hispanic", address={0x001FECB}, values={0x05}},
            {name="Brazil",   address={0x001FECB}, values={0x06}},
            {name="Oceania",  address={0x001FECB}, values={0x07}},
        }
    },

    -----------------------------------------------------------
    -- PARRY TAB
    -----------------------------------------------------------

    {
        name = "Auto Blocking PL1",
        category = "Parry",
        address = {0x2026335,0x2026337,0x2026339,0x2026346},
        values = {0x06,0x06,0x06,0x06},
        default_values = {0,0,0,0},
        enabled = false
    },
    {
        name = "Select Ground Parry (High)",
        category = "Parry",
        address = {0x2026335},
        values = {0x0A},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Select Ground Parry (Low)",
        category = "Parry",
        address = {0x2026337},
        values = {0x0A},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Select Air Parry (On Ground)",
        category = "Parry",
        address = {0x2026347},
        values = {0x0A},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Select Air Parry (In Air)",
        category = "Parry",
        address = {0x2026339},
        values = {0x0A},
        default_values = {0x00},
        enabled = false
    },
    {
        name = "Select Grab Tech",
        category = "Parry",
        address = {0x2026328},
        values = {0x01},
        default_values = {0x00},
        enabled = false
    },

    {
        name = "Auto Blocking PL2",
        category = "Parry",
        address = {0x20267CD,0x20267CF,0x20267D1,0x20267DE},
        values = {0x06,0x06,0x06,0x06},
        default_values = {0,0,0,0},
        enabled = false
    },

    -----------------------------------------------------------
    -- UNIVERSAL TAB
    -- (unchanged except visuals)
    -----------------------------------------------------------

    {
        name = "Select Universal Cancel Settings #1",
        category = "Universal",
        selected_option = 1,
        options = {
            { name="Disabled",         address={0x2068E8D}, values={0x00} },
            { name="Special",          address={0x2068E8D}, values={0x20} },
            { name="Super",            address={0x2068E8D}, values={0x40} },
            { name="Special + Super",  address={0x2068E8D}, values={0x60} },
            { name="Crazy Cancel",     address={0x2068E8D}, values={0x10} },
            { name="All",              address={0x2068E8D}, values={0xC0} },
        }
    },

    {
        name = "Select Universal Cancel Settings #2",
        category = "Universal",
        selected_option = 1,
        options = {
            { name="Disabled", address={0x2068E8D}, values={0x00} },
            { name="Super", address={0x2068E8D}, values={0x01} },
            { name="Dash", address={0x2068E8D}, values={0x02} },
            { name="Normal", address={0x2068E8D}, values={0x04} },
            { name="Allow Chains", address={0x2068E8D}, values={0x08} },
            { name="Super Jump + Dash", address={0x2068E8D}, values={0x03} },
            { name="Super Jump + Normals", address={0x2068E8D}, values={0x05} },
            { name="Super Jump + Chains", address={0x2068E8D}, values={0x09} },
            { name="Dash + Normals", address={0x2068E8D}, values={0x06} },
            { name="Dash + Chains", address={0x2068E8D}, values={0x0A} },
            { name="Super Jump + Dash + Normals", address={0x2068E8D}, values={0x07} },
            { name="Super Jump + Dash + Chains", address={0x2068E8D}, values={0x0B} },
            { name="Dash + Normals + Chains", address={0x2068E8D}, values={0x0E} },
            { name="All", address={0x2068E8D}, values={0x0F} },
        }
    },
}

---------------------------------------------------------------
-- TAB + NAVIGATION SYSTEM
---------------------------------------------------------------
local tabs = {"Player","System","Parry","Universal"}
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
    for _, c in ipairs(cheats) do
        if c ~= target and c.enabled and c.address then
            for _, ta in ipairs(target.address) do
                for _, ca in ipairs(c.address) do
                    if ca == ta then
                        c.enabled = false
                        if c.default_values then
                            for i = 1, #c.address do
                                write(c.address[i], c.default_values[i] or 0)
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

local function toggle_cheat(c)
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
    if not c.address or not c.values then return end
    if c.enabled then
        for i=1,#c.address do
            write(c.address[i], c.values[i] or 0)
        end
    end
end

local function select_character(c, idx)
    c.selected_character = idx
    local d = c.characters[idx]
    for i=1,#d.address do
        write(d.address[i], d.values[i])
    end
end

local function select_super_art(c, idx)
    c.selected_super_art = idx
    local d = c.super_arts[idx]
    if d.value ~= nil then write(d.address, d.value) end
end

local function select_bonus_damage(c, idx)
    c.selected_bonus_damage = idx
    local d = c.bonus_damage[idx]
    for i=1,#d.address do
        write(d.address[i], d.values[i])
    end
end

local function select_option(c, idx)
    c.selected_option = idx
    local o = c.options[idx]
    for i=1,#o.address do
        write(o.address[i], o.values[i])
    end
end

local function apply_option_cheat(c)
    local idx = c.selected_option or 1
    local o = c.options[idx]
    if not o then return end
    for i=1,#o.address do
        write(o.address[i], o.values[i])
    end
end

---------------------------------------------------------------
-- UNIVERSAL CANCEL BITWISE COMBINE
---------------------------------------------------------------
local function apply_universal_cancel()
    local uc1, uc2 = 0, 0

    for _, c in ipairs(cheats) do
        if c.category == "Universal" then
            local list = c.options
            local idx = c.selected_option or 1
            local v = list[idx].values[1]

            if c.name == "Select Universal Cancel Settings #1" then
                uc1 = v
            elseif c.name == "Select Universal Cancel Settings #2" then
                uc2 = v
            end
        end
    end

    local final = safe_bor(uc1, uc2)
    write(0x2068E8D, final)
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

    local list = visible_cheats()
    clamp_selection(list)
    local c = list[current_cheat_index]
    if not c then return end

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
        local dir = inp.right and 1 or -1

        if c.characters then
            local total = #c.characters
            local idx = ((c.selected_character - 1 + dir + total) % total) + 1
            select_character(c, idx)

        elseif c.super_arts then
            local total = #c.super_arts
            local idx = (((c.selected_super_art or 1) - 1 + dir + total) % total) + 1
            select_super_art(c, idx)

        elseif c.bonus_damage then
            local total = #c.bonus_damage
            local idx = ((c.selected_bonus_damage - 1 + dir + total) % total) + 1
            select_bonus_damage(c, idx)

        elseif c.options then
            local total = #c.options
            local idx = (((c.selected_option or 1) - 1 + dir + total) % total) + 1
            select_option(c, idx)

        else
            if inp.right then toggle_cheat(c) end
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
        local is_active = (i == current_tab_index)
        local label = is_active and (">"..name.."<") or name
        local color = is_active and COLOR_TAB_ACTIVE or COLOR_TAB_INACT
        gui.text(tx, tab_y, label, color)
        tx = tx + (#label * 4 + 16)
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
        if c.characters then status = c.characters[c.selected_character or 1].name
        elseif c.super_arts then status = c.super_arts[c.selected_super_art or 1].name
        elseif c.bonus_damage then status = c.bonus_damage[c.selected_bonus_damage or 1].name
        elseif c.options then status = c.options[c.selected_option or 1].name
        elseif c.enabled then status = "On"
        else status = "Off" end

        gui.text(x+10, row_y, c.name, c.enabled and 0xFFFF6060 or 0xFFE0F8FF)
        gui.text(x+MENU_WIDTH-120, row_y, status, 0xFF7FE8FF)
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
    gui.text(x+10, y+menu_height-12, "Up/Down Select  Left/Right Change  Q/E Tabs", 0xFF7FE8FF)
end

---------------------------------------------------------------
-- MAIN LOOP
---------------------------------------------------------------
while true do
    handle_input()

    for _, c in ipairs(cheats) do
        if c.category == "Universal" then
            -- skip: handled after loop

        elseif c.options then
            apply_option_cheat(c)

        elseif c.bonus_damage then
            select_bonus_damage(c, c.selected_bonus_damage or 1)

        elseif c.characters then
            -- FIX: Only apply when NOT Disabled
            if c.selected_character ~= 1 then
                select_character(c, c.selected_character)
            end

        elseif c.super_arts then
            if (c.selected_super_art or 1) ~= 1 then
                select_super_art(c, c.selected_super_art)
            end

        else
            apply_normal_cheat(c)
        end
    end

    apply_universal_cancel()
    draw_menu()
    emu.frameadvance()
end

