require 'crozeng/helpers'
local Colors = require 'colors'

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
  local blocks = {
    newBlock({x=1,y=1,z=0},{x=1,y=2,z=0.3}, Colors.Blue, "Blue"),
    newBlock({x=2,y=2,z=0},{x=1,y=2,z=1.25}, Colors.Red, "Red"),
    newBlock({x=4,y=0,z=0},{x=1,y=1,z=1}, Colors.Yellow, "Yellow"),
  }

  local model ={
    viewoff={x=400,y=300},
    blocks = blocks,
    blockIndex = lcopy(blocks),
    selectedBlock = 1,
    doSort = true,
  }
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
end

local function updateWorld(model,action)
  if action.type == "keyboard" and action.state == "pressed" then

    if action.key == 'w' then wasd('up',model,action)
    elseif action.key == 's' then wasd('down',model,action)
    elseif action.key == 'a' then wasd('left',model,action)
    elseif action.key == 'd' then wasd('right',model,action)
    elseif action.key == 'z' then wasd('sink',model,action)
    elseif action.key == 'x' then wasd('float',model,action)

    elseif action.key == 't' then
      model.doSort = not model.doSort

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


-- Dimetric projection parameters
local TW = 64  -- on-screen tile width (from left diamond point to right)
local HALF_TW = TW / 2  -- tile height is half the tile width
local HALF_TH = TW / 4  -- half the tile height
local MAGIC_Z_NUMBER = 0.88388 -- in game-style isometric projection, this is what you multiply by the "pixel size in 3d space" to squish Z into the right on-screen Y
local WORLD_SIDE = math.pow(math.pow(TW,2) / 2, 0.5) -- how long in pixels, pre-projection, the tile side would be to create a hypotenuse of TILE_WIDTH.  45.254833995939 when TW=64
local TILE_Z = WORLD_SIDE * MAGIC_Z_NUMBER -- screen y adjustment based on z.  40 when TW=64,  60 when TW=96
local Z_FACTOR = 1.41421 * MAGIC_Z_NUMBER -- how to adjust virtual-tile y values based on z.   1.2499919348.  I guessed at this, it works, dunno why.  1.41421 == sqrt(2)

-- 3d space coordinates to screen coords, returned as {x, y}
local function spaceToScreen(x,y,z)
  return { ((x-y) * HALF_TW), -(x+y) * HALF_TH - (z * TILE_Z) }
end

-- 3d space coordinates to screen coords, returned as x, y
local function spaceToScreen_(x,y,z)
  return ((x-y) * HALF_TW), -(x+y) * HALF_TH - (z * TILE_Z)
end

-- Draw the tile located at the given space coordinates.
-- The 0,0 point of the tile is the bottom pt on the drawn diamond.
-- Tile size is based on the dimetric constants above.
local function drawTileOutline(sx,sy,sz)
  local x,y = spaceToScreen_(sx,sy,sz)
  love.graphics.line(
    x,         y,
    x+HALF_TW, y-HALF_TH,
    x,         y-HALF_TW,
    x-HALF_TW, y-HALF_TH,
    x,         y)
end

-- Draw our virtual graph paper
local function drawFloorGrid()
  local z = 0
  for x=0,5 do
    for y = 0,5 do
      drawTileOutline(x,y,z)
    end
  end
end

-- Draw a block's three visible faces using translucent color
-- and solid edges, based on block.color
local function drawBlock(block)
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

-- (Re)calculate a block's virtual silhouette and store in block.sil
-- x, y and h are used to detect overlap.  v is just for fun.
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

-- Draw the projected silhouette extents for a block, on the virtual y, x and h axes
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

-- Returns true if the two linear ranges do NOT overlap
local function areRangesDisjoint(amin,amax,bmin,bmax)
  return (amax <= bmin or bmax <= amin)
end

-- Returns true if all three of its virtual silhouette ranges overlap: x, y and h
local function blocksOverlap(a,b)
  return not(
       areRangesDisjoint(a.sil.hmin,a.sil.hmax, b.sil.hmin,b.sil.hmax)
    or areRangesDisjoint(a.sil.xmin,a.sil.xmax, b.sil.xmin,b.sil.xmax)
    or areRangesDisjoint(a.sil.ymin,a.sil.ymax, b.sil.ymin,b.sil.ymax)
  )
end

