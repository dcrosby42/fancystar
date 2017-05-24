local Colors = require 'colors'
-- local IsoBlock = require 'isoblock'

local function newBlock(pos,size,color,name)
  return {
    type="block",
    pos=pos,
    size=size,
    color=color,
    name=name,
    sil={x={0,0},y={0,0},h={0,0}},
  }
end

local function newWorld()
  -- local blocks = {
  --   newBlock({x=2,y=2,z=0},{x=1,y=1,z=1.5}, Colors.Red, "red"),
  --   newBlock({x=3,y=1,z=0},{x=1,y=4,z=1},   Colors.Blue, "blue"),
  --   newBlock({x=1,y=3,z=0},{x=2,y=2,z=2.5}, Colors.Green, "green"),
  --   newBlock({x=5,y=0,z=0},{x=1,y=1,z=1}, Colors.Yellow, "yellow"),
  -- }
  local blocks = {
    newBlock({x=1,y=1,z=0},{x=1,y=2,z=0.3}, Colors.Blue, "Blue"),
    newBlock({x=2,y=2,z=0},{x=1,y=2,z=1.25}, Colors.Red, "Red"),
    newBlock({x=4,y=0,z=0},{x=1,y=1,z=1}, Colors.Yellow, "Yellow"),
  }
  -- printBlocks(blocks)

  -- blocks = IsoBlock.sortBlocks(blocks)
  -- IsoBlock.printBlocks(blocks)

  local model ={
    viewoff={x=400,y=300},
    blocks = blocks,
    blockIndex = lcopy(blocks),
    selectedBlock = 1,
  }
  -- printBlocks(model.blockIndex)
  return model

end

local WASD_INC = 0.25
local function wasd(dir,model,action)
  local block = model.blockIndex[model.selectedBlock]
  if dir == "up" then
    if action.ctrl then
      block.size.y = block.size.y + WASD_INC
    else
      block.pos.y = block.pos.y + WASD_INC
    end
  elseif dir == "down" then
    if action.ctrl then
      block.size.y = block.size.y - WASD_INC
    else
      block.pos.y = block.pos.y - WASD_INC
    end
  elseif dir == "left" then
    if action.ctrl then
      block.size.x = block.size.x - WASD_INC
    else
      block.pos.x = block.pos.x - WASD_INC
    end
  elseif dir == "right" then
    if action.ctrl then
      block.size.x = block.size.x + WASD_INC
    else
      block.pos.x = block.pos.x + WASD_INC
    end
  elseif dir == "float" then
    if action.ctrl then
      block.size.z = block.size.z + WASD_INC
    else
      block.pos.z = block.pos.z + WASD_INC
    end
  elseif dir == "sink" then
    if action.ctrl then
      block.size.z = block.size.z - WASD_INC
    else
      block.pos.z = block.pos.z - WASD_INC
    end
  end
  -- print("wasd "..block.name.." "..block.pos.x..","..block.pos.y..","..block.pos.z)
  -- model.blocks = IsoBlock.sortBlocks(model.blocks)
end

local function updateWorld(model,action)
  if action.type == "keyboard" and action.state == "pressed" then

    if action.key == 'w' then wasd('up',model,action)
    elseif action.key == 's' then wasd('down',model,action)
    elseif action.key == 'a' then wasd('left',model,action)
    elseif action.key == 'd' then wasd('right',model,action)
    elseif action.key == 'z' then wasd('sink',model,action)
    elseif action.key == 'x' then wasd('float',model,action)

    elseif action.key == 'r' then
      return model, {{type="crozeng.reloadRootModule"}}
    elseif action.key == 'space' then
      model.selectedBlock = model.selectedBlock + 1
      if model.selectedBlock > #model.blockIndex then
        model.selectedBlock = 1
      end
    end
  end
  return model, nil
end


local TW = 96
local HALF_TW = TW / 2
local HALF_TH = TW / 4
local MAGIC_Z_NUMBER = 0.88388
local WORLD_SIDE = math.pow(math.pow(TW,2) / 2, 0.5) -- how long in pixels, pre-projection, the tile side would be to create a hypotenuse of TILE_WIDTH
local TILE_Z = WORLD_SIDE * MAGIC_Z_NUMBER
local Z_FACTOR = 1.41421 * MAGIC_Z_NUMBER
print("Z_FACTOR: "..Z_FACTOR)

local function isoProj(vx,vy,vz)
  return ((vx-vy) * HALF_TW), -(vx+vy) * HALF_TH - (vz * TILE_Z)
end

local function isoProjPt(vx,vy,vz)
  local x,y = isoProj(vx,vy,vz)
  return {x,y}
end

local function drawTileOutline(vx,vy,vz)
  local x,y = isoProj(vx,vy,vz)
  love.graphics.line(
    x,         y,
    x+HALF_TW, y-HALF_TH,
    x,         y-HALF_TW,
    x-HALF_TW, y-HALF_TH,
    x,         y)
end

local function drawFloorGrid()
  local z = 0
  for x=0,5 do
    for y = 0,5 do
      drawTileOutline(x,y,z)
    end
  end
