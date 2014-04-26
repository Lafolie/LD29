local keymap =
{
	[1] =
	{
		up = "w",
		down = "s",
		left = "a",
		right = "d",
		punch = " "
	},
	[2] =
	{
		up = "up",
		down = "down",
		left = "left",
		right = "right",
		punch = " "
	},
}


class "Controller"
{
	__init__ = function(self, player)
		self.player = player
		self.keymap = keymap[self.player]
	end,

	isDown = function(self, keyname)
		if love.keyboard.isDown(self.keymap[keyname]) then
			return true
		end

		return false
	end,
}