-- Figure out the "axis of spatial separation" between two blocks.
-- This is only really interesting if two blocks are virtually overlapping.
-- Eg, if box a has 0 or more distance between box b along the x axis, return 'x'.
--
-- The tutorial used this as part of getFrontBlock but I folded this logic
-- into that function directly... this is just here for illustration
local function getSpaceSepAxis(a,b)
  if areRangesDisjoint(a.pos.x, a.pos.x+a.size.x, b.pos.x, b.pos.x+b.size.x) then
    return 'x'
  elseif areRangesDisjoint(a.pos.y, a.pos.y+a.size.y, b.pos.y, b.pos.y+b.size.y) then
    return 'y'
  elseif areRangesDisjoint(a.pos.z, a.pos.z+a.size.z, b.pos.z, b.pos.z+b.size.z) then
    return 'z'
  end
  return nil
end

-- Figure out if block a is "in front" of block b or vice versa.
-- If the blocks aren't virtually overlapping, nil is returned, indicating no front-back dependency.
local function getFrontBlock(a,b)
  if not blocksOverlap(a,b) then return nil end

  if areRangesDisjoint(a.pos.x, a.pos.x+a.size.x, b.pos.x, b.pos.x+b.size.x) then
    -- space sep axis is X
    if a.pos.x < b.pos.x then return a else return b end
  elseif areRangesDisjoint(a.pos.y, a.pos.y+a.size.y, b.pos.y, b.pos.y+b.size.y) then
    -- space sep axis is Y
    if a.pos.y < b.pos.y then return a else return b end
  elseif areRangesDisjoint(a.pos.z, a.pos.z+a.size.z, b.pos.z, b.pos.z+b.size.z) then
    -- space sep axis is Z
    if a.pos.z < b.pos.z then return b else return a end
  end

  -- Uh oh, a and b are intersecting volumes.
  -- This is not strictly legit... getFrontBlock's contract is that a and b are
  -- non-intersecting.  But instead of erring or pretending their's no
  -- relationship at all, let's just take a guess and pretend it's the X axis.
  if a.pos.x < b.pos.x then return a else return b end
end

-- Calculate front-back dependencies between any overlapping blocks,
-- and treat this dependency graph as a topological sort to produce
-- a proper drawing order for the given blocks such that frontmost blocks
-- are drawn after any blocks they may be occluding.
local function sortBlocks(blocks)
  -- Initialize the list of blocks that each block is behind.
  for i=1,#blocks do
    updateBlockSil(blocks[i])
    blocks[i].blocksBehind = {}
    blocks[i].blocksInFront = {}
  end

  -- For each pair of blocks, determine which is in front and behind.
  for i=1,#blocks do
    local a = blocks[i]
    for j=i+1,#blocks do
      local b = blocks[j]
      local frontBlock = getFrontBlock(a,b)
      if frontBlock then
        if a == frontBlock then
          table.insert(a.blocksBehind, b)
          table.insert(b.blocksInFront, a)
        else
          table.insert(b.blocksBehind, a)
          table.insert(a.blocksInFront, b)
        end
      end
    end
  end


  -- Get list of blocks we can safely draw right now.
  -- These are the blocks with nothing behind them.
  local stack = {}
  for i=1,#blocks do
    if #blocks[i].blocksBehind == 0 then
      table.insert(stack, blocks[i])
    end
  end

  -- While there are still blocks we can draw...
  local sorted = {}
  while #stack > 0 do
    -- Draw block by removing one from "to draw" and adding
    -- it to the end of our "drawn" list.
    local block = stack[#stack]
    stack[#stack] = nil
    table.insert(sorted, block)

    -- Tell blocks in front of the one we just drew
    -- that they can stop waiting on it.
    for j=1,#block.blocksInFront do
      local frontBlock = block.blocksInFront[j]

      -- Add this front block to our "to draw" list if there's
      -- nothing else behind it waiting to be drawn.
      removeObject(frontBlock.blocksBehind, block)
      if #frontBlock.blocksBehind == 0 then
        table.insert(stack, frontBlock)
      end
    end
  end

  return sorted
end

local function drawWorld(model)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.push()
  love.graphics.translate(model.viewoff.x,model.viewoff.y)

  drawFloorGrid()

  local blocks = model.blocks
  if model.doSort then
    blocks = sortBlocks(blocks)
  end

  for i=1,#blocks do
    drawBlock(blocks[i])
    drawBlockSil(blocks[i])
  end

  local pry = 75
  for i=1,#blocks do
    local a = blocks[i]
    for j=i+1,#blocks do
      local b = blocks[j]
      if blocksOverlap(a,b) then
        local axis = getSpaceSepAxis(a,b)
        if not axis then axis = "?" end
        local frontBlock = getFrontBlock(a,b)
        local fbname = "??"
        if frontBlock then fbname=frontBlock.name end
        love.graphics.print(a.name.." overlaps "..b.name.." sepAxis="..axis.." FRONT="..fbname,0,pry)
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
