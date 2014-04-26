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
require "classes.AIController"

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

local mech1, mech2, controllerSelect
function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	collider = HC(100, collision, collision_end)
	mech1 = Mech(100, 150, 1, false)
	mech2 = Mech(300, 150, 2, true)
	
	mech2.controller = AIController(2,mech2,mech1)

	controllerSelect = false
end

function love.update(dt)
	if controllerSelect then return end

	collider:update(dt)
	if mech1.pos.x > mech2.pos.x then
		mech1.enemyDirection = 'left'
		mech2.enemyDirection = 'right'
	else
		mech1.enemyDirection = 'right'
		mech2.enemyDirection = 'left'
	end
	
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

	if controllerSelect then
		love.graphics.origin()
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 200, 150, 400, 300)

		love.graphics.setColor(255, 255, 255)
		local str = "A new gamepad was used, please select a player:\n"
		if not mech1.controller:hasJoystick() then
			str = str .. "Press '1' if it's for player 1\n"
		end
		if not mech2.controller:hasJoystick() then
			str = str .. "Press '2' if it's for player 2\n"
		end
		love.graphics.printf(str .. "Press 'q' if it was by mistake\n", 220, 165, 360)
	end
end

function love.keypressed(key)
	if key == "escape" then
		print("What's wrong Lafolie?!")
		love.timer.sleep(2)
		love.event.quit()
	end

	if controllerSelect then
		if key == "1" and not mech1.controller:hasJoystick() then
			mech1.controller:setJoystick(controllerSelect)
		elseif key == "2" and not mech2.controller:hasJoystick() then
			mech2.controller:setJoystick(controllerSelect)
		elseif key == "q" then
		else
			return
		end
		controllerSelect = false
	end
end

function love.joystickpressed(joystick, button)
	local controller = registry.joysticks.getController(joystick)
	if not controller and not
			(mech1.controller:hasJoystick() and mech2.controller:hasJoystick()) then
		print("New controller used")
		controllerSelect = joystick
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
