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

local model = {}
function love.load()
  model.boxes = {
    newBox({1,0,0},{1,1,1},Colors.Red),
    newBox({1,1,0},{1,1,1},Colors.Blue),
    newBox({0,0,0},{1,1,1},Colors.White),
    newBox({0,1,0},{1,1,1},Colors.Green),
    newBox({1,1,1},{1,1,1},Colors.Purple),
    -- newBox({-0.5,-0.5,0},{1,1,1},Colors.Yellow),
  }

  table.sort(model.boxes, Iso.sort)

  model.images = {}
  model.images[concrete003] = love.graphics.newImage(concrete003)
  model.images[blender_cube] = love.graphics.newImage(blender_cube)

  model.flags = {
    drawWireframes = false,
    drawWireframesOpaque = false,
    drawSolids = true,
  }

  local img = model.images[blender_cube]
  -- print("image "..blender_cube..": w="..img:getWidth()..", "..img:getHeight())
end

function love.draw()
  love.graphics.translate(100,100)

  if model.flags.drawSolids then
    local img = model.images[blender_cube]
    DebugDraw.drawSolids(model.boxes, img)
  end

  if model.flags.drawWireframes then
    DebugDraw.drawWireframes(model.boxes)
  end

  if model.flags.drawWireframesOpaque then
    DebugDraw.drawWireframesOpaque(model.boxes)
  end

end
