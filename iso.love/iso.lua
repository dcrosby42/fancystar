local Iso = {}

-- local TILE_WIDTH = 64
-- local TILE_WIDTH_HALF = 32 -- TILE_WIDTH / 2
-- local TILE_HEIGHT = 32 -- TILE_WIDTH / 2
-- local TILE_HEIGHT_HALF = 16 -- TILE_HEIGHT / 2
-- local TILE_SIDE_3DP = 45.2548  -- sqrt(64^2 / 2) -- math.pow(math.pow(TILE_WIDTH,2) / 2, 0.5) -- derived from assuming TILE_WIDTH=64 = hypotenuse of flat tile
-- local MAGIC_Z_NUMBER = 0.88388   -- 40 / tile_side_for(tile_w=64) -- magic number derived from physical screen measure of 40 vertical pixels
-- local TILE_Z = 40                -- TILE_SIDE_3DP * MAGIC_Z_NUMBER

local MAGIC_Z_NUMBER = 0.88388
local TILE_WIDTH = 96
local PER_TILE_WIDTH = 1 / 96
local TILE_WIDTH_HALF = TILE_WIDTH / 2
local TILE_HEIGHT = TILE_WIDTH_HALF
local TILE_HEIGHT_HALF = TILE_HEIGHT / 2
local TILE_SIDE_3DP = math.pow(math.pow(TILE_WIDTH,2) / 2, 0.5) -- how long in pixels, pre-projection, the tile side would be to create a hypotenuse of TILE_WIDTH
local TILE_Z = TILE_SIDE_3DP * MAGIC_Z_NUMBER
local PER_TILE_Z = 1 / TILE_Z
-- print("TILE_SIDE_3DP "..TILE_SIDE_3DP)
-- print("TILE_Z "..TILE_Z)
-- print("PER_TILE_Z "..PER_TILE_Z)

Iso.TILE_WIDTH = TILE_WIDTH
Iso.PER_TILE_WIDTH = PER_TILE_WIDTH
Iso.TILE_HEIGHT = TILE_HEIGHT
Iso.TILE_WIDTH_HALF = TILE_WIDTH_HALF
Iso.TILE_HEIGHT_HALF = TILE_HEIGHT_HALF
Iso.TILE_SIDE_3DP = TILE_SIDE_3DP
Iso.MAGIC_Z_NUMBER = MAGIC_Z_NUMBER
Iso.TILE_Z = TILE_Z
Iso.PER_TILE_Z = PER_TILE_Z

local function worldPointToScreenPoint(p)
  return {
    (p[1] +  p[2]) * TILE_WIDTH_HALF,
    ((p[2] - p[1]) * TILE_HEIGHT_HALF) - (p[3] * TILE_Z)
  }
end

local function imgWidthToWorldWidth(imgw)
  return imgw * PER_TILE_WIDTH
end

local function imgHeightToWorldHeight(imgh)
  return imgh * PER_TILE_Z
end

local proj = worldPointToScreenPoint

local function projOrthoTop(p)
  return {p[1],p[2]}
end


local function isoSortZ(a,b)
  -- First considers VIRTUAL Z (height), sort ascending.
  if a.pos[3] ~= b.pos[3] then
    return a.pos[3] < b.pos[3]
  else
    -- Within same Z level, sort ascending by SCREEN Y
    local sa=proj(a.pos)
    local sb=proj(b.pos)
    return sa[2] < sb[2]
  end
end

local function isoSortZ2(a,b)
  local apos = a.pos
  local bpos = b.pos
  if a.bounds then
    apos = {apos[1],apos[2],apos[3]+a.bounds.dim[3]}
  end
  if b.bounds then
    bpos = {bpos[1],bpos[2],bpos[3]+b.bounds.dim[3]}
  end
  -- First considers VIRTUAL Z (height), sort ascending.
  if apos[3] ~= bpos[3] then
    return apos[3] < bpos[3]
  else
    -- Within same Z level, sort ascending by SCREEN Y
    local sa=proj(apos)
    local sb=proj(bpos)
    return sa[2] < sb[2]
  end
end

local function isoSortY(a,b)
  local sa=proj(a.pos)
  local sb=proj(b.pos)
  if sa[2] == sb[2] then
    return a.pos[3] < b.pos[3]
  else
    return sa[2] < sb[2]
  end
end

local one_over_sqrt_two = 1 / math.pow(2,0.5)
local neg_cam_y = 1000
local function isoSortD2(a,b)
  local da = (a.pos[2] - a.pos[1] + neg_cam_y) * one_over_sqrt_two
  local db = (b.pos[2] - b.pos[1] + neg_cam_y) * one_over_sqrt_two
  if da ~= db then
    return da < db
  else
    return a.pos[3] < b.pos[3]
  end
end

local function transCopy(p, tr)
  return {p[1]+tr[1], p[2]+tr[2], p[3]+tr[3]}
end

Iso.sort = isoSortZ
Iso.proj = worldPointToScreenPoint
Iso.transCopy = transCopy
Iso.imgWidthToWorldWidth = imgWidthToWorldWidth
Iso.imgHeightToWorldHeight = imgHeightToWorldHeight

return Iso
