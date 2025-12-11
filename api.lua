function wither.age()
    local game_time = core.get_day_count() + core.get_timeofday()
    for event_time, event_data in pairs(wither.metatable) do
        if tonumber(event_time) then
            wither.debug("Checking event at time " .. event_time .. " at ".. game_time)
           if game_time > tonumber(event_time) then
                wither.debug("Node has expired at position: ".. core.serialize(event_data.pos))
                local current_node = core.get_node(event_data.pos)
                wither.debug("The current node at position: ".. core.serialize(event_data.pos).. " is "..current_node.name)
                if event_data.node == current_node.name then
                    core.set_node(event_data.pos,{name = wither[event_data.node].swapnode})
                    wither.metatable[event_time] = nil
                end 
            end 
        end
    end
end

function wither.step(dtime)
    local last_scan_day = wither.metadata:get_int("last_scan")
    local current_day = core.get_day_count()

    --core.chat_send_all("current Day "..current_day .. " previous scan ".. last_scan_day)
    
    if current_day - last_scan_day > 0 then
        --It is a new day
        wither.debug("Scanning for nodes")
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