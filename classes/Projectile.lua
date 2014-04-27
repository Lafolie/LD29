require "classes.Entity"
require "classes.Actor"
require "classes.Drawable"
require "classes.Living"
local vector = require "lib.hump.vector"
local registry = require "registry"

local img

class "Projectile" (Entity, Actor, Drawable, Living)
{
	__init__ = function(self, x, y, vx, vy)
		Entity.__init__(self)
		if not img then
			img = love.graphics.newImage("gfx/torpedo.png")
		end

		self.pos = vector(x, y)
		self.vel = vector(vx, vy)
		self.offset = vector(-img:getWidth()+5, -2)
		self.hitTarget = false
		self.bubbles = {}
		self.bubbletimer = 0

		self.body = HCShapes.newCircleShape(x, y, 5)
		registry.shapes.register(self, self.body)
	end,

	update = function(self, dt)
		self.pos = self.pos + self.vel*dt
		self.body:moveTo(self.pos:unpack())

		self.bubbletimer = self.bubbletimer + dt
		if self.bubbletimer > 0.075 then
			self.bubbletimer = 0
			local dir = self.vel.x > 0 and -1 or 1
			local x = self.pos.x + (img:getWidth()-5)*dir
			table.insert(self.bubbles, Bubble(x, self.pos.y, dir))
		end
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255)
		local pos = self.pos
		local dir = -1
		if self.vel.x > 0 then
			pos = pos + self.offset
			dir = 1
		else
			pos = pos - self.offset
		end
		love.graphics.draw(img, pos.x, pos.y, 0, dir)
	end,

	dead = function(self)
		return self.hitTarget or self.pos.x < -5 or self.pos.x > 205
	end,

	kill = function(self)
		self.hitTarget = true
	end,

	collideWith = function(self, shape, other, dx, dy)
		if class.isinstance(other, Living) then
			self.hitTarget = true
			other:damage(50)
		end
	end,

	damage = function(self)
		self:kill()
	end,
}
