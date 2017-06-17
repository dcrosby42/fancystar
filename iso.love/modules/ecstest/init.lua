local Iso = require 'iso'
local Colors = require 'colors'
local Estore = require 'ecs/estore'
require 'ecs/ecshelpers'
local timerSystem = require 'systems/timer'

local Comps = require 'comps'

local CHEAT = {}
local BlenderCube96 = "assets/images/blender_cube_96.png"


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
  local isoWorld = estore:newEntity({
    {'isoworld',{}},
  })
  isoWorld:newChild({
    {'timer', {name="testme", countDown=false}},
  })
  isoWorld:newChild({
    {'iso',{}},
    {'isoPos', {x=0,y=0,z=0}},
    {'isoSize', {x=1,y=1,z=1}},
    {'color', {color=Colors.Blue}},
  })
  isoWorld:newChild({
    {'iso',{}},
    {'isoPos', {x=1,y=0,z=0}},
    {'isoSize', {x=1,y=1,z=1}},
    {'color', {color=Colors.Red}},
  })
  isoWorld:newChild({
    {'iso',{}},
    {'isoPos', {x=0,y=1,z=0}},
    {'isoSize', {x=1,y=1,z=1}},
    {'color', {color=Colors.White}},
  })
  isoWorld:newChild({
    {'iso',{}},
    {'isoPos', {x=1,y=1,z=0}},
    {'isoSize', {x=1,y=1,z=1}},
    {'color', {color=Colors.Yellow}},
  })
  isoWorld:newChild({
    {'iso',{}},
    {'isoPos', {x=1,y=1,z=1}},
    {'isoSize', {x=1,y=1,z=1}},
    {'color', {color=Colors.Green}},
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

local function newCubeSprite(pos,color)
  local b = Iso.newSortable(pos, {x=1,y=1,z=1})
  b.type = "sprite"
  b.color = color or {255,255,255,255}
  print(b.color)
  local img = CHEAT.images[BlenderCube96]
  b.image = {
    name = BlenderCube96,
    offx = img:getWidth() / 2,
    offy = img:getHeight(),
    width = img:getWidth(),
    height = img:getHeight(),
  }
  b.dbg = {}
  return b
end

local function drawCubeSprite(block)
  local img = CHEAT.images[block.image.name]
  local x,y = Iso.spaceToScreen_(block.pos.x, block.pos.y, block.pos.z)
  love.graphics.setColor(block.color[1], block.color[2], block.color[3], block.color[4])
  love.graphics.draw(
    img,
    x,y,
    0,                                 -- rotation
    1,1,                               -- scalex,scaley
    block.image.offx, block.image.offy -- xoff,yoff
  )
  love.graphics.setColor(255,255,255,255)
end

local function getIsoPos(e)
  local par = e:getParent()
  if par and par.isoPos then
    local pp = getIsoPos(par)
    return {
      x=e.isoPos.x + pp.x,
      y=e.isoPos.y + pp.y,
      z=e.isoPos.z + pp.z,
    }
  else
    return {
      x=e.isoPos.x,
      y=e.isoPos.y,
      z=e.isoPos.z,
    }
  end
end

local function getIsoSize(e)
    return {
      x=e.isoSize.x,
      y=e.isoSize.y,
      z=e.isoSize.z,
    }
end

local function drawIsoWorld(isoWorldEnt, estore, resources)
  local saw = {}
  local cache = CHEAT.blockCache
  -- Find entities to draw:
  estore:walkEntity(isoWorldEnt, hasComps('iso'),function(e)
    table.insert(saw, e.eid)
    if cache[e.eid] then
      -- UPDATE CACHED BLOCK
      local block = cache[e.eid]
      block.entity = e -- ?.  reset this just in case the Entity object is actually a new Lua table
      block.pos = getIsoPos(e)
      block.size = getIsoSize(e)
      if e.color then
        block.color = e.color.color
      else
        block.color = {255,255,255,255}
      end
      -- TODO: check image name difference --> rebuild block.image table
    else
      -- ADD NEW CACHED BLOCK
      -- table.insert(CHEAT.blocks, newCubeSprite({x=0,y=0,z=0}, Colors.Blue))

      local block = Iso.newSortable(getIsoPos(e), getIsoSize(e))
      block.type = "iso-entity"
      block.entity = e -- ?.  reset this just in case the Entity object is actually a new Lua table
      if e.color then
        block.color = e.color.color
      else
        block.color = {255,255,255,255}
      end
      -- TODO base this in info from a component
      local img = CHEAT.images[BlenderCube96]
      block.image = {
        name = BlenderCube96,
        offx = img:getWidth() / 2,
        offy = img:getHeight(),
        width = img:getWidth(),
        height = img:getHeight(),
      }

      cache[e.eid] = block
    end
  end)

  local toSort = {}
  -- Filter out cached blocks that no longer correspond to an entity:
  for eid,block in pairs(cache) do
    if lcontains(saw,eid) then
      table.insert(toSort, block)
    else
      -- REMOVE CACHED BLOCK
      cache[eid] = nil
    end
  end
  CHEAT.blocks = Iso.sortBlocks(toSort)

  -- TODO move this translation up?
  -- TODO use viewport component to determine translation
  love.graphics.push()
  love.graphics.translate(400,400)
  for i=1,#CHEAT.blocks do
    drawCubeSprite(CHEAT.blocks[i])
  end
  love.graphics.pop()

  -- XXX: debugging only
  estore:walkEntity(isoWorldEnt, hasComps('timer'),function(e)
    if e.timer.name == "testme" then
      love.graphics.print("testme Timer: "..e.timer.t)
    end
  end)
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

  CHEAT.images={}
  CHEAT.images[BlenderCube96] = love.graphics.newImage(BlenderCube96)

  CHEAT.blocks={} -- list
  CHEAT.blockCache={} -- map
  -- table.insert(CHEAT.blocks, newCubeSprite({x=0,y=0,z=0}, Colors.Blue))
  -- table.insert(CHEAT.blocks, newCubeSprite({x=1,y=0,z=0}, Colors.Red))
  -- table.insert(CHEAT.blocks, newCubeSprite({x=0,y=0,z=-1}, Colors.White))


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

  world.estore:seekEntity(hasComps('isoworld'),function(e)
    drawIsoWorld(e, world.estore, world.resources)
  end)

  -- world.estore:walkEntities(hasComps('timer'),function(e)
  --   if e.timer.name == "testme" then
  --     love.graphics.print("testme Timer: "..e.timer.t)
  --   end
  -- end)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
