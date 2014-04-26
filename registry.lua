local registry = {}
registry.shapes = {}
registry.entities = {}
registry.joysticks= {}

local shapes = setmetatable({}, {__mode = "kv"})
local entities = setmetatable({}, {__mode = "v"})
local joysticks = setmetatable({}, {__mode = "kv"})

--- SHAPES ---
function registry.shapes.register(entity, shape)
	collider:addShape(shape)
	shapes[shape] = entity
end

function registry.shapes.unregister(shape)
	collider:remove(shape)
	shapes[shape] = nil
end

function registry.shapes.getEntity(shape)
	return shapes[shape]
end

--- ENTITIES ---
function registry.entities.register(entity)
	table.insert(entities, entity)
end

function registry.entities.iterate()
	return pairs(entities)
end

--- JOYSTICKS ---
function registry.joysticks.bind(controller, joystick)
	joysticks[joystick:getGUID()] = controller
end

function registry.joysticks.unbind(joystick)
	joysticks[joystick:getGUID()] = nil
end

function registry.joysticks.getController(joystick)
	return joysticks[joystick:getGUID()]
end

return registry
