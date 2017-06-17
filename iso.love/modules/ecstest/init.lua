local Iso = require 'iso'
local IsoDebug = require 'isodebug'
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
    offset={x=0.3, y=0.3, z=0},
    size={x=0.6, y=0.6, z=1.55},
  },
  freya1= {
    id="freya1",
    image={name=Freya, offx=38, offy=114, width=68, height=106},
    offset={x=0.35, y=0.3, z=0},
    size={x=0.7, y=0.6, z=1.55},
  },
  blockRed = {
    id="blockRed",
    image={name=BlenderCube96, offx=48, offy=128, width=96, height=128},
    color=Colors.Red,
    offset={x=0, y=0, z=0},
    size={x=1, y=1, z=1},
  },
  blockBlue = {
    id="blockBlue",
    image={name=BlenderCube96, offx=48, offy=128, width=96, height=128},
    color=Colors.Blue,
    offset={x=0, y=1, z=0},
    size={x=1, y=1, z=1},
  },
  blockGreen = {
    id="blockGreen",
    image={name=BlenderCube96, offx=48, offy=128, width=96, height=128},
    color=Colors.Green,
    offset={x=0, y=0, z=0},
    size={x=1, y=1, z=1},
  },
  blockWhite = {
    id="blockWhite",
    image={name=BlenderCube96, offx=48, offy=128, width=96, height=128},
    color=Colors.White,
    offset={x=0, y=0, z=0},
    size={x=1, y=1, z=1},
  },
  blockYellow = {
    id="blockYellow",
    image={name=BlenderCube96, offx=48, offy=128, width=96, height=128},
    color=Colors.Yellow,
    offset={x=0, y=0, z=0},
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
  -- isoWorld:newChild({
  --   {'timer', {name="testme", countDown=false}},
  -- })
  isoWorld:newChild({
    {'isoSprite', {id='blockRed'}},
    {'isoPos', {x=0,y=0,z=0}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='blockYellow'}},
    {'isoPos', {x=1,y=0,z=0}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='blockGreen'}},
    {'isoPos', {x=1,y=-1,z=0}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='blockBlue'}},
    {'isoPos', {x=0,y=0,z=0}},
    {'isoDebug', {on=false}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='maya1'}},
    {'isoPos', {x=0.5,y=0.5,z=1}},
    {'isoDebug', {on=false}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='freya1'}},
    {'isoPos', {x=0.5,y=-0.5,z=1}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='maya1'}},
    {'isoPos', {x=1.5,y=0.5,z=1}},
    {'isoDebug', {on=false}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='freya1'}},
    {'isoPos', {x=1.5,y=-0.5,z=1}},
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

local function drawSpriteBlock(block)
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
  if block.debug then
    -- Draw the x,y location as a white dot:
    love.graphics.setPointSize(4)
    love.graphics.setColor(255,255,255)
    love.graphics.points(x,y)
    love.graphics.setPointSize(1)

    -- draw image bounds as a red rectangle:
    love.graphics.setColor(255,100,100)
    love.graphics.rectangle("line",x-block.image.offx,y-block.image.offy, block.image.width,block.image.height)

    -- draw a transluscent cube around the sprite:
    IsoDebug.drawBlock(block,{255,255,255,100})

    -- draw "real" position of sprite as a yellow dot:
    -- love.graphics.setPointSize(4)
    -- love.graphics.setColor(255,255,0,180)
    -- local sloc = Iso.offsetPos(block)
    -- local slx,sly = Iso.spaceToScreen_(block.pos.x-sloc.x, block.pos.y-sloc.y, block.pos.z-sloc.z) love.graphics.points(slx,sly)

  end
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

local function applyOffset(isoPos, offset)
  isoPos.x = isoPos.x - offset.x
  isoPos.y = isoPos.y - offset.y
  isoPos.z = isoPos.z - offset.z
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
  block.debug = false
  if e.isoDebug and e.isoDebug.on then
    block.debug = true
  end
  block.pos = applyOffset(getIsoPos(e), block.sprite.offset)
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
  estore:walkEntity(isoWorldEnt, hasComps('isoSprite'),function(e)
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
    drawSpriteBlock(CHEAT.blocks[i])
  end


  love.graphics.pop()
  -- Draw origin
  -- love.graphics.setPointSize(4,4)
  -- love.graphics.setColor(0,0,255)
  -- love.graphics.points(400,400)
  -- love.graphics.setColor(255,255,255)


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
