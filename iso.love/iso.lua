require 'crozeng/helpers'

local Iso = {}

local Colors = require 'colors'

-- Dimetric projection parameters
local TW = 96  -- on-screen tile width (from left diamond point to right)
local HALF_TW = TW / 2  -- tile height is half the tile width
local HALF_TH = TW / 4  -- half the tile height
local MAGIC_Z_NUMBER = 0.88388 -- in game-style isometric projection, this is what you multiply by the "pixel size in 3d space" to squish Z into the right on-screen Y
local WORLD_SIDE = math.pow(math.pow(TW,2) / 2, 0.5) -- how long in pixels, pre-projection, the tile side would be to create a hypotenuse of TILE_WIDTH.  45.254833995939 when TW=64
local TILE_Z = WORLD_SIDE * MAGIC_Z_NUMBER -- screen y adjustment based on z.  40 when TW=64,  60 when TW=96
local Z_FACTOR = 1.41421 * MAGIC_Z_NUMBER -- how to adjust virtual-tile y values based on z.   1.2499919348.  I guessed at this, it works, dunno why.  1.41421 == sqrt(2)
local PER_TILE_WIDTH = 1 / TW
local PER_TILE_Z = 1 / TILE_Z

Iso.TW = TW
Iso.HALF_TW = HALF_TW
Iso.HALF_TH = HALF_TH
Iso.MAGIC_Z_NUMBER = MAGIC_Z_NUMBER
Iso.WORLD_SIDE = WORLD_SIDE
Iso.TILE_Z = TILE_Z
Iso.Z_FACTOR = Z_FACTOR

-- 3d space coordinates to screen coords, returned as {x, y}
local function spaceToScreen(x,y,z)
  return { ((x-y) * HALF_TW), -(x+y) * HALF_TH - (z * TILE_Z) }
end

-- 3d space coordinates to screen coords, returned as x, y
local function spaceToScreen_(x,y,z)
  return ((x-y) * HALF_TW), -(x+y) * HALF_TH - (z * TILE_Z)
end

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

local function transCopy(p, tr)
  return {p[1]+tr[1], p[2]+tr[2], p[3]+tr[3]}
end

local function imgWidthToWorldWidth(imgw)
  return imgw * PER_TILE_WIDTH
end

local function imgHeightToWorldHeight(imgh)
  return imgh * PER_TILE_Z
end

Iso.sortBlocks = sortBlocks
Iso.newBlock = newBlock
Iso.spaceToScreen = spaceToScreen
Iso.spaceToScreen_ = spaceToScreen_
Iso.blocksOverlap = blocksOverlap
Iso.getSpaceSepAxis = getSpaceSepAxis
Iso.getFrontBlock = getFrontBlock
Iso.transCopy = transCopy
Iso.imgWidthToWorldWidth = imgWidthToWorldWidth
Iso.imgHeightToWorldHeight = imgHeightToWorldHeight

return Iso
