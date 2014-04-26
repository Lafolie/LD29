class "Shader"
{
	__init__ = function(self, filename)
		local src = love.filesystem.read("glsl/" .. filename)
		assert(src, "Shader file does not exist")
		self.shader = love.graphics.newShader(src)
		print(self.shader:getWarnings())

		self.uniforms = setmetatable({},
			{
				__newindex = function(_, name, value)
					self.shader:send(name, value)
				end,
			})
	end,

	apply = function(self)
		love.graphics.setShader(self.shader)
	end,

	unapply = function(self)
		love.graphics.setShader()
	end,
}
