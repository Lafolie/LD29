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
		self.matchHeight = true
		self.goInForKill = false
		print("Cerberus AI Initiated")
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
		elseif keyname == "punch" then
			return self:shouldPunch()
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
			if self.matchHeight then
				return self.playerMech.pos.y - self.enemyMech.pos.y > self.heightThreshold
			else
				return self.playerMech.pos.y - self.desiredHeight > self.heightThreshold
			end
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
			if self.matchHeight then
				return self.enemyMech.pos.y - self.playerMech.pos.y > self.heightThreshold 
			else
				return self.desiredHeight - self.playerMech.pos.y > self.heightThreshold
			end
		end
	end,
	
	shouldMoveLeft = function(self)
		if self.enemyMech.pos.x - self.playerMech.pos.x < -5 and not self.playerMech.facingLeft then
			return true
		elseif self.goInForKill then
			return self.playerMech.pos.x > self.enemyMech.pos.x and self.playerMech.pos.x > self.enemyMech.pos.x + 20 - self.horizontalThreshold 
				or (self.playerMech.pos.x < self.enemyMech.pos.x and self.enemyMech.pos.x < self.playerMech.pos.x + 20 + self.horizontalThreshold)
		else
			return self.playerMech.pos.x - self.desiredHorizontal > self.horizontalThreshold 
		end 
	end,
	
	shouldMoveRight = function(self)
		if self.enemyMech.pos.x - self.playerMech.pos.x > 5 and self.playerMech.facingLeft then
			return true
		elseif self.goInForKill then
			return self.enemyMech.pos.x > self.playerMech.pos.x and self.enemyMech.pos.x > self.playerMech.pos.x + 20 - self.horizontalThreshold 
				or (self.enemyMech.pos.x < self.playerMech.pos.x and self.playerMech.pos.x < self.enemyMech.pos.x + 20 + self.horizontalThreshold)
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
	
	shouldPunch = function(self)
		return self.playerMech.pos.x  - self.enemyMech.pos.x < 25 and self.playerMech.pos.x  - self.enemyMech.pos.x > -25
		and self.playerMech.pos.y  - self.enemyMech.pos.y < 20 and self.playerMech.pos.y  - self.enemyMech.pos.y > -20
	end,
	
	update = function(self, dt)
		self.enemyVel = (self.enemyMech.pos - self.lastEnemyPosition)/dt
		self.lastEnemyPosition = self.enemyMech.pos
		
		self.timeTillEvaluate = self.timeTillEvaluate - dt
		if(self.timeTillEvaluate < 0) then
			self.timeTillEvaluate = love.math.random(2,5)
			local randomState = love.math.random(0,10)
			if(randomState > 6) then
				print("Kill mode Engaged")
				self.goInForKill = true
				self.heightThreshold = 5
				self.matchHeight = true
				self.horizontalThreshold = 5
			elseif(randomState > 3) then
				print("Track Height")
				self.matchHeight = true
				self.heightThreshold = love.math.random(5,20)
				
				self.goInForKill = false
				self.desiredHorizontal = love.math.random(7,87) + love.math.random(7,100) -- 2 rands to give higher weighting to centre of screen
				self.horizontalThreshold = love.math.random(5,20)
			else
				print("Hold Ground")
				self.matchHeight = false
				self.desiredHeight = love.math.random(25,150) 
				self.heightThreshold = love.math.random(5,20)
				
				self.goInForKill = false
				self.desiredHorizontal = love.math.random(7,87) + love.math.random(7,100) -- 2 rands to give higher weighting to centre of screen
				self.horizontalThreshold = love.math.random(5,20)
			end
		end
		
	end,

	hasJoystick = function(self)
		return true -- Always be ineligible for joystick attachment
	end,
}
