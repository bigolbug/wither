wither.debug_Enable = true
wither.debuglevel = "error" -- options "info" "none", "error", "warning", "action", or "verbose"
wither.metadata = core.get_mod_storage()
if not wither.metadata:contains("table") then
    wither.metatable = {}
else
    wither.metatable = core.deserialize(wither.metadata:get_string("table"))
end
wither.enabled = wither.metadata:get_int("enabled")
wither.nuke = false
wither.time_ratio = 86400/tonumber(core.settings:get("time_speed")) -- Real time seconds per luanti day
if wither.metadata:contains("abm") then
    wither.abm = wither.metadata:get_int("abm")
else
    wither.abm = 0
end



-- Swap nodes (lifespan is in minetest days)
wither.nodes = {}
wither.nodes["moremesecons_playerkiller:playerkiller"] = {swapnode = "default:dirt",lifespan = 1}
