-- catacomb 0.3.3 by paramat
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

minetest.register_node("catacomb:chambern", {
	description = "Chamber spawner north",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chambers", {
	description = "Chamber spawner south",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chambere", {
	description = "Chamber spawner east",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("catacomb:chamberw", {
	description = "Chamber spawner west",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

-- ABM

-- Chamber north

minetest.register_abm({
	nodenames = {"catacomb:chambern"},
	interval = 16 * ABMINT,
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
		local c_chambere = minetest.get_content_id("catacomb:chambere")
		local c_chamberw = minetest.get_content_id("catacomb:chamberw")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x+MINPWID, y=y, z=z}
		local pos2 = {x=x+MAXCWID, y=y, z=z}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		local wallwid = MINPWID
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
		local exoffe = math.random(0, chamns - 3)
		local exoffw = math.random(0, chamns - 3)

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
					elseif i == chamew and j == chamvoff and k == passlen + 1 + exoffe then
						data[vi] = c_chambere
					elseif i == 0 and j == chamvoff and k == passlen + 1 + exoffw then
						data[vi] = c_chamberw
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

-- Chamber south

minetest.register_abm({
	nodenames = {"catacomb:chambers"},
	interval = 17 * ABMINT,
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
		local c_chambers = minetest.get_content_id("catacomb:chambers")
		local c_chambere = minetest.get_content_id("catacomb:chambere")
		local c_chamberw = minetest.get_content_id("catacomb:chamberw")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x+MINPWID, y=y, z=z}
		local pos2 = {x=x+MAXCWID, y=y, z=z}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		local wallwid = MINPWID
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
		local exoffs = math.random(0, chamew - 3)
		local exoffe = math.random(0, chamns - 3)
		local exoffw = math.random(0, chamns - 3)

		local vmvd = math.min(chamvoff, 0) -- voxel manip volume edges relative to spawner
		local vmvu = math.max(chamvoff + chamhei, 5)
		local vmvw = chamhoff
		local vmve = chamhoff + chamew
		local vmvs = chamns + passlen

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x+vmvw, y=y+vmvd, z=z-vmvs}
		local pos2 = {x=x+vmve, y=y+vmvu, z=z}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then -- check for obstruction
			for k = passlen + 1, vmvs do
			for j = chamvoff, chamvoff + chamhei do
				local vi = area:index(x+chamhoff, y+j, z-k)
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

		local vi = area:index(x, y, z-1)
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
								data[vi] = c_stairn
							else
								data[vi] = c_stairs
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
			vi = vi + (passdlu - 6) * vvii - nvii -- down 5 or 6 or 7, southwards 1
		end

		for k = passlen + 1, vmvs do -- spawn chamber
		for j = chamvoff, chamvoff + chamhei do
			local vi = area:index(x+chamhoff, y+j, z-k)
			for i = 0, chamew do
				local nodid = data[vi]
				if nodid ~= c_air
				and nodid ~= c_ignore
				and nodid ~= c_cobble -- default dungeons remain
				and nodid ~= c_mobble
				and nodid ~= c_stobble
				and nodid ~= c_leaves
				and nodid ~= c_apple then
					if k == vmvs and j == chamvoff and i == exoffs then
						data[vi] = c_chambers
					elseif i == chamew and j == chamvoff and k == passlen + 1 + exoffe then
						data[vi] = c_chambere
					elseif i == 0 and j == chamvoff and k == passlen + 1 + exoffw then
						data[vi] = c_chamberw
					elseif (k > passlen + 1 and k < vmvs
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
		print ("[catacomb] Chamber south "..chugent)
	end,
})

-- Chamber east

minetest.register_abm({
	nodenames = {"catacomb:chambere"},
	interval = 18 * ABMINT,
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
		local c_staire = minetest.get_content_id("catacomb:staire")
		local c_stairw = minetest.get_content_id("catacomb:stairw")
		local c_chambern = minetest.get_content_id("catacomb:chambern")
		local c_chambers = minetest.get_content_id("catacomb:chambers")
		local c_chambere = minetest.get_content_id("catacomb:chambere")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x, y=y, z=z+MINPWID}
		local pos2 = {x=x, y=y, z=z+MAXCWID}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local wallwid = MINPWID
		local vi = area:index(x, y, z+MINPWID)
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

		local chamns = math.random(passwid, MAXCWID) - 1
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
		local pos1 = {x=x, y=y+vmvd, z=z+vmvs}
		local pos2 = {x=x+vmve, y=y+vmvu, z=z+vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then -- check for obstruction
			for k = chamhoff, vmvn do
			for j = chamvoff, chamvoff + chamhei do
				local vi = area:index(x+passlen+1, y+j, z+k)
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

		local vi = area:index(x, y+1, z+1) -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for k = 1, passwid - 2 do
				data[vi] = c_air
				vi = vi + nvii
			end
			vi = vi - (passwid - 2) * nvii + vvii -- back 2, up 1
		end

		local vi = area:index(x+1, y, z)
		for i = 1, passlen do
			for j = 1, 6 do
				for k = 1, passwid do
					local nodid = data[vi]
					if nodid ~= c_air
					and nodid ~= c_ignore
					and nodid ~= c_leaves -- no spawning in leaves
					and nodid ~= c_apple then
						if passdlu ~= 0 and j == 1
						and not (passdlu == 1 and i == 1)
						and not (passdlu == -1 and i == len)
						and (k >= 2 and k <= passwid - 1) then
							if passdlu == -1 then
								data[vi] = c_stairw
							else
								data[vi] = c_staire
							end
						elseif j == 1 or j == 6 or k == 1 or k == passwid then
							data[vi] = c_catcobble
						else
							data[vi] = c_air
						end
					end
					vi = vi + nvii -- northwards 1
				end
				vi = vi - passwid * nvii + vvii -- back passwid, up 1
			end
			vi = vi + (passdlu - 6) * vvii + 1 -- down 5 or 6 or 7, eastwards 1
		end

		for k = chamhoff, vmvn do -- spawn chamber
		for j = chamvoff, chamvoff + chamhei do
			local vi = area:index(x+passlen+1, y+j, z+k)
			for i = 0, chamew do
				local nodid = data[vi]
				if nodid ~= c_air
				and nodid ~= c_ignore
				and nodid ~= c_cobble -- default dungeons remain
				and nodid ~= c_mobble
				and nodid ~= c_stobble
				and nodid ~= c_leaves
				and nodid ~= c_apple then
					if k == chamhoff + exoffe and j == chamvoff and i == chamew then
						data[vi] = c_chambere
					elseif i == exoffn and j == chamvoff and k == vmvn then
						data[vi] = c_chambern
					elseif i == exoffs and j == chamvoff and k == chamhoff then
						data[vi] = c_chambers
					elseif (k > chamhoff and k < vmvn
					and j > chamvoff and j < chamvoff + chamhei
					and i > 0 and i < chamew)
					or (i == 0 and j > chamvoff and j <= chamvoff + 4
					and (k > 0 and k < passwid - 1)) then
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
		print ("[catacomb] Chamber east "..chugent)
	end,
})

-- Chamber west

minetest.register_abm({
	nodenames = {"catacomb:chamberw"},
	interval = 19 * ABMINT,
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
		local c_staire = minetest.get_content_id("catacomb:staire")
		local c_stairw = minetest.get_content_id("catacomb:stairw")
		local c_chambern = minetest.get_content_id("catacomb:chambern")
		local c_chambers = minetest.get_content_id("catacomb:chambers")
		local c_chamberw = minetest.get_content_id("catacomb:chamberw")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x, y=y, z=z+MINPWID}
		local pos2 = {x=x, y=y, z=z+MAXCWID}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local wallwid = MINPWID
		local vi = area:index(x, y, z+MINPWID)
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

		local chamns = math.random(passwid, MAXCWID) - 1
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
		local pos1 = {x=x-vmvw, y=y+vmvd, z=z+vmvs}
		local pos2 = {x=x, y=y+vmvu, z=z+vmvn}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local vvii = emax.x - emin.x + 1
		local nvii = (emax.y - emin.y + 1) * vvii

		local vi = area:index(x, y, z) -- remove spawner
		data[vi] = c_catcobble

		if OBCHECK then -- check for obstruction
			for k = chamhoff, vmvn do
			for j = chamvoff, chamvoff + chamhei do
				local vi = area:index(x-vmvw, y+j, z+k)
				for i = 0, chamew - 1 do
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

		local vi = area:index(x, y+1, z+1) -- spawn passage
		for j = 1, 4 do -- carve hole in chamber wall
			for k = 1, passwid - 2 do
				data[vi] = c_air
				vi = vi + nvii
			end
			vi = vi - (passwid - 2) * nvii + vvii -- back 2, up 1
		end

		local vi = area:index(x-1, y, z)
		for i = 1, passlen do
			for j = 1, 6 do
				for k = 1, passwid do
					local nodid = data[vi]
					if nodid ~= c_air
					and nodid ~= c_ignore
					and nodid ~= c_leaves -- no spawning in leaves
					and nodid ~= c_apple then
						if passdlu ~= 0 and j == 1
						and not (passdlu == 1 and i == 1)
						and not (passdlu == -1 and i == len)
						and (k >= 2 and k <= passwid - 1) then
							if passdlu == -1 then
								data[vi] = c_staire
							else
								data[vi] = c_stairw
							end
						elseif j == 1 or j == 6 or k == 1 or k == passwid then
							data[vi] = c_catcobble
						else
							data[vi] = c_air
						end
					end
					vi = vi + nvii -- northwards 1
				end
				vi = vi - passwid * nvii + vvii -- back passwid, up 1
			end
			vi = vi + (passdlu - 6) * vvii - 1 -- down 5 or 6 or 7, westwards 1
		end

		for k = chamhoff, vmvn do -- spawn chamber
		for j = chamvoff, chamvoff + chamhei do
			local vi = area:index(x-vmvw, y+j, z+k)
			for i = 0, chamew - 1 do
				local nodid = data[vi]
				if nodid ~= c_air
				and nodid ~= c_ignore
				and nodid ~= c_cobble -- default dungeons remain
				and nodid ~= c_mobble
				and nodid ~= c_stobble
				and nodid ~= c_leaves
				and nodid ~= c_apple then
					if k == chamhoff + exoffw and j == chamvoff and i == 0 then
						data[vi] = c_chamberw
					elseif i == exoffn and j == chamvoff and k == vmvn then
						data[vi] = c_chambern
					elseif i == exoffs and j == chamvoff and k == chamhoff then
						data[vi] = c_chambers
					elseif (k > chamhoff and k < vmvn
					and j > chamvoff and j < chamvoff + chamhei
					and i > 0 and i < chamew - 1)
					or (i == chamew - 1 and j > chamvoff and j <= chamvoff + 4
					and (k > 0 and k < passwid - 1)) then
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
		print ("[catacomb] Chamber west "..chugent)
	end,
})

