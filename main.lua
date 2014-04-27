class = require "lib.slither" -- BOO, globals
local game = require "game"
local menu = require "menu"

HCShapes = require "lib.HardonCollider.shapes"
function HCShapes.newRectangleShape(x, y, w, h)
	return HCShapes.newPolygonShape(x, y, x+w, y, x+w, y+h, x, y+h)
end

local state = menu

function switchState(name)
	if name == "game" then
		state = game
	elseif name == "menu" then
		state = menu
	end

	state.load()
end

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	timerFont = love.graphics.newFont("font/BMarmy.TTF", 12)
	timerFont:setFilter("nearest", "nearest")
	love.graphics.setFont(timerFont)

	state.load()
end

function love.update(dt)
	state.update(dt)
end

function love.draw()
	state.draw()
end

function love.keypressed(key)
	if key == "escape" then
		print("What's wrong Lafolie?!")
		if os.getenv("USERNAME") == "Dale" then
			os.execute("start http://tbitw.com")
		end
		return love.event.quit()
	end

	state.keypressed(key)
end

function love.joystickpressed(joystick, button)
	state.joystickpressed(joystick, button)
end

function print(...)
	local t = {...}
	for i, v in ipairs(t) do
		t[i] = tostring(v)
	end

	local str = table.concat(t, "\t")
	return io.write("[" .. os.date() .. "] " .. str .. "\n")
end
