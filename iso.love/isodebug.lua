local Colors = require 'colors'
local Iso = require 'iso'
local spaceToScreen = Iso.spaceToScreen
local spaceToScreen_ = Iso.spaceToScreen_
local HALF_TW = Iso.HALF_TW
local HALF_TH = Iso.HALF_TH

local IsoDebug = {}

IsoDebug.drawTileOutline = function(sx,sy,sz,side)
  local x,y = spaceToScreen_(sx,sy,sz)
  if side == "right" then
    local upx,upy = spaceToScreen_(sx,sy,sz+1)
    love.graphics.line(
      x,         y,
      upx,       upy,
      upx+HALF_TW, upy-HALF_TH,
      x+HALF_TW, y-HALF_TH,
      x,         y)
  elseif side == "left" then
    local upx,upy = spaceToScreen_(sx,sy,sz+1)
    love.graphics.line(
      x,         y,
      upx,       upy,
      upx+HALF_TW, upy+HALF_TH,
      x+HALF_TW, y+HALF_TH,
      x,         y)
  else
    love.graphics.line(
      x,         y,
      x+HALF_TW, y-HALF_TH,
      x,         y-HALF_TW,
      x-HALF_TW, y-HALF_TH,
      x,         y)
  end
end

-- Draw our virtual graph paper
IsoDebug.drawFloorGrid = function ()
  local z = 0
  for x=0,5 do
    for y = 0,5 do
      IsoDebug.drawTileOutline(x,y,z,"bottom")
    end
  end
end

-- Draw the projected silhouette extents for a block, on the virtual y, x and h axes
IsoDebug.drawBlockSil = function (block)
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

-- Draw a block's three visible faces using translucent color
-- and solid edges, based on block.color
IsoDebug.drawBlock = function(block,color)
  color = color or block.color or Colors.White
  local pos = block.pos
  local size = block.size
  local faces = {
    { -- left
      spaceToScreen(pos.x,pos.y,pos.z),
      spaceToScreen(pos.x,pos.y+size.y,pos.z),
      spaceToScreen(pos.x,pos.y+size.y,pos.z+size.z),
      spaceToScreen(pos.x,pos.y,pos.z+size.z),
    },
    { -- right
      spaceToScreen(pos.x,pos.y,pos.z),
      spaceToScreen(pos.x,pos.y,pos.z+size.z),
      spaceToScreen(pos.x+size.x,pos.y,pos.z+size.z),
      spaceToScreen(pos.x+size.x,pos.y,pos.z),
    },
    { --top
      spaceToScreen(pos.x,pos.y,pos.z+size.z),
      spaceToScreen(pos.x,pos.y+size.y,pos.z+size.z),
      spaceToScreen(pos.x+size.x,pos.y+size.y,pos.z+size.z),
      spaceToScreen(pos.x+size.x,pos.y,pos.z+size.z),
    }
  }
  local r,g,b,a = unpack(color)
  love.graphics.setColor(r,g,b,100)
  for i=1,#faces do
    love.graphics.polygon("fill",faces[i][1][1],faces[i][1][2],faces[i][2][1],faces[i][2][2],faces[i][3][1],faces[i][3][2],faces[i][4][1],faces[i][4][2])
  end
  love.graphics.setColor(r,g,b,a)
  for i=1,#faces do
    love.graphics.polygon("line",faces[i][1][1],faces[i][1][2],faces[i][2][1],faces[i][2][2],faces[i][3][1],faces[i][3][2],faces[i][4][1],faces[i][4][2])
  end
  love.graphics.setColor(unpack(Colors.White))
end
return IsoDebug
