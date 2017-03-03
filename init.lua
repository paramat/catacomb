-- Parameters

-- Approximate generation limits
local YMIN = -33000
local YMAX = 33000
local XMIN = -33000
local XMAX = 33000
local ZMIN = -33000
local ZMAX = 33000
local YMAXSPA = -33 -- Maximum y for initial catacomb spawn and steps in air

-- Spawn and generation
local TCATSPA = 2.0 -- 3D noise threshold for initial chamber
local TCATA = -2.0 -- 3D noise for generation limit
local GEN = true -- Enable spawn and generation
local OBCHECK = true -- Enable chamber obstruction check
local ABMINT = 1 -- ABM interval multiplier, 1 = fast generation

-- Spawn and generation noise
local np_cata = {
	offset = 0,
	scale = 1,
	spread = {x = 256, y = 256, z = 256},
	seed = 5829058,
	octaves = 3,
	persist = 0.5,
	lacunarity = 2.0,
	--flags = ""
}

-- Passages
local MINPLEN = 3 -- Min max length
local MAXPLEN = 32
local MINPWID = 3 -- Min max outer width
local MAXPWID = 24

-- Chambers
local MINCWID = 6 -- Min max outer EW NS widths, min max outer height.
local MAXCWID = 32
local MINCHEI = 6
local MAXCHEI = 32


-- Nodes

minetest.register_node("catacomb:cobble", {
	description = "Mod cobblestone",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	drop = "default:cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:stairn", {
	description = "Stair north",
	tiles = {"default_cobble.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
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
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
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
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
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
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, -0.5, 0, 0.5, 0.5},
		},
	},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chambern", {
	description = "Chamber spawner north",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chambers", {
	description = "Chamber spawner south",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chambere", {
	description = "Chamber spawner east",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chamberw", {
	description = "Chamber spawner west",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	sounds = default.node_sound_stone_defaults(),
})


-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z

	-- Check mapchunk is within limits
	if not (x0 > XMIN and x1 < XMAX and
			y0 > YMIN and y1 <= YMAXSPA and
			z0 > ZMIN and z1 < ZMAX) or not GEN then
		return
	end

	-- Check minimum point is within catacomb spawn volume
	local nobj_cata = minetest.get_perlin(np_cata)
	local nval_cata = nobj_cata:get3d({x = x0, y = y0, z = z0})
	if nval_cata < TCATSPA then 
		--print ("[catacomb] Spawn noise " .. nval_cata)
		return
	end

	-- Check for nearby catacomb cobble
	local sidelen = x1 - x0 + 1
	local sidelen2 = sidelen * 2
	local c_catcobble = minetest.get_content_id("catacomb:cobble")
	for vmvns = z0 - sidelen2, z0 + sidelen2, sidelen do -- Step sidelen
	for vmvud = y0 - sidelen2, y0 + sidelen2, sidelen do
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x0 - sidelen2, y = vmvud, z = vmvns}
		local pos2 = {x = x0 + sidelen2, y = vmvud, z = vmvns}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()

		for vi = 1, sidelen * 4 do
			if data[vi] == c_catcobble then
				print ("[catacomb] First chamber obstructed")
				return
			end
		end
	end
	end

	-- Spawn first chamber
	local t1 = os.clock()
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")
	local c_cobble = minetest.get_content_id("default:cobble")
	local c_mobble = minetest.get_content_id("default:mossycobble")
	local c_stobble = minetest.get_content_id("stairs:stair_cobble")
	local c_chambers = minetest.get_content_id("catacomb:chambers")

	local vm = minetest.get_voxel_manip()
	local pos1 = {x = x0, y = y0, z = z0}
	local pos2 = {x = x0 + MAXCWID, y = y0 + MAXCHEI, z = z0 + MAXCWID}
	local emin, emax = vm:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()

	local exoffs = math.random(0, MAXCWID - 3)

	for z = z0, z0 + MAXCWID do
	for y = y0, y0 + MAXCHEI do
		local vi = area:index(x0, y, z)
		for x = x0, x0 + MAXCWID do
			local nodid = data[vi]
			if nodid ~= c_air
					and nodid ~= c_ignore
					and nodid ~= c_cobble
					and nodid ~= c_mobble
					and nodid ~= c_stobble then
				if z == z0 and y == y0 and x == x0 + exoffs then
					data[vi] = c_chambers
				elseif (z > z0 and z < z0 + MAXCWID
						and y > y0 and y < y0 + MAXCHEI
						and x > x0 and x < x0 + MAXCWID) then
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
	print ("[catacomb] Spawn first chamber " .. chugent ..
		" ms  minp " .. x0 .. " " .. y0 .. " " .. z0)
end)


-- ABM

-- Chamber north

minetest.register_abm({
	nodenames = {"catacomb:chambern"},
	interval = 16 * ABMINT,
	chance = 1,
	catch_up = false,
	action = function(pos, node)
		--local t1 = os.clock()
		local x = pos.x
		local y = pos.y
		local z = pos.z

		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local c_mobble = minetest.get_content_id("default:mossycobble")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_jleaves = minetest.get_content_id("default:jungleleaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_stobble = minetest.get_content_id("stairs:stair_cobble")

		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_stairn = minetest.get_content_id("catacomb:stairn")
		local c_stairs = minetest.get_content_id("catacomb:stairs")
		local c_chambern = minetest.get_content_id("catacomb:chambern")
		local c_chambere = minetest.get_content_id("catacomb:chambere")
		local c_chamberw = minetest.get_content_id("catacomb:chamberw")

		-- Measure existing chamber wall width
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x + MINPWID, y = y, z = z}
		local pos2 = {x = x + MAXCWID, y = y, z = z}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()

		local wallwid = MINPWID
		local vi = area:index(x + MINPWID, y, z)
		for i = MINPWID, MAXCWID do
			if data[vi] ~= c_catcobble then
				wallwid = i
				break
			end
			vi = vi + 1
		end

		-- Calculate dimensions of passage and chamber
		local passwid = math.random(MINPWID, math.min(MAXPWID, wallwid)) -- Width including walls
		local passdlu = math.random(-1, 1) -- Passage direction, -1 down, 0 level, 1 up.
		local passlen = math.random(MINPLEN, MAXPLEN)

		local chamew = math.random(math.max(passwid, MINCWID), MAXCWID) - 1
		local chamns = math.random(MINCWID, MAXCWID) - 1
		local chamhei = math.random(MINCHEI, MAXCHEI) - 1
		local chamhoff = -math.random(0, chamew + 1 - passwid) -- Chamber W offset relative to passage
		local chamvoff = math.min(passdlu * passlen, passlen - 1)
		local exoffn = math.random(0, chamew - 3)
		local exoffe = math.random(0, chamns - 3)
		local exoffw = math.random(0, chamns - 3)

		local vmvd = math.min(chamvoff, 0) -- Voxelmanip volume edges relative to spawner
		local vmvu = math.max(chamvoff + chamhei, 5)
		local vmvw = chamhoff
		local vmve = chamhoff + chamew
		local vmvn = chamns + passlen

		-- Read entire volume
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x + vmvw, y = y + vmvd, z = z}
		local pos2 = {x = x + vmve, y = y + vmvu, z = z + vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- Remove spawner
		data[vi] = c_catcobble

		-- Check for obstruction
		if OBCHECK then 
			for k = passlen + 1, vmvn do
			for j = chamvoff, chamvoff + chamhei do
				local vi = area:index(x + chamhoff, y + j, z + k)
				for i = 0, chamew do
					local nodid = data[vi]
					if nodid == c_catcobble then
						vm:set_data(data) -- To remove spawner
						vm:write_to_map()
						vm:update_map()
						--print ("[catacomb] Chamber obstructed")
						return
					end
					vi = vi + 1
				end
			end
			end
		end

		-- Carve hole in chamber wall
		local vi = area:index(x + 1, y + 1, z)
		for j = 1, 4 do
			for i = 1, passwid - 2 do
				data[vi] = c_air
				vi = vi + 1
			end
			vi = vi - passwid + 2 + vvii -- Back 2, up 1.
		end

		-- Spawn passage
		local vi = area:index(x, y, z + 1)
		for k = 1, passlen do
			for j = 1, 6 do
				for i = 1, passwid do
					local nodid = data[vi]
					if nodid ~= c_ignore then
						if passdlu ~= 0 and j == 1 -- steps spawn in underground air
								and not (passdlu == 1 and k == 1)
								and not (passdlu == -1 and k == len)
								and (i >= 2 and i <= passwid - 1)
								and (nodid ~= c_air or y <= YMAXSPA) then
							if passdlu == -1 then
								data[vi] = c_stairs
								data[vi - vvii] = c_catcobble
							else
								data[vi] = c_stairn
								data[vi - vvii] = c_catcobble
							end
						elseif passdlu == 0 and j == 1 and
								(i >= 2 and i <= passwid - 1) then
							data[vi] = c_catcobble -- Level passage floor spawns in air
						elseif nodid ~= c_air then
							if j == 1 or j == 6 or i == 1 or i == passwid then
								data[vi] = c_catcobble
							else
								data[vi] = c_air
							end
						end
					end
					vi = vi + 1 -- Eastwards 1
				end
				vi = vi - passwid + vvii -- Back passwid, up 1.
			end
			vi = vi + (passdlu - 6) * vvii + nvii -- Down 5 or 6 or 7, northwards 1.
		end

		-- Decide whether to place spawners in chamber
		local nobj_cata = minetest.get_perlin(np_cata)
		local spawn = GEN and nobj_cata:get3d(
			{x = x + chamhoff, y = y + chamvoff, z = z + vmvn}) > TCATA and
			x > XMIN and x < XMAX and y > YMIN and y < YMAX and z > ZMIN and z < ZMAX

		-- Spawn chamber
		for k = passlen + 1, vmvn do
		for j = chamvoff, chamvoff + chamhei do
			local vi = area:index(x + chamhoff, y + j, z + k)
			for i = 0, chamew do
				local nodid = data[vi]
				if nodid ~= c_air
						and nodid ~= c_ignore
						and nodid ~= c_cobble -- Default dungeons remain TODO update for new dungeons
						and nodid ~= c_mobble
						and nodid ~= c_stobble then
					if spawn and k == vmvn and j == chamvoff and i == exoffn then
						data[vi] = c_chambern
					elseif spawn and i == chamew and j == chamvoff and
							k == passlen + 1 + exoffe then
						data[vi] = c_chambere
					elseif spawn and i == 0 and j == chamvoff and
							k == passlen + 1 + exoffw then
						data[vi] = c_chamberw
					elseif (k > passlen + 1 and k < vmvn and j > chamvoff and
							j < chamvoff + chamhei and i > 0 and i < chamew) or
							(k == passlen + 1 and j > chamvoff and j <= chamvoff + 4 and
							(i > -chamhoff and i < -chamhoff + passwid - 1)) then
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

		--local chugent = math.ceil((os.clock() - t1) * 1000)
		--print ("[catacomb] Chamber North " .. chugent .. "ms")
	end,
})


