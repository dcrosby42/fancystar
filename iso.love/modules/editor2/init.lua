local Iso = require 'iso'
local IsoDebug = require 'isodebug'
local Colors = require 'colors'
local DataLoader = require 'dataloader'
local suit = require 'SUIT'
local Widgets = require 'modules.editor.widgets'

require 'ecs.ecshelpers' -- eg, hasComps
local Comps = require 'comps'
local Estore = require 'ecs.estore'
local Resources = require 'modules.ecstest.resources'
local timerSystem = require 'systems.timer'
local blockMoverSystem = require 'systems.blockmover'
local blockMapSystem = require 'systems.blockmap'
local isoSpriteAnimSystem = require 'systems.isospriteanim'

local Pics = require("data/pics")

local Maya = "assets/images/maya_trans.png"
local Freya = "assets/images/freya_trans.png"
local BlenderCube96 = "assets/images/blender_cube_96.png"
local TshirtGuy = "assets/images/freya_trans.png"

-- XXX delete this:
-- local sprites = {
--   maya1= {
--     type="sprite",
--     id="maya1",
--     name="Maya",
--     image={name=Maya, offx=38, offy=114},
--     offp={x=0.5, y=0.5, z=0},
--     size={x=0.6, y=0.6, z=1.55},
--     debug={color=Colors.White},
--   },
--   freya1= {
--     type="sprite",
--     id="maya1",
--     name="Freya",
--     image={name=Freya, offx=38, offy=114},
--     offp={x=0.5, y=0.5, z=0},
--     size={x=0.7, y=0.6, z=1.55},
--     debug={color=Colors.White},
--   },
--   tshirt_guy= {
--     type="sprite",
--     id="tshirt_guy",
--     name="TshirtGuy",
--     image={name=TShirtGuy, offx=38, offy=114},
--     offp={x=0.5, y=0.5, z=0},
--     size={x=0.7, y=0.6, z=1.55},
--     debug={color=Colors.White},
--   }
-- }

--
-- INIT
--
local RunAllSystems = iterateFuncs({
  timerSystem,
  -- scriptSystem,
  isoSpriteAnimSystem,
  blockMapSystem,
  blockMoverSystem,
})

local function setupEstore(estore, resources, opts)
  local isoWorld = estore:newEntity({
    {'isoWorld',{}},
  })

  isoWorld:newChild({
    {'pos', {x=0.5,y=0.5,z=0}},
    {'isoSprite', {id='ninja', picname="ninja.fl.walk.1", dir="fl", action="walk"}},
    -- {'isoSprite', {id='tshirt_guy', picname="ninja.fl.walk.1", dir="fl", action="walk"}},
    {'isoSpriteAnimated', {timer='animation'}},
    {'timer', {name='animation', countDown=false}},
    {'isoDebug', {on=true}},
  })
end

--
-- UPDATING
--

local function changeZoom(model,zoom)
  if zoom <= 0 then zoom = 0.25 end
  if zoom > 3 then zoom = 3 end
  model.view.scale = zoom
end

local function handleKeyPressed(key,model,action)
  if key == "-" then changeZoom(model,model.view.scale - model.view.zoomInc) end
  if key == "=" then changeZoom(model,model.view.scale + model.view.zoomInc) end
  if key == "0" then changeZoom(model,1) end
  if key == "g" then model.flags.grid = not model.flags.grid end
  if key == "i" then model.flags.drawSprites = not model.flags.drawSprites end
  if key == "b" then model.flags.drawSpriteGeom = not model.flags.drawSpriteGeom end
end

local function handleMouse(model,action)
  if action.state == 'moved' then
    if model.mouse.down then
      if model.mouse.pan then
        model.view.x = model.view.x + action.dx
        model.view.y = model.view.y + action.dy
      elseif model.mouse.move then
        -- TODO Redo this to update the entity
        -- local comp = model.comp
        -- comp.pos.x = comp.pos.x + Iso.imgWidthToWorldWidth(action.dx)
        -- comp.pos.y = comp.pos.y - Iso.imgWidthToWorldWidth(action.dy)
        -- updateDrawables(model)
      end
    end
  elseif action.state == 'pressed' then
    model.mouse.down = true
    if action.button == 1 then
      model.mouse.move = true
    else
      model.mouse.pan = true
    end
  elseif action.state == 'released' then
    model.mouse.down = false
    model.mouse.move = false
    model.mouse.pan = false
  end
