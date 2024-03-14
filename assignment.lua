local width = 75
local height = 20
local floor = "."
local wall = "#"
local empty = " "
local door = "+"


local map = {}

local rooms = {}


local function room_add(room, type, x, y)
    if type == floor then
        if room.floor[x] == nil then
            room.floor[x] = {}
        end
        room.floor[x][y] = type
    end
    if type == wall then
        if room.walls[x] == nil then
            room.walls[x] = {}
        end
        room.walls[x][y] = type
    end
    if type == door then
        if room.doors[x] == nil then
            room.doors[x] = {}
        end
        room.doors[x][y] = type
    end
	if type == empty then
        if room.floor[x] then
            room.floor[x][y] = nil
        end
        if room.walls[x] then
            room.walls[x][y] = nil
        end
		if room.doors[x] then
            room.doors[x][y] = nil
        end
	end
end

local function room_check_for(room, type, x, y)
	if type == floor then
        if room.floor[x] ~= nil or room.floor[x][y] ~=nil then
			return true
		end
    end
    if type == wall then
        if room.walls[x] ~= nil or room.walls[x][y] ~=nil then
			return true
		end
    end
    if type == door then
        if room.doors[x] ~= nil or room.doors[x][y] ~=nil then
			return true
		end
    end
    if type == empty then
        if room.floor[x] == nil or room.floor[x][y] == nil then
			if room.doors[x] == nil or room.doors[x][y] == nil then
				if room.walls[x] == nil or room.walls[x][y] == nil then
					return true
        		end
        	end
        end
    end
	
	return false
end

local function init_map()
	for x=1,width,1 do
		map[x] = {}
		for y=1,height,1 do
			map[x][y] = empty
		end
	end
end

local function print_map()
	for _,room in pairs(rooms) do
		for x,column in pairs(room.floor) do
            for y, type in pairs(column) do
				if map[x] ~= nil and map[x][y] ~= nil then
					map[x][y] = type
				end
			end
		end
	end

    for _, room in pairs(rooms) do
        for x, column in pairs(room.walls) do
            for y, type in pairs(column) do
                if map[x] ~= nil and map[x][y] ~= nil then
					map[x][y] = type
				end
            end
        end
    end

	for _, room in pairs(rooms) do
        for x, column in pairs(room.doors) do
            for y, type in pairs(column) do
                if map[x] ~= nil and map[x][y] ~= nil then
					map[x][y] = type
				end
            end
        end
    end


	for y=1,height,1 do
		for x=1,width,1 do
			io.write(map[x][y])
		end

		io.write("\n")
	end
end

local function generate_square_room(x, y, room_width, room_height)
    local room = {
        walls = {},
        floor = {},
		doors = {}
	}

	-- Vertical Walls
	for y_index=y,y+room_height,1 do
		room_add(room, wall, x, y_index)
		room_add(room, wall, x + room_width, y_index)
	end

	-- Horizontal Walls
	for x_index=x, x + room_width, 1 do
		room_add(room, wall, x_index, y)
		room_add(room, wall, x_index, y + room_height)
	end

	-- Floor
	for x_index=x + 1, x + room_width - 1, 1 do
        for y_index = y + 1, y + room_height - 1, 1 do
			room_add(room, floor, x_index, y_index)
		end
	end

	table.insert(rooms, room)
end

local function generate_random_square_rooms(amount)
	for i=1, amount, 1 do
		local x = math.random(1, width - 3)
		local y = math.random(1, height - 3)
		local room_width = math.random(3, width - x)
		local room_height = math.random(3, height - y)

		generate_square_room(x, y, room_width, room_height)
	end
end

local function check_if_rooms_overlap(room_key, other_room_key)
	for x,column in pairs(rooms[room_key].floor) do
		for y,_ in pairs(column) do
			if rooms[other_room_key].walls[x] ~= nil and rooms[other_room_key].walls[x][y] ~= nil then
				return true
			end
		end
	end
