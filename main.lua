class = require "lib.slither" -- BOO, globals
local HC = require "lib.HardonCollider"
local registry = require "registry"

HCShapes = require "lib.HardonCollider.shapes"
function HCShapes.newRectangleShape(x, y, w, h)
	return HCShapes.newPolygonShape(x, y, x+w, y, x+w, y+h, x, y+h)
end

FLOORHEIGHT = 120

require "classes.Actor"
require "classes.Drawable"
require "classes.Mech"
require "classes.AIController"

local function collision(dt, aShape, bShape, dx, dy)
	local a = registry.shapes.getEntity(aShape)
	local b = registry.shapes.getEntity(bShape)

	if not a or not b then
		if not a then
			collider:remove(aShape)
		end
		if not b then
			collider:remove(bShape)
		end
		print("Collision occured between non-entities")
		return
	elseif a == b then -- Don't resolve internal collisions
		-- Prevent this collision from registering again
		local groupname = tostring(a)
		collider:addToGroup(groupname, aShape, bShape)
		-- Then don't resolve it
		return
	elseif a:dead() or b:dead() then
		-- No collisions between dead objects
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
	mech1 = Mech(50, 80, 1, false)
	mech2 = Mech(150, 80, 2, true)
	
	mech2.controller = AIController(2,mech2,mech1)

	controllerSelect = false
	roundTimer = 99
	timerTick = 1
	timerFont = love.graphics.newFont("font/BMarmy.TTF", 12)
	timerFont:setFilter("nearest", "nearest")
	love.graphics.setFont(timerFont)
end

function love.update(dt)
	if controllerSelect then return end

	local restart = false
	if mech1.hp <= 0 then
		mech2.wins = mech2.wins + 1
		restart = true
	end
	if mech2.hp <= 0 then
		mech1.wins = mech1.wins + 1
		restart = true
	end

	collider:update(dt)

	timerTick = timerTick - dt
	if timerTick <= 0 then
		timerTick = 1
		roundTimer = roundTimer - 1
		if roundTimer <= 0 then
			if mech1.hp > mech2.hp then
				mech1.wins = mech1.wins + 1
			else
				mech2.wins = mech2.wins + 1
			end
			restart = true
		end
	end

	if restart then
		mech1.hp = 1000
		mech2.hp = 1000
		mech1.pos.x, mech1.pos.y = 50, 80
		mech2.pos.x, mech2.pos.y = 150, 80
		roundTimer = 99

		if mech1.projectile then mech1.projectile:kill() end
		if mech2.projectile then mech2.projectile:kill() end
	end

	if mech1.pos.x > mech2.pos.x then
		mech1.enemyDirection = 'left'
		mech2.enemyDirection = 'right'
	else
		mech1.enemyDirection = 'right'
		mech2.enemyDirection = 'left'
	end
	
	for i, v in registry.entities.iterate() do
		if class.isinstance(v, Actor) and not v:dead() then
			v:update(dt)
		end
	end
end

function love.draw()
	love.graphics.scale(4, 4)

	love.graphics.setColor(0xEA, 0xB9, 0x88)
	love.graphics.rectangle("fill", 0, 0, 400, 300)
	love.graphics.setColor(25, 50, 120)
	love.graphics.rectangle("fill", 0, 0, 400, FLOORHEIGHT)

	for i, v in registry.entities.iterate() do
		if class.isinstance(v, Drawable) and not v:dead() then
			v:draw()
		end
	end

	love.graphics.setColor(38, 38, 38, 255)
	love.graphics.print(roundTimer, 90, 4)
	love.graphics.setColor(225, 200, 100, 255)
	love.graphics.print(roundTimer, 89, 3)

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
