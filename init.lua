wither = {}
local modname = "wither"

wither.modpath = minetest.get_modpath(modname)
dofile(wither.modpath.."/config.lua")
dofile(wither.modpath.."/api.lua")
dofile(wither.modpath.."/chatcommands.lua")

core.register_globalstep(wither.step)

core.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    if wither.nodes[newnode.name] then
        local Expiration = wither.nodes[newnode.name].lifespan + core.get_day_count() + core.get_timeofday()
        wither.metatable[Expiration] = {}
        wither.metatable[Expiration] = {
            placed = core.get_day_count() + core.get_timeofday(),
            pos = pos,
            node = newnode.name
        }
        -- convert luanti day to seconds
        core.after(wither.time_ratio*wither.nodes[newnode.name].lifespan,wither.remove,pos,newnode.name)
        wither.debug("Node placed will expire in "..wither.time_ratio*wither.nodes[newnode.name].lifespan.." seconds")
        wither.save()

        local node_meta = core.get_meta(pos)
        node_meta:set_string("expiration",Expiration)
    end
end)

core.register_abm({
    label = "Wither Nodes ABM",
    nodenames = {"moremesecons_playerkiller:playerkiller"},
    interval = 5,
    chance = 1,
    min_y = -32768,
    max_y = 32767,
    action = function(pos, node, active_object_count, active_object_count_wider)
        if wither.nuke then
            core.set_node(pos,{name = "default:dirt"})
        end
        if wither.abm == 1 then
            wither.debug("Running wither abm")
            local node_meta = core.get_meta(pos)
            if not node_meta:contains("expiration") then
                wither.debug("ABM Found block without expiration")
                core.set_node(pos,{name = "default:dirt"})
            else
                local game_time = core.get_day_count() + core.get_timeofday()
                wither.debug("ABM: block expiration time:".. tonumber(node_meta:get_string("expiration")).." game time:" .. game_time)
                if game_time > tonumber(node_meta:get_string("expiration")) then
                    wither.debug("ABM Found expirated block, removing")
                    core.set_node(pos,{name = "default:dirt"})
                end
            end

        end
    end,
})