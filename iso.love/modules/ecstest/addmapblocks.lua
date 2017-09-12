local function genCheckerboard(x1,y1, x2,y2, z1,z2, c1,c2)
  c2 = c2 or c1
  local items = {}
  for z=z1,z2 do
    for x=x1,x2 do
      for y=y1,y2 do
        local kind = c1
        if (x + y +   z) % 2 == 0 then
          kind = c2
        end
        items[#items+1] = {pos={x=x,y=y,z=z},kind=kind}
      end
    end
  end
  return items
end

local function addMapBlocks(isoWorld)
  local items = {}
  tconcat(items, genCheckerboard(-4,-5, 5,4, 0,0, 'blockWhite', 'blockBlue'))
  tconcat(items, genCheckerboard(1,2, 1,2, 1,3, 'blockRed','blockWhite'))
  tconcat(items, genCheckerboard(1,-3, 1,-3, 1,3, 'blockRed','blockWhite'))
  tconcat(items, genCheckerboard(1,-2, 1,1, 3,3, 'blockRed','blockWhite'))
  tconcat(items, genCheckerboard(-1,2, 0,2, 1,1, 'blockGreen','blockYellow'))
  tconcat(items, genCheckerboard(0,2, 0,2, 2,2, 'blockYellow'))
  tconcat(items, genCheckerboard(0,1, 0,1, 1,1, 'blockYellow'))
  tconcat(items, genCheckerboard(-1,-3, -1,-2, 1,1, 'blockYellow'))
  -- tconcat(items, genCheckerboard(0,0, 0,0, 1,1, 'blockRed'))
  for _,item in ipairs(items) do
    isoWorld:newChild({
      {'isoSprite', {id=item.kind, picname="blender_cube_96"}},
      {'pos', item.pos},
    })
  end
end

return addMapBlocks
