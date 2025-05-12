-- Teaches the AI to do some basic [cheaty] sliptiding, in case difficulty isn't enough :)
-- Works best with v2.4+ codebase, where the AI will not only sliptide, but also charge wavedash
-- and wavedash from time to time (it looks like the bot movement code is better there).
-- In v2.3, it'll still activate the sliptide, but it won't charge or perform wavedash.
-- Since the AI doesn't have the real notion of "drifting" in bot movement code, this has to
-- rely on determining the movement angle to determine which way the wavedash should "go".
-- This is cheaty as hell and probably an unnecessary difficulty increase for the bot, so
-- just a little experiment.

local ANGLE_180 = 0x80000000
local SLIPTIDEHANDLING = (7 * 65536) / 8

local function do_bot_sliptide(player)
	for player in players.iterate do
		if player.bot then
			if player.handleboost >= SLIPTIDEHANDLING / 2 then
				if player.mo.angle >= ANGLE_180 then
					player.aizdriftstrat = 1
				else
					player.aizdriftstrat = -1
				end
			end
		end
	end
end

addHook("ThinkFrame", do_bot_sliptide)
