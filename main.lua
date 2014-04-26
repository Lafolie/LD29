class = require "lib.slither" -- BOO, globals
local HC = require "lib.HardonCollider"
local registry = require "registry"

HCShapes = require "lib.HardonCollider.shapes"
function HCShapes.newRectangleShape(x, y, w, h)
	return HCShapes.newPolygonShape(x, y, x+w, y, x+w, y+h, x, y+h)
end

require "classes.Actor"
require "classes.Drawable"
require "classes.Mech"

local function collision(dt, aShape, bShape, dx, dy)
	a = registry.shapes.getEntity(aShape)
	b = registry.shapes.getEntity(bShape)

	if not a and not b then
		print("Collision occured between non-entities")
	elseif a == b then -- Don't resolve internal collisions
		-- Prevent this collision from registering again
		local groupname = tostring(a)
		collider:addToGroup(groupname, aShape, bShape)
		-- Then don't resolve it
		return
	end

	-- entity:collideWith(shape, other, first, dx, dy)
	a:collideWith(aShape, b, dx, dy)
	b:collideWith(bShape, a, 0, 0)
end

local function collision_end(dt, a, b, dx, dy)
end

local mech
function love.load()
	collider = HC(100, collision, collision_end)
	mech1 = Mech(200, 300, 1)
	mech2 = Mech(600, 300, 2)
end

function love.update(dt)
	collider:update(dt)

	for i, v in registry.entities.iterate() do
		if class.isinstance(v, Actor) then
			v:update(dt)
		end
	end
end

function love.draw()
	for i, v in registry.entities.iterate() do
		if class.isinstance(v, Drawable) then
			v:draw()
		end
	end
end