-- Chamber south

minetest.register_abm({
	nodenames = {"catacomb:chambers"},
	interval = 17 * ABMINT,
	chance = 1,
	catch_up = false,
	action = function(pos, node)
		--local t1 = os.clock()
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local c_mobble = minetest.get_content_id("default:mossycobble")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_jleaves = minetest.get_content_id("default:jungleleaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_stobble = minetest.get_content_id("stairs:stair_cobble")

		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_stairn = minetest.get_content_id("catacomb:stairn")
		local c_stairs = minetest.get_content_id("catacomb:stairs")
		local c_chambers = minetest.get_content_id("catacomb:chambers")
		local c_chambere = minetest.get_content_id("catacomb:chambere")
		local c_chamberw = minetest.get_content_id("catacomb:chamberw")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x + MINPWID, y = y, z = z}
		local pos2 = {x = x + MAXCWID, y = y, z = z}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()

		local wallwid = MINPWID
		local vi = area:index(x + MINPWID, y, z)
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

		local chamew = math.random(math.max(passwid, MINCWID), MAXCWID) - 1
		local chamns = math.random(MINCWID, MAXCWID) - 1
		local chamhei = math.random(MINCHEI, MAXCHEI) - 1
		local chamhoff = -math.random(0, chamew + 1 - passwid) -- chamber W offset relative to passage
		local chamvoff = math.min(passdlu * passlen, passlen - 1)
		local exoffs = math.random(0, chamew - 3)
		local exoffe = math.random(0 + 3, chamns)
		local exoffw = math.random(0 + 3, chamns)

		local vmvd = math.min(chamvoff, 0) -- voxel manip volume edges relative to spawner
		local vmvu = math.max(chamvoff + chamhei, 5)
		local vmvw = chamhoff
		local vmve = chamhoff + chamew
		local vmvs = chamns + passlen

		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x + vmvw, y = y + vmvd, z = z - vmvs}
		local pos2 = {x = x + vmve, y  =y + vmvu, z = z}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then -- check for obstruction
			for k = passlen + 1, vmvs do
			for j = chamvoff, chamvoff + chamhei do
				local vi = area:index(x + chamhoff, y + j, z - k)
				for i = 0, chamew do
					local nodid = data[vi]
					if nodid == c_catcobble then
						vm:set_data(data) -- abort chamber spawn
						vm:write_to_map()
						vm:update_map()
						--print ("[catacomb] Chamber obstructed")
						return
					end
					vi = vi + 1
				end
			end
			end
		end

		local vi = area:index(x + 1, y + 1, z) -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for i = 1, passwid - 2 do
				data[vi] = c_air
				vi = vi + 1
			end
			vi = vi - passwid + 2 + vvii -- back 2, up 1
		end

		local vi = area:index(x, y, z - 1)
		for k = 1, passlen do
			for j = 1, 6 do
				for i = 1, passwid do
					local nodid = data[vi]
					if nodid ~= c_ignore then
						if passdlu ~= 0 and j == 1
								and not (passdlu == 1 and k == 1)
								and not (passdlu == -1 and k == len)
								and (i >= 2 and i <= passwid - 1)
								and (nodid ~= c_air or y <= YMAXSPA) then
							if passdlu == -1 then
								data[vi] = c_stairn
								data[vi - vvii] = c_catcobble
							else
								data[vi] = c_stairs
								data[vi - vvii] = c_catcobble
							end
						elseif passdlu == 0 and j == 1 and
								(i >= 2 and i <= passwid - 1) then
							data[vi] = c_catcobble
						elseif nodid ~= c_air then
							if j == 1 or j == 6 or i == 1 or i == passwid then
								data[vi] = c_catcobble
							else
								data[vi] = c_air
							end
						end
					end
					vi = vi + 1 -- eastwards 1
				end
				vi = vi - passwid + vvii -- back passwid, up 1
			end
			vi = vi + (passdlu - 6) * vvii - nvii -- down 5 or 6 or 7, southwards 1
		end

		-- Decide whether to place spawners in chamber
		local nobj_cata = minetest.get_perlin(np_cata)
		local spawn = GEN and nobj_cata:get3d(
			{x = x + chamhoff, y = y + chamvoff, z = z - vmvs}) > TCATA and
			x > XMIN and x < XMAX and y > YMIN and y < YMAX and z > ZMIN and z < ZMAX

		for k = passlen + 1, vmvs do -- spawn chamber
		for j = chamvoff, chamvoff + chamhei do
			local vi = area:index(x + chamhoff, y + j, z - k)
			for i = 0, chamew do
				local nodid = data[vi]
				if nodid ~= c_air
						and nodid ~= c_ignore
						and nodid ~= c_cobble -- default dungeons remain
						and nodid ~= c_mobble
						and nodid ~= c_stobble then
					if spawn and k == vmvs and j == chamvoff and i == exoffs then
						data[vi] = c_chambers
					elseif spawn and i == chamew and j == chamvoff and
							k == passlen + 1 + exoffe then
						data[vi] = c_chambere
					elseif spawn and i == 0 and j == chamvoff and
							k == passlen + 1 + exoffw then
						data[vi] = c_chamberw
					elseif (k > passlen + 1 and k < vmvs and j > chamvoff and
							j < chamvoff + chamhei and i > 0 and i < chamew) or
							(k == passlen + 1 and j > chamvoff and j <= chamvoff + 4 and
							(i > -chamhoff and i < -chamhoff + passwid - 1)) then
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

		--local chugent = math.ceil((os.clock() - t1) * 1000)
		--print ("[catacomb] Chamber south " .. chugent .. "ms")
	end,
})

