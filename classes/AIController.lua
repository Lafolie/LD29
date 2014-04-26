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
		print("Cerberus AI Initiated")
		print("Kill mode Engaged")
	end,

	isDown = function(self, keyname)
		if keyname == "up" then
			return self:shouldJump()
		elseif keyname == "down" then
			return self:shouldDive()
		end

		return false
	end,
	
	shouldJump = function(self)
		if self.enemyMech.projectile 
		and ((self.enemyMech.projectile.pos.x < self.playerMech.pos.x + self.playerMech.size.x and self.enemyMech.projectile.vel.x > 0) 
		or (self.enemyMech.projectile.pos.x > self.playerMech.pos.x - self.playerMech.size.x and self.enemyMech.projectile.vel.x < 0)) then
			if self.enemyMech.projectile.pos.y + 5 > FLOORHEIGHT - self.playerMech.size.y then
				if self.playerMech.pos.y - self.enemyMech.projectile.pos.y > -25 then
					return true
				end
			end
		else
			return self.enemyMech.pos.y < self.playerMech.pos.y and self.enemyMech.pos.y - self.playerMech.pos.y < -15	
		end
	end,
	
	shouldDive = function(self)
		if self.enemyMech.projectile 
		and ((self.enemyMech.projectile.pos.x < self.playerMech.pos.x + self.playerMech.size.x and self.enemyMech.projectile.vel.x > 0) 
		or (self.enemyMech.projectile.pos.x > self.playerMech.pos.x - self.playerMech.size.x and self.enemyMech.projectile.vel.x < 0)) then
			if self.enemyMech.projectile.pos.y + 5 < FLOORHEIGHT - self.playerMech.size.y then
				if self.playerMech.pos.y - self.enemyMech.projectile.pos.y < 25 then
					return true
				end
			end
		else
			return self.enemyMech.pos.y > self.playerMech.pos.y and self.enemyMech.pos.y - self.playerMech.pos.y > 15	
		end
	end,
	
	update = function(self, dt)
	
	end,
}
