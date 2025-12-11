wither = {}
local modname = "wither"

wither.modpath = minetest.get_modpath(modname)
dofile(wither.modpath.."/config.lua")
dofile(wither.modpath.."/api.lua")
--dofile(area_rent.modpath.."/chatcommands.lua")

core.register_globalstep(wither.step)

core.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    if wither[newnode.name] then
        local Expiration = wither[newnode.name].lifespan + core.get_day_count() + core.get_timeofday()
        wither.metatable[Expiration] = {}
        wither.metatable[Expiration] = {
            placed = core.get_day_count() + core.get_timeofday(),
            pos = pos,
            node = newnode.name
        }
        wither.save()
    end
end)

core.register_abm(
    {
    label = "Wither Nodes ABM",
    nodenames = {"moremesecons_playerkiller:playerkiller"},
    -- Apply `action` function to these nodes.
    -- `group:groupname` can also be used here.
    interval = 1,
    -- Operation interval in seconds

    chance = 1,
    -- Probability of triggering `action` per-node per-interval is 1.0 / chance (integers only)

    min_y = -32768,
    max_y = 32767,
    -- min and max height levels where ABM will be processed (inclusive)
    -- can be used to reduce CPU usage

    catch_up = true,
    -- If true, catch-up behavior is enabled: The `chance` value is
    -- temporarily reduced when returning to an area to simulate time lost
    -- by the area being unattended. Note that the `chance` value can often
    -- be reduced to 1.

    action = function(pos, node, active_object_count, active_object_count_wider)
        core.set_node(pos,{name = "default:dirt"})
    end,
})