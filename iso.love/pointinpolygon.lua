-- http://alienryderflex.com/polygon/
--  The function will return true if the point x,y is inside the polygon, or
--  false if it is not.  If the point is exactly on the edge of the polygon,
--  then the function may return true or false.
--
--  Note that division by zero is avoided because the division is protected
--  by the "if" clause which surrounds it.
local function pointInPolygon1(x, y, verts)
  local result = false
  local j = #verts --  - 1
  for i=1,#verts do
    if ((verts[i][2] < y and verts[j][2] >= y) or (verts[j][2] < y and verts[i][2] >= y)) and (verts[i][1] <= x or verts[j][1] <= x) then
      if verts[i][1] + (y - verts[i][2]) / (verts[j][2] - verts[i][2]) * (verts[j][1] - verts[i][1]) < x then
        result = not result
      end
    end
    j = i
  end
  return result
end

local function shortestDistanceToLine(x,y, pt1, pt2)
  if pt1[1] == pt2[1] then -- vertical
    return math.abs(x-pt1[1])
  elseif pt1[2] == pt2[2] then -- horizontal
    return math.abs(y-pt1[2])
  else
    -- https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
    return math.abs( (pt2[2] - pt1[2])*x - (pt2[1] - pt1[1])*y + pt2[1]*pt1[2] - pt2[2]*pt1[1] ) / math.sqrt(math.pow(pt2[2]-pt1[2], 2) + math.pow(pt2[1]-pt1[2],2))
  end
end

return {
  pointInPolygon=pointInPolygon1,
  perpDist=perpDist,
}
