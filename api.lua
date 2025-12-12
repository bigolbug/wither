function wither.age()
    wither.debug("Aging blocks")
    local game_time = core.get_day_count() + core.get_timeofday()
    for event_time, event_data in pairs(wither.metatable) do
        if tonumber(event_time) then
            wither.debug("Checking event time: Event time = " .. event_time .. " at game time = ".. game_time)
           if game_time > tonumber(event_time) then
                wither.debug("Node has expired at position: ".. core.serialize(event_data.pos))
                wither.remove(event_data.pos,event_data.node)
                wither.metatable[event_time] = nil
                wither.save()
            end 
        end
    end
end

function wither.remove(pos,node_name)
    local current_node = core.get_node(pos)
    wither.debug("The current node at position: ".. core.serialize(pos).. " is "..current_node.name)
    if current_node.name == node_name then
        wither.debug("setting "..current_node.name.." to "..wither.nodes[node_name].swapnode)
        core.set_node(pos,{name = wither.nodes[node_name].swapnode})
    else
        wither.scan_area(pos,node_name)
    end
    
end

function wither.scan_area(pos,node_name)
    -- Not needed after adding the abm node meta
    local lost_node = core.find_node_near(pos,5,node_name)

end

function wither.step(dtime)

    if wither.enabled == 0 then
        return
    end

    local last_scan_day = wither.metadata:get_int("last_scan")
    local current_day = core.get_day_count()

    --core.chat_send_all("current Day "..current_day .. " previous scan ".. last_scan_day)
    
    if current_day - last_scan_day > 0 then
        --It is a new day
        wither.debug("New day, scanning for nodes")
        wither.age()
        wither.metadata:set_int("last_scan",current_day)
        
    end
    
end

function wither.save()
    wither.metadata:set_string("table",core.serialize(wither.metatable))
    return
end

function wither.debug(text)
    if wither.debug_Enable then
        core.log(wither.debuglevel,text)
    end
end

wither.set_enabled = function(state)
    if state then
        wither.metadata:set_int("enabled",1)
        wither.enabled = 1
    else
        wither.metadata:set_int("enabled",0)
        wither.enabled = 0
    end
	
end

wither.is_enabled = function()
    if wither.metadata:get_int("enabled") == 0 then
        return false
    else
        return true
    end
end
