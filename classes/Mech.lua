require "classes.Entity"
require "classes.Drawable"
require "classes.Actor"
require "classes.Living"
require "classes.Shader"

local vector = require "lib.hump.vector"
local registry = require "registry"

local function drawBbox(shape)
	local x1, y1, x2, y2 = shape:bbox()
	return love.graphics.rectangle("fill", x1, y1, x2-x1, y2-y1)
end

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

class "Mech" (Entity, Drawable, Actor, Living)
{
	__init__ = function(self, x, y, player)
		Entity.__init__(self)
		self.player = player
		self.pos = vector(x, y)
		self.gravity = 0
		self.hp = 1000
		
		if player == 1 then
			self.healthbarPosiiton = vector(50,20)
		else
			self.healthbarPosiiton = vector(450,20)
		end
		
		self.damagingShapes = {}

		self.bodyOffset = vector(0, 0)
		self.rightArmOffset = vector(60, 0)
		self.leftLegOffset = vector(-20, 75)
		self.rightLegOffset = vector(5, 75)
		self.rightFistOffset = vector(105, 0)

		self.body = self.pos + self.bodyOffset
		self.rightArm = self.pos + self.rightArmOffset
		self.leftLeg = self.pos + self.leftLegOffset
		self.rightLeg = self.pos + self.rightLegOffset
		self.rightFist = self.pos + self.rightFistOffset

		self.body = HCShapes.newRectangleShape(self.body.x-30, self.body.y-75, 60, 150)
		self.rightArm = HCShapes.newRectangleShape(self.rightArm.x-30, self.rightArm.y-7, 60, 15)
		self.leftLeg = HCShapes.newRectangleShape(self.leftLeg.x, self.leftLeg.y, 15, 60)
		self.rightLeg = HCShapes.newRectangleShape(self.rightLeg.x, self.rightLeg.y, 15, 60)
		self.rightFist = HCShapes.newRectangleShape(self.rightFist.x-15, self.rightFist.y-15, 30, 30)

		registry.shapes.register(self, self.body)
		registry.shapes.register(self, self.rightArm)
		registry.shapes.register(self, self.leftLeg)
		registry.shapes.register(self, self.rightArm)
		registry.shapes.register(self, self.rightFist)

		self.imageTemplate = love.graphics.newImage("gfx/S_TempMech.png")
		self.shader = Shader("mechPaint.glsl")
		self.shader.uniforms.mask = love.graphics.newImage("gfx/M_TempMech.png")
		self.shader.uniforms.user_color = {1, 0, 1}
	end,

	update = function(self, dt)
		local movement = vector(0, 0)
		if self.pos.y < 460 then
			-- gravitay
			self.gravity = self.gravity + 3 * dt
			movement.y = self.gravity
		else
			self.gravity = 0
		end

		if love.keyboard.isDown(keymap[self.player].up) then
			movement.y = movement.y - 50
			self.gravity = 0
		end
		if love.keyboard.isDown(keymap[self.player].down) then
			movement.y = movement.y + 50
		end
		if love.keyboard.isDown(keymap[self.player].left) then
			movement.x = movement.x - 50
		end
		if love.keyboard.isDown(keymap[self.player].right) then
			movement.x = movement.x + 50
		end
		if love.keyboard.isDown(keymap[self.player].punch) then
			self:punch(dt)
		end

		if movement.x ~= 0 or movement.y ~= 0 then
			self.pos = self.pos + movement*dt

			if self.pos.y > 460 then self.pos.y = 460 end

			self.body:moveTo((self.pos + self.bodyOffset):unpack())
			self.rightArm:moveTo((self.pos + self.rightArmOffset):unpack())
			self.rightFist:moveTo((self.pos + self.rightFistOffset):unpack())
		end
	end,
	
	punch =  function(self, dt)
		self.damagingShapes[self.rightFist] = { damage = 100, stuns = false, singleHit = true }
	end,

	collideWith = function(self, shape, other, dx, dy)
		if self.damagingShapes[shape] and class.isinstance(other, Living) then
			other:damage(self.damagingShapes[shape].damage)
			if self.damagingShapes[shape] then
				self.damagingShapes[shape] = false
			end
			
		end
	end,
	
	damage = function(self, amount)
		self.hp = self.hp - amount
		if self.hp < 0 then
			self.hp = 0
		end
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255)
		drawBbox(self.body)
		drawBbox(self.rightArm)
		drawBbox(self.leftLeg)
		drawBbox(self.rightLeg)

		love.graphics.setColor(0, 255, 0)
		drawBbox(self.rightFist)

		love.graphics.setColor(255, 0, 0)
		love.graphics.point(self.pos.x, self.pos.y)

		love.graphics.setColor(255, 255, 255)
		self.shader:apply()
		love.graphics.draw(self.imageTemplate, self.pos.x, self.pos.y)
		self.shader:unapply()
		
		self:drawHPBars()
	end,
	
	drawHPBars = function(self)
		love.graphics.setColor(0, 255, 0)
		love.graphics.rectangle("fill", self.healthbarPosiiton.x, self.healthbarPosiiton.y, self.hp/1000*300, 20)
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("line", self.healthbarPosiiton.x, self.healthbarPosiiton.y, 300, 20)
	end
}
