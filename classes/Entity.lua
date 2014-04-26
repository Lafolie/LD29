local registry = require "registry"

class "Entity"
{
	__init__ = function(self)
		registry.entities.register(self)
	end,

	collideWith = function(self, shape, other, first, dx, dy)
	end,
}