end

local function updateEstore(model,action)
  model.input.dt = action.dt
  RunAllSystems(model.estore, model.input, model.resources)
  model.input.events = {} -- clear the events that happened leading up to this tick

  effects = {}
  model.estore:search(hasComps('output'), function(e)
    for _,out in pairs(e.outputs) do
      table.insert(effects,{type=out.kind, value=out.value})
    end
  end)
  return model, effects
end

--
-- DRAWING
--

local function drawGrid()
  -- Floor
  love.graphics.setColor(255,255,255)
  for x=-1,1 do
    for y=-1,1 do
      IsoDebug.drawTileOutline(x,y,0,"bottom")
    end
  end
  -- back-wall (left)
  love.graphics.setColor(200,200,200)
  for x=-1,1 do
    for z=0,1 do
      IsoDebug.drawTileOutline(x,2,z,"right")
    end
  end
  -- back wall (right)
  love.graphics.setColor(110,110,110)
  for y=0,2 do
    for z=0,1 do
      IsoDebug.drawTileOutline(2,y,z,"left")
    end
  end

  -- Origin point
  love.graphics.setColor(255,255,255)
  love.graphics.setPointSize(6)
  love.graphics.points(unpack(Iso.spaceToScreen(0,0,0)))
  love.graphics.setPointSize(1)

  -- Z arrow
  love.graphics.setColor(120,120,255)
  local x1,y1 = Iso.spaceToScreen_(-1.25,2,0)
  local x2,y2 = Iso.spaceToScreen_(-1.25,2,1)
  love.graphics.line(x1,y1,x2,y2)
  love.graphics.line(x2-3,y2+5, x2,y2, x2+3,y2+5)
  love.graphics.print("z",x1-11,y1-11)

  -- X arrow
  love.graphics.setColor(255,120,120)
  local x1,y1 = Iso.spaceToScreen_(-1,-1.25,0)
  local x2,y2 = Iso.spaceToScreen_(0,-1.25,0)
  love.graphics.line(x1,y1,x2,y2)
  love.graphics.line(x2-7,y2, x2,y2, x2-3,y2+5)
  love.graphics.print("x",x1+5,y1)

  -- Y arrow
  love.graphics.setColor(120,255,120)
  local x1,y1 = Iso.spaceToScreen_(-1.25,-1,0)
  local x2,y2 = Iso.spaceToScreen_(-1.25,0,0)
  love.graphics.line(x1,y1,x2,y2)
  love.graphics.line(x2+7,y2, x2,y2, x2+3,y2+5)
  love.graphics.print("y",x1-13,y1-3)
end

local function drawSprite(images,block)
  local img = images[block.image.name]
  local x,y = Iso.spaceToScreen_(block.pos.x, block.pos.y, block.pos.z)
  local r,g,b,a = unpack(block.color)
  local offx = block.image.offx
  local offy = block.image.offy
  love.graphics.setColor(r,g,b,a)
    love.graphics.draw(
      img,
      x,y,
      0,                                 -- rotation
      1,1,                               -- scalex,scaley
      offx, offy -- xoff,yoff
    )
  love.graphics.setColor(255,255,255)
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


local function drawIsoWorld(isoWorldEnt, estore, resources)
  local blocks = isoWorldEnt.isoWorld.blockCache.sorted
  for i=1,#blocks do
    drawSpriteBlock(blocks[i])
  end
end

-- TODO bring this back
-- local function drawSpriteDebug(images,block)
--   local img = images[block.image.name]
--   local x,y = Iso.spaceToScreen_(block.pos.x, block.pos.y, block.pos.z)
--   local offx = block.image.offx
--   local offy = block.image.offy
--
--   -- draw image bounds as a red rectangle:
--   love.graphics.setColor(255,100,100)
--   love.graphics.rectangle("line",x-offx,y-offy, img:getWidth(), img:getHeight())
--
--   -- draw a transluscent cube:
--   IsoDebug.drawBlock(block,{255,255,255,100})
--   love.graphics.setPointSize(4)
--   love.graphics.setColor(255,255,0,180)
--
--   -- draw "real" position of sprite as a yellow dot:
--   local sloc = Iso.offsetPos(block)
--   local slx,sly = Iso.spaceToScreen_(block.pos.x-sloc.x, block.pos.y-sloc.y, block.pos.z-sloc.z)
--   love.graphics.points(slx,sly)
--
--   love.graphics.setColor(255,255,255)
-- end

