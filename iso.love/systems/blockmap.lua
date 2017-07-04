local Iso = require 'iso'

local function getIsoPos(e)
  local par = e:getParent()
  if par and par.pos then
    local pp = getIsoPos(par)
    return {
      x=e.pos.x + pp.x,
      y=e.pos.y + pp.y,
      z=e.pos.z + pp.z,
    }
  else
    return {
      x=e.pos.x,
      y=e.pos.y,
      z=e.pos.z,
    }
  end
end

local function copyOffset(pos, offset)
  return {
    x = pos.x - offset.x,
    y = pos.y - offset.y,
    z = pos.z - offset.z,
  }
end

local function updateCachedBlock(block,e,resources)
  block.entity = e -- ?.  reset this just in case the Entity object is actually a new Lua table
  if block.spriteId ~= e.isoSprite.id then
    block.spriteId = e.isoSprite.id
    local sprite = resources.sprites[block.spriteId]
    assert(sprite, "No sprite for block.spriteId="..block.spriteId)
    block.spriteOffset = sprite.offset
    block.size = sprite.size
    if sprite.color then
      block.color = sprite.color
    else
      block.color = {255,255,255,255} -- white
    end
    block.imageOffset = sprite.imageOffset
    block.picname = ""
    block.pic = {}
  end
  if block.picname ~= e.isoSprite.picname then
    block.picname = e.isoSprite.picname
    block.pic = resources.pics[e.isoSprite.picname]
    assert(block.pic, "No sprite for block.picname="..block.picname)
  end
  block.spritePos = getIsoPos(e)
  block.pos = copyOffset(block.spritePos, block.spriteOffset)
  if e.isoDebug and e.isoDebug.on then
    block.debug.on = true
  else
    block.debug.on = false
  end
  return block
end

local function newCachedBlock(e)
  local block = Iso.newSortable()
  block.type = "spriteEntityBlock" -- not used?
  block.eid = e.eid
  block.debug = {on=false}
  return block
end

local system = defineUpdateSystem(hasComps('isoWorld'), function(isoWorldEnt,estore,input,resources)
  local saw = {}
  local blocksByEid = isoWorldEnt.isoWorld.blockCache.byEid


  -- Find entities to draw:
  estore:walkEntity(isoWorldEnt, hasComps('isoSprite'),function(e)
    table.insert(saw, e.eid)
    if blocksByEid[e.eid] then
      -- UPDATE CACHED BLOCK
      updateCachedBlock(blocksByEid[e.eid], e, resources)
      blocksByEid[e.eid].debug.on = false -- TODO better mouse picking
    else
      -- ADD NEW CACHED BLOCK
      blocksByEid[e.eid] = updateCachedBlock(newCachedBlock(e), e, resources)
      local bl = blocksByEid[e.eid]
    end
  end)

  -- Sort blocks, dropping any cached blocks that no longer correspond to an entity:
  local toSort = {}
  for eid,block in pairs(blocksByEid) do
    if lcontains(saw,eid) then
      table.insert(toSort, block)
    else
      -- REMOVE CACHED BLOCK
      blocksByEid[eid] = nil
    end
  end
  isoWorldEnt.isoWorld.blockCache.sorted = Iso.sortBlocks(toSort)
end)

return system
