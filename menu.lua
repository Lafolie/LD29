local menu = {}

local options = {
	"Startu gamu!",
	"Quittu",
}

local selection = 1
local xOff, yOff

function menu.load()
end

function menu.update(dt)
	xOff, yOff = love.math.random()*2, love.math.random()*2
end

function menu.draw()
	love.graphics.scale(4, 4)
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
