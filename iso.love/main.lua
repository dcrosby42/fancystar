require 'helpers'

local Colors = {
  White = {255,255,255},
  Red = {255,100,100},
  Green = {100,255,100},
  Blue = {100,100,255},
  Purple = {100,0,255},
}

local function newBox(pos,dim,color)
  return {
    pos=pos,
    dim=dim,
    color=color,
  }
end

local function transCopy(p, tr)
  return {p[1]+tr[1], p[2]+tr[2], p[3]+tr[3]}
end

local function projOrthoTop(p)
  return {p[1],p[2]}
end

local function projIso(p)
  return {
    p[1] + p[2],
    p[2] - ((p[1]+p[2])/2) - p[3],
  }
end

-- local proj = projOrthoTop
local proj = projIso

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
end

local model = {}
function love.load()
  model.boxes = {
    newBox({0,0,0},{40,40,40},Colors.White),
    newBox({40,0,0},{40,40,40},Colors.Red),
    newBox({0,40,0},{40,40,40},Colors.Green),
    newBox({40,40,0},{40,40,40},Colors.Blue),
    newBox({40,40,40},{40,40,40},Colors.Purple),
  }
end

function love.draw()
  love.graphics.translate(100,100)
  for i=1,#model.boxes do
    local box = model.boxes[i]
    drawWireframeBox(box)
  end
end
