local Iso = require 'iso'
local IsoDebug = require 'isodebug'
local pointInPolygon = require('pointinpolygon').pointInPolygon
local spaceToScreen = Iso.spaceToScreen
local Colors = require 'colors'
local Estore = require 'ecs.estore'
require 'ecs.ecshelpers'
local timerSystem = require 'systems.timer'
local scriptSystem = require 'systems.script'
local controllerSystem = require 'systems.controller'
local isoSpriteAnimSystem = require 'systems.isospriteanim'
local characterControllerSystem = require 'systems.charactercontroller'
local blockMoverSystem = require 'systems.blockmover'
local blockMapSystem = require 'systems.blockmap'
local gravitySystem = require 'systems.gravity'

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
  characterControllerSystem,
  gravitySystem,
  isoSpriteAnimSystem,
  -- avatarControlSystem,
  -- moverSystem,
  -- animSystem,
  -- zChildrenSystem,
  blockMapSystem,
  blockMoverSystem,
  -- effectsSystem,
})

local function setupEstore(estore, resources, opts)
  local isoWorld = estore:newEntity({
    {'isoWorld',{}},
  })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='blockRed', picname="blender_cube_96"}},
  --   {'pos', {x=0,y=0,z=0}},
  -- })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='blockYellow', picname="blender_cube_96"}},
  --   {'pos', {x=1,y=0,z=0}},
  -- })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='blockGreen', picname="blender_cube_96"}},
  --   {'pos', {x=1,y=-1,z=0}},
  -- })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='blockBlue', picname="blender_cube_96"}},
  --   {'pos', {x=0,y=0,z=0}},
  --   {'isoDebug', {on=false}},
  -- })
  addMapBlocks(isoWorld)

  isoWorld:newChild({
    {'pos', {x=0.5,y=0.5,z=1}},
    {'vel', {}},
    {'collidable', {}},
    {'adjacents', {}},
    {'gravity', {}},
    -- {'isoSprite', {id='tshirt_guy', picname="tshirt_guy.fl.walk.1", dir="fr", action="walk"}},
    {'isoSprite', {id='ninja', picname="ninja.fl.walk.1", dir="fl", action="walk"}},
    {'isoSpriteAnimated', {timer='animation'}},
    {'timer', {name='animation', countDown=false}},
    {'controller', {id='con1'}},
    {'isoDebug', {on=true}},
    -- {'script', {scriptName='moverTest', on='tick'}}
  })

  -- isoWorld:newChild({
  --   {'isoSprite', {id='maya1', picname="maya.fl.stand.1"}},
  --   {'pos', {x=0.5,y=0.5,z=1}},
  --   {'isoDebug', {on=true}},
  -- })


  -- isoWorld:newChild({
  --   {'isoSprite', {id='freya1', picname="freya.fl.stand.1"}},
  --   {'pos', {x=0.5,y=-0.5,z=1}},
  -- })
  -- isoWorld:newChild({
  --   {'isoSprite', {id='maya1', picname="maya.fl.stand.1"}},
  --   {'pos', {x=1.5,y=0.5,z=1}},
  -- })
  isoWorld:newChild({
    -- {'isoSprite', {id='freya1', picname="freya.fl.stand.1"}},
    {'isoSprite', {id='ninjatest', picname="ninjatest.fl.stand.1"}},
    {'pos', {x=1.5,y=-0.5,z=1}},
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
  keyboardControllerInput(world.input, { up='w', left='a', down='s', right='d', jump='space' }, 'con1', action, world.controllerState)

  return world,nil
end

local function addBlockToIsoWorld(world, pos, spriteId)
  world.estore:seekEntity(hasComps('isoWorld'), function(e)
    e:newChild({
      {'isoSprite', {id=spriteId, picname="blender_cube_96"}},
      {'pos', pos},
    })
  end)
end

Updaters.mouse = function(world,action)
  world.mouse.x = action.x - world.xform.tx
  world.mouse.y = action.y - world.xform.ty
  if action.state == 'pressed' then
    print(tflatten(action))
    local block = world.mouse.pick.block
    if block then
      local face = world.mouse.pick.face
      if face == 1 then
        local pos = shallowclone(block.pos)
        if action.shift then
          pos.x = pos.x + 1
        else
          pos.x = pos.x - 1
        end
        addBlockToIsoWorld(world, pos, 'blockGreen')
      elseif face == 2 then
        local pos = shallowclone(block.pos)
        pos.y = pos.y - 1
        addBlockToIsoWorld(world, pos, 'blockGreen')
      elseif face == 3 then
        local pos = shallowclone(block.pos)
        pos.z = pos.z + 1
        addBlockToIsoWorld(world, pos, 'blockGreen')
      end
    end
  end
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
local function pickBlockFace(x,y, block)
  local pos = block.pos
  local size = block.size
  local faces = {
    { -- left
      spaceToScreen(pos.x,pos.y,pos.z),
      spaceToScreen(pos.x,pos.y+size.y,pos.z),
      spaceToScreen(pos.x,pos.y+size.y,pos.z+size.z),
      spaceToScreen(pos.x,pos.y,pos.z+size.z),
    },
    { -- right
      spaceToScreen(pos.x,pos.y,pos.z),
      spaceToScreen(pos.x,pos.y,pos.z+size.z),
      spaceToScreen(pos.x+size.x,pos.y,pos.z+size.z),
      spaceToScreen(pos.x+size.x,pos.y,pos.z),
    },
    { --top
      spaceToScreen(pos.x,pos.y,pos.z+size.z),
      spaceToScreen(pos.x,pos.y+size.y,pos.z+size.z),
      spaceToScreen(pos.x+size.x,pos.y+size.y,pos.z+size.z),
      spaceToScreen(pos.x+size.x,pos.y,pos.z+size.z),
    }
  }
  for f=1,#faces do
    if pointInPolygon(x,y, faces[f]) then
      return {f=f}
    end
  end
  return nil
end

local function drawIsoWorld(world, isoWorldEnt, estore, resources)
  local sortedBlocks = isoWorldEnt.isoWorld.blockCache.sorted

  world.mouse.pick.block = nil
  world.mouse.pick.face = nil
  local mouseBlock = pickBlock(world.mouse.x, world.mouse.y, sortedBlocks)
  if mouseBlock then
    world.mouse.pick.block = mouseBlock
    mouseBlock.debug.on = true
    love.graphics.print(mouseBlock.spriteId.." "..tflatten(mouseBlock.pos), 0,0)
    local blockFace = pickBlockFace(world.mouse.x, world.mouse.y, mouseBlock)
    if blockFace then
      world.mouse.pick.face = blockFace.f
      love.graphics.print("  face: "..tflatten(blockFace), 0,15)
    end
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
  love.graphics.setPointSize(3)
  love.graphics.setColor(255,0,0)
  love.graphics.points(world.mouse.x, world.mouse.y)
  love.graphics.setColor(255,255,255)

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

  world.controllerState = {}
  world.mouse = {x=0,y=0,pick={}}

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
    drawIsoWorld(world, e, world.estore, world.resources)
  end)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
