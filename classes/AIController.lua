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
		self.timeTillEvaluate = 0
		self.desiredHeight = 0
		self.heightThreshold = 5
		self.desiredHorizontal = 0
		self.horizontalThreshold = 5
		print("Cerberus AI Initiated")
		print("Kill mode Engaged")
	end,

	isDown = function(self, keyname)
		if keyname == "up" then
			return self:shouldJump()
		elseif keyname == "down" then
			return self:shouldDive()
		elseif keyname == "left" then
			return self:shouldMoveLeft()
		elseif keyname == "right" then
			return self:shouldMoveRight()
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
			--return self.enemyMech.pos.y < self.playerMech.pos.y and self.enemyMech.pos.y - self.playerMech.pos.y < -20
			return self.playerMech.pos.y - self.desiredHeight > self.heightThreshold 
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
			 --return self.enemyMech.pos.y > self.playerMech.pos.y and self.enemyMech.pos.y - self.playerMech.pos.y > 20
			return self.desiredHeight - self.playerMech.pos.y > self.heightThreshold 
		end
	end,
	
	shouldMoveLeft = function(self)
		if self.enemyMech.pos.x - self.playerMech.pos.x < -5 and not self.playerMech.facingLeft then
			return true
		else
			return self.playerMech.pos.x - self.desiredHorizontal > self.horizontalThreshold 
		end 
	end,
	
	shouldMoveRight = function(self)
		if self.enemyMech.pos.x - self.playerMech.pos.x > 5 and self.playerMech.facingLeft then
			return true
		else
			return self.desiredHorizontal - self.playerMech.pos.x > self.horizontalThreshold 
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
		
		self.timeTillEvaluate = self.timeTillEvaluate - dt
		if(self.timeTillEvaluate < 0) then
			self.timeTillEvaluate = 3
			
			self.desiredHeight = love.math.random(25,150) 
			print(self.desiredHeight)
			self.heightThreshold = love.math.random(5,20)
			
			self.desiredHorizontal = love.math.random(7,87) + love.math.random(7,100) -- 2 rands to give higher weighting to centre of screen
			self.horizontalThreshold = love.math.random(5,20)
		end
		
	end,

	hasJoystick = function(self)
		return true -- Always be ineligible for joystick attachment
	end,
}
