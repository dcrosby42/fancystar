local IsoBlock = {}

local function newBlock(pos,size,color)
  return {
    pos=pos,
    size=size,
    color=color,
  }
end

IsoBlock.newBlock = newBlock

local blocks = {
  newBlock({x=1,y=3,z=0},{x=2,y=2,z=2.5}, Colors.Green),
  newBlock({x=2,y=2,z=0},{x=1,y=1,z=1.5}, IsoBlock.colors.red),
  newBlock({x=3,y=1,z=0},{x=1,y=4,z=1},   IsoBlock.colors.blue),
}

local function getBlockBounds(block)
    local p = block.pos;
    local s = block.size;
    return {
      xmin= p.x,
      xmax= p.x + s.x,
      ymin= p.y,
      ymax= p.y + s.y,
      zmin= p.z,
      zmax= p.z + s.z,
    }
end

local function areRangesDisjoint(amin,amax,bmin,bmax)
  return (amax <= bmin or bmax <= amin)
end

-- -- Convert 3D space coordinates to flattened 2D isometric coordinates.
-- -- x and y coordinates are oblique axes separated by 120 degrees.
-- -- h,v are the horizontal and vertical distances from the origin.
local function spaceToIso(spacePos)
  local z
  if not spacePos.z then
    z = 0
  else
    z = spacePos.z
  end

  local x = spacePos.x + z
  local y = spacePos.y + z

  return {
    x= x,
    y= y,
    h= (x-y)*Math.sqrt(3)/2, ---- Math.cos(Math.PI/6)
    v= (x+y)/2,              ---- Math.sin(Math.PI/6)
  }
end

-- local function isoToScreen(isoPos)
--   return {
--     x= isoPos.h * this.scale + this.origin.x,
--     y= -isoPos.v * this.scale + this.origin.y,
--   }
-- end
--
-- local function spaceToScreen(block)
--   return isoToScreen(spaceToIso(spacePos))
-- end

local function getIsoNamedSpaceVerts(block)
  local p = block.pos
  local s = block.size
  return {
    rightDown= {x=p.x+s.x, y=p.y,     z=p.z},
    leftDown=  {x=p.x,     y=p.y+s.y, z=p.z},
    backDown=  {x=p.x+s.x, y=p.y+s.y, z=p.z},
    frontDown= {x=p.x,     y=p.y,     z=p.z},
    rightUp=   {x=p.x+s.x, y=p.y,     z=p.z+s.z},
    leftUp=    {x=p.x,     y=p.y+s.y, z=p.z+s.z},
    backUp=    {x=p.x+s.x, y=p.y+s.y, z=p.z+s.z},
    frontUp=   {x=p.x,     y=p.y,     z=p.z+s.z},
  }
end


local function getIsoVerts(block)
  local verts = getIsoNamedSpaceVerts(block)
  return {
    leftDown=  this.spaceToIso(verts.leftDown),
    rightDown= this.spaceToIso(verts.rightDown),
    backDown=  this.spaceToIso(verts.backDown),
    frontDown= this.spaceToIso(verts.frontDown),
    leftUp=    this.spaceToIso(verts.leftUp),
    rightUp=   this.spaceToIso(verts.rightUp),
    backUp=    this.spaceToIso(verts.backUp),
    frontUp=   this.spaceToIso(verts.frontUp),
  }
end

local function getIsoBounds(block)
  local verts = getIsoVerts(block)
  return {
    xmin= verts.frontDown.x,
    xmax= verts.backUp.x,
    ymin= verts.frontDown.y,
    ymax= verts.backUp.y,
    hmin= verts.leftDown.h,
    hmax= verts.rightDown.h,
  }
end


