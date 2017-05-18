local Colors = require 'colors'
local function newBlock(pos,size,color)
  return {
    type="block",
    pos=pos,
    size=size,
    color=color
  }
end

local function newWorld()
  local model ={
    blocks={
      newBlock({3,2,0},{2,2,2},Colors.Blue),
      newBlock({2,4,0},{2.3,2,1},Colors.Green),
    },
    viewoff={x=400,y=300}
  }
  return model
end

local function updateWorld(model,action)
  if action.type == "keyboard" and action.state == "pressed" then
    if action.key == 'r' then
      return model, {{type="crozeng.reloadRootModule"}}
    end
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
      isoProjPt(pos[1],pos[2],pos[3]),
      isoProjPt(pos[1],pos[2]+size[2],pos[3]),
      isoProjPt(pos[1],pos[2]+size[2],pos[3]+size[3]),
      isoProjPt(pos[1],pos[2],pos[3]+size[3]),
    },
    { -- right
      isoProjPt(pos[1],pos[2],pos[3]),
      isoProjPt(pos[1],pos[2],pos[3]+size[3]),
      isoProjPt(pos[1]+size[1],pos[2],pos[3]+size[3]),
      isoProjPt(pos[1]+size[1],pos[2],pos[3]),
    },
    { --top
      isoProjPt(pos[1],pos[2],pos[3]+size[3]),
      isoProjPt(pos[1],pos[2]+size[2],pos[3]+size[3]),
      isoProjPt(pos[1]+size[1],pos[2]+size[2],pos[3]+size[3]),
      isoProjPt(pos[1]+size[1],pos[2],pos[3]+size[3]),
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
  love.graphics.push()
  love.graphics.translate(model.viewoff.x,model.viewoff.y)

  drawFloorGrid()
  for i=1,#model.blocks do
    drawBlock(model.blocks[i])
  end

  love.graphics.pop()



  love.graphics.print("Hllo")
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
