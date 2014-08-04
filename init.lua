-- catacomb 0.1.0 by paramat
-- For Minetest 0.4.8 and later
-- Depends default
-- License: code WTFPL

-- Parameters

local MINLEN = 3 -- Min/max length for passages
local MAXLEN = 32

-- Nodes

minetest.register_node("catacomb:pan", {
	description = "Cobble passage spawner north",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:pas", {
	description = "Cobble passage spawner south",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:pae", {
	description = "Cobble passage spawner east",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:paw", {
	description = "Cobble passage spawner west",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chn", {
	description = "Cobble chamber spawner north",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chs", {
	description = "Cobble chamber spawner south",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:che", {
	description = "Cobble chamber spawner east",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chw", {
	description = "Cobble chamber spawner west",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

-- ABM

-- Passage north

minetest.register_abm({
	nodenames = {"catacomb:pan"},
	interval = 7,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local dlu = math.random(-1, 1)
		local len = math.random(MINLEN, MAXLEN)
		local vmvd, vmvu -- voxelmanip volume down, up
		if dlu == -1 then -- down
			vmvd = -len
			vmvu = 4
		elseif dlu == 0 then -- level
			vmvd = 0
			vmvu = 4
		else -- up
			vmvd = 0
			vmvu = len + 4
		end

		local vm = minetest.get_voxel_manip() -- check for obstruction
		local pos1 = {x=x, y=y+vmvd, z=z}
		local pos2 = {x=x+3, y=y+vmvu, z=z+len}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1  -- vertical vi interval
		local nvii = (emax.y - emin.y + 1) * vvii -- northward vi interval

		local vi = area:index(x, y+dlu, z + 1)
		for k = 1, len do
			for j = 1, 5 do
				for i = 1, 4 do
					local nodid = data[vi]
					if nodid == c_cobble then
						local vi = area:index(x, y, z)
						data[vi] = c_cobble -- replace spawner

						vm:set_data(data)
						vm:write_to_map()
						vm:update_map()
						return
					end
					vi = vi + 1
				end
				vi = vi - 4 + vvii
			end
			vi = vi + (dlu - 5) * vvii + nvii
		end

		local vm = minetest.get_voxel_manip() -- spawn passage
		local pos1 = {x=x, y=y+vmvd, z=z}
		local pos2 = {x=x+3, y=y+vmvu, z=z+len}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z)
		for k = 0, len do
			for j = 1, 5 do
				for i = 1, 4 do
					local nodid = data[vi]
					if nodid ~= c_air then
						if j == 1 or j == 5 or i == 1 or i == 4 then
							data[vi] = c_cobble
						else
							data[vi] = c_air
						end
					end
					vi = vi + 1
				end
				vi = vi - 4 + vvii
			end
			vi = vi + (dlu - 5) * vvii + nvii
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