-- Chamber east

minetest.register_abm({
	nodenames = {"catacomb:chambere"},
	interval = 18 * ABMINT,
	chance = 1,
	catch_up = false,
	action = function(pos, node)
		--local t1 = os.clock()
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local c_mobble = minetest.get_content_id("default:mossycobble")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_jleaves = minetest.get_content_id("default:jungleleaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_stobble = minetest.get_content_id("stairs:stair_cobble")

		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_staire = minetest.get_content_id("catacomb:staire")
		local c_stairw = minetest.get_content_id("catacomb:stairw")
		local c_chambern = minetest.get_content_id("catacomb:chambern")
		local c_chambers = minetest.get_content_id("catacomb:chambers")
		local c_chambere = minetest.get_content_id("catacomb:chambere")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x, y = y, z = z + MINPWID}
		local pos2 = {x = x, y = y, z = z + MAXCWID}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local wallwid = MINPWID
		local vi = area:index(x, y, z + MINPWID)
		for i = MINPWID, MAXCWID do
			if data[vi] ~= c_catcobble then
				wallwid = i
				break
			end
			vi = vi + nvii
		end

		local passwid = math.random(MINPWID, math.min(MAXPWID, wallwid)) -- width including walls
		local passdlu = math.random(-1, 1) -- passage direction, -1 down, 0 level, 1 up
		local passlen = math.random(MINPLEN, MAXPLEN)

		local chamns = math.random(math.max(passwid, MINCWID), MAXCWID) - 1
		local chamew = math.random(MINCWID, MAXCWID) - 1
		local chamhei = math.random(MINCHEI, MAXCHEI) - 1
		local chamhoff = -math.random(0, chamns + 1 - passwid) -- chamber S offset relative to passage
		local chamvoff = math.min(passdlu * passlen, passlen - 1)
		local exoffe = math.random(0, chamns - 3)
		local exoffn = math.random(0, chamew - 3)
		local exoffs = math.random(0, chamew - 3)

		local vmvd = math.min(chamvoff, 0) -- voxel manip volume edges relative to spawner
		local vmvu = math.max(chamvoff + chamhei, 5)
		local vmvs = chamhoff
		local vmvn = chamhoff + chamns
		local vmve = chamew + passlen

		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x, y = y + vmvd, z = z + vmvs}
		local pos2 = {x=x + vmve, y = y + vmvu, z = z + vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then -- check for obstruction
			for k = chamhoff, vmvn do
			for j = chamvoff, chamvoff + chamhei do
				local vi = area:index(x + passlen + 1, y + j, z + k)
				for i = 0, chamew do
					local nodid = data[vi]
					if nodid == c_catcobble then
						vm:set_data(data) -- abort chamber spawn
						vm:write_to_map()
						vm:update_map()
						--print ("[catacomb] Chamber obstructed")
						return
					end
					vi = vi + 1
				end
			end
			end
		end

		local vi = area:index(x, y + 1, z + 1) -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for k = 1, passwid - 2 do
				data[vi] = c_air
				vi = vi + nvii
			end
			vi = vi - (passwid - 2) * nvii + vvii -- back 2, up 1
		end

		local vi = area:index(x + 1, y, z)
		for i = 1, passlen do
			for j = 1, 6 do
				for k = 1, passwid do
					local nodid = data[vi]
					if nodid ~= c_ignore then
						if passdlu ~= 0 and j == 1
								and not (passdlu == 1 and i == 1)
								and not (passdlu == -1 and i == len)
								and (k >= 2 and k <= passwid - 1)
								and (nodid ~= c_air or y <= YMAXSPA) then
							if passdlu == -1 then
								data[vi] = c_stairw
								data[vi - vvii] = c_catcobble
							else
								data[vi] = c_staire
								data[vi - vvii] = c_catcobble
							end
						elseif passdlu == 0 and j == 1 and
								(k >= 2 and k <= passwid - 1) then
							data[vi] = c_catcobble
						elseif nodid ~= c_air then
							if j == 1 or j == 6 or k == 1 or k == passwid then
								data[vi] = c_catcobble
							else
								data[vi] = c_air
							end
						end
					end
					vi = vi + nvii -- northwards 1
				end
				vi = vi - passwid * nvii + vvii -- back passwid, up 1
			end
			vi = vi + (passdlu - 6) * vvii + 1 -- down 5 or 6 or 7, eastwards 1
		end

		-- Decide whether to place spawners in chamber
		local nobj_cata = minetest.get_perlin(np_cata)
		local spawn = GEN and nobj_cata:get3d(
			{x = x + vmve, y = y + chamvoff, z = z + chamhoff}) > TCATA and
			x > XMIN and x < XMAX and y > YMIN and y < YMAX and z > ZMIN and z < ZMAX

		for k = chamhoff, vmvn do -- spawn chamber
		for j = chamvoff, chamvoff + chamhei do
			local vi = area:index(x + passlen + 1, y + j, z + k)
			for i = 0, chamew do
				local nodid = data[vi]
				if nodid ~= c_air
						and nodid ~= c_ignore
						and nodid ~= c_cobble -- default dungeons remain
						and nodid ~= c_mobble
						and nodid ~= c_stobble then
					if spawn and k == chamhoff + exoffe and
							j == chamvoff and i == chamew then
						data[vi] = c_chambere
					elseif spawn and i == exoffn and j == chamvoff and k == vmvn then
						data[vi] = c_chambern
					elseif spawn and i == exoffs and j == chamvoff and k == chamhoff then
						data[vi] = c_chambers
					elseif (k > chamhoff and k < vmvn and j > chamvoff and
							j < chamvoff + chamhei and i > 0 and i < chamew) or
							(i == 0 and j > chamvoff and j <= chamvoff + 4 and
							(k > 0 and k < passwid - 1)) then
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

		--local chugent = math.ceil((os.clock() - t1) * 1000)
		--print ("[catacomb] Chamber east " .. chugent .. "ms")
	end,
})

