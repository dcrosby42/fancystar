DebugDraw = require 'debugdraw'
Iso = require 'iso'

local Colors = {
  White = {255,255,255},
  Red = {255,100,100},
  Green = {100,255,100},
  Blue = {100,100,255},
  Purple = {100,0,255},
  Yellow = {255,255,100},
}

local function newBox(pos,dim,color)
  return {
    type='box',
    pos=pos,
    dim=dim,
    color=color,
  }
end

local concrete003 = "images/concrete003.png"
-- local blender_cube = "images/blender_cube.png"
-- local blender_cube = "images/blender_cube2.png"
local blender_cube = "images/blender_cube_96.png"
local mayaimg = "images/maya_trans.png"
-- local blender_cube = "images/blender_cube_copy.png"

local Unit = {1,1,1}

function generateCheckerboard(xsize,ysize, startx, starty, z, acolor, bcolor)
  local boxes = {}
  for x=startx, startx+xsize do
    for y=starty, starty+ysize do
      local color = acolor
      if (x + y) % 2 == 0 then
        color = bcolor
      end
      boxes[#boxes+1] = newBox({x,y,z}, Unit, color)
    end
  end
  return boxes
end

function generateCheckerboardSprites(model, xsize,ysize, startx, starty, z, acolor, bcolor)
  local sprites = {}
  local cubeimg = model.images[blender_cube]
  local iw = cubeimg:getWidth()
  local ih = cubeimg:getHeight()
  -- local bw = Iso.imgWidthToWorldWidth(iw)
  -- local bl = Iso.imgWidthToWorldWidth(iw)
  -- local bh = Iso.imgHeightToWorldHeight(ih)
  local imgoffx=0
  local imgoffy=0
  for x=startx, startx+xsize do
    for y=starty, starty+ysize do
      local color = acolor
      if (x + y) % 2 == 0 then
        color = bcolor
      end
      sprites[#sprites+1] = {
        type="sprite",
        color=color,
        img = { name = blender_cube },
        pos = {x,y,z},
        bounds = newBox({0,0,0}, Unit, Colors.White),
        imgbounds={
          offx = 0,
          offy = ih-Iso.TILE_HEIGHT_HALF,
          w = iw,
          h = ih
        },
      }
    end
  end
  return sprites
end

function makeSomeBoxes()
  local boxes = {
    newBox({1,0,0},Unit,Colors.Red),
    newBox({1,1,0},Unit,Colors.Blue),
    newBox({0,0,0},Unit,Colors.White),
    newBox({0,1,0},Unit,Colors.Green),
    newBox({1,1,1},Unit,Colors.Purple),
    -- newBox({-0.5,-0.5,0},{1,1,1},Colors.Yellow),
  }

  return boxes
end

function sortDrawables(model)
  table.sort(model.drawables, Iso.sort)
end

local function buildMap1(model)
  local boxtiles={}
  tconcat(boxtiles, generateCheckerboard(10,10,-5,-5,0, Colors.Blue, Colors.White)) -- floor
  tconcat(boxtiles, generateCheckerboard(5,0, -2,3,1, Colors.Red, Colors.Yellow)) -- near wall
  tconcat(boxtiles, generateCheckerboard(5,0, -2,-3,1, Colors.Red, Colors.Yellow)) -- far wall
  tconcat(boxtiles, generateCheckerboard(5,0, -2,-3,2, Colors.Yellow, Colors.Red))
  tconcat(boxtiles, generateCheckerboard(0,2, -3,-3,1, Colors.Red, Colors.Yellow))
  tconcat(boxtiles, generateCheckerboard(0,1, -3,2,1, Colors.Red, Colors.Yellow))
  -- door arch
  tconcat(boxtiles, generateCheckerboard(0,0, -3,-1,2, Colors.Purple, Colors.Green))
  tconcat(boxtiles, generateCheckerboard(0,3, -3,-1,3, Colors.Green, Colors.Purple))
  tconcat(boxtiles, generateCheckerboard(0,0, -3,2,2, Colors.Purple, Colors.Green))
  return boxtiles
end
local function buildMap2(model)
  local sprites={}
  tconcat(sprites, generateCheckerboardSprites(model,5,5,-2,-2,0, Colors.Blue, Colors.White)) -- floor
  tconcat(sprites, generateCheckerboardSprites(model,3,0, -2,2,1, Colors.Red, Colors.Yellow)) -- near wall
  tconcat(sprites, generateCheckerboardSprites(model,3,0, -2,-1,2, Colors.Yellow, Colors.Red))
  tconcat(sprites, generateCheckerboardSprites(model,3,0, -2,-1,1, Colors.Red, Colors.Yellow)) -- far wall

  -- tconcat(sprites, generateCheckerboardSprites(model,0,0, -3,-1,2, Colors.Purple, Colors.Green))
  -- tconcat(sprites, generateCheckerboardSprites(model,0,3, -3,-1,3, Colors.Green, Colors.Purple))
  -- tconcat(sprites, generateCheckerboardSprites(model,0,0, -3,2,2, Colors.Purple, Colors.Green))
  return sprites
end

function initModel()
  local model = {}
  -- model.boxes = makeSomeBoxes()
  model.boxes = {}

  model.images = {}
  model.images[concrete003] = love.graphics.newImage(concrete003)
  model.images[blender_cube] = love.graphics.newImage(blender_cube)
  model.images[mayaimg] = love.graphics.newImage(mayaimg)

  local boxtiles = buildMap1(model)
  -- local boxtiles = buildMap2(model)

  -- Make the maya sprite:
  local mimg = model.images[mayaimg]
  local iw = mimg:getWidth()
  local ih = mimg:getHeight()
  local bw = Iso.imgWidthToWorldWidth(iw-12)
  local bl = Iso.imgWidthToWorldWidth(iw-12)
  local bh = Iso.imgHeightToWorldHeight(ih-10)
  local imgoffx=-4
  local imgoffy=6
  model.maya = {
    type='sprite',
    img = { name = mayaimg},
    pos = {0.5, 0.5, 1},  -- world coords
    bounds = newBox({bw/2,bl/2,0}, {bw,bl,bh}, Colors.Green), -- world coords
    imgbounds={
      offx = (iw / 2)-imgoffx,
      offy = ih-imgoffy,
      w = iw,
      h = ih
    },
  }
  local sprites = { model.maya }

  model.drawables = lcopy(boxtiles)
  tconcat(model.drawables,sprites)

  sortDrawables(model)


  model.dbg = {
    screen={offx=450, offy=400},
    mouse={},
    flags = {
      drawHeadsup = true,
      drawSolids = true,
      drawWireframes = false,
      drawWireframesOpaque = false,
      drawImageBounds = false,
      drawBounds = false,
    },
    cursor = newBox({0,0,0},Unit,Colors.White),
    mapScale = 1,
    drawableLimit = -1,
  }


  -- local img = model.images[blender_cube]
  -- print("image "..blender_cube..": w="..img:getWidth()..", "..img:getHeight())


  return model
end


local function toggleFlag(obj,flag)
  obj[flag] = not obj[flag]
end

function handleKeyPressed(model,action)
  local key = action.key
  if key == "1" then toggleFlag(model.dbg.flags, 'drawSolids') end
  if key == "2" then toggleFlag(model.dbg.flags, 'drawWireframes') end
  if key == "3" then toggleFlag(model.dbg.flags, 'drawWireframesOpaque') end
  if key == "h" then toggleFlag(model.dbg.flags, 'drawHeadsup') end
  if key == "b" then toggleFlag(model.dbg.flags, 'drawBounds') end
  if key == "i" then toggleFlag(model.dbg.flags, 'drawImageBounds') end

  if key == "w" then model.dbg.cursor.pos[1] = model.dbg.cursor.pos[1] + 1 end
  if key == "a" then model.dbg.cursor.pos[2] = model.dbg.cursor.pos[2] - 1 end
  if key == "s" then model.dbg.cursor.pos[1] = model.dbg.cursor.pos[1] - 1 end
  if key == "d" then model.dbg.cursor.pos[2] = model.dbg.cursor.pos[2] + 1 end
  if key == "z" then model.dbg.cursor.pos[3] = model.dbg.cursor.pos[3] - 1 end
  if key == "x" then model.dbg.cursor.pos[3] = model.dbg.cursor.pos[3] + 1 end

  if key == "up" then
    if action.shift then
      model.maya.pos[3] = model.maya.pos[3] + 0.25
    else
      model.maya.pos[1] = model.maya.pos[1] + 0.25
    end
    sortDrawables(model)
  end
  if key == "down" then
    if action.shift then
      model.maya.pos[3] = model.maya.pos[3] - 0.25
    else
      model.maya.pos[1] = model.maya.pos[1] - 0.25
    end
    sortDrawables(model)
   end
  if key == "left" then model.maya.pos[2] = model.maya.pos[2] - 0.25; sortDrawables(model) end
  -- if key == "down" then model.maya.pos[1] = model.maya.pos[1] - 0.25; sortDrawables(model) end
  if key == "right" then model.maya.pos[2] = model.maya.pos[2] + 0.25; sortDrawables(model) end

  if key == "-" then model.dbg.mapScale = model.dbg.mapScale - 0.5 end
  if key == "=" then model.dbg.mapScale = model.dbg.mapScale + 0.5 end
  if key == "0" then model.dbg.mapScale = 1 end

  if key == "[" then
    model.dbg.drawableLimit = model.dbg.drawableLimit - 1
    if model.dbg.drawableLimit < 0 then
      model.dbg.drawableLimit = #model.drawables
    end
  elseif key == "]" then
    model.dbg.drawableLimit = model.dbg.drawableLimit + 1
    if model.dbg.drawableLimit > #model.drawables then
      model.dbg.drawableLimit = 0
    end
  end

  if key == "r" then
    return {
      {type="crozeng.reloadRootModule"}
    }
  end
  return {}
end



function drawHeadsup(model)
  local sh = love.graphics.getHeight()
  local sw = love.graphics.getWidth()
  local hh = 50

  love.graphics.push()

  love.graphics.translate(0,sh-hh)
  love.graphics.setColor(255,255,255)
  love.graphics.rectangle("fill",0,0, sw,hh)


  love.graphics.setColor(0,0,0)
  local liney = 0
  love.graphics.print("Screen: "..model.dbg.screen.offx..","..model.dbg.screen.offy,0,liney)
  liney = liney + 12
  local cp = model.dbg.cursor.pos
  love.graphics.print("Cursor: "..cp[1]..","..cp[2]..","..cp[3],0,liney)
  liney = liney + 12
  love.graphics.print("Map Scale: "..model.dbg.mapScale,0,liney)
  liney = liney + 12
  local mpos = model.maya.pos
  local mbounds = model.maya.imgbounds
  love.graphics.print("Maya pos: ("..mpos[1]..", "..mpos[2]..", "..mpos[3]..") bounds: ("..mbounds.w..", "..mbounds.h..", "..mbounds.offx..", "..mbounds.offy..")",0,liney)
  liney = liney + 12

  love.graphics.setColor(255,255,255)
  love.graphics.pop()
end

local function newWorld(opts)
  return initModel()
end

local function updateWorld(model,action)
  local sidefx = {}
  if action.type == 'keyboard' then
    if action.state == 'pressed' then
      tconcat(sidefx, handleKeyPressed(model, action))
    end

  elseif action.type == 'mouse' then
    if action.state == 'moved' then
      if model.dbg.mouse.down then
        model.dbg.screen.offx = model.dbg.screen.offx + action.dx
        model.dbg.screen.offy = model.dbg.screen.offy + action.dy
      end
    elseif action.state == 'pressed' then
      model.dbg.mouse.down = true
    elseif action.state == 'released' then
      model.dbg.mouse.down = false
    end
  elseif action.type == "resize" then
    print("devui: screen resize "..tflatten(action))
  end
  return model, sidefx
end

-- Sprite:
local function drawSprite(sprite, model,i)
  local img = model.images[sprite.img.name]
  -- print("sprite "..img:getWidth().." "..img:getHeight())
  local screenPt = Iso.proj(sprite.pos)
  if sprite.color then
    love.graphics.setColor(unpack(sprite.color))
  else
    love.graphics.setColor(255,255,255)
  end
  love.graphics.draw(
    img,
    screenPt[1],screenPt[2],
    0,                                 -- rotation
    1,1,                               -- scalex,scaley
    sprite.imgbounds.offx,sprite.imgbounds.offy                                -- xoff,yoff
  )
  if model.dbg.flags.drawImageBounds then
    love.graphics.setColor(0,0,255)
    love.graphics.rectangle("line", screenPt[1] - sprite.imgbounds.offx, screenPt[2] - sprite.imgbounds.offy, sprite.imgbounds.w, sprite.imgbounds.h)
    love.graphics.setColor(255,255,255)
  end
  if model.dbg.flags.drawBounds then
    local box = newBox({
      sprite.pos[1] - sprite.bounds.pos[1],
      sprite.pos[2] - sprite.bounds.pos[2],
      sprite.pos[3] - sprite.bounds.pos[3],
    }, sprite.bounds.dim, sprite.bounds.color)
    DebugDraw.drawWireframesOpaque({box})
    love.graphics.setColor(unpack(box.color))
    love.graphics.setPointSize(3)
    love.graphics.points(screenPt[1],screenPt[2])
    love.graphics.setPointSize(1)
    local nx = screenPt[1]
    local ny = screenPt[2] - sprite.bounds.dim[3]*Iso.TILE_Z
    love.graphics.print(tostring(i),nx,ny)
    love.graphics.setColor(255,255,255)
  end
end

local function drawThing(thing, model,i)
  if thing.type == 'box' then
    local img = model.images[blender_cube]
    DebugDraw.drawBoxTile(thing, img,i)

  elseif thing.type == 'sprite' then
    drawSprite(thing, model,i)
  end
end

local function drawWorld(model)
  local dbg = model.dbg


  love.graphics.push()
  love.graphics.translate(dbg.screen.offx, dbg.screen.offy)
  love.graphics.scale(model.dbg.mapScale,model.dbg.mapScale)

  -- if model.dbg.flags.drawSolids then
  --   local img = model.images[blender_cube]
  --   DebugDraw.drawSolids(model.boxes, img)
  -- end
  --
  -- if model.dbg.flags.drawWireframes then
  --   DebugDraw.drawWireframes(model.boxes)
  -- end
  --
  -- if model.dbg.flags.drawWireframesOpaque then
  --   DebugDraw.drawWireframesOpaque(model.boxes)
  -- end
  --
  -- drawSprite(model.maya, model)
  local max = #model.drawables
  if model.dbg.drawableLimit >= 0 then
    max = model.dbg.drawableLimit
  end
  for i=1,max do
    drawThing(model.drawables[i], model, i)
  end

  DebugDraw.drawWireframesOpaque({model.dbg.cursor})

  love.graphics.pop()


  if model.dbg.flags.drawHeadsup then
    drawHeadsup(model)
  end
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
  getStructure=function() return {} end,
}
