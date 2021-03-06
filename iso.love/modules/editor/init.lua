local Iso = require 'iso'
local IsoDebug = require 'isodebug'
local Colors = require 'colors'
local DataLoader = require 'dataloader'
local suit = require 'SUIT'
local Widgets = require 'modules.editor.widgets'

local Pics = require("data/pics")

local Maya = "assets/images/maya_trans.png"
local Freya = "assets/images/freya_trans.png"
local BlenderCube96 = "assets/images/blender_cube_96.png"
local TshirtGuy = "assets/images/freya_trans.png"

local sprites = {
  maya1= {
    type="sprite",
    id="maya1",
    name="Maya",
    image={name=Maya, offx=38, offy=114},
    offp={x=0.5, y=0.5, z=0},
    size={x=0.6, y=0.6, z=1.55},
    debug={color=Colors.White},
  },
  freya1= {
    type="sprite",
    id="maya1",
    name="Freya",
    image={name=Freya, offx=38, offy=114},
    offp={x=0.5, y=0.5, z=0},
    size={x=0.7, y=0.6, z=1.55},
    debug={color=Colors.White},
  },
  tshirt_guy= {
    type="sprite",
    id="tshirt_guy",
    name="TshirtGuy",
    image={name=TShirtGuy, offx=38, offy=114},
    offp={x=0.5, y=0.5, z=0},
    size={x=0.7, y=0.6, z=1.55},
    debug={color=Colors.White},
  }
}

local function updateDrawables(model)
  local sawCids = {}
  -- For each com either insert a new drawable or update an existing
  for i=1,#model.comps do
    local comp = model.comps[i]
    local sprite = model.res.sprites[comp.spriteId]
    local pos = Iso.transCopy(comp.pos, Iso.offsetPos(sprite))

    local dr
    for j=1,#model.drawables do
      if model.drawables[j].cid == comp.cid then
        dr = model.drawables[j]
      end
    end
    if dr then
      -- just update
      dr.pos = pos
    else
      -- new drawable from sprite:
      local dr = Iso.newBlock(pos, sprite.size, sprite.debug.color, sprite.name)
      dr.type = "spriteBox"
      if sprite.image then
        dr.image = tcopy(sprite.image)
      else
        dr.pic = tcopy(sprite.image)
      end
      dr.offp = sprite.offp
      dr.cid = comp.cid
      table.insert(model.drawables, dr)
    end

    -- keep track of which cids are in existence
    table.insert(sawCids, comp.cid)
  end

  -- For any drawables with a cid, but which cid is no longer in comps, drop them.
  local keeps=model.drawables
  -- local keeps={}
  -- for i=1,#model.drawables do
  --   if (not model.drawables[i].cid) or lfind(sawCids, function(id) return id  == model.drawables[i].cid end) then
  --     table.insert(keeps,model.drawables[i])
  --   end
  -- end

  -- topo-sort the drawable blocks:
  model.drawables = Iso.sortBlocks(keeps)
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
      if model.mouse.pan then
        model.view.x = model.view.x + action.dx
        model.view.y = model.view.y + action.dy
      elseif model.mouse.move then
        local comp = model.comp
        comp.pos.x = comp.pos.x + Iso.imgWidthToWorldWidth(action.dx)
        comp.pos.y = comp.pos.y - Iso.imgWidthToWorldWidth(action.dy)
        updateDrawables(model)
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

local tinput = {text="stuff"}
local function updateGui(model,action)
  local e = model.editor
  local comp = model.comp
  local spr = sprites[comp.spriteId]
  -- if suit.Button("Hello, World!", e.x,e.y, 200,30).hit then
  --   print("clicked!")
  -- end
  suit.layout:reset(e.x,e.y, 5,5) -- x,y and padding

  suit.Label(comp.spriteId, suit.layout:row(200,30))
  local posW = Widgets.Vector3(suit,"Pos", comp.pos, e.scratch.pos)
  local spriteW = Widgets.Sprite(suit,"Sprite",spr,e.scratch.sprite)
  if posW.changed or spriteW.changed then
    updateDrawables(model)
  end

  -- suit.Label("dude:", suit.layout:col())
  -- suit.Label("wat:", suit.layout:col())
  -- state = suit.Button("Click?", suit.layout:row())
  -- if state.hit then
  --   print("Ouch!")
  -- end
  --
  -- if suit.Input(tinput, suit.layout:row()).submitted then
  --     print(tinput.text)
  -- end


-- if the button was pressed at least one time, but a label below
  -- if show_message then
  --   suit.Label("How are you today?", 100,150, 300,30)
  -- end
  --
  -- suit.Slider(slider, 100,200, 200,20)
  -- suit.Label(input.text.." - "..tostring(slider.value), {align="left"},300,200, 200,20)
  --
  -- suit.Input(input, 100,300,200,30)
  -- suit.Label("Hello, "..input.text, {align="left"}, 100,350,200,30)

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
  local sloc = Iso.offsetPos(block)
  local slx,sly = Iso.spaceToScreen_(block.pos.x-sloc.x, block.pos.y-sloc.y, block.pos.z-sloc.z)
  love.graphics.points(slx,sly)

  love.graphics.setColor(255,255,255)
end



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
  model.images = {}
  model.images[BlenderCube96] = love.graphics.newImage(BlenderCube96)
  model.images[Maya] = love.graphics.newImage(Maya)
  model.images[Freya] = love.graphics.newImage(Freya)
  -- addSprite(model)

  local comp = {
    cid="c1",
    -- spriteId="maya1",
    spriteId="freya1",
    pos = {x=0.5,y=0.5,z=0}
  }
  -- local comp2 = {
  --   cid="c2",
  --   spriteId="maya1",
  --   pos = {x=-0.3,y=0.3,z=0}
  -- }
  -- model.comps = {comp,comp2}

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

  updateDrawables(model)
  return model
end

local function drawPropEditor(model)

  suit.draw()
  -- love.graphics.print("Dude")

end

local function updateWorld(model,action)
  if action.type == "tick" then
    updateGui(model,action)
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

  for i=1,#model.drawables do
    local dr = model.drawables[i]
    if dr.type == "spriteBox" then
      if model.flags.drawSprites then
        drawSprite(model.images, dr)
      end
      if model.flags.drawSpriteGeom then
        drawSpriteDebug(model.images, dr)
      end
    end
  end

  love.graphics.pop()

  drawPropEditor(model)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
