local Iso = require 'iso'
local Colors = require 'colors'
local Estore = require 'ecs/estore'
require 'ecs/ecshelpers'
local timerSystem = require 'systems/timer'

local Comps = require 'comps'

local CHEAT = {}
local BlenderCube96 = "assets/images/blender_cube_96.png" -- 96x128
local Maya = "assets/images/maya_trans.png"
local Freya = "assets/images/freya_trans.png"

CHEAT.isoSprites = {
  maya1= {
    id="maya1",
    image={name=Maya, offx=38, offy=114, width=68, height=106},
    offp={x=0.5, y=0.5, z=0},
    size={x=0.6, y=0.6, z=1.55},
  },
  freya1= {
    id="freya1",
    image={name=Freya, offx=38, offy=114, width=68, height=106},
    offp={x=0.5, y=0.5, z=0},
    size={x=0.7, y=0.6, z=1.55},
  },
  blockRed = {
    id="blockRed",
    image={name=BlenderCube96, offx=38, offy=114, width=96, height=128},
    offp={x=0, y=0, z=0},
    size={x=1, y=1, z=1},
  },
}

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
    {'isoSprite', {id='blockRed'}},
    {'isoPos', {x=0,y=0,z=0}},
  })
  isoWorld:newChild({
    {'iso',{}},
    {'isoSprite', {id='maya1'}},
    -- {'isoPos', {x=0.5,y=0.5,z=1}},
    {'isoPos', {x=0,y=0,z=1}},
  })
  isoWorld:newChild({
    {'iso',{}},
    {'isoSprite', {id='freya1'}},
    {'isoPos', {x=1,y=0,z=1}},
  })
  -- isoWorld:newChild({
  --   {'iso',{}},
  --   {'isoPos', {x=1,y=0,z=0}},
  --   {'isoSize', {x=1,y=1,z=1}},
  --   {'color', {color=Colors.Red}},
  -- })
  -- isoWorld:newChild({
  --   {'iso',{}},
  --   {'isoPos', {x=0,y=1,z=0}},
  --   {'isoSize', {x=1,y=1,z=1}},
  --   {'color', {color=Colors.White}},
  -- })
  -- isoWorld:newChild({
  --   {'iso',{}},
  --   {'isoPos', {x=1,y=1,z=0}},
  --   {'isoSize', {x=1,y=1,z=1}},
  --   {'color', {color=Colors.Yellow}},
  -- })
  -- isoWorld:newChild({
  --   {'iso',{}},
  --   {'isoPos', {x=1,y=1,z=1}},
  --   {'isoSize', {x=1,y=1,z=1}},
  --   {'color', {color=Colors.Green}},
  -- })
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
  local img = CHEAT.images[BlenderCube96]
  b.image = {
    name = BlenderCube96,
    offx = img:getWidth() / 2,
    offy = img:getHeight(),
    -- width = img:getWidth(),
    -- height = img:getHeight(),
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

local function applyOffset(isoPos, offp)
  isoPos.x = isoPos.x - offp.x
  isoPos.y = isoPos.y - offp.y
  isoPos.z = isoPos.z - offp.z
  return isoPos
end

local function updateCachedBlock(block,e)
  block.entity = e -- ?.  reset this just in case the Entity object is actually a new Lua table
  if block.spriteId ~= e.isoSprite.id then
    block.spriteId = e.isoSprite.id
    local sprite = CHEAT.isoSprites[block.spriteId]
    block.sprite = sprite
    block.size = sprite.size
    if sprite.color then
      block.color = sprite.color
    else
      block.color = {255,255,255,255} -- white
    end
    block.image = {
      name = sprite.image.name,
      offx = sprite.image.offx,
      offy = sprite.image.offy,
      width = sprite.image.width,
      height = sprite.image.height,
    }
  end
  block.pos = applyOffset(getIsoPos(e), block.sprite.offp)
  return block
end

local function newCachedBlock(e)
  local block = Iso.newSortable()
  block.type = "spriteEntityBlock" -- not used?
  return block
end

local function drawIsoWorld(isoWorldEnt, estore, resources)
  local saw = {}
  local cache = CHEAT.blockCache
  -- Find entities to draw:
  estore:walkEntity(isoWorldEnt, hasComps('iso'),function(e)
    table.insert(saw, e.eid)
    if cache[e.eid] then
      -- UPDATE CACHED BLOCK
      updateCachedBlock(cache[e.eid], e)
    else
      -- ADD NEW CACHED BLOCK
      cache[e.eid] = updateCachedBlock(newCachedBlock(e), e)
      local bl = cache[e.eid]
      print("new cached block "..e.eid..": "..tdebug(bl.image))
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
  CHEAT.images[Maya] = love.graphics.newImage(Maya)
  CHEAT.images[Freya] = love.graphics.newImage(Freya)

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
