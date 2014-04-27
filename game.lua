local HC = require "lib.HardonCollider"
local registry = require "registry"

local game = {}

FLOORHEIGHT = 120

require "classes.Actor"
require "classes.Drawable"
require "classes.Mech"
require "classes.AIController"

local mech1, mech2, controllerSelect, bubbles

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

function game.load()
	collider = HC(100, collision, collision_end)
	mech1 = Mech(50, 80, 1, false)
	mech2 = Mech(150, 80, 2, true)
	
	mech2.controller = AIController(2,mech2,mech1)

	controllerSelect = false
	roundTimer = 90
	timerTick = 1
	timerFont = love.graphics.newFont("font/BMarmy.TTF", 12)
	timerFont:setFilter("nearest", "nearest")
	love.graphics.setFont(timerFont)

	bubbles = {}
end

function game.update(dt)
	if controllerSelect then return end

	for i, v in pairs(bubbles) do
		if v:dead() then
			bubbles[i] = nil
		end
	end

	if love.math.random() > 0.97 then
		table.insert(bubbles,
			Bubble(love.math.random(200), love.math.random(FLOORHEIGHT),
				0, -1, 40))
	end

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
			elseif mech1.hp < mech2.hp then
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

function game.draw()
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
	love.graphics.print(roundTimer, 91, 4)
	love.graphics.setColor(225, 200, 100, 255)
	love.graphics.print(roundTimer, 90, 3)

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

function game.keypressed(key)
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

function game.joystickpressed(joystick, button)
	local controller = registry.joysticks.getController(joystick)
	if not controller and not
			(mech1.controller:hasJoystick() and mech2.controller:hasJoystick()) then
		print("New controller used")
		controllerSelect = joystick
	end
end

return game
