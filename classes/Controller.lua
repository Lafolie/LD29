local registry = require "registry"

local keymap =
{
	[1] =
	{
		up = "w",
		down = "s",
		left = "a",
		right = "d",
		punch = "e",
		hadouken = "q",
	},
	[2] =
	{
		up = "up",
		down = "down",
		left = "left",
		right = "right",
		punch = "return",
		hadouken = "backspace",
	},
}


class "Controller"
{
	__init__ = function(self, player)
		self.player = player
		self.keymap = keymap[self.player]
		self.joystick = nil
	end,

	isDown = function(self, keyname)
		if love.keyboard.isDown(self.keymap[keyname]) then
			return true
		end

		if self.joystick then
			local xaxis, yaxis = self.joystick:getAxes()
			if keyname == "up" then
				return yaxis < -0.5
			elseif keyname == "down" then
				return yaxis > 0.5
			elseif keyname == "left" then
				return xaxis < -0.5
			elseif keyname == "right" then
				return xaxis > 0.5
			elseif keyname == "punch" then
				return self.joystick:isDown(1)
			elseif keyname == "hadouken" then
				return self.joystick:isDown(2)
			end
		end

		return false
	end,

	hasJoystick = function(self)
		return not not self.joystick
	end,

	setJoystick = function(self, joystick)
		if self.joystick then
			registry.joysticks.unbind(self.joystick)
		end
		self.joystick = joystick
		registry.joysticks.bind(self, self.joystick)
	end,
	
	update = function(self, dt)
	end,
}
