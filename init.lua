-- catacomb 0.2.3 by paramat
-- For Minetest 0.4.8 and later
-- Depends default
-- License: code WTFPL

-- Generation option
-- Optional chamber obstruction check
-- Check GEN and limits before placing passage spawners

-- Parameters

local YMIN = -33000 -- Approximate generation limits
local YMAX = 33000
local XMIN = -33000
local XMAX = 33000
local ZMIN = -33000
local ZMAX = 33000

local GEN = true -- Enable generation
local OBCHECK = false -- Enable chamber obstruction check

local MINLEN = 3 -- Min max length for passages
local MAXLEN = 32

local MINWID = 8 -- Min max EW NS widths, min max height, for chambers
local MAXWID = 32
local MINHEI = 6
local MAXHEI = 32

-- Nodes

minetest.register_node("catacomb:cobble", {
	description = "Mod cobblestone",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	drop = "default:cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:stairn", {
	description = "Stair north",
	tiles = {"default_cobble.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {cracky=3, stone=2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0.5, 0.5, 0.5},
		},
	},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:stairs", {
	description = "Stair south",
	tiles = {"default_cobble.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {cracky=3, stone=2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, -0.5, 0.5, 0.5, 0},
		},
	},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:staire", {
	description = "Stair East",
	tiles = {"default_cobble.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {cracky=3, stone=2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{0, 0, -0.5, 0.5, 0.5, 0.5},
		},
	},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:stairw", {
	description = "Stair west",
	tiles = {"default_cobble.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {cracky=3, stone=2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, -0.5, 0, 0.5, 0.5},
		},
	},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:pan", {
	description = "Passage spawner north",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:pas", {
	description = "Passage spawner south",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:pae", {
	description = "Passage spawner east",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:paw", {
	description = "Passage spawner west",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chn", {
	description = "Chamber spawner north",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chs", {
	description = "Chamber spawner south",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:che", {
	description = "Chamber spawner east",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chw", {
	description = "Chamber spawner west",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

-- ABM

-- Passage north

minetest.register_abm({
	nodenames = {"catacomb:pan"},
	interval = 13,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_stairn = minetest.get_content_id("catacomb:stairn")
		local c_stairs = minetest.get_content_id("catacomb:stairs")
		local c_chn = minetest.get_content_id("catacomb:chn")
		local dlu = math.random(-1, 1)
		local len = math.random(MINLEN, MAXLEN)
		local vmvd, vmvu -- voxelmanip volume down, up
		if dlu == -1 then -- down
			vmvd = -len
			vmvu = 5
		elseif dlu == 0 then -- level
			vmvd = 0
			vmvu = 5
		else -- up
			vmvd = 0
			vmvu = len + 5
		end

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x, y=y+vmvd, z=z}
		local pos2 = {x=x+3, y=y+vmvu, z=z+len}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		local vi = vi + 1 + vvii -- across 1, up 1 -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for i = 1, 2 do
				data[vi] = c_air
				vi = vi + 1
			end
			vi = vi - 2 + vvii -- back 2, up 1
		end

		local vi = area:index(x, y, z+1)
		for k = 1, len do
			for j = 1, 6 do
				for i = 1, 4 do
					local nodid = data[vi]
					if nodid ~= c_air
					and nodid ~= c_ignore
					and nodid ~= c_leaves -- no spawning in leaves
					and nodid ~= c_apple then
						if dlu ~= 0 and j == 1
						and not (dlu == 1 and k == 1)
						and not (dlu == -1 and k == len)
						and (i == 2 or i == 3) then
							if dlu == -1 then
								data[vi] = c_stairs
							else
								data[vi] = c_stairn
							end
						elseif k == len and j == 1 and i == 1 then
							data[vi] = c_chn
						elseif j == 1 or j == 6 or i == 1 or i == 4 then
							data[vi] = c_catcobble
						else
							data[vi] = c_air
						end
					end
					vi = vi + 1 -- eastwards 1
				end
				vi = vi - 4 + vvii -- back 4, up 1
			end
			vi = vi + (dlu - 6) * vvii + nvii -- down 5 or 6 or 7, northwards 1
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})


-- Passage south

