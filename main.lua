class = require "lib.slither" -- BOO, globals
local HC = require "lib.HardonCollider"
local registry = require "registry"
local game = require "game"

HCShapes = require "lib.HardonCollider.shapes"
function HCShapes.newRectangleShape(x, y, w, h)
	return HCShapes.newPolygonShape(x, y, x+w, y, x+w, y+h, x, y+h)
end

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	game.load()
end

function love.update(dt)
	game.update(dt)
end

function love.draw()
	game.draw()
end

function love.keypressed(key)
	if key == "escape" then
		print("What's wrong Lafolie?!")
		if os.getenv("USERNAME") == "Dale" then
			os.execute("start http://tbitw.com")
		end
		return love.event.quit()
	end

	game.keypressed(key)
end

function love.joystickpressed(joystick, button)
	game.joystickpressed(joystick, button)
end

function print(...)
	local t = {...}
	for i, v in ipairs(t) do
		t[i] = tostring(v)
	end

	local str = table.concat(t, "\t")
	return io.write("[" .. os.date() .. "] " .. str .. "\n")
end
