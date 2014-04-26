require "classes.Entity"
require "classes.Actor"
require "classes.Drawable"
require "classes.Living"
local vector = require "lib.hump.vector"
local registry = require "registry"

class "Projectile" (Entity, Actor, Drawable, Living)
{
	__init__ = function(self, x, y, vx, vy)
		Entity.__init__(self)
		self.pos = vector(x, y)
		self.vel = vector(vx, vy)
		self.hitTarget = false

		self.body = HCShapes.newCircleShape(x, y, 5)
		registry.shapes.register(self, self.body)
	end,

	update = function(self, dt)
		self.pos = self.pos + self.vel*dt
		self.body:moveTo(self.pos:unpack())
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255)
		love.graphics.circle("fill", self.pos.x, self.pos.y, 5)
	end,

	dead = function(self)
		return self.hitTarget or self.pos.x < -5 or self.pos.x > 405
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