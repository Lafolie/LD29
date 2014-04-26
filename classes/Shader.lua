class "Shader"
{
	__init__ = function(self, filenameA, filenameB)
		local srcA = love.filesystem.read("glsl/" .. filenameA)
		assert(srcA, "Shader file does not exist")
		local srcB = filenameB and love.filesystem.read("glsl/" .. filenameB)
		assert(not filenameB or srcB, "Shader file does not exist")
		self.shader = love.graphics.newShader(srcA, srcB)
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