---- Try to find an axis in 2D isometric that separates the two given blocks.
---- This helps identify if the the two blocks are overlap on the screen.
local function getIsoSepAxis(block_a, block_b)
  local a = getIsoBounds(block_a)
  local b = getIsoBounds(block_b)

  local sepAxis = null
  if areRangesDisjoint(a.xmin,a.xmax,b.xmin,b.xmax) then
    sepAxis = 'x'
  end
  if areRangesDisjoint(a.ymin,a.ymax,b.ymin,b.ymax) then
    sepAxis = 'y'
  end
  if areRangesDisjoint(a.hmin,a.hmax,b.hmin,b.hmax) then
    sepAxis = 'h'
  end
  return sepAxis
end

-- -- Try to find an axis in 3D space that separates the two given blocks.
-- -- This helps identify which block is in front of the other.
local function getSpaceSepAxis(block_a, block_b)
  local sepAxis = null;

  local a = block_a.getBounds();
  local b = block_b.getBounds();

  if (areRangesDisjoint(a.xmin,a.xmax,b.xmin,b.xmax)) then
    sepAxis = 'x';
  elseif (areRangesDisjoint(a.ymin,a.ymax,b.ymin,b.ymax)) then
    sepAxis = 'y';
  elseif (areRangesDisjoint(a.zmin,a.zmax,b.zmin,b.zmax)) then
    sepAxis = 'z';
  end
  return sepAxis;
end

---- In an isometric perspective of the two given blocks, determine
---- if they will overlap each other on the screen. If they do, then return
---- the block that will appear in front.
local function getFrontBlock(block_a, block_b)
  ---- If no isometric separation axis is found,
  ---- then the two blocks do not overlap on the screen.
  ---- This means there is no "front" block to identify.
  if getIsoSepAxis(block_a, block_b) then
    return nil;
  end

  ---- Find a 3D separation axis, and use it to determine
  ---- which block is in front of the other.
  local a = block_a.getBounds()
  local b = block_b.getBounds()
  local val = getSpaceSepAxis(block_a, block_b)
  if val == 'x' then
    if a.xmin < b.xmin then return block_a else return block_b end
  elseif val == 'y' then
    if a.ymin < b.ymin then return block_a else return block_b end
  elseif val == 'z' then
    if a.zmin < b.zmin then return block_b else return block_a end
  else
    error("blocks must be non-intersecting")
  end
end

---- Sort blocks in the order that they should be drawn
local function sortBlocks(blocks)
  local i, j, numBlocks
  numBlocks = #blocks

  -- -- Initialize the list of blocks that each block is behind.
  for i=1,numBlocks do
    blocks[i].blocksBehind = {}
    blocks[i].blocksInFront = {}
  end

  ---- For each pair of blocks, determine which is in front and behind.
  local a,b,frontBlock
  for i=1,numBlocks do
    a = blocks[i]
    for j=i+1,j<numBlocks do
      b = blocks[j]
      frontBlock = getFrontBlock(a,b)
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
  local blocksToDraw = {}
  for i=1,numBlocks do
    if #blocks[i].blocksBehind == 0 then
      table.insert(blocksToDraw, blocks[i])
    end
  end

  -- While there are still blocks we can draw...
  local blocksDrawn = {}
  while #blocksToDraw > 0 do
    -- Draw block by removing one from "to draw" and adding
    -- it to the end of our "drawn" list.
    local block = blocksToDraw[#blocksToDraw]
    blocksToDraw[#blocksToDraw] = nil
    table.insert(blocksDrawn, block)

    -- Tell blocks in front of the one we just drew
    -- that they can stop waiting on it.
    for j=1,#block.blocksInFront do
      local frontBlock = block.blocksInFront[j];

      -- Add this front block to our "to draw" list if there's
      -- nothing else behind it waiting to be drawn.
      table.remove(frontBlock.blocksBehind, block)
      if #frontBlock.blocksBehind == 0 then
        table.insert(blocksToDraw, frontBlock)
      end
    end
  end

  return blocksDrawn
end

IsoBlock.sortBlocks = sortBlocks
