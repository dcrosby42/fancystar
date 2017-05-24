
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
    h= (x-y)*math.pow(3,0.5)*0.5, ---- Math.cos(Math.PI/6)
    v= (x+y)*0.5,              ---- Math.sin(Math.PI/6)
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

local S = 64
local HS = 32
local QS = 16
local MAGIC_Z_NUMBER = 0.88388
local TILE_SIDE_3DP = math.pow(math.pow(S,2) / 2, 0.5) -- how long in pixels, pre-projection, the tile side would be to create a hypotenuse of TILE_WIDTH
local TILE_Z = TILE_SIDE_3DP * MAGIC_Z_NUMBER

local function isoProj(vx,vy,vz)
  return ((vx-vy)*HS), -(vx+vy)*QS - (vz*TILE_Z)
end

local pts = {
  {x=0,y=0,z=0},
  {x=0,y=1,z=0},
  {x=1,y=0,z=0},
  {x=1,y=1,z=0},

  {x=0,y=0,z=1},
  {x=0,y=1,z=1},
  {x=1,y=0,z=1},
  {x=1,y=1,z=1},
}

for i=1,#pts do
  local pos = pts[i]
  local myx,myy = isoProj(pos.x,pos.y,pos.z)
  local ib = spaceToIso(pos)
  print("("..pos.x..","..pos.y..","..pos.z..")".." isoProj=("..myx..","..myy..") spaceToIso=("..ib.x..","..ib.y..",  "..ib.h..","..ib.v..")")
end
