local Estore = require 'ecs/estore'
require 'ecs/ecshelpers'
local timerSystem = require 'systems/timer'

local Comps = require 'comps'

local Updaters = {}

local RunSystems = iterateFuncs({
  -- outputCleanupSystem,
  timerSystem,
  -- selfDestructSystem,
  -- controllerSystem,
  -- scriptSystem,
  -- avatarControlSystem,
  -- moverSystem,
  -- animSystem,
  -- zChildrenSystem,
  -- effectsSystem,
})


local function setupEstore(estore, resources, opts)
  estore:newEntity({
    {'timer', {name="testme", countDown=false}},
  })
end

local function updateEstore(world,action)
  world.input.dt = action.dt
  RunSystems(world.estore, world.input, world.resources)
  world.input.events = {} -- clear the events that happened leading up to this tick

  effects = {}
  world.estore:search(hasComps('output'), function(e)
    for _,out in pairs(e.outputs) do
      table.insert(effects,{type=out.kind, value=out.value})
    end
  end)
  return world, effects
end

Updaters.tick = function(world,action)
  local world,effects = updateEstore(world,action)
  return world,effects
end

Updaters.mouse = function(world,action)
  return world,nil
end

--
-- Module interface:
--

local function newWorld(opts)
  local model = {}

  model.estore = Estore:new()
  model.resources = {}
  model.input = {dt=0, events={}}

  setupEstore(model.estore, model.resources, opts)

  return model
end

local function updateWorld(world, action)
  local fn = Updaters[action.type]
  if fn then
    return fn(world,action)
  end
  return world, nil
end

local function drawWorld(world)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(255,255,255)

  world.estore:walkEntities(hasComps('timer'),function(e)
    if e.timer.name == "testme" then
      love.graphics.print("testme Timer: "..e.timer.t)
    end
  end)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
