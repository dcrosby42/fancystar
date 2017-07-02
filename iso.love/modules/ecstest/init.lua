local Iso = require 'iso'
local IsoDebug = require 'isodebug'
local Colors = require 'colors'
local Estore = require 'ecs.estore'
require 'ecs.ecshelpers'
local timerSystem = require 'systems.timer'
local scriptSystem = require 'systems.script'
local controllerSystem = require 'systems.controller'
local isoSpriteAnimSystem = require 'systems.isospriteanim'
local characterMoverSystem = require 'systems.charactermover'
local blockMapSystem = require 'systems.blockmap'

local Comps = require 'comps'

local Resources = require 'modules.ecstest.resources'

local keyboardControllerInput = require 'keyboardcontrollerinput'
local addMapBlocks = require 'modules.ecstest.addmapblocks'

local BlenderCube96 = "assets/images/blender_cube_96.png" -- 96x128
local Maya = "assets/images/maya_trans.png"
local Freya = "assets/images/freya_trans.png"

local Updaters = {}

local RunSystems = iterateFuncs({
  -- outputCleanupSystem,
  timerSystem,
  -- selfDestructSystem,
  controllerSystem,
  scriptSystem,
  characterMoverSystem,
  isoSpriteAnimSystem,
  -- avatarControlSystem,
  -- moverSystem,
  -- animSystem,
  -- zChildrenSystem,
  blockMapSystem,
  -- effectsSystem,
})

local function setupEstore(estore, resources, opts)
  local isoWorld = estore:newEntity({
    {'isoWorld',{}},
  })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='blockRed', picname="blender_cube_96"}},
  --   {'isoPos', {x=0,y=0,z=0}},
  -- })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='blockYellow', picname="blender_cube_96"}},
  --   {'isoPos', {x=1,y=0,z=0}},
  -- })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='blockGreen', picname="blender_cube_96"}},
  --   {'isoPos', {x=1,y=-1,z=0}},
  -- })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='blockBlue', picname="blender_cube_96"}},
  --   {'isoPos', {x=0,y=0,z=0}},
  --   {'isoDebug', {on=false}},
  -- })
  addMapBlocks(isoWorld)

  isoWorld:newChild({
    {'isoPos', {x=0.5,y=0.5,z=1}},
    {'isoSprite', {id='tshirt_guy', picname="tshirt_guy.fl.walk.1", dir="fr", action="walk"}},
    {'isoSpriteAnimated', {timer='animation'}},
    {'timer', {name='animation', countDown=false}},
    {'controller', {id='con1'}},
    {'isoDebug', {on=true}},
    -- {'script', {scriptName='moverTest', on='tick'}}
  })

  -- isoWorld:newChild({
  --   {'isoSprite', {id='maya1', picname="maya.fl.stand.1"}},
  --   {'isoPos', {x=0.5,y=0.5,z=1}},
  --   {'isoDebug', {on=true}},
  -- })


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

Updaters.keyboard = function(world,action)
  -- addInputEvent(world.input, action)
  keyboardControllerInput(world.input, { up='w', left='a', down='s', right='d' }, 'con1', action, world.controllerState)
  return world,nil
end

Updaters.mouse = function(world,action)
  world.mouse.x = action.x - world.xform.tx
  world.mouse.y = action.y - world.xform.ty
  return world,nil
end

local function drawSpriteBlock(block)
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
    local sx,sy = Iso.spaceToScreen_(block.spritePos.x, block.spritePos.y, block.spritePos.z)
    love.graphics.setPointSize(4)
    love.graphics.setColor(255,255,0,180)
    love.graphics.points(sx,sy)
    -- local slx,sly = Iso.spaceToScreen_(block.pos.x-sloc.x, block.pos.y-sloc.y, block.pos.z-sloc.z) love.graphics.points(slx,sly)

    love.graphics.setPointSize(1)
  end
  love.graphics.setColor(255,255,255,255)
end

local function pickBlock(x,y, blocks)
  for i=#blocks,1,-1 do
    local block = blocks[i]
    local bx,by = Iso.spaceToScreen_(block.pos.x, block.pos.y, block.pos.z)
    bx = bx - block.imageOffset.x
    by = by - block.imageOffset.y
    if math.pointinrect(x,y, bx,by, block.pic.rect.w, block.pic.rect.h) then
      local imgdata = block.pic.image:getData()
      local r,g,b,a = imgdata:getPixel(x-bx+block.pic.rect.x, y-by+block.pic.rect.y)
      if a > 0 then
        return block
      end
    end
  end
  return nil
end

local function drawIsoWorld(world, isoWorldEnt, estore, resources, blockCache)
  local sortedBlocks = isoWorldEnt.isoWorld.sortedBlocks

  local mouseBlock = pickBlock(world.mouse.x, world.mouse.y, sortedBlocks)
  if mouseBlock then
    mouseBlock.debug.on = true
  end

  -- DRAW THE SORTED BLOCKS
  -- TODO move this translation up?
  love.graphics.push()
  love.graphics.translate(world.xform.tx,world.xform.ty)
  for i=1,#sortedBlocks do
    drawSpriteBlock(sortedBlocks[i])
  end

  -- Draw projection axes:
  -- local ox,oy = Iso.spaceToScreen_(0,0,0)
  -- local xx,xy = Iso.spaceToScreen_(5,0,0)
  -- local yx,yy = Iso.spaceToScreen_(0,5,0)
  -- local zx,zy = Iso.spaceToScreen_(0,0,5)
  -- love.graphics.setColor(unpack(Colors.Red))
  -- love.graphics.line(ox,oy, xx,xy)
  -- love.graphics.setColor(unpack(Colors.Green))
  -- love.graphics.line(ox,oy, yx,yy)
  -- love.graphics.setColor(unpack(Colors.Blue))
  -- love.graphics.line(ox,oy, zx,zy)
  -- love.graphics.setPointSize(4)
  --
  -- local smx,smy = Iso.screenToSpace_(world.mouse.x, world.mouse.y)
  -- love.graphics.setColor(unpack(Colors.Yellow))
  -- local xmax,xmay = Iso.spaceToScreen_(smx,0,0)
  -- local ymax,ymay = Iso.spaceToScreen_(0,smy,0)
  -- love.graphics.points(ox,oy, xmax,xmay, ymax,ymay)

  love.graphics.pop()
end

--
-- Module interface:
--
local function newWorld(opts)
  local world = {}
  world.estore = Estore:new()
  world.resources = Resources.load()
  world.input = {dt=0, events={}}

  world.caches = { blockCache={} }

  world.controllerState = {}
  world.mouse = {x=0,y=0}

  world.xform={tx=450, ty=450, sx=1, sy=1}

  setupEstore(world.estore, world.resources, opts)

  return world
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

  world.estore:seekEntity(hasComps('isoWorld'),function(e)
    drawIsoWorld(world, e, world.estore, world.resources, world.caches.blockCache)
  end)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