-- Chamber west

minetest.register_abm({
	nodenames = {"catacomb:chamberw"},
	interval = 19 * ABMINT,
	chance = 1,
	catch_up = false,
	action = function(pos, node)
		--local t1 = os.clock()
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_cobble = minetest.get_content_id("default:cobble")
		local c_mobble = minetest.get_content_id("default:mossycobble")
		local c_leaves = minetest.get_content_id("default:leaves")
		local c_jleaves = minetest.get_content_id("default:jungleleaves")
		local c_apple = minetest.get_content_id("default:apple")
		local c_stobble = minetest.get_content_id("stairs:stair_cobble")

		local c_catcobble = minetest.get_content_id("catacomb:cobble")
		local c_staire = minetest.get_content_id("catacomb:staire")
		local c_stairw = minetest.get_content_id("catacomb:stairw")
		local c_chambern = minetest.get_content_id("catacomb:chambern")
		local c_chambers = minetest.get_content_id("catacomb:chambers")
		local c_chamberw = minetest.get_content_id("catacomb:chamberw")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x, y = y, z = z + MINPWID}
		local pos2 = {x = x, y = y, z = z + MAXCWID}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local wallwid = MINPWID
		local vi = area:index(x, y, z + MINPWID)
		for i = MINPWID, MAXCWID do
			if data[vi] ~= c_catcobble then
				wallwid = i
				break
			end
			vi = vi + nvii
		end

		local passwid = math.random(MINPWID, math.min(MAXPWID, wallwid)) -- width including walls
		local passdlu = math.random(-1, 1) -- passage direction, -1 down, 0 level, 1 up
		local passlen = math.random(MINPLEN, MAXPLEN)

		local chamns = math.random(math.max(passwid, MINCWID), MAXCWID) - 1
		local chamew = math.random(MINCWID, MAXCWID) - 1
		local chamhei = math.random(MINCHEI, MAXCHEI) - 1
		local chamhoff = -math.random(0, chamns + 1 - passwid) -- chamber S offset relative to passage
		local chamvoff = math.min(passdlu * passlen, passlen - 1)
		local exoffw = math.random(0, chamns - 3)
		local exoffn = math.random(0, chamew - 3)
		local exoffs = math.random(0, chamew - 3)

		local vmvd = math.min(chamvoff, 0) -- voxel manip volume edges relative to spawner
		local vmvu = math.max(chamvoff + chamhei, 5)
		local vmvs = chamhoff
		local vmvn = chamhoff + chamns
		local vmvw = chamew + passlen

		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x - vmvw, y = y + vmvd, z = z + vmvs}
		local pos2 = {x = x, y = y + vmvu, z = z + vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then -- check for obstruction
			for k = chamhoff, vmvn do
			for j = chamvoff, chamvoff + chamhei do
				local vi = area:index(x - vmvw, y + j, z + k)
				for i = 0, chamew - 1 do
					local nodid = data[vi]
					if nodid == c_catcobble then
						vm:set_data(data) -- abort chamber spawn
						vm:write_to_map()
						vm:update_map()
						--print ("[catacomb] Chamber obstructed")
						return
					end
					vi = vi + 1
				end
			end
			end
		end

		local vi = area:index(x, y + 1, z + 1) -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for k = 1, passwid - 2 do
				data[vi] = c_air
				vi = vi + nvii
			end
			vi = vi - (passwid - 2) * nvii + vvii -- back 2, up 1
		end

		local vi = area:index(x - 1, y, z)
		for i = 1, passlen do
			for j = 1, 6 do
				for k = 1, passwid do
					local nodid = data[vi]
					if nodid ~= c_ignore then
						if passdlu ~= 0 and j == 1
								and not (passdlu == 1 and i == 1)
								and not (passdlu == -1 and i == len)
								and (k >= 2 and k <= passwid - 1)
								and (nodid ~= c_air or y <= YMAXSPA) then
							if passdlu == -1 then
								data[vi] = c_staire
								data[vi - vvii] = c_catcobble
							else
								data[vi] = c_stairw
								data[vi - vvii] = c_catcobble
							end
						elseif passdlu == 0 and j == 1 and
								(k >= 2 and k <= passwid - 1) then
							data[vi] = c_catcobble
						elseif nodid ~= c_air then
							if j == 1 or j == 6 or k == 1 or k == passwid then
								data[vi] = c_catcobble
							else
								data[vi] = c_air
							end
						end
					end
					vi = vi + nvii -- northwards 1
				end
				vi = vi - passwid * nvii + vvii -- back passwid, up 1
			end
			vi = vi + (passdlu - 6) * vvii - 1 -- down 5 or 6 or 7, westwards 1
		end

		-- Decide whether to place spawners in chamber
		local nobj_cata = minetest.get_perlin(np_cata)
		local spawn = GEN and nobj_cata:get3d(
			{x = x - vmvw, y = y + chamvoff, z = z + chamhoff}) > TCATA and
			x > XMIN and x < XMAX and y > YMIN and y < YMAX and z > ZMIN and z < ZMAX

		for k = chamhoff, vmvn do -- spawn chamber
		for j = chamvoff, chamvoff + chamhei do
			local vi = area:index(x - vmvw, y + j, z + k)
			for i = 0, chamew - 1 do
				local nodid = data[vi]
				if nodid ~= c_air
						and nodid ~= c_ignore
						and nodid ~= c_cobble -- default dungeons remain
						and nodid ~= c_mobble
						and nodid ~= c_stobble then
					if spawn and k == chamhoff + exoffw and j == chamvoff and i == 0 then
						data[vi] = c_chamberw
					elseif spawn and i == exoffn and j == chamvoff and k == vmvn then
						data[vi] = c_chambern
					elseif spawn and i == exoffs and j == chamvoff and k == chamhoff then
						data[vi] = c_chambers
					elseif (k > chamhoff and k < vmvn and j > chamvoff and
							j < chamvoff + chamhei and i > 0 and i < chamew - 1) or
							(i == chamew - 1 and j > chamvoff and j <= chamvoff + 4 and
							(k > 0 and k < passwid - 1)) then
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

		--local chugent = math.ceil((os.clock() - t1) * 1000)
		--print ("[catacomb] Chamber west " .. chugent .. "ms")
	end,
})
