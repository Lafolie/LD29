require "classes.Entity"
require "classes.Drawable"
require "classes.Actor"
require "classes.Living"
require "classes.Shader"
require "classes.Controller"
require "classes.Projectile"

local vector = require "lib.hump.vector"
local registry = require "registry"

local function drawBbox(shape)
	local x1, y1, x2, y2 = shape:bbox()
	return love.graphics.rectangle("fill", x1, y1, x2-x1, y2-y1)
end

class "Mech" (Entity, Drawable, Actor, Living)
{
	__init__ = function(self, x, y, player,faceLeft)
		Entity.__init__(self)
		self.player = player
		self.pos = vector(x, y)
		self.gravity = 0
		self.hp = 1000
		self.wins = 0
		self.facingLeft = faceLeft
		self.controller = Controller(player)
		self.animtimer = 0
		self.projectile = nil
		
		if player == 1 then
			self.healthbarPosition = vector(25,10)
		else
			self.healthbarPosition = vector(225,10)
		end
		
		self.damagingShapes = {}

		self.imageTemplate = love.graphics.newImage("gfx/S_Mech.png")
		self.shader = Shader("texAtlas.glsl", "mechPaint.glsl")
		self.size = vector(32, 32)
		self.imageOffset = -self.size/2

		self.shader.uniforms.mask = love.graphics.newImage("gfx/M_Mech.png")
		self.shader.uniforms.user_color = {1, 0, 1}
		self.shader.uniforms.cel_size =
			{
				self.size.x/self.imageTemplate:getWidth(),
				self.size.y/self.imageTemplate:getHeight(),
				1,
				1
			}
		self.shader.uniforms.current_cel = {1, 1}

		self.bodyOffset = vector(-3, -5)
		self.armOffset = vector(8, 0)
		self.fistOffset = vector(12, 0)
		
		if self.facingLeft then
			self.bodyOffset.x = - self.bodyOffset.x
			self.armOffset.x = - self.armOffset.x 
			self.fistOffset.x = - self.fistOffset.x
		end

		self.body = self.pos + self.bodyOffset
		self.arm = self.pos + self.armOffset 
		self.fist = self.pos + self.fistOffset

		self.body = HCShapes.newRectangleShape(self.body.x, self.body.y, 20, 19)
		self.arm = HCShapes.newRectangleShape(self.arm.x, self.arm.y, 6, 7)
		self.fist = HCShapes.newRectangleShape(self.fist.x, self.fist.y, 6, 7)
		
		self.damagingShapes = {}

		registry.shapes.register(self, self.body)
		registry.shapes.register(self, self.arm)
		registry.shapes.register(self, self.fist)
	end,

	update = function(self, dt)
		self.controller:update(dt)
		local movement = vector(0, 0)
		if self.pos.y < FLOORHEIGHT+self.imageOffset.y then
			-- gravitay
			self.gravity = self.gravity + 3 * dt
			movement.y = self.gravity
		else
			self.gravity = 0
		end

		if self.controller:isDown("up") then
			movement.y = movement.y - 50
			self.gravity = 0
		end
		if self.controller:isDown("down") then
			movement.y = movement.y + 50
		end
		if self.controller:isDown("left") then
			movement.x = movement.x - 50
			if not self.facingLeft and self.enemyDirection == 'left' then
				self:flipFacing()
			end
		end
		if self.controller:isDown("right") then
			movement.x = movement.x + 50
			if self.facingLeft  and self.enemyDirection == 'right' then
				self:flipFacing()
			end
		end
		if self.controller:isDown("punch") then
			self:punch(dt)
		end

		if self.projectile and self.projectile:dead() then
			self.projectile = nil
		end

		if self.controller:isDown("hadouken") and not self.projectile then
			local dir = self.facingLeft and -1 or 1
			self.projectile = Projectile(self.pos.x + dir * 30, self.pos.y, dir * 30, 0)
		end

		if movement.x ~= 0 or movement.y ~= 0 then
			self.pos = self.pos + movement*dt

			if self.pos.y > FLOORHEIGHT+self.imageOffset.y then
				self.pos.y = FLOORHEIGHT+self.imageOffset.y
			end

			self.body:moveTo((self.pos + self.bodyOffset):unpack())
			self.arm:moveTo((self.pos + self.armOffset):unpack())
			self.fist:moveTo((self.pos + self.fistOffset):unpack())
		end

		if movement.x ~= 0 then
			self.animtimer = self.animtimer + dt
			if self.animtimer >= 0.125 then
				self.animtimer = self.animtimer - 0.125
				self.shader.uniforms.current_cel = {self.shader.uniforms.current_cel[1]%6+1, 1}
			end
		end
	end,
	
	punch =  function(self, dt)
		self.damagingShapes[self.fist] = { damage = 100, stuns = false, singleHit = true }
	end,
	
	flipFacing = function(self)
		self.facingLeft = not self.facingLeft
		self.bodyOffset.x = - self.bodyOffset.x
		self.armOffset.x = - self.armOffset.x 
		self.fistOffset.x = - self.fistOffset.x
	end,

	collideWith = function(self, shape, other, dx, dy)
		if self.damagingShapes[shape] and class.isinstance(other, Living) then
			other:damage(self.damagingShapes[shape].damage)
			if self.damagingShapes[shape].singleHit then
				self.damagingShapes[shape] = false
			end
			
		end
	end,
	
	damage = function(self, amount)
		self.hp = self.hp - amount
		if self.hp < 0 then
			self.hp = 0
			print("Babooooom bitches")
		end
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255)
		self.shader:apply()
		if self.facingLeft then
			love.graphics.draw(self.imageTemplate, (self.pos - self.imageOffset).x, (self.pos + self.imageOffset).y, 0, -1, 1)
		else
			love.graphics.draw(self.imageTemplate, (self.pos + self.imageOffset).x, (self.pos + self.imageOffset).y)
		end
		self.shader:unapply()
		--[[love.graphics.setColor(255, 255, 255, 50)
		drawBbox(self.body)
		drawBbox(self.arm)
		drawBbox(self.fist)]]

		self:drawHPBars()
	end,
	
	drawHPBars = function(self)
		local lifeperc = self.hp/1000
		local r, g = (1-lifeperc*lifeperc)*255, (1-(1-lifeperc)*(1-lifeperc))*255
		love.graphics.setColor(r, g, 0)
		love.graphics.rectangle("fill", self.healthbarPosition.x, self.healthbarPosition.y, self.hp/1000*150, 10)
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("line", self.healthbarPosition.x, self.healthbarPosition.y, 150, 10)

		for i = 1, self.wins do
			local startx = self.healthbarPosition.x
			local dist = 18
			if self.player == 1 then
				startx = startx + 150
				dist = -dist
			end

			love.graphics.setColor(255, 255, 0)
			love.graphics.circle("fill", startx + dist * i, self.healthbarPosition.y + 18, 4)
			love.graphics.setColor(200, 50, 50)
			love.graphics.circle("fill", startx + dist * i, self.healthbarPosition.y + 18, 3)
		end
	end
}
