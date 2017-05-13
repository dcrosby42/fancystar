require 'helpers'

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

local model = {}
function love.load()
  -- model.boxes = makeSomeBoxes()
  model.boxes = generateCheckerboard(10,10,-5,-5,0, Colors.White, Colors.Blue)

  table.sort(model.boxes, Iso.sort)

  model.images = {}
  model.images[concrete003] = love.graphics.newImage(concrete003)
  model.images[blender_cube] = love.graphics.newImage(blender_cube)

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
  }

  local img = model.images[blender_cube]
  -- print("image "..blender_cube..": w="..img:getWidth()..", "..img:getHeight())

  love.window.setMode(1024,768)
end

local drawHeadsup
function love.draw()
  local dbg = model.dbg

  love.graphics.push()
  love.graphics.translate(dbg.screen.offx, dbg.screen.offy)

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

local function toggleFlag(obj,flag)
  obj[flag] = not obj[flag]
end

function love.keypressed(key, _scancode, _isrepeat)
  if key == "1" then toggleFlag(model.dbg.flags, 'drawSolids') end
  if key == "2" then toggleFlag(model.dbg.flags, 'drawWireframes') end
  if key == "3" then toggleFlag(model.dbg.flags, 'drawWireframesOpaque') end

  if key == "w" then model.dbg.cursor.pos[1] = model.dbg.cursor.pos[1] + 1 end
  if key == "a" then model.dbg.cursor.pos[2] = model.dbg.cursor.pos[2] - 1 end
  if key == "s" then model.dbg.cursor.pos[1] = model.dbg.cursor.pos[1] - 1 end
  if key == "d" then model.dbg.cursor.pos[2] = model.dbg.cursor.pos[2] + 1 end
  if key == "z" then model.dbg.cursor.pos[3] = model.dbg.cursor.pos[3] - 1 end
  if key == "x" then model.dbg.cursor.pos[3] = model.dbg.cursor.pos[3] + 1 end
end

function love.keyreleased(key, _scancode, _isrepeat)
end


function love.mousepressed(x,y, button, isTouch, dx, dy)
  model.dbg.mouse.down = true
end

function love.mousereleased(x,y, button, isTouch)
  model.dbg.mouse.down = false
end

function love.mousemoved(x,y, dx,dy, isTouch)
  if model.dbg.mouse.down then
    model.dbg.screen.offx = model.dbg.screen.offx + dx
    model.dbg.screen.offy = model.dbg.screen.offy + dy
  end
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
  love.graphics.pop()
end
