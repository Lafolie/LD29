local registry = require "registry"
local vector = require "lib.hump.vector"

class "AIController"
{
	__init__ = function(self, player, playerMech, enemyMech)
		self.player = player
		self.playerMech = playerMech
		self.enemyMech = enemyMech
		self.enemyVel = vector(0, 0)
		self.lastEnemyPosition = self.enemyMech.pos
		print("Cerberus AI Initiated")
		print("Kill mode Engaged")
	end,

	isDown = function(self, keyname)
		if keyname == "up" then
			return self:shouldJump()
		elseif keyname == "down" then
			return self:shouldDive()
		elseif keyname == "hadouken" then
			return self:shouldHadouken()
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
			return self.enemyMech.pos.y < self.playerMech.pos.y and self.enemyMech.pos.y - self.playerMech.pos.y < -20	
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
			return self.enemyMech.pos.y > self.playerMech.pos.y and self.enemyMech.pos.y - self.playerMech.pos.y > 20	
		end
	end,
	
	shouldHadouken = function(self)
		if self.enemyMech.pos.y < self.playerMech.pos.y and self.enemyVel.y > 10 then
			if self.playerMech.pos.y - self.enemyMech.pos.y > 15 then
				return true
			end
		elseif self.enemyMech.pos.y > self.playerMech.pos.y and self.enemyVel.y < -10 then
			if self.playerMech.pos.y - self.enemyMech.pos.y < -15 then
				return true
			end
		else
			return false
		end
		
	end,
	
	update = function(self, dt)
		self.enemyVel = (self.enemyMech.pos - self.lastEnemyPosition)/dt
		self.lastEnemyPosition = self.enemyMech.pos
	end,

	hasJoystick = function(self)
		return true -- Always be ineligible for joystick attachment
	end,
}