end

local function drawBlock(block)
  local pos = block.pos
  local size = block.size
  local faces = {
    { -- left
      isoProjPt(pos.x,pos.y,pos.z),
      isoProjPt(pos.x,pos.y+size.y,pos.z),
      isoProjPt(pos.x,pos.y+size.y,pos.z+size.z),
      isoProjPt(pos.x,pos.y,pos.z+size.z),
    },
    { -- right
      isoProjPt(pos.x,pos.y,pos.z),
      isoProjPt(pos.x,pos.y,pos.z+size.z),
      isoProjPt(pos.x+size.x,pos.y,pos.z+size.z),
      isoProjPt(pos.x+size.x,pos.y,pos.z),
    },
    { --top
      isoProjPt(pos.x,pos.y,pos.z+size.z),
      isoProjPt(pos.x,pos.y+size.y,pos.z+size.z),
      isoProjPt(pos.x+size.x,pos.y+size.y,pos.z+size.z),
      isoProjPt(pos.x+size.x,pos.y,pos.z+size.z),
    }
  }
  local r,g,b,a = unpack(block.color)
  love.graphics.setColor(r,g,b,200)
  for i=1,#faces do
    love.graphics.polygon("fill",faces[i][1][1],faces[i][1][2],faces[i][2][1],faces[i][2][2],faces[i][3][1],faces[i][3][2],faces[i][4][1],faces[i][4][2])
  end
  love.graphics.setColor(r,g,b,255)
  for i=1,#faces do
    love.graphics.polygon("line",faces[i][1][1],faces[i][1][2],faces[i][2][1],faces[i][2][2],faces[i][3][1],faces[i][3][2],faces[i][4][1],faces[i][4][2])
  end
  love.graphics.setColor(unpack(Colors.White))
end

local function updateBlockSil(block)
  block.sil.xmin = block.pos.x + (Z_FACTOR * block.pos.z)
  block.sil.xmax = block.pos.x + block.size.x + (Z_FACTOR * (block.pos.z + block.size.z))

  block.sil.ymin = block.pos.y + (Z_FACTOR * block.pos.z)
  block.sil.ymax = block.pos.y + block.size.y + (Z_FACTOR * (block.pos.z + block.size.z))

  block.sil.hmin = block.pos.x - block.pos.y - block.size.y
  block.sil.hmax = block.pos.x - block.pos.y + block.size.x

  block.sil.vmin = block.pos.x + block.pos.y + (2*Z_FACTOR * block.pos.z) -- why 2*Z_FACTOR ??
  block.sil.vmax = block.pos.x + block.size.x + block.pos.y + block.size.y + (2*Z_FACTOR * (block.pos.z + block.size.z)) -- why 2*Z_FACTOR??
end

local function drawBlockSil(block)
  love.graphics.setColor(unpack(block.color))
  love.graphics.setPointSize(4)
  love.graphics.setLineWidth(3)

  love.graphics.line(block.sil.xmin * HALF_TW, -block.sil.xmin * HALF_TH,
                     block.sil.xmax * HALF_TW, -block.sil.xmax * HALF_TH)

  love.graphics.line(-block.sil.ymin * HALF_TW, -block.sil.ymin * HALF_TH,
                     -block.sil.ymax * HALF_TW, -block.sil.ymax * HALF_TH)

  love.graphics.line(block.sil.hmin * HALF_TW, 50,
                     block.sil.hmax * HALF_TW, 50)

  love.graphics.line(250, -block.sil.vmin * HALF_TH,
                     250, -block.sil.vmax * HALF_TH)

  love.graphics.setLineWidth(1)
  love.graphics.setColor(255,255,255)
end

local function areRangesDisjoint(amin,amax,bmin,bmax)
  return (amax <= bmin or bmax <= amin)
end

local function blocksOverlap(a,b)
  return not(
       areRangesDisjoint(a.sil.hmin,a.sil.hmax, b.sil.hmin,b.sil.hmax)
    or areRangesDisjoint(a.sil.xmin,a.sil.xmax, b.sil.xmin,b.sil.xmax)
    or areRangesDisjoint(a.sil.ymin,a.sil.ymax, b.sil.ymin,b.sil.ymax)
  )
end

local function drawWorld(model)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.push()
  love.graphics.translate(model.viewoff.x,model.viewoff.y)

  drawFloorGrid()

  for i=1,#model.blocks do
    drawBlock(model.blocks[i])
    updateBlockSil(model.blocks[i])
    drawBlockSil(model.blocks[i])
  end

  local pry = 75
  for i=1,#model.blocks do
    local a = model.blocks[i]
    for j=i+1,#model.blocks do
      local b = model.blocks[j]
      if blocksOverlap(a,b) then
        love.graphics.print(a.name.." overlaps "..b.name,0,pry)
        pry = pry + 15
      end
    end
  end

  love.graphics.pop()

  love.graphics.print("selected: "..model.blockIndex[model.selectedBlock].name)



end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
