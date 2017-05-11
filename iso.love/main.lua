require 'helpers'

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

local function transCopy(p, tr)
  return {p[1]+tr[1], p[2]+tr[2], p[3]+tr[3]}
end

local function projOrthoTop(p)
  return {p[1],p[2]}
end

local function projIso(p)
  return {
    p[1] + p[2],
    p[2] - ((p[1]+p[2])/2) - (1.25*p[3]),
  }
end
local function projIso_(p)
  return
    p[1] + p[2],
    p[2] - ((p[1]+p[2])/2) - (1.25*p[3])
end

-- local proj = projOrthoTop
local proj = projIso

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
    rp4[1],rp4[2]
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


local function isoSort2(a,b)
  return (a.pos[1] + a.pos[2] + a.pos[3]) > (b.pos[1] + b.pos[2] + b.pos[3])
end

local function isoSort3(a,b)
  ax,ay=projIso_(a.pos)
  bx,by=projIso_(b.pos)
  return ay < by
end

local function isoSort(a,b)
  -- if a.pos[1] == b.pos[1] then
  --   if a.pos[2] == b.pos[2] then
  --     return a.pos[3] > b.pos[3]
  --   end
  --   return a.pos[2] < b.pos[2]
  -- end
  -- return a.pos[1] < b.pos[1]

  -- if a.pos[3] == b.pos[3] then
  --   if a.pos[2] == b.pos[2] then
  --     return a.pos[1] < b.pos[1]
  --   end
  --   return a.pos[2] > b.pos[2]
  -- end
  -- return a.pos[3] > b.pos[3]
  if a.pos[3] ~= b.pos[3] then
    return a.pos[3] < b.pos[3]
  else
    ax,ay=projIso_(a.pos)
    bx,by=projIso_(b.pos)
    return ay < by
  end
end

local concrete003 = "images/concrete003.png"
local blender_cube = "images/blender_cube.png"

local model = {}
function love.load()
  local s = 32--.5-1
  model.boxes = {
    newBox({s,0,0},{s,s,s},Colors.Red),
    newBox({s,s,0},{s,s,s},Colors.Blue),
    newBox({0,0,0},{s,s,s},Colors.White),
    newBox({0,s,0},{s,s,s},Colors.Green),
    newBox({s,s,s},{s,s,s},Colors.Purple),
    -- newBox({0,0,s},{s,s,s},Colors.Yellow),
  }

  table.sort(model.boxes, isoSort)

  model.images = {}
  model.images[concrete003] = love.graphics.newImage(concrete003)
  model.images[blender_cube] = love.graphics.newImage(blender_cube)

  local img = model.images[blender_cube]
  print("image "..blender_cube..": w="..img:getWidth()..", "..img:getHeight())
end

function love.draw()
  love.graphics.translate(100,100)


  for i=1,#model.boxes do
    local blockPt = model.boxes[i].pos
    local blockXY = proj(blockPt)
    local imgx = blockXY[1]
    local imgy = blockXY[2] - (128 -(1.25*32/2))
    love.graphics.setColor(unpack(model.boxes[i].color))
    love.graphics.draw(
      model.images[blender_cube],
      imgx,imgy) --,
      -- 0,  -- r
      -- 1,1, -- sx, sy
      -- 0,0) -- offx offy
    -- love.graphics.setColor(255,0,0)
    -- love.graphics.rectangle("line", imgx, imgy, model.images[concrete003]:getWidth(), model.images[concrete003]:getHeight())
  end

  -- for i=1,#model.boxes do
  --   local box = model.boxes[i]
  --   drawWireframeBox( box)
  --   -- drawWireframeBoxOpaque(box)
  -- end

  -- love.graphics.setColor(255,0,0)
  -- love.graphics.line(0,0,32,0)
  -- love.graphics.line(0,0,0,-32)

end
