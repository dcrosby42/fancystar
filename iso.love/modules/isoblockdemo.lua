local Colors = require 'colors'
local IsoBlock = require 'isoblock'
local function newBlock(pos,size,color,name)
  return {
    type="block",
    pos=pos,
    size=size,
    color=color,
    name=name
  }
end
local function printBlocks(blocks)
  print("Blocks:")
  for i=1,#blocks do
    print("  "..i..": "..blocks[i].name)
  end
end

local function newWorld()
  -- local blocks={
  --   newBlock({x=3,y=2,z=0},{x=2,y=2,z=2},Colors.Blue),
  --   newBlock({x=2,y=4,z=0},{x=2.3,y=2,z=1},Colors.Green),
  -- }
  local blocks = {
    newBlock({x=2,y=2,z=0},{x=1,y=1,z=1.5}, Colors.Red, "red"),
    newBlock({x=3,y=1,z=0},{x=1,y=4,z=1},   Colors.Blue, "blue"),
    newBlock({x=1,y=3,z=0},{x=2,y=2,z=2.5}, Colors.Green, "green"),
  }
  printBlocks(blocks)

  blocks = IsoBlock.sortBlocks(blocks)
  printBlocks(blocks)
  local model ={
    viewoff={x=400,y=300},
    blocks = blocks,
    blockIndex = lcopy(blocks),
    selectedBlock = 1,
  }
  printBlocks(model.blockIndex)
  return model

end

local function wasd(dir,model,action)
  local block = model.blockIndex[model.selectedBlock]
  if dir == "up" then
    if action.shift then
      block.pos.z = block.pos.z + 1
    else
      block.pos.y = block.pos.y + 1
    end
  elseif dir == "down" then
    if action.shift then
      block.pos.z = block.pos.z - 1
    else
      block.pos.y = block.pos.y - 1
    end
  elseif dir == "left" then
    block.pos.x = block.pos.x - 1
  elseif dir == "right" then
    block.pos.x = block.pos.x + 1
  end
  print("wasd "..block.name.." "..block.pos.x..","..block.pos.y..","..block.pos.z)
  model.blocks = IsoBlock.sortBlocks(model.blocks)
end

local function updateWorld(model,action)
  if action.type == "keyboard" and action.state == "pressed" then

    if action.key == 'w' then wasd('up',model,action)
    elseif action.key == 's' then wasd('down',model,action)
    elseif action.key == 'a' then wasd('left',model,action)
    elseif action.key == 'd' then wasd('right',model,action)

    elseif action.key == 'r' then
      return model, {{type="crozeng.reloadRootModule"}}
    elseif action.key == 'space' then
      model.selectedBlock = model.selectedBlock + 1
      if model.selectedBlock > #model.blockIndex then
        model.selectedBlock = 0
      end
    end

  elseif action.type == "crozeng.reloadError" then
    model.reloadError = "DANG"
  elseif action.type == "crozeng.reloadOk" then
    model.reloadError = nil
  end
  return model, nil
end


local S = 64
local HS = 32
local QS = 16
local MAGIC_Z_NUMBER = 0.88388
-- local TILE_WIDTH = 96
-- local PER_TILE_WIDTH = 1 / 96
-- local TILE_WIDTH_HALF = TILE_WIDTH / 2
-- local TILE_HEIGHT = TILE_WIDTH_HALF
-- local TILE_HEIGHT_HALF = TILE_HEIGHT / 2
local TILE_SIDE_3DP = math.pow(math.pow(S,2) / 2, 0.5) -- how long in pixels, pre-projection, the tile side would be to create a hypotenuse of TILE_WIDTH
local TILE_Z = TILE_SIDE_3DP * MAGIC_Z_NUMBER
-- local PER_TILE_Z = 1 / TILE_Z
local function isoProj(vx,vy,vz)
  return ((vx-vy)*HS), -(vx+vy)*QS - (vz*TILE_Z)
end
local function isoProjPt(vx,vy,vz)
  local x,y = isoProj(vx,vy,vz)
  return {x,y}
end

local function drawTileOutline(vx,vy,vz)
  local x,y = isoProj(vx,vy,vz)
  love.graphics.line(x,y,  x+HS,y-QS, x,y-HS,  x-HS,y-QS, x,y)--, -32,16, 0,0)
  -- love.graphics.print(vx..","..vy, x,y)
end

local function drawFloorGrid()
  local z = 0
  for x=-5,5 do
    for y = -5,5 do
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

local function drawWorld(model)
  if model.reloadError then
    love.graphics.print(model.reloadError)
    return
  end

  love.graphics.push()
  love.graphics.translate(model.viewoff.x,model.viewoff.y)

  drawFloorGrid()
  for i=1,#model.blocks do
    drawBlock(model.blocks[i])
  end

  love.graphics.pop()

  love.graphics.print("selected: "..model.blockIndex[model.selectedBlock].name)



end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
