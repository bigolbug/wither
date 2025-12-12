core.register_chatcommand("wither_nuke", {
	params = "<on|off>",
	description = "Every node that is on the wither list will be replaced",
	privs = {server = true},
	func = function(name, param)
		if param == "on" then
			wither.nuke = true
			return true, "Wither nuke drop ... Boom"
		elseif param == "off" then
			wither.nuke = false
			return true, "Wither nuke deactivated"
		else
			return false, "Usage: /wither_nuke <on|off>"
		end
	end,
})

core.register_chatcommand("wither_abm", {
	params = "<on|off>",
	description = "Every node that is on the wither list will be replaced",
	privs = {server = true},
	func = function(name, param)
		if param == "on" then
			wither.abm = 1
			wither.metadata:set_int("abm",1)
			return true, "Advanced wither ABM enabled"
		elseif param == "off" then
			wither.metadata:set_int("abm",0)
			wither.abm = 0
			return true, "Advanced wither ABM disabled"
		else
			return false, "Usage: /wither_abm <on|off>"
		end
	end,
})

core.register_chatcommand("wither", {
	params = "<on|off>",
	description = "Enable or diable the wither mod",
	privs = {server = true},
	func = function(name, param)
		if param == "on" then
			wither.set_enabled(true)
			return true, "Wither enabled."
		elseif param == "off" then
			afk.set_enabled(false)
			return true, "Wither disabled."
		else
			core.chat_send_player(name,"Wither Status: (ABM:" .. wither.abm..") (Mod: ".. wither.enabled") (Nuke: ".. tostring(wither.nuke)..")")
			return false, "Usage: /wither <on|off>"
		end
	end,
})