minetest.register_abm({
	nodenames = {"catacomb:pas"},
	interval = 14,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_stairn = minetest.get_content_id("catacomb:stairn")
		local c_stairs = minetest.get_content_id("catacomb:stairs")
		local c_chs = minetest.get_content_id("catacomb:chs")
		local dlu = math.random(-1, 1)
		local len = math.random(MINLEN, MAXLEN)
		local vmvd, vmvu -- voxelmanip volume down, up
		if dlu == -1 then -- down
			vmvd = -len
			vmvu = 5
		elseif dlu == 0 then -- level
			vmvd = 0
			vmvu = 5
		else -- up
			vmvd = 0
			vmvu = len + 5
		end

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x, y=y+vmvd, z=z-len}
		local pos2 = {x=x+3, y=y+vmvu, z=z}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		local vi = vi + 1 + vvii -- across 1, up 1 -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for i = 1, 2 do
				data[vi] = c_air
				vi = vi + 1
			end
			vi = vi - 2 + vvii -- back 2, up 1
		end

		local vi = area:index(x, y, z-1)
		for k = 1, len do
			for j = 1, 6 do
				for i = 1, 4 do
					local nodid = data[vi]
					if nodid ~= c_air
					and nodid ~= c_ignore
					and nodid ~= c_leaves -- no spawning in leaves
					and nodid ~= c_apple then
						if dlu ~= 0 and j == 1
						and not (dlu == 1 and k == 1)
						and not (dlu == -1 and k == len)
						and (i == 2 or i == 3) then
							if dlu == 1 then
								data[vi] = c_stairs
							else
								data[vi] = c_stairn
							end
						elseif k == len and j == 1 and i == 1 then
							data[vi] = c_chs
						elseif j == 1 or j == 6 or i == 1 or i == 4 then
							data[vi] = c_catcobble
						else
							data[vi] = c_air
						end
					end
					vi = vi + 1 -- eastwards 1
				end
				vi = vi - 4 + vvii -- back 4, up 1
			end
			vi = vi + (dlu - 6) * vvii - nvii -- down 5 or 6 or 7, southwards 1
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

-- Passage east

minetest.register_abm({
	nodenames = {"catacomb:pae"},
	interval = 15,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_staire = minetest.get_content_id("catacomb:staire")
		local c_stairw = minetest.get_content_id("catacomb:stairw")
		local c_che = minetest.get_content_id("catacomb:che")
		local dlu = math.random(-1, 1)
		local len = math.random(MINLEN, MAXLEN)
		local vmvd, vmvu -- voxelmanip volume down, up
		if dlu == -1 then -- down
			vmvd = -len
			vmvu = 5
		elseif dlu == 0 then -- level
			vmvd = 0
			vmvu = 5
		else -- up
			vmvd = 0
			vmvu = len + 5
		end

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x, y=y+vmvd, z=z}
		local pos2 = {x=x+len, y=y+vmvu, z=z+3}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		local vi = vi + nvii + vvii -- north 1, up 1 -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for k = 1, 2 do
				data[vi] = c_air
				vi = vi + nvii
			end
			vi = vi - 2 * nvii + vvii -- back 2, up 1
		end

		local vi = area:index(x+1, y, z)
		for i = 1, len do
			for j = 1, 6 do
				for k = 1, 4 do
					local nodid = data[vi]
					if nodid ~= c_air
					and nodid ~= c_ignore
					and nodid ~= c_leaves -- no spawning in leaves
					and nodid ~= c_apple then
						if dlu ~= 0 and j == 1
						and not (dlu == 1 and i == 1)
						and not (dlu == -1 and i == len)
						and (k == 2 or k == 3) then
							if dlu == -1 then
								data[vi] = c_stairw
							else
								data[vi] = c_staire
							end
						elseif i == len and j == 1 and k == 1 then
							data[vi] = c_che
						elseif j == 1 or j == 6 or k == 1 or k == 4 then
							data[vi] = c_catcobble
						else
							data[vi] = c_air
						end
					end
					vi = vi + nvii -- northwards 1
				end
				vi = vi - 4 * nvii + vvii -- back 4, up 1
			end
			vi = vi + (dlu - 6) * vvii + 1 -- down 5 or 6 or 7, eastwards 1
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})


-- Passage west

