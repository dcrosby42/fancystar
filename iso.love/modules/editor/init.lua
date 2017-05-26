local Iso = require 'iso'
local IsoDebug = require 'isodebug'
local Colors = require 'colors'

local Maya = "images/maya_trans.png"
local BlenderCube96 = "images/blender_cube_96.png"

local function boundsToPos(bounds)
  return {
    x = -(bounds.size.x * bounds.offp.x),
    y = -(bounds.size.y * bounds.offp.y),
    z = -(bounds.size.z * bounds.offp.z),
  }
end

local function addSprite(model)
  local spriteDef = {
    name="Maya",
    image={name=Maya, offx=38, offy=114},
    bounds={
      offp={x=0.5, y=0.5, z=0},
      size={x=0.75, y=0.75, z=1.6},
    },
    debug={color=Colors.White},
  }

  local pos = Iso.worldOrigin()
  pos = Iso.transCopy(pos,boundsToPos(spriteDef.bounds))
  local s = Iso.newBlock(pos, spriteDef.bounds.size, spriteDef.debug.color, spriteDef.name)
  s.type = "sprite"
  s.image = tcopy(spriteDef.image)
  s.bounds = spriteDef.bounds
  model.sprite = s
end

local function newWorld()
  local model ={
    view={x=400, y=400,scale=1,zoomInc=0.25},
    mouse={down=false},
    flags={
      grid=true,
      drawSprites=true,
      drawSpriteGeom=true,
    },
  }
  model.images = {}
  model.images[BlenderCube96] = love.graphics.newImage(BlenderCube96)
  model.images[Maya] = love.graphics.newImage(Maya)
  addSprite(model)
  return model
end

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
      model.view.x = model.view.x + action.dx
      model.view.y = model.view.y + action.dy
    end
  elseif action.state == 'pressed' then
    model.mouse.down = true
  elseif action.state == 'released' then
    model.mouse.down = false
  end
end

local function updateWorld(model,action)
  if action.type == "keyboard" and action.state == "pressed" then
    handleKeyPressed(action.key, model, action)

  elseif action.type == "mouse" then
    handleMouse(model,action)
  end
  return model, nil
end


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

local function drawSpriteDebug(images,block)
  local img = images[block.image.name]
  local x,y = Iso.spaceToScreen_(block.pos.x, block.pos.y, block.pos.z)
  local offx = block.image.offx
  local offy = block.image.offy

  -- draw image bounds as a red rectangle:
  love.graphics.setColor(255,100,100)
  love.graphics.rectangle("line",x-offx,y-offy, img:getWidth(), img:getHeight())

  -- draw a transluscent cube:
  IsoDebug.drawBlock(block,{255,255,255,100})
  love.graphics.setPointSize(4)
  love.graphics.setColor(255,255,0,180)

  -- draw "real" position of sprite as a yellow dot:
  local sloc = boundsToPos(block.bounds)
  local slx,sly = Iso.spaceToScreen_(block.pos.x-sloc.x, block.pos.y-sloc.y, block.pos.z-sloc.z)
  love.graphics.points(slx,sly)

  love.graphics.setColor(255,255,255)
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

  if model.flags.drawSprites then
    drawSprite(model.images, model.sprite)
  end
  if model.flags.drawSpriteGeom then
    drawSpriteDebug(model.images, model.sprite)
  end

  love.graphics.pop()
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
