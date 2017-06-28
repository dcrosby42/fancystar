local Iso = require 'iso'
local IsoDebug = require 'isodebug'
local Colors = require 'colors'
local Estore = require 'ecs/estore'
require 'ecs/ecshelpers'
local timerSystem = require 'systems/timer'
local scriptSystem = require 'systems/script'

local Comps = require 'comps'

local Pics = require 'data.pics'
local Sprites = require 'data.sprites'

local Resources = require 'modules.ecstest.resources'

local CHEAT = {}
local BlenderCube96 = "assets/images/blender_cube_96.png" -- 96x128
local Maya = "assets/images/maya_trans.png"
local Freya = "assets/images/freya_trans.png"

-- f(bundle, pose, dir, time) -> pic


local Updaters = {}

local RunSystems = iterateFuncs({
  -- outputCleanupSystem,
  timerSystem,
  -- selfDestructSystem,
  -- controllerSystem,
  scriptSystem,
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
    {'isoSprite', {id='blockRed', picname="blender_cube_96"}},
    {'isoPos', {x=0,y=0,z=0}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='blockYellow', picname="blender_cube_96"}},
    {'isoPos', {x=1,y=0,z=0}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='blockGreen', picname="blender_cube_96"}},
    {'isoPos', {x=1,y=-1,z=0}},
  })
  isoWorld:newChild({
    {'isoSprite', {id='blockBlue', picname="blender_cube_96"}},
    {'isoPos', {x=0,y=0,z=0}},
    {'isoDebug', {on=false}},
  })

  -- isoWorld:newChild({
  --   {'isoSprite', {id='maya1', picname="maya.fl.stand.1"}},
  --   {'isoPos', {x=0.5,y=0.5,z=1}},
  --   {'isoDebug', {on=true}},
  -- })

  isoWorld:newChild({
    -- {'isoSprite', {id='tshirt_guy', picname="tshirt_guy.fl.walk.2"}},
    {'isoSprite', {id='tshirt_guy', picname="tshirt_guy.fr.walk.1"}},
    {'isoPos', {x=0.5,y=0.5,z=1}},
    -- {'isoDebug', {on=true}},
    {'timer', {name='rotate', t=1, loop=true, reset=1}},
    {'timer', {name='animate', loop=true, reset=0.15}},
    {'timer', {name='animation', countDown=false}},
    -- {'script', {scriptName='rotateTshirtGuy', on='tick'}}
    {'script', {scriptName='walkFR', on='tick'}}
  })

  -- isoWorld:newChild({
  --   {'isoSprite', {id='freya1', picname="freya.fl.stand.1"}},
  --   {'isoPos', {x=0.5,y=-0.5,z=1}},
  -- })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='maya1', picname="maya.fl.stand.1"}},
  --   {'isoPos', {x=1.5,y=0.5,z=1}},
  -- })
  isoWorld:newChild({
    {'isoSprite', {id='freya1', picname="freya.fl.stand.1"}},
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
  -- local pic = CHEAT.picdata.pics[block.picname]
  local pic = block.pic
  local x,y = Iso.spaceToScreen_(block.pos.x, block.pos.y, block.pos.z)
  love.graphics.setColor(block.color[1], block.color[2], block.color[3], block.color[4])
  love.graphics.draw(
    pic.image,
    pic.quad,
    x,y,
    0,                                 -- rotation
    1,1,                               -- scalex,scaley
    block.imageOffset.x, block.imageOffset.y -- xoff,yoff
  )
  if block.debug.on then
    -- draw image bounds as a red rectangle:
    love.graphics.setColor(255,100,100)
    love.graphics.rectangle("line", x - block.imageOffset.x, y - block.imageOffset.y, block.pic.rect.w, block.pic.rect.h)

    -- draw sprite box bounds as a transluscent cube
    IsoDebug.drawBlock(block,{255,255,255,100})

    -- draw "real" position of sprite as a yellow dot:
    local sx,sy = Iso.spaceToScreen_(block.debug.spritePos.x, block.debug.spritePos.y, block.debug.spritePos.z)
    love.graphics.setPointSize(4)
    love.graphics.setColor(255,255,0,180)
    love.graphics.points(sx,sy)
    -- local slx,sly = Iso.spaceToScreen_(block.pos.x-sloc.x, block.pos.y-sloc.y, block.pos.z-sloc.z) love.graphics.points(slx,sly)

    love.graphics.setPointSize(1)
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
    assert(sprite, "No sprite for block.spriteId="..block.spriteId)
    block.spriteOffset = sprite.offset
    block.size = sprite.size
    if sprite.color then
      block.color = sprite.color
    else
      block.color = {255,255,255,255} -- white
    end
    block.imageOffset = sprite.imageOffset
    block.picname = ""
    block.pic = {}
  end
  if block.picname ~= e.isoSprite.picname then
    block.picname = e.isoSprite.picname
    block.pic = CHEAT.picdata.pics[e.isoSprite.picname]
    assert(block.pic, "No sprite for block.picname="..block.picname)
    -- local pic = CHEAT.picdata.pics[e.isoSprite.picname]
    -- block.picref = {
    --   name = e.isoSprite.picname,
    --   offx = sprite.imageOffset.x,
    --   offy = sprite.imageOffset.y,
    --   width = pic.rect.w,
    --   height = pic.rect.h,
    -- }
  end
  if e.isoDebug and e.isoDebug.on then
    block.debug.on = true
  end
  block.pos = applyOffset(getIsoPos(e), block.spriteOffset)
  if e.isoDebug and e.isoDebug.on then
    block.debug.on = true
    block.debug.spritePos = getIsoPos(e)
  else
    block.debug.on = false
  end
  return block
end

local function newCachedBlock(e)
  local block = Iso.newSortable()
  block.type = "spriteEntityBlock" -- not used?
  block.debug = {on=false}
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
  model.resources = Resources
  model.input = {dt=0, events={}}

  setupEstore(model.estore, model.resources, opts)

  CHEAT.images={}
  CHEAT.images[BlenderCube96] = love.graphics.newImage(BlenderCube96)
  CHEAT.images[Maya] = love.graphics.newImage(Maya)
  CHEAT.images[Freya] = love.graphics.newImage(Freya)

  CHEAT.blocks={} -- list
  CHEAT.blockCache={} -- map

  CHEAT.picdata = Pics.load()
  CHEAT.isoSprites = Sprites.load()
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
