-- catacomb 0.3.1 by paramat
-- For Minetest 0.4.8 and later
-- Depends default
-- License: code WTFPL

-- Parameters

local YMIN = -33000 -- Approximate generation limits
local YMAX = 33000
local XMIN = -33000
local XMAX = 33000
local ZMIN = -33000
local ZMAX = 33000

local YMAXSPA = -112 -- Maximum y for initial catacomb spawn

local SEED = 5829058
local OCTA = 3
local PERS = 0.5
local SCAL = 512
local TCATSPA = 2 -- 3D noise threshold for catacomb spawn
local TCATA = -2 -- 3D noise threshold for catacomb generation
local GEN = true -- Enable generation
local OBCHECK = true -- Enable chamber obstruction check
local ABMINT = 1 -- ABM interval multiplier, 1 = fast generation

local MINPLEN = 3 -- Min max length for passages
local MAXPLEN = 32
local MINPWID = 3 -- Min max (outer) width for passages
local MAXPWID = 24

local MINCWID = 8 -- Min max EW NS widths, min max height, for chambers
local MAXCWID = 32
local MINCHEI = 6
local MAXCHEI = 32

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

minetest.register_node("catacomb:chambern", {
	description = "Chamber spawner north 030",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

-- ABM

-- Passage north

minetest.register_abm({
	nodenames = {"catacomb:pan"},
	interval = 17 * ABMINT,
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
		print ("[catacomb] Passage north "..len)
	end,
})


-- Passage south

minetest.register_abm({
	nodenames = {"catacomb:pas"},
	interval = 18 * ABMINT,
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
		print ("[catacomb] Passage south "..len)
	end,
})

-- Passage east

minetest.register_abm({
	nodenames = {"catacomb:pae"},
	interval = 19 * ABMINT,
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
		print ("[catacomb] Passage east "..len)
	end,
})


-- Passage west

minetest.register_abm({
	nodenames = {"catacomb:paw"},
	interval = 20 * ABMINT,
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
		print ("[catacomb] Passage west "..len)
	end,
})

-- Chamber north

minetest.register_abm({
	nodenames = {"catacomb:chn"},
	interval = 21 * ABMINT,
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
		local exoffe = math.random(1, vmvn - 3)
		local exoffw = math.random(1, vmvn - 3)

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

		local perlin = minetest.get_perlin(SEED, OCTA, PERS, SCAL)
		local n_cata = perlin:get3d({x=x,y=y,z=z})
		local paspawn = GEN and n_cata > TCATA -- whether to place passage spawners
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
		print ("[catacomb] Chamber north")
	end,
})

-- Chamber south

minetest.register_abm({
	nodenames = {"catacomb:chs"},
	interval = 22 * ABMINT,
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
		local exoffe = math.random(1, vmvs - 3)
		local exoffw = math.random(1, vmvs - 3)

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

		local perlin = minetest.get_perlin(SEED, OCTA, PERS, SCAL)
		local n_cata = perlin:get3d({x=x,y=y,z=z})
		local paspawn = GEN and n_cata > TCATA -- whether to place passage spawners
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
					if paspawn and k == vmvs and j == 0 and i == exoffs then
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
		print ("[catacomb] Chamber south")
	end,
})

-- Chamber east

minetest.register_abm({
	nodenames = {"catacomb:che"},
	interval = 23 * ABMINT,
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
		local exoffn = math.random(1, vmve - 3)
		local exoffs = math.random(1, vmve - 3)
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

		local perlin = minetest.get_perlin(SEED, OCTA, PERS, SCAL)
		local n_cata = perlin:get3d({x=x,y=y,z=z})
		local paspawn = GEN and n_cata > TCATA -- whether to place passage spawners
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
		print ("[catacomb] Chamber east")
	end,
})

-- Chamber west

minetest.register_abm({
	nodenames = {"catacomb:chw"},
	interval = 24 * ABMINT,
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
		local exoffn = math.random(1, vmvw - 3)
		local exoffs = math.random(1, vmvw - 3)
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

		local perlin = minetest.get_perlin(SEED, OCTA, PERS, SCAL)
		local n_cata = perlin:get3d({x=x,y=y,z=z})
		local paspawn = GEN and n_cata > TCATA -- whether to place passage spawners
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
		print ("[catacomb] Chamber west")
	end,
})

minetest.register_on_generated(function(minp, maxp, seed)
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	if not GEN
	or not (x0 > XMIN and x0 < XMAX and y0 > YMIN and y0 <= YMAXSPA and z0 > ZMIN and z0 < ZMAX) then
		return
	end
	local perlin = minetest.get_perlin(SEED, OCTA, PERS, SCAL)
	local n_catspa = perlin:get3d({x=x0,y=y0,z=z0})
	if n_catspa > TCATSPA then
		minetest.add_node({x=x0,y=y0,z=z0},{name="catacomb:chs"})
		print ("[catacomb] Spawn catacomb "..x0.." "..y0.." "..z0)
	end
end)

-- Chamber north v0.3.0

minetest.register_abm({
	nodenames = {"catacomb:chambern"},
	interval = 21 * ABMINT,
	chance = 1,
	action = function(pos, node)
		local t1 = os.clock()
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
		local c_stairn = minetest.get_content_id("catacomb:stairn")
		local c_stairs = minetest.get_content_id("catacomb:stairs")
		local c_chambern = minetest.get_content_id("catacomb:chambern")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x+MINPWID, y=y, z=z}
		local pos2 = {x=x+MAXCWID, y=y, z=z}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		local wallwid
		local vi = area:index(x+MINPWID, y, z)
		for i = MINPWID, MAXCWID do
			if data[vi] ~= c_catcobble then
				wallwid = i
				break
			end
			vi = vi + 1
		end

		local passwid = math.random(MINPWID, math.min(MAXPWID, wallwid)) -- width including walls
		local passdlu = math.random(-1, 1) -- passage direction, -1 down, 0 level, 1 up
		local passlen = math.random(MINPLEN, MAXPLEN)

		local chamew = math.random(passwid, MAXCWID) - 1
		local chamns = math.random(MINCWID, MAXCWID) - 1
		local chamhei = math.random(MINCHEI, MAXCHEI) - 1
		local chamhoff = -math.random(0, chamew + 1 - passwid) -- chamber W offset relative to passage
		local chamvoff = math.min(passdlu * passlen, passlen - 1)
		local exoffn = math.random(0, chamew - 3)

		local vmvd = math.min(chamvoff, 0) -- voxel manip volume edges relative to spawner
		local vmvu = math.max(chamvoff + chamhei, 5)
		local vmvw = chamhoff
		local vmve = chamhoff + chamew
		local vmvn = chamns + passlen

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x+vmvw, y=y+vmvd, z=z}
		local pos2 = {x=x+vmve, y=y+vmvu, z=z+vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then -- check for obstruction
			for k = passlen + 1, vmvn do
			for j = chamvoff, chamvoff + chamhei do
				local vi = area:index(x+chamhoff, y+j, z+k)
				for i = 0, chamew do
					local nodid = data[vi]
					if nodid == c_catcobble then
						vm:set_data(data) -- abort chamber spawn
						vm:write_to_map()
						vm:update_map()
						print ("[catacomb] Chamber obstructed")
						return
					end
					vi = vi + 1
				end
			end
			end
		end

		local vi = area:index(x+1, y+1, z) -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for i = 1, passwid - 2 do
				data[vi] = c_air
				vi = vi + 1
			end
			vi = vi - passwid + 2 + vvii -- back 2, up 1
		end

		local vi = area:index(x, y, z+1)
		for k = 1, passlen do
			for j = 1, 6 do
				for i = 1, passwid do
					local nodid = data[vi]
					if nodid ~= c_air
					and nodid ~= c_ignore
					and nodid ~= c_leaves -- no spawning in leaves
					and nodid ~= c_apple then
						if passdlu ~= 0 and j == 1
						and not (passdlu == 1 and k == 1)
						and not (passdlu == -1 and k == len)
						and (i >= 2 and i <= passwid - 1) then
							if passdlu == -1 then
								data[vi] = c_stairs
							else
								data[vi] = c_stairn
							end
						elseif j == 1 or j == 6 or i == 1 or i == passwid then
							data[vi] = c_catcobble
						else
							data[vi] = c_air
						end
					end
					vi = vi + 1 -- eastwards 1
				end
				vi = vi - passwid + vvii -- back passwid, up 1
			end
			vi = vi + (passdlu - 6) * vvii + nvii -- down 5 or 6 or 7, northwards 1
		end

		for k = passlen + 1, vmvn do -- spawn chamber
		for j = chamvoff, chamvoff + chamhei do
			local vi = area:index(x+chamhoff, y+j, z+k)
			for i = 0, chamew do
				local nodid = data[vi]
				if nodid ~= c_air
				and nodid ~= c_ignore
				and nodid ~= c_cobble -- default dungeons remain
				and nodid ~= c_mobble
				and nodid ~= c_stobble
				and nodid ~= c_leaves
				and nodid ~= c_apple then
					if k == vmvn and j == chamvoff and i == exoffn then
						data[vi] = c_chambern
					elseif (k > passlen + 1 and k < vmvn
					and j > chamvoff and j < chamvoff + chamhei
					and i > 0 and i < chamew)
					or (k == passlen + 1 and j > chamvoff and j <= chamvoff + 4
					and (i > -chamhoff and i < -chamhoff + passwid - 1)) then
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

		local chugent = math.ceil((os.clock() - t1) * 1000)
		print ("[catacomb] Chamber north "..chugent)
	end,
})