minetest.register_abm({
	nodenames = {"catacomb:paw"},
	interval = 16,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_staire = minetest.get_content_id("catacomb:staire")
		local c_stairw = minetest.get_content_id("catacomb:stairw")
		local c_chw = minetest.get_content_id("catacomb:chw")
		local dlu = math.random(-1, 1)
		local len = math.random(MINLEN, MAXLEN)
		local vmvd, vmvu -- voxelmanip volume down, up
		if dlu == -1 then -- down
			vmvd = -len
			vmvu = 5
		elseif dlu == 0 then -- level
			vmvd = 0
			vmvu = 5
		else -- up
			vmvd = 0
			vmvu = len + 5
		end

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x-len, y=y+vmvd, z=z}
		local pos2 = {x=x, y=y+vmvu, z=z+3}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		local vi = vi + nvii + vvii -- north 1, up 1 -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for k = 1, 2 do
				data[vi] = c_air
				vi = vi + nvii
			end
			vi = vi - 2 * nvii + vvii -- back 2, up 1
		end

		local vi = area:index(x-1, y, z)
		for i = 1, len do
			for j = 1, 6 do
				for k = 1, 4 do
					local nodid = data[vi]
					if nodid ~= c_air
					and nodid ~= c_ignore
					and nodid ~= c_leaves -- no spawning in leaves
					and nodid ~= c_apple then
						if dlu ~= 0 and j == 1
						and not (dlu == 1 and i == 1)
						and not (dlu == -1 and i == len)
						and (k == 2 or k == 3) then
							if dlu == 1 then
								data[vi] = c_stairw
							else
								data[vi] = c_staire
							end
						elseif i == len and j == 1 and k == 1 then
							data[vi] = c_chw
						elseif j == 1 or j == 6 or k == 1 or k == 4 then
							data[vi] = c_catcobble
						else
							data[vi] = c_air
						end
					end
					vi = vi + nvii -- northwards 1
				end
				vi = vi - 4 * nvii + vvii -- back 4, up 1
			end
			vi = vi + (dlu - 6) * vvii - 1 -- down 5 or 6 or 7, westwards 1
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

-- Chamber north

minetest.register_abm({
	nodenames = {"catacomb:chn"},
	interval = 17,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local c_mobble = minetest.get_content_id("default:mossycobble")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_stobble = minetest.get_content_id("stairs:stair_cobble")
		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_pan = minetest.get_content_id("catacomb:pan")
		local c_pae = minetest.get_content_id("catacomb:pae")
		local c_paw = minetest.get_content_id("catacomb:paw")
		local widew = math.random(MINWID, MAXWID) - 1
		local vmvw = -math.random(0, widew - 3)
		local vmve = widew + vmvw
		local vmvn = math.random(MINWID, MAXWID) - 1
		local vmvu = math.random(MINHEI, MAXHEI) - 1
		local exoffn = math.random(0, widew - 3)
		local exoffe = math.random(0, vmvn - 3)
		local exoffw = math.random(0, vmvn - 3)

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x+vmvw, y=y, z=z}
		local pos2 = {x=x+vmve, y=y+vmvu, z=z+vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then
			for k = 1, vmvn do -- check for obstruction
			for j = 0, vmvu do
				local vi = area:index(x+vmvw, y + j, z + k)
				for i = 0, widew do
					local nodid = data[vi]
					if nodid == c_catcobble then
						vm:set_data(data) -- abort chamber spawn
						vm:write_to_map()
						vm:update_map()
						return
					end
					vi = vi + 1
				end
			end
			end
		end

		local paspawn = GEN -- whether to place passage spawners
		and x > XMIN and x < XMAX and y > YMIN and y < YMAX and z > ZMIN and z < ZMAX

		for k = 1, vmvn do -- spawn chamber
		for j = 0, vmvu do
			local vi = area:index(x+vmvw, y + j, z + k)
			for i = 0, widew do
				local nodid = data[vi]
				if nodid ~= c_air
				and nodid ~= c_ignore
				and nodid ~= c_cobble -- default dungeons remain
				and nodid ~= c_mobble
				and nodid ~= c_stobble
				and nodid ~= c_leaves
				and nodid ~= c_apple then
					if paspawn and k == vmvn and j == 0 and i == exoffn then
						data[vi] = c_pan -- passage spawner
					elseif paspawn and i == widew and j == 0 and k == exoffe then
						data[vi] = c_pae
					elseif paspawn and i == 0 and j == 0 and k == exoffw then
						data[vi] = c_paw
					elseif (k >= 2 and k <= vmvn - 1
					and j >= 1 and j <= vmvu - 1
					and i >= 1 and i <= widew - 1)
					or (k == 1 and j >= 1 and j <= 4
					and (i == 1 - vmvw or i == 2 - vmvw)) then
						data[vi] = c_air
					else
						data[vi] = c_catcobble
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

-- Chamber south

minetest.register_abm({
	nodenames = {"catacomb:chs"},
	interval = 18,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local c_mobble = minetest.get_content_id("default:mossycobble")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_stobble = minetest.get_content_id("stairs:stair_cobble")
		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_pas = minetest.get_content_id("catacomb:pas")
		local c_pae = minetest.get_content_id("catacomb:pae")
		local c_paw = minetest.get_content_id("catacomb:paw")
		local widew = math.random(MINWID, MAXWID) - 1
		local vmvw = -math.random(0, widew - 3)
		local vmve = widew + vmvw
		local vmvs = math.random(MINWID, MAXWID) - 1
		local vmvu = math.random(MINHEI, MAXHEI) - 1
		local exoffs = math.random(0, widew - 3)
		local exoffe = math.random(0, vmvs - 3)
		local exoffw = math.random(0, vmvs - 3)

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x+vmvw, y=y, z=z-vmvs}
		local pos2 = {x=x+vmve, y=y+vmvu, z=z}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then
			for k = 1, vmvs do -- check for obstruction
			for j = 0, vmvu do
				local vi = area:index(x+vmvw, y + j, z - k)
				for i = 0, widew do
					local nodid = data[vi]
					if nodid == c_catcobble then
						vm:set_data(data) -- abort chamber spawn
						vm:write_to_map()
						vm:update_map()
						return
					end
					vi = vi + 1
				end
			end
			end
		end

		local paspawn = GEN
		and x > XMIN and x < XMAX and y > YMIN and y < YMAX and z > ZMIN and z < ZMAX

		for k = 1, vmvs do -- spawn chamber
		for j = 0, vmvu do
			local vi = area:index(x+vmvw, y + j, z - k)
			for i = 0, widew do
				local nodid = data[vi]
				if nodid ~= c_air
				and nodid ~= c_ignore
				and nodid ~= c_cobble -- default dungeons remain
				and nodid ~= c_mobble
				and nodid ~= c_stobble
				and nodid ~= c_leaves
				and nodid ~= c_apple then
					if paspawn and k == vmvs and j == 0 and i == exoff then
						data[vi] = c_pas -- passage spawner
					elseif paspawn and i == widew and j == 0 and k == exoffe then
						data[vi] = c_pae
					elseif paspawn and i == 0 and j == 0 and k == exoffw then
						data[vi] = c_paw
					elseif (k >= 2 and k <= vmvs - 1
					and j >= 1 and j <= vmvu - 1
					and i >= 1 and i <= widew - 1)
					or (k == 1 and j >= 1 and j <= 4
					and (i == 1 - vmvw or i == 2 - vmvw)) then
						data[vi] = c_air
					else
						data[vi] = c_catcobble
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

-- Chamber east

minetest.register_abm({
	nodenames = {"catacomb:che"},
	interval = 19,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local c_mobble = minetest.get_content_id("default:mossycobble")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_stobble = minetest.get_content_id("stairs:stair_cobble")
		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_pan = minetest.get_content_id("catacomb:pan")
		local c_pas = minetest.get_content_id("catacomb:pas")
		local c_pae = minetest.get_content_id("catacomb:pae")
		local widns = math.random(MINWID, MAXWID) - 1
		local vmvs = -math.random(0, widns - 3)
		local vmvn = widns + vmvs
		local vmve = math.random(MINWID, MAXWID) - 1
		local vmvu = math.random(MINHEI, MAXHEI) - 1
		local exoffn = math.random(0, vmve - 3)
		local exoffs = math.random(0, vmve - 3)
		local exoffe = math.random(0, widns - 3)

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x, y=y, z=z+vmvs}
		local pos2 = {x=x+vmve, y=y+vmvu, z=z+vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then
			for k = vmvs, vmvn do -- check for obstruction
			for j = 0, vmvu do
				local vi = area:index(x+1, y+j, z+k)
				for i = 1, vmve do
					local nodid = data[vi]
					if nodid == c_catcobble then
						vm:set_data(data) -- abort chamber spawn
						vm:write_to_map()
						vm:update_map()
						return
					end
					vi = vi + 1
				end
			end
			end
		end

		local paspawn = GEN
		and x > XMIN and x < XMAX and y > YMIN and y < YMAX and z > ZMIN and z < ZMAX

		for k = vmvs, vmvn do -- spawn chamber
		for j = 0, vmvu do
			local vi = area:index(x+1, y+j, z+k)
			for i = 1, vmve do
				local nodid = data[vi]
				if nodid ~= c_air
				and nodid ~= c_ignore
				and nodid ~= c_cobble -- default dungeons remain
				and nodid ~= c_mobble
				and nodid ~= c_stobble
				and nodid ~= c_leaves
				and nodid ~= c_apple then
					if paspawn and i == vmve and j == 0 and k == vmvs + exoffe then
						data[vi] = c_pae -- passage spawner
					elseif paspawn and k == vmvn and j == 0 and i == exoffn then
						data[vi] = c_pan
					elseif paspawn and k == vmvs and j == 0 and i == exoffs then
						data[vi] = c_pas
					elseif (i >= 2 and i <= vmve - 1
					and j >= 1 and j <= vmvu - 1
					and k >= vmvs + 1 and k <= vmvn - 1)
					or (i == 1 and j >= 1 and j <= 4
					and (k == 1 or k == 2)) then
						data[vi] = c_air
					else
						data[vi] = c_catcobble
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

-- Chamber west

minetest.register_abm({
	nodenames = {"catacomb:chw"},
	interval = 20,
	chance = 1,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local c_mobble = minetest.get_content_id("default:mossycobble")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_stobble = minetest.get_content_id("stairs:stair_cobble")
		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_pan = minetest.get_content_id("catacomb:pan")
		local c_pas = minetest.get_content_id("catacomb:pas")
		local c_paw = minetest.get_content_id("catacomb:paw")
		local widns = math.random(MINWID, MAXWID) - 1
		local vmvs = -math.random(0, widns - 3)
		local vmvn = widns + vmvs
		local vmvw = math.random(MINWID, MAXWID) - 1
		local vmvu = math.random(MINHEI, MAXHEI) - 1
		local exoffn = math.random(0, vmvw - 3)
		local exoffs = math.random(0, vmvw - 3)
		local exoffw = math.random(0, widns - 3)

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x-vmvw, y=y, z=z+vmvs}
		local pos2 = {x=x, y=y+vmvu, z=z+vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then
			for k = vmvs, vmvn do -- check for obstruction
			for j = 0, vmvu do
				local vi = area:index(x-vmvw, y+j, z+k)
				for i = 1, vmvw do
					local nodid = data[vi]
					if nodid == c_catcobble then
						vm:set_data(data) -- abort chamber spawn
						vm:write_to_map()
						vm:update_map()
						return
					end
					vi = vi + 1
				end
			end
			end
		end

		local paspawn = GEN
		and x > XMIN and x < XMAX and y > YMIN and y < YMAX and z > ZMIN and z < ZMAX

		for k = vmvs, vmvn do -- spawn chamber
		for j = 0, vmvu do
			local vi = area:index(x-vmvw, y+j, z+k)
			for i = 1, vmvw do
				local nodid = data[vi]
				if nodid ~= c_air
				and nodid ~= c_ignore
				and nodid ~= c_cobble -- default dungeons remain
				and nodid ~= c_mobble
				and nodid ~= c_stobble
				and nodid ~= c_leaves
				and nodid ~= c_apple then
					if paspawn and i == 1 and j == 0 and k == vmvs + exoffw then
						data[vi] = c_paw -- passage spawner
					elseif paspawn and k == vmvn and j == 0 and i == exoffn then
						data[vi] = c_pan
					elseif paspawn and k == vmvs and j == 0 and i == exoffs then
						data[vi] = c_pas
					elseif (i >= 2 and i <= vmvw - 1
					and j >= 1 and j <= vmvu - 1
					and k >= vmvs + 1 and k <= vmvn - 1)
					or (i == vmvw and j >= 1 and j <= 4
					and (k == 1 or k == 2)) then
						data[vi] = c_air
					else
						data[vi] = c_catcobble
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

