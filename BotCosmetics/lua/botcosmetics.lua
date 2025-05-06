-- Bot Cosmetics (bots use skins and followers)
-- Only works in Online mode to "simulate" diverse player characters, 
-- not active in Local play (Grand Prix etc.) since that is meant to be
-- played with bots with default skins (so they look like their own selves)

local bc_maxskincolor = CV_RegisterVar({
    name = "bc_max_skincolor",
    defaultvalue = "100",
    flags = CV_NETVAR,
    possiblevalue = {MIN = 0, MAX = 1024} -- TODO: 100 in the default game, but might have extra free slots set if modded
})
local bc_maxfollowerid = CV_RegisterVar({
    name = "bc_max_follower_id",
    defaultvalue = "130",
    flags = CV_NETVAR,
    possiblevalue = {MIN = 0, MAX = 1024} -- TODO: 130 in the default game
})
local bc_skinchance = CV_RegisterVar({
    name = "bc_change_skin_chance",
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

-- For followers, UINT16_MAX is MATCH color and UINT16_MAX - 1 is OPPOSITE color

local function on_player_join(player)
    if replayplayback then return end
    if not netgame then return end

    if players[player].bot then
        if P_RandomRange(0, 100) < bc_skinchance.value then
            players[player].skincolor = P_RandomRange(0, bc_maxskincolor.value)
        end
        if P_RandomRange(0, 100) < bc_followerchance.value then
            players[player].followerready = true
            players[player].followerskin = P_RandomRange(0, bc_maxfollowerid.value)
	    -- TODO: improve this so that the chance isn't checked separately for each special color
            if P_RandomRange(0, 100) < bc_samecolorchance.value then
                players[player].followercolor = UINT16_MAX
            elseif P_RandomRange(0, 100) < bc_oppcolorchance.value then
                players[player].followercolor = UINT16_MAX - 1
            else
                players[player].followercolor = P_RandomRange(0, bc_maxskincolor.value)
            end
        end
    end
end

addHook("PlayerJoin", on_player_join)
