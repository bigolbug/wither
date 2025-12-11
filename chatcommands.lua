
core.register_chatcommand("withercmd", {
	params = "[action] [area ID]",
	description = "Misc wither admin commands\n"..
	"Example: \n"..
	"Nothing exists yet"
	,
	func = function(name, param)
		-- define a local variables
		local params = param:gmatch("([%a%d_,]+)")
		local action, area_ID = params(1), params(2)
		if action ~= nil then action = string.upper(action) end
		local player = core.get_player_by_name(name)
		if player == nil then
			return false, name .. " is not currently active in the game"
		end
		local player_meta = player:get_meta()
		local player_rent = player_meta:get_int("rent")
		local pos = player:get_pos()
		local XP = area_rent.metadata:get_int(name.."XP")
		local area_data = {}
		area_data.pos1, area_data.pos2 = areas:getPos(name)
		area_data.owner = "SERVER"
		area_data.loaner = name
		area_data.cost = nil
		area_data.time = tostring(os.time())

		if action == "STAT" then

			if action and tonumber(action) then
				return false, ""
			end
			
			-- Check to see if mod is enabled
			local ar_center = core.deserialize(area_rent.metadata:get_string("center"))
			if not ar_center then
				return false, "Area rent mod is not setup. Ask your admin to set a center with /rcmd center"
			end

			-- Check to see if an area needs to be selected. 
			if not (area_data.pos1 and area_data.pos2) then
				return false, "You need to select an area first. Use /area_pos1 \nand /area_pos2 to set the bounding corners"
			else
				-- Make sure that pos2 is the farther then pos1
				if area_data.pos1.x > area_data.pos2.x then
					local temp_pos = area_data.pos1
					area_data.pos1 = area_data.pos2
					area_data.pos2 = temp_pos
				end
			end
			
			-- find distance and direction from area center to the universal center
			area_data.center = area_rent.center_pos(area_data.pos1,area_data.pos2)
			area_data.distance_to_center = vector.distance(ar_center, area_data.center)
			local direction = vector.direction(area_data.center,ar_center)
			area_data.direction = math.atan2(direction.x,-direction.z)+math.pi

			--Set Deltas
			area_data.dy = math.abs(area_data.pos1.y - area_data.pos2.y)
			area_data.dx = math.abs(area_data.pos1.x - area_data.pos2.x)
			area_data.dz = math.abs(area_data.pos1.z - area_data.pos2.z)

			-- find the XZ center
			area_rent.xz_center(area_data, ar_center)

			--Check for intersecting areas and determine action. 
			--local intersecting_areas = areas:getAreasIntersectingArea(area_data.pos1, area_data.pos2)
			local intersecting_areas = area_rent.get_intersecting_areas(area_data)
			--This is were you would find out if the player owns the area. 
			
			if not intersecting_areas then
				return false, "You can't rent this selection since it intersects with another players property"
			elseif area_rent.tableLen(intersecting_areas) then
				area_rent.debug("This is how many intersecting areas there are "..area_rent.tableLen(intersecting_areas))
				core.chat_send_player(name, core.colorize(area_rent.color.red,"FYI, Your selection intersects with your area(s)!"))
				area_rent.debug("Listing areas that area intersecting")
				for area_ID, area_data in pairs(intersecting_areas) do
					area_rent.debug(area_ID.." with name ".. area_data.name)
					core.chat_send_player(name,core.colorize(area_rent.color.red,"\t\t"..area_data.name .. " with ID "..area_data.ID))
				end
				core.chat_send_player(name, core.colorize(area_rent.color.red,"Use the /rent view <Area Name> command to view intersecting areas"))
			else
				area_rent.debug("no intersecting areas")
			end
			
			if area_rent.greifer_check(area_data.dx,area_data.dy,area_data.dz,area_data.loaner) then
				return false, "Please reselect an area and try /rent again"
			end

			--Calculate Volume
			area_data.volume = area_data.dy * area_data.dx * area_data.dz
			if area_data.volume > area_rent.limit.volume then return false, "Please reduce the size of your selection" end

			-- CALCULATE RENTAL PRICE
			local rate = area_rent.price.rate(area_data.distance_to_center)
			area_data.cost = math.ceil(rate * area_data.volume)
			core.chat_send_player(name,"This area will cost: ".. area_data.cost .. " xp per day ("..rate.." xp per node per day)")
			
			--Based on your current XP and Volume...
			if not area_rent.qualify(area_data) then
				return false, "It looks like you don't qualify. You either have to much property or not enough XP"..
				"\nYou must have an additional "..area_rent.qualifying_term * XP.. " XP to rent this area"..
				"\nor you must remove areas to add additional ones. Do this with /rent remove <ID>"
			end
			
			--Save the area in mod storage and inform the user on how to recall it. 
			local message = ""
			local area_name = area_rent.cue_Area(area_data)
			message = message .. "\tThe area you have cued is called " .. area_name .. ". Here is the command for renting the area"
			message = message .. "\n\t/rent area "..area_name
			core.chat_send_player(name,message)

			if area_ID then
				-- is the player already the owner?
				local area = areas.areas[area_ID]
				return false, "Your selection itersects with another players area"
			end
		end
	end
})
