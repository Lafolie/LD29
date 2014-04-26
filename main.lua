class = require "lib.slither" -- BOO, globals
local HC = require "lib.HardonCollider"
local registry = require "registry"

HCShapes = require "lib.HardonCollider.shapes"
function HCShapes.newRectangleShape(x, y, w, h)
	return HCShapes.newPolygonShape(x, y, x+w, y, x+w, y+h, x, y+h)
end

FLOORHEIGHT = 230

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
	love.graphics.setDefaultFilter("nearest", "nearest")

	collider = HC(100, collision, collision_end)
	mech1 = Mech(100, 150, 1, false)
	mech2 = Mech(300, 150, 2, true)
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
	love.graphics.scale(2, 2)

	love.graphics.setColor(0xEA, 0xB9, 0x88)
	love.graphics.rectangle("fill", 0, 0, 400, 300)
	love.graphics.setColor(80, 70, 190)
	love.graphics.rectangle("fill", 0, 0, 400, FLOORHEIGHT)

	for i, v in registry.entities.iterate() do
		if class.isinstance(v, Drawable) then
			v:draw()
		end
	end
end

function love.keypressed(key)
	if key == "escape" then
		print("What's wrong Lafolie?!")
		love.timer.sleep(2)
		love.event.quit()
	end
end

function print(...)
	local t = {...}
	for i, v in ipairs(t) do
		t[i] = tostring(v)
	end

	local str = table.concat(t, "\t")
	return io.write("[" .. os.date() .. "] " .. str .. "\n")
end
