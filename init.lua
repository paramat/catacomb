-- catacomb 0.1.1 by paramat
-- For Minetest 0.4.8 and later
-- Depends default
-- License: code WTFPL

-- Parameters

local CHCHA = 0.5 -- Adjacent chambers chance

local MINLEN = 3 -- Min max length for passages
local MAXLEN = 32

local MINWID = 8 -- Min max EW NS widths, min max height, for chambers
local MAXWID = 32
local MINHEI = 5
local MAXHEI = 32

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
		local c_chn = minetest.get_content_id("catacomb:chn")
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
						if k == len then -- passage end wall with chamber spawner
							if j == 1 and i == 1 then
								data[vi] = c_chn
							else
								data[vi] = c_cobble
							end
						else -- passage
							if j == 1 or j == 5 or i == 1 or i == 4 then
								data[vi] = c_cobble
							else
								data[vi] = c_air
							end
						end
					end
					vi = vi + 1 -- eastwards 1
				end
				vi = vi - 4 + vvii -- back 4, up 1
			end
			vi = vi + (dlu - 5) * vvii + nvii -- down 4 or 5 or 6, northwards 1
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

-- Chamber north

minetest.register_abm({
	nodenames = {"catacomb:chn"},
	interval = 11,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local c_pan = minetest.get_content_id("catacomb:pan")
		local c_chn = minetest.get_content_id("catacomb:chn")
		local widew = math.random(MINWID, MAXWID) - 1
		local vmvw = -math.random(0, widew - 3)
		local vmve = widew + vmvw
		local vmvn = math.random(MINWID, MAXWID) - 1
		local vmvu = math.random(MINHEI, MAXHEI) - 1
		local exoff = math.random(0, widew - 3) -- exit offset

		local vm = minetest.get_voxel_manip() -- check for obstruction
		local pos1 = {x=x+vmvw, y=y, z=z}
		local pos2 = {x=x+vmve, y=y+vmvu, z=z+vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		for k = 1, vmvn do
		for j = 0, vmvu do
			local vi = area:index(x+vmvw, y + j, z + k)
			for i = 0, widew do
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
		end
		end

		local vm = minetest.get_voxel_manip() -- spawn chamber
		local pos1 = {x=x+vmvw, y=y, z=z}
		local pos2 = {x=x+vmve, y=y+vmvu, z=z+vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		for k = 0, vmvn do
		for j = 0, vmvu do
			local vi = area:index(x+vmvw, y + j, z + k)
			for i = 0, widew do
				local nodid = data[vi]
				if nodid ~= c_air then
					if k == vmvn and j == 0 and i == exoff then
						if math.random() < CHCHA then
							data[vi] = c_chn -- adjacent chamber
						else
							data[vi] = c_pan -- passage
						end
					elseif (k >= 1 and k <= vmvn - 1
					and j >= 1 and j <= vmvu - 1
					and i >= 1 and i <= widew - 1)
					or (k == 0 and j >= 1 and j <= 3 and i >= 1 - vmvw
					and i <= 2 - vmvw) then
						data[vi] = c_air
					else
						data[vi] = c_cobble
					end
				end
				vi = vi + 1
			end
		end
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

