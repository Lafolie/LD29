require "classes.Timer"

local menu = {}

local options = {
	"Startu gamu!",
	"Quittu",
}

local selection = 1
local xOff, yOff, xTarget, yTarget, t
local r, g, b, rTarget, gTarget, bTarget

function menu.load()
	xOff, yOff = 0, 0
	xTarget, yTarget = 0, 0
	r, g, b = 255, 255, 255
	rTarget, gTarget, bTarget = 255, 255, 255

	t = Timer("periodic", 0.050, function()
		xTarget, yTarget = love.math.random()*6-3, love.math.random()*6-3

		rTarget, gTarget, bTarget = love.math.random(0, 255), love.math.random(0, 255), love.math.random(0, 255)
	end)
end

function menu.update(dt)
	t:update(dt)
	xOff = xOff - (xOff-xTarget)*dt
	yOff = yOff - (yOff-yTarget)*dt
	r = r - (r-rTarget)*dt
	g = g - (g-gTarget)*dt
	b = b - (b-bTarget)*dt
end

function menu.draw()
	love.graphics.scale(4, 4)
	love.graphics.setColor(r, g, b)
	love.graphics.printf("BESTU GEMU", xOff, yOff + 20, 200, "center")
	for i, v in ipairs(options) do
		local str = v
		if selection == i then
			str = "> " .. str .. " <"
		end

		love.graphics.printf(str, xOff, yOff + 50 + 30 * i, 200, "center")
	end
end

function menu.keypressed(key)
	if key == "down" or key == "s" then
		selection = selection%#options + 1
	elseif key == "up" or key == "w" then
		selection = (selection-2)%#options+1
	elseif key == "return" then
		if selection == 1 then
			switchState("game")
		elseif selection == 2 then
			love.event.quit()
		end
	end
end

function menu.joystickpressed(joystick, button)
end

return menu
