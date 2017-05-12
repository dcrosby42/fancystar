local Iso = {}

local TILE_WIDTH = 64
local TILE_HEIGHT = 32
local TILE_WIDTH_HALF = 32 -- TILE_WIDTH / 2
local TILE_HEIGHT_HALF = 16 -- TILE_HEIGHT / 2
local WORLD_TILE_SIDE = 45.2548  -- sqrt(64^2 / 2) -- math.pow(math.pow(TILE_WIDTH,2) / 2, 0.5) -- derived from assuming TILE_WIDTH=64 = hypotenuse of flat tile
local MAGIC_Z_NUMBER = 0.88388   -- 40 / tile_side_for(tile_w=64) -- magic number derived from physical screen measure of 40 vertical pixels
local TILE_Z = 40                -- WORLD_TILE_SIDE * MAGIC_Z_NUMBER

Iso.TILE_WIDTH = TILE_WIDTH
Iso.TILE_HEIGHT = TILE_HEIGHT
Iso.TILE_WIDTH_HALF = TILE_WIDTH_HALF
Iso.TILE_HEIGHT_HALF = TILE_HEIGHT_HALF
Iso.WORLD_TILE_SIDE = WORLD_TILE_SIDE
Iso.MAGIC_Z_NUMBER = MAGIC_Z_NUMBER
Iso.TILE_Z = TILE_Z


local function worldPointToScreenPoint(p)
  return {
    (p[1] +  p[2]) * TILE_WIDTH_HALF,
    ((p[2] - p[1]) * TILE_HEIGHT_HALF) - (p[3] * TILE_Z)
  }
end

local proj = worldPointToScreenPoint

local function projOrthoTop(p)
  return {p[1],p[2]}
end


local function isoSort(a,b)
  -- First considers VIRTUAL Z (height), sort ascending.
  if a.pos[3] ~= b.pos[3] then
    return a.pos[3] < b.pos[3]
  else
    -- Within same Z level, sort ascending by SCREEN Y
    sa=proj(a.pos)
    sb=proj(b.pos)
    return sa[2] < sb[2]
  end
end

local function transCopy(p, tr)
  return {p[1]+tr[1], p[2]+tr[2], p[3]+tr[3]}
end

Iso.sort = isoSort
Iso.proj = worldPointToScreenPoint
Iso.transCopy = transCopy

return Iso
