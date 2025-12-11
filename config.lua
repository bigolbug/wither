wither.debug_Enable = true
wither.debuglevel = "error" -- options "info" "none", "error", "warning", "action", or "verbose"
wither.metadata = core.get_mod_storage()
wither.metatable = core.deserialize(wither.metadata:get_string("table"))
if not wither.metatable then
    wither.metatable = {}
end

-- Swap nodes (lifespan is in minetest days)
wither["moremesecons_playerkiller:playerkiller"] = {swapnode = "default:air",lifespan = 6}
