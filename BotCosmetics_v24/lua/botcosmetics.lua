-- Bot Cosmetics (bots use skins and followers)
-- Only works in Online mode to "simulate" diverse player characters, 
-- not active in Local play (Grand Prix etc.) since that is meant to be
-- played with bots with default skins (so they look like their own selves)

-- This version is adapted to work on v2.4rc1+, which changes API compared to
-- v2.3 when it comes to setting visual bot properties from PlayerJoin.

local bc_maxfollowerid = CV_RegisterVar({
    name = "bc_max_follower_id",
    defaultvalue = "130",
    flags = CV_NETVAR,
    possiblevalue = {MIN = 0, MAX = 1024} -- v2.4+ can determine this dynamically
})
local bc_skincolorchance = CV_RegisterVar({
    name = "bc_change_color_chance",
    defaultvalue = "50",
    flags = CV_NETVAR,
    possiblevalue = {MIN = 0, MAX = 100}
})
local bc_followerchance = CV_RegisterVar({
    name = "bc_add_follower_chance",
    defaultvalue = "50",
    flags = CV_NETVAR,
    possiblevalue = {MIN = 0, MAX = 100}
})
local bc_samecolorchance = CV_RegisterVar({
    name = "bc_same_follower_color_chance",
    defaultvalue = "50",
    flags = CV_NETVAR,
    possiblevalue = {MIN = 0, MAX = 100}
})
local bc_oppcolorchance = CV_RegisterVar({
    name = "bc_opp_follower_color_chance",
    defaultvalue = "33",
    flags = CV_NETVAR,
    possiblevalue = {MIN = 0, MAX = 100}
})

-- Obtain the max color dynamically, currently assuming that there are 100 default colors in the game
-- and the first free color slot is defined below
local first_free_color_slot = 170   -- Per v2.4 doomdef.h, might need updating in the future game versions
local max_skin_color = #skincolors - first_free_color_slot + 100

-- Obtain the max follower ID dynamically
local max_follower_id = bc_maxfollowerid.value
local function set_max_follower_id()
    max_follower_id = #followers - 1
end

-- Dynamic table (array) storing the players which have already had their skin/follower data set
-- Needed in v2.4+ because we have to use the PlayerSpawn hook to modify these properties,
-- thus, we need some way to indicate that the given bot was already modified.
local player_mod_table = {}

-- Color note: for followers, UINT16_MAX is MATCH color and UINT16_MAX - 1 is OPPOSITE color

local function on_game_quit() 
    -- Reset the player mod table when the game ends
    print("--- GameQuit hook fired")
    player_mod_table = {}
end

local function on_player_spawn(player)
    if replayplayback then return end
    if not netgame then return end

    -- Try to obtain the max follower id dynamically, this requires v2.4+ 
    pcall(set_max_follower_id)

    if player.bot then
	-- Check if the bot with this name is already in the table of modified players
	if player_mod_table[player.name] != nil then
	    player.skincolor = player_mod_table[player.name].skincolor
	    player.followerready = player_mod_table[player.name].followerready
	    player.followerskin = player_mod_table[player.name].followerskin
	    player.followercolor = player_mod_table[player.name].followercolor
	    return
	end

        if P_RandomRange(0, 100) < bc_skincolorchance.value then
            -- Per v2.4, there are 100 colors before the supercolor and the free slot groups
            -- Thus, skin color 101 should be mapped to 170 (first free slot)
            local skincolor = P_RandomRange(0, max_skin_color)
            if skincolor > 100 then
                skincolor = skincolor - 100 + first_free_color_slot - 1
            end
            player.skincolor = skincolor
        end
        if P_RandomRange(0, 100) < bc_followerchance.value then
            player.followerready = true
            player.followerskin = P_RandomRange(0, max_follower_id)
            if P_RandomRange(0, 100) < bc_samecolorchance.value then
                player.followercolor = UINT16_MAX
            elseif P_RandomRange(0, 100) < bc_oppcolorchance.value then
                player.followercolor = UINT16_MAX - 1
            else
                -- same color logic as above, needs updating if the default skin indexes change
                local followercolor = P_RandomRange(0, max_skin_color)
                if followercolor > 100 then
                    followercolor = followercolor - 100 + first_free_color_slot - 1
                end
                player.followercolor = followercolor
            end
        end

	-- Store the info about how we modified the given bot so that this info persists across
	-- map changes and restarts
	local mod_table = {}
	mod_table.skincolor = player.skincolor
	mod_table.followerskin = player.followerskin
	mod_table.followerready = player.followerready
	mod_table.followercolor = player.followercolor
	player_mod_table[player.name] = mod_table
    end
end

addHook("PlayerSpawn", on_player_spawn)
addHook("GameQuit", on_game_quit)