local function updatePropEditor(model,action)
  -- local e = model.editor
  -- local comp = model.comp
  -- local spr = sprites[comp.spriteId]
  -- suit.layout:reset(e.x,e.y, 5,5) -- x,y and padding
  --
  -- suit.Label(comp.spriteId, suit.layout:row(200,30))
  -- local posW = Widgets.Vector3(suit,"Pos", comp.pos, e.scratch.pos)
  -- local spriteW = Widgets.Sprite(suit,"Sprite",spr,e.scratch.sprite)
  -- if posW.changed or spriteW.changed then
  --   updateDrawables(model)
  -- end
  -- TODO THIS IS A PLACEHOLDER
  local e = model.editor
  suit.layout:reset(e.x,e.y, 5,5) -- x,y and padding
  suit.Label("TBD spriteId", suit.layout:row(200,30))
  local posW = Widgets.Vector3(suit,"Pos", {x=0,y=0,z=0}, {x=0,y=0,z=0})
end

local function drawPropEditor(model)
  suit.draw()
end

--
-- MODULE HOOKS
--

local function newWorld()
  DataLoader.test()
  Pics.test()

  local model ={
    view={x=400, y=400,scale=1.5,zoomInc=0.25},
    mouse={down=false,pan=false,move=false},
    flags={
      grid=true,
      drawSprites=true,
      drawSpriteGeom=true,
    },
    res={sprites=sprites},
  }

  model.estore = Estore:new()
  model.resources = Resources.load()
  model.input = {dt=0, events={}}
  setupEstore(model.estore, model.resources, {})

  model.images = {}
  model.images[BlenderCube96] = love.graphics.newImage(BlenderCube96)
  model.images[Maya] = love.graphics.newImage(Maya)
  model.images[Freya] = love.graphics.newImage(Freya)

  local comp = {
    cid="c1",
    spriteId="freya1",
    pos = {x=0.5,y=0.5,z=0}
  }
  model.comp = comp
  model.comps = {comp}
  model.drawables = {}

  model.screen = {w=love.graphics.getWidth(), h=love.graphics.getHeight()}
  model.editor = {}
  model.editor.w = 300
  model.editor.x = model.screen.w-model.editor.w
  model.editor.y = 0
  model.editor.scratch = {
    pos={
      x={text="0"},
      y={text="0"},
      z={text="0"},
    },
    sprite={
      offp={
        x={text="0"},
        y={text="0"},
        z={text="0"},
      },
      size={
        x={text="0"},
        y={text="0"},
        z={text="0"},
      },
    },
  }

  return model
end

local function updateWorld(model,action)
  if action.type == "tick" then
    updatePropEditor(model,action)
    updateEstore(model,action)
  elseif action.type == "keyboard" and action.state == "pressed" then
    handleKeyPressed(action.key, model, action)
    suit.keypressed(action.key)
  elseif action.type == "textinput" then
    suit.textinput(action.text)
  elseif action.type == "mouse" then
    handleMouse(model,action)
  end
  return model, nil
end


local function drawWorld(model)
  love.graphics.setBackgroundColor(0,0,50)
  love.graphics.setColor(255,255,255)

  love.graphics.push()
  love.graphics.translate(model.view.x, model.view.y)
  love.graphics.scale(model.view.scale,model.view.scale)

  if model.flags.grid then
    drawGrid()
  end

  --
  -- TODO drawSpriteDebug(img, drawableBlock)
  --

  model.estore:seekEntity(hasComps('isoWorld'), function(isoWorldEnt)
    drawIsoWorld(isoWorldEnt, model.estore, model.resources)
  end)

  love.graphics.pop()


  drawPropEditor(model)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
