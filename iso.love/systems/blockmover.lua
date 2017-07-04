local Iso = require 'iso'

local max = math.max
local min = math.min

local function blocksOverlap(a,b)
  return (a.pos.x < b.pos.x+b.size.x and a.pos.x+a.size.x > b.pos.x) and
         (a.pos.y < b.pos.y+b.size.y and a.pos.y+a.size.y > b.pos.y) and
         (a.pos.z < b.pos.z+b.size.z and a.pos.z+a.size.z > b.pos.z)
end

local function blocksTouch(a,b)
  return (a.pos.x <= b.pos.x+b.size.x and a.pos.x+a.size.x >= b.pos.x) and
         (a.pos.y <= b.pos.y+b.size.y and a.pos.y+a.size.y >= b.pos.y) and
         (a.pos.z <= b.pos.z+b.size.z and a.pos.z+a.size.z >= b.pos.z)
end

local function getOverlap(a,b)
  local ret = {
    pos={
      x=max(0, b.pos.x-a.pos.x),
      y=max(0, b.pos.y-a.pos.y),
      z=max(0, b.pos.z-a.pos.z),
    },
    size={
      x=min(a.pos.x+a.size.x-b.pos.x, b.pos.x+b.size.x-a.pos.x),
      y=min(a.pos.y+a.size.y-b.pos.y, b.pos.y+b.size.y-a.pos.y),
      z=min(a.pos.z+a.size.z-b.pos.z, b.pos.z+b.size.z-a.pos.z),
    },
    adj=false,
    adjX=false,
    adjY=false,
    adjZ=false,
  }
  if ret.size.x == 0 then
    ret.adj = true
    ret.adjX = true
  end
  if ret.size.y == 0 then
    ret.adj = true
    ret.adjY = true
  end
  if ret.size.z == 0 then
    ret.adj = true
    ret.adjZ = true
  end

  return ret
end

local function tryMoveBlock(block,vec,otherBlocks)
  local blockStart = {x=block.pos.x, y=block.pos.y, z=block.pos.z}
  local collided = false
  local collisions = {}
  if vec.z ~= 0 then
    block.pos.z = block.pos.z + vec.z
    for i=1,#otherBlocks do
      local other = otherBlocks[i]
      if other.eid ~= block.eid then
        if blocksOverlap(block,other) then
          collided = true
          table.insert(collisions,other)
          if vec.z > 0 then
            -- collided upward
            local pendist = block.pos.z + block.size.z - other.pos.z
            block.pos.z = block.pos.z - pendist
          else
            -- collided downward
            local pendist = other.pos.z + other.size.z - block.pos.z
            block.pos.z = block.pos.z + pendist
          end
        end
      end
    end
  end
  if vec.x ~= 0 then
    block.pos.x = block.pos.x + vec.x
    for i=1,#otherBlocks do
      local other = otherBlocks[i]
      if other.eid ~= block.eid then
        if blocksOverlap(block,other) then
          collided = true
          table.insert(collisions,other)
          if vec.x > 0 then
            -- collided to the right
            local pendist = block.pos.x + block.size.x - other.pos.x
            block.pos.x = block.pos.x - pendist
          else
            -- collided downward
            local pendist = other.pos.x + other.size.x - block.pos.x
            block.pos.x = block.pos.x + pendist
          end
        end
      end
    end
  end
  if vec.y ~= 0 then
    block.pos.y = block.pos.y + vec.y
    for i=1,#otherBlocks do
      local other = otherBlocks[i]
      if other.eid ~= block.eid then
        if blocksOverlap(block,other) then
          collided = true
          table.insert(collisions,other)
          if vec.y > 0 then
            -- collided ahead
            local pendist = block.pos.y + block.size.y - other.pos.y
            block.pos.y = block.pos.y - pendist
          else
            -- collided behind
            local pendist = other.pos.y + other.size.y - block.pos.y
            block.pos.y = block.pos.y + pendist
          end
        end
      end
    end
  end
  if collided then
    local movedVec = {x=block.pos.x-blockStart.x, y=block.pos.y-blockStart.y, z=block.pos.z-blockStart.z}
    return movedVec, collided, collisions
  else
    return vec, false, nil
  end
end

local system = defineUpdateSystem(hasComps('isoWorld'), function(isoWorldEnt,estore,input,resources)
  local blockCache = isoWorldEnt.isoWorld.blockCache
  local otherBlocks = blockCache.sorted
  estore:walkEntity(isoWorldEnt, hasComps('isoSprite','pos','vel'),function(e)
    local block = blockCache.byEid[e.eid]
    local movedVec, collided, collisions = tryMoveBlock(block, e.vel, otherBlocks)
    e.pos.x = e.pos.x + movedVec.x
    e.pos.y = e.pos.y + movedVec.y
    e.pos.z = e.pos.z + movedVec.z
  end)

end)

return system
