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
    pos=pos,
    dim=dim,
    color=color,
  }
end

local concrete003 = "images/concrete003.png"
local blender_cube = "images/blender_cube.png"
local maya = "images/maya.png"
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

function initModel()
  local model = {}
  -- model.boxes = makeSomeBoxes()
  model.boxes = generateCheckerboard(10,10,-5,-5,0, Colors.White, Colors.Blue)

  table.sort(model.boxes, Iso.sort)

  model.images = {}
  model.images[concrete003] = love.graphics.newImage(concrete003)
  model.images[blender_cube] = love.graphics.newImage(blender_cube)
  model.images[maya] = love.graphics.newImage(maya)

  model.dbg = {
    screen={offx=400, offy=400},
    mouse={},
    flags = {
      drawHeadsup = true,
      drawSolids = true,
      drawWireframes = false,
      drawWireframesOpaque = false,
    },
    cursor = newBox({0,0,0},Unit,Colors.White),
    mapScale = 1,
  }

  local img = model.images[blender_cube]
  -- print("image "..blender_cube..": w="..img:getWidth()..", "..img:getHeight())


  return model
end


local function toggleFlag(obj,flag)
  obj[flag] = not obj[flag]
end

function handleKeyPressed(model,key)
  if key == "1" then toggleFlag(model.dbg.flags, 'drawSolids') end
  if key == "2" then toggleFlag(model.dbg.flags, 'drawWireframes') end
  if key == "3" then toggleFlag(model.dbg.flags, 'drawWireframesOpaque') end
  if key == "h" then toggleFlag(model.dbg.flags, 'drawHeadsup') end

  if key == "w" then model.dbg.cursor.pos[1] = model.dbg.cursor.pos[1] + 1 end
  if key == "a" then model.dbg.cursor.pos[2] = model.dbg.cursor.pos[2] - 1 end
  if key == "s" then model.dbg.cursor.pos[1] = model.dbg.cursor.pos[1] - 1 end
  if key == "d" then model.dbg.cursor.pos[2] = model.dbg.cursor.pos[2] + 1 end
  if key == "z" then model.dbg.cursor.pos[3] = model.dbg.cursor.pos[3] - 1 end
  if key == "x" then model.dbg.cursor.pos[3] = model.dbg.cursor.pos[3] + 1 end

  if key == "-" then model.dbg.mapScale = model.dbg.mapScale - 0.5 end
  if key == "=" then model.dbg.mapScale = model.dbg.mapScale + 0.5 end
  if key == "0" then model.dbg.mapScale = 1 end

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
  love.graphics.print("Screen: "..model.dbg.screen.offx..","..model.dbg.screen.offy,0,0)
  local cp = model.dbg.cursor.pos
  love.graphics.print("Cursor: "..cp[1]..","..cp[2]..","..cp[3],0,10)

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
      tconcat(sidefx, handleKeyPressed(model, action.key))
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

local function drawMaya(model)
  local img = model.images[maya]
  -- print("maya "..img:getWidth().." "..img:getHeight())
  love.graphics.draw(
    img,
    100,100,                               -- location
    0,                                 -- rotation
    1,1,                               -- size
    0,0                                -- xoff,yoff
  )
end

local function drawWorld(model)
  local dbg = model.dbg

  drawMaya(model)

  love.graphics.push()
  love.graphics.translate(dbg.screen.offx, dbg.screen.offy)
  love.graphics.scale(model.dbg.mapScale,model.dbg.mapScale)

  if model.dbg.flags.drawSolids then
    local img = model.images[blender_cube]
    DebugDraw.drawSolids(model.boxes, img)
  end

  if model.dbg.flags.drawWireframes then
    DebugDraw.drawWireframes(model.boxes)
  end

  if model.dbg.flags.drawWireframesOpaque then
    DebugDraw.drawWireframesOpaque(model.boxes)
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
