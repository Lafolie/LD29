local registry = require "registry"

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


class "AIController"
{
	__init__ = function(self, player, playerMech, enemyMech)
		self.player = player
		self.keymap = keymap[self.player]
		self.playerMech = playerMech
		self.enemyMech = enemyMech
		print("AI")
	end,

	isDown = function(self, keyname)
		if keyname == "up" then
			return self:shouldJump()
			--return self.enemyMech.pos.y < self.playerMech.pos.y and self.enemyMech.pos.y - self.playerMech.pos.y < -30
		elseif keyname == "down" then
			return self.enemyMech.pos.y > self.playerMech.pos.y and self.enemyMech.pos.y - self.playerMech.pos.y > 30
		end

		return false
	end,
	
	shouldJump = function(self)
		if self.enemyMech.projectile then
			if self.enemyMech.projectile.pos.y > FLOORHEIGHT - 50 then
				if self.playerMech.pos.y - self.enemyMech.projectile.pos.y > -25 then
					return true
				end
			end
		end
		
		return false
			
	end,
	
	update = function(self, dt)
	
	end,
}
