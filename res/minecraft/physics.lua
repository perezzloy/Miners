-- Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
-- See copyright notice in src/charge/charge.d (GPLv2 only).



----
-- This is script holds physics related functions.
--

----
-- Some defines
--
local playerSize = 0.32
local playerHeight = 1.5
local gravity = 0.98 / 200

local floor = _G.math.floor


----
-- Get the block to where the player moved.
--
local getMovedBodyPosition = function(pos, v, minVal, maxVal)
	if v < 0 then
		return floor(pos + v + minVal)
	else
		return floor(pos + v + maxVal)
	end
end


----
-- Collides a axis aligned bounding box against the terrain.
--
-- minX, minY, minZ: Smallest corner of box.
-- maxX, maxY, maxZ: Smallest corner of box.
--
local collidesInRange = function(minX, minY, minZ, maxX, maxY, maxZ)
	minX = floor(minX)
	minY = floor(minY)
	minZ = floor(minZ)
	maxX = floor(maxX)
	maxY = floor(maxY)
	maxZ = floor(maxZ)

	for x = minX, maxX do
		for y = minY, maxY do
			for z = minZ, maxZ do
				local b = terrain:block(x, y, z)
				if b ~= 0 then
					return true
				end
			end
		end
	end
	return false
end


----
-- Applie physics to a player and move it
--
function doPlayerPhysics(player, vec)

	if not vec then
		vec = Vector()
	end

	local pos = player.pos
	local ground = player.ground

	local x = pos.x
	local y = pos.y
	local z = pos.z

	local size = playerSize
	local height = playerHeight

	local minX = x - size
	local minY = y
	local minZ = z - size
	local maxX = x + size
	local maxY = y + height
	local maxZ = z + size

	local old
	local v

	v = vec.x
	old = x
	if v ~= 0 then
		local cx = getMovedBodyPosition(pos.x, v, -size, size)
		if collidesInRange(cx, minY, minZ, cx, maxY, maxZ) then
			if v < 0 then
				x = cx + 1 + size + 0.00001
			else
				x = cx - size - 0.00001
			end
		else
			x = x + v
		end

		-- Update for next axis
		minX = x - size
		maxX = x + size
		vec.x = x - old
	end

	v = vec.z
	old = z
	if v ~= 0 then
		local cz = getMovedBodyPosition(z, v, -size, size)
		if collidesInRange(minX, minY, cz, maxX, maxY, cz) then
			if v < 0 then
				z = cz + 1 + size + 0.00001
			else
				z = cz - size - 0.00001
			end
		else
			z = z + v
		end

		-- Update for next axis
		minZ = z - size
		maxZ = z + size
		vec.z = z - old
	end

	v = vec.y - gravity
	old = y
	if v ~= 0 then
		local cy = getMovedBodyPosition(y, v, 0, height)
		if collidesInRange(minX, cy, minZ, maxX, cy, maxZ) then
			if v < 0 then
				y = cy + 1 + 0.00001
			else
				y = cy - height - 0.00001
			end
			ground = true
		else
			ground = false
			y = y + v
		end

		-- Not needed
		--minY = y - size
		--maxY = y + size
		vec.y = y - old
	end

	return Point(x, y, z), vec, ground
end