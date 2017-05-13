local D = {}

local Iso = require 'iso'

local transCopy = Iso.transCopy
local proj = Iso.proj

local function drawWireframeBoxOpaque(box)
  local p1 = transCopy(box.pos, {0,0,0})
  local p2 = transCopy(p1, {0, box.dim[2], 0})
  local p3 = transCopy(p2, {box.dim[1], 0, 0})
  local p4 = transCopy(p1, {box.dim[1], 0, 0})

  local p5 = transCopy(p1, {0,0,box.dim[3]})
  local p6 = transCopy(p5, {0, box.dim[2], 0})
  local p7 = transCopy(p6, {box.dim[1], 0, 0})
  local p8 = transCopy(p5, {box.dim[1], 0, 0})

  local rp1 = proj(p1)
  local rp2 = proj(p2)
  local rp3 = proj(p3)
  local rp4 = proj(p4)
  local rp5 = proj(p5)
  local rp6 = proj(p6)
  local rp7 = proj(p7)
  local rp8 = proj(p8)
  love.graphics.setColor(box.color)
  love.graphics.line(
    rp1[1],rp1[2],
    rp2[1],rp2[2],
    rp3[1],rp3[2],
    rp7[1],rp7[2],
    rp6[1],rp6[2],
    rp5[1],rp5[2],
    rp8[1],rp8[2],
    rp7[1],rp7[2]
  )
  love.graphics.line(
    rp1[1],rp1[2],
    rp5[1],rp5[2]
  )
  love.graphics.line(
    rp2[1],rp2[2],
    rp6[1],rp6[2]
  )
end
local function drawWireframeBox(box)
  local p1 = transCopy(box.pos, {0,0,0})
  local p2 = transCopy(p1, {0, box.dim[2], 0})
  local p3 = transCopy(p2, {box.dim[1], 0, 0})
  local p4 = transCopy(p1, {box.dim[1], 0, 0})

  local p5 = transCopy(p1, {0,0,box.dim[3]})
  local p6 = transCopy(p5, {0, box.dim[2], 0})
  local p7 = transCopy(p6, {box.dim[1], 0, 0})
  local p8 = transCopy(p5, {box.dim[1], 0, 0})

  local rp1 = proj(p1)
  local rp2 = proj(p2)
  local rp3 = proj(p3)
  local rp4 = proj(p4)
  local rp5 = proj(p5)
  local rp6 = proj(p6)
  local rp7 = proj(p7)
  local rp8 = proj(p8)
  love.graphics.setColor(box.color)
  love.graphics.line(
    rp1[1],rp1[2],
    rp2[1],rp2[2],
    rp3[1],rp3[2],
    rp4[1],rp4[2],
    rp1[1],rp1[2],
    rp5[1],rp5[2],
    rp6[1],rp6[2],
    rp7[1],rp7[2],
    rp8[1],rp8[2],
    rp5[1],rp5[2]
  )
  love.graphics.line(
    rp2[1],rp2[2],
    rp6[1],rp6[2]
  )
  love.graphics.line(
    rp3[1],rp3[2],
    rp7[1],rp7[2]
  )
  love.graphics.line(
    rp3[1],rp3[2],
    rp7[1],rp7[2]
  )
  love.graphics.line(
    rp4[1],rp4[2],
    rp8[1],rp8[2]
  )
end

D.drawSolids = function(boxes,img)
  for i=1,#boxes do
    local blockPt = boxes[i].pos
    local screenPt = proj(blockPt)

    love.graphics.setColor(unpack(boxes[i].color))
    love.graphics.draw(
      img,
      screenPt[1], screenPt[2],          -- location
      0,                                 -- rotation
      1,1,                               -- size
      0,img:getHeight()-Iso.TILE_HEIGHT_HALF -- x,y offsets
    )
  end
end

D.drawWireframes = function(boxes)
  for i=1,#boxes do
    local box = boxes[i]
    drawWireframeBox(box)
  end
end

D.drawWireframesOpaque = function(boxes)
  for i=1,#boxes do
    local box = boxes[i]
    drawWireframeBoxOpaque(box)
  end
end

return D
