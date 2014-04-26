require "classes.Entity"
require "classes.Drawable"
require "classes.Actor"

local registry = require "registry"

class "Mech" (Entity, Drawable, Actor)
{
	__init__ = function(self, x, y)
		Entity.__init__(self)
		self.x, self.y = x, y
		self.body = collider:addRectangle(x-10, y-10, 20, 20)
		registry.shapes.register(self, self.body)
	end,

	draw = function(self)
		love.graphics.rectangle("fill", self.x, self.y, 50, 50)
	end,
}
