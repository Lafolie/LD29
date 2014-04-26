class = require "lib.slither" -- BOO, globals
local HC = require "lib.HardonCollider"
local registry = require "shaperegistry"

local collider

local function collision(dt, aShape, bShape, dx, dy)
	a = registry.getEntity(aShape)
	b = registry.getEntity(bShape)

	if not a and not b then
		print("Collision occured between non-entities")
	elseif a == b then -- Don't resolve internal collisions
		-- Prevent this collision from registering again
		local groupname = tostring(a)
		collider:addToGroup(groupname, aShape, bShape)
		-- Then don't resolve it
		return
	end

	-- entity:collideWith(other, first, dx, dy)
	a:collideWith(b, true, dx, dy)
	b:collideWith(a, false, 0, 0)
end

local function collision_end(dt, a, b, dx, dy)
end

function love.load()
	collider = HC(100, collision, collision_end)
end

function love.update(dt)
	collider:update(dt)
end

function love.draw()
	love.graphics.rectangle("fill", 50, 50, 50, 50)
end