end

local function check_and_combine_rooms(room_key, other_room_key)
	if not check_if_rooms_overlap(room_key, other_room_key) then
		return false
	end

	local other_room = rooms[other_room_key]
	rooms[other_room_key] = nil

	-- Copy over floor
	for x,column in pairs(other_room.floor) do
		for y,_ in pairs(column) do
			room_add(rooms[room_key], floor, x, y)
		end
	end

	-- Copy over walls
	for x,column in pairs(other_room.walls) do
		for y,_ in pairs(column) do
			room_add(rooms[room_key], wall, x, y)
		end
	end

	-- Remove interior walls
	for x,column in pairs(rooms[room_key].floor) do
		for y,_ in pairs(column) do
			-- Remove half the interior walls
			if rooms[room_key].walls[x] and rooms[room_key].walls[x][y] then
				rooms[room_key].walls[x][y] = nil
			end
		end
	end

	return true
end

local function combine_overlapping_rooms()
	for k1,_ in pairs(rooms) do
		for k2,_ in pairs(rooms) do
			if k1 ~= k2 then
				if check_and_combine_rooms(k1, k2) then
					-- Rerun the function if a room has been removed from the table
					combine_overlapping_rooms()
					return
				end
			end
		end
	end
end


local function get_grid_position(x, y)
	if x < 1 or x > width or y < 1 or y > height then
		return nil
	end

    for _, room in pairs(rooms) do
        if room.walls[x] ~= nil and room.walls[x][y] ~= nil then
            return room.walls[x][y]
        elseif room.floor[x] ~= nil and room.floor[x][y] ~= nil then
            return room.floor[x][y]
        elseif room.doors[x] ~= nil and room.doors[x][y] ~= nil then
            return room.doors[x][y]
        end
    end

	return empty
end

local function get_adjacent_grid_positions(x, y)
    local adjacents = {}
    --adjacents[1][1] = { type = get_grid_position(x - 1, y - 1), position = { x = x - 1, y = y - 1, } }
    table.insert(adjacents, { type = get_grid_position(x - 1, y), position = { x = x - 1, y = y, } })
    table.insert(adjacents, { type = get_grid_position(x, y - 1), position = { x = x, y = y - 1, } })
    table.insert(adjacents, { type = nil, position = { x = x, y = y, } })
    table.insert(adjacents, { type = get_grid_position(x + 1, y), position = { x = x + 1, y = y, } })
    table.insert(adjacents, { type = get_grid_position(x, y + 1), position = { x = x, y = y + 1, } })
    --adjacents[3][3] = { type = get_grid_position(x + 1, y + 1), position = { x = x + 1, y = y + 1, } }
    --adjacents[1][3] = { type = get_grid_position(x - 1, y + 1), position = { x = x - 1, y = y + 1, } }
    --adjacents[3][1] = { type = get_grid_position(x + 1, y - 1), position = { x = x + 1, y = y - 1, } }

    return adjacents
end

-- Necessary due to Lua table keys not being based on the stored values only the table id
local function check_if_frontier_or_came_from_contains(frontier, came_from, x, y)
    for _, v in pairs(frontier) do
        if v.x == x and v.y == y then
            return true
        end
    end

	for k,_ in pairs(came_from) do
		if k.x == x and k.y == y then
			return true
		end
	end

	return false
end

local function find_path(startx, starty, goalx, goaly)
    local start = { x = startx, y = starty }
	local goal = { x = goalx, y = goaly }

    local frontier = {}
	table.insert(frontier, start)

	local came_from = {}
    came_from[start] = nil

    while #frontier > 0 do
        local current = table.remove(frontier, 1)
        local adjacents = get_adjacent_grid_positions(current.x, current.y)
        for _, adjacent in pairs(adjacents) do
			if adjacent.position.x == goal.x and adjacent.position.y == goal.y then
				came_from[adjacent.position] = current
				local path = {}
				local current_path = current

				while current_path ~= start do
					table.insert(path, current_path)

					current_path = came_from[current_path]
				end

				return path
			end

			if adjacent.type ~= nil and adjacent.type == empty and not check_if_frontier_or_came_from_contains(frontier, came_from, adjacent.position.x, adjacent.position.y) then
				table.insert(frontier, adjacent.position)
				came_from[adjacent.position] = current
			end
        end
    end

	return nil
end

local function generate_corridor(room_key, other_room_key)
    local wall_locations = {}
    local other_wall_locations = {}

    for x, column in pairs(rooms[room_key].walls) do
		for y,_ in pairs(column) do
			table.insert(wall_locations, {x = x, y = y})
		end
    end

	for x, column in pairs(rooms[other_room_key].walls) do
		for y,_ in pairs(column) do
			table.insert(other_wall_locations, {x = x, y = y})
		end
	end

	while true do
        local start = wall_locations[math.random(1, #wall_locations)]
        local goal = other_wall_locations[math.random(1, #other_wall_locations)]

        local path = find_path(start.x, start.y, goal.x, goal.y)
        if path ~= nil then
            local other_room = rooms[other_room_key]
            rooms[other_room_key] = nil
 
			-- Copy over floor
			for x,column in pairs(other_room.floor) do
				for y,type in pairs(column) do
					room_add(rooms[room_key], floor, x, y)
				end
			end

			-- Copy over walls
			for x,column in pairs(other_room.walls) do
				for y,type in pairs(column) do
					room_add(rooms[room_key], wall, x, y)
				end
			end

			-- Add corridor floor
            for _, pos in pairs(path) do
                room_add(rooms[room_key], floor, pos.x, pos.y)
            end

			-- Add corridor walls
			for _, pos in pairs(path) do
				if room_check_for(rooms[room_key], empty, pos.x - 1, pos.y) then
					room_add(rooms[room_key], wall, pos.x - 1, pos.y)
				end
				if room_check_for(rooms[room_key], empty, pos.x + 1, pos.y) then
					room_add(rooms[room_key], wall, pos.x + 1, pos.y)
				end
				if room_check_for(rooms[room_key], empty, pos.x, pos.y - 1) then
					room_add(rooms[room_key], wall, pos.x, pos.y - 1)
				end
				if room_check_for(rooms[room_key], empty, pos.x, pos.y + 1) then
					room_add(rooms[room_key], wall, pos.x, pos.y + 1)
				end
				if room_check_for(rooms[room_key], empty, pos.x - 1, pos.y - 1) then
					room_add(rooms[room_key], wall, pos.x - 1, pos.y - 1)
				end
				if room_check_for(rooms[room_key], empty, pos.x + 1, pos.y - 1) then
					room_add(rooms[room_key], wall, pos.x + 1, pos.y - 1)
				end
				if room_check_for(rooms[room_key], empty, pos.x - 1, pos.y + 1) then
					room_add(rooms[room_key], wall, pos.x - 1, pos.y + 1)
				end
				if room_check_for(rooms[room_key], empty, pos.x + 1, pos.y + 1) then
					room_add(rooms[room_key], wall, pos.x + 1, pos.y + 1)
				end
            end

			room_add(rooms[room_key], door, start.x, start.y)
			room_add(rooms[room_key], door, goal.x, goal.y)

			return
		end
	end
end

local function generate_corridors()
	for k1,_ in pairs(rooms) do
		for k2,_ in pairs(rooms) do
			if k1 ~= k2 then
                generate_corridor(k1, k2)
                generate_corridors() -- Rerun the function as the rooms table is modified every generate_corridor call
				return
			end
		end
	end
end

init_map()
-- generate_square_room(2, 2, 5, 4)
generate_random_square_rooms(4)
combine_overlapping_rooms()
generate_corridors()
print_map()