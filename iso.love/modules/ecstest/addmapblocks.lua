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

local types={
  gr="blockGrass",
  p1="blockGrassPath1",
  p2="blockGrassPath2",
}
local function makePath()
  local plan = {
    {"gr", "gr", "p1", "gr","gr"},
    {"gr", "gr", "p1", "gr","gr"},
    {"gr", "gr", "p1", "gr","gr"},
    {"gr", "gr", "p1", "gr","gr"},
    {"gr", "gr", "p1", "gr","gr"},
  }
  local ul={-2,-2}
  local w = #plan[1]
  local h = #plan
  local items={}
  local z = 0
  for i=1,#plan do
    local row=plan[i]
    for j=1,#row do
      local kind = types[plan[i][j]]
      local x = j-1+ul[1]
      local y = i-1+ul[2]
      local z = 0
      table.insert(items,{pos={x=x,y=y,z=z},kind="blockGrass"})
    end
  end
  return item
end

local function cube(x,y,z)
  local cube={}
  for i=1,z do
    local layer={}
    for j=1,y do
      local row={}
      for k=1,x do
        table.insert(row,"")
      end
      table.insert(layer,row)
    end
    table.insert(cube,layer)
  end
  return cube
end

local function cubeSet(sp, x,y,z, val)
  sp[z][y][x] = val
end

local function cubeToItems(sp,opts)
  opts = opts or {}
  opts.loc = opts.loc or {0,0,0}
  local items = {}
  for z=1,#sp do
    for y=1,#sp[z] do
      for x=1,#sp[z][y] do
        table.insert(items, {
          pos={x=(x-1)+opts.loc[1], y=(y-1)+opts.loc[2], z=(z-1)+opts.loc[3]},
          kind=sp[z][y][x],
        })
      end
    end
  end
  return items
end

local function grassField()
  local sp = cube(11,11,1)
  for x=1,11 do
    for y=1,11 do
      cubeSet(sp,x,y,1, "blockGrass")
    end
  end

  return cubeToItems(sp,{loc={-5,-5,0}})
end

local function addMapBlocks(isoWorld)
  -- local items = {}
  -- tconcat(items, genCheckerboard(-3,-4, 4,3, 0,0, 'blockGrass'))
  -- tconcat(items, genCheckerboard(1,2, 1,2, 1,3, 'blockRed','blockWhite'))
  -- tconcat(items, genCheckerboard(1,-3, 1,-3, 1,3, 'blockGrass','blockWhite'))
  -- tconcat(items, genCheckerboard(1,-2, 1,1, 3,3, 'blockRed','blockWhite'))
  -- tconcat(items, genCheckerboard(-1,2, 0,2, 1,1, 'blockCrate'))
  -- tconcat(items, genCheckerboard(0,2, 0,2, 2,2, 'blockCrate'))
  -- tconcat(items, genCheckerboard(0,1, 0,1, 1,1, 'blockCrate'))
  -- tconcat(items, genCheckerboard(-1,-3, -1,-2, 1,1, 'blockCrate'))
  -- tconcat(items, makePath())

  local items = grassField()
  for _,item in ipairs(items) do
    isoWorld:newChild({
      {'isoSprite', {id=item.kind}},
      {'pos', item.pos},
    })
  end

    -- isoWorld:newChild({
    --   {'isoSprite', {id="blockGrass"}},
    --   {'pos', {x=0,y=0,z=0}},
    -- })
    -- isoWorld:newChild({
    --   {'isoSprite', {id="blockGrassPath1"}},
    --   {'pos', {x=1,y=0,z=0}},
    -- })
    -- isoWorld:newChild({
    --   {'isoSprite', {id="blockGrassPath1"}},
    --   {'pos', {x=1,y=1,z=0}},
    -- })
    -- isoWorld:newChild({
    --   {'isoSprite', {id="blockGrassPath1"}},
    --   {'pos', {x=1,y=-1,z=0}},
    -- })
    -- isoWorld:newChild({
    --   {'isoSprite', {id="blockGrassPathCorner1"}},
    --   {'pos', {x=1,y=-2,z=0}},
    -- })
    -- isoWorld:newChild({
    --   {'isoSprite', {id="blockGrassPath2"}},
    --   {'pos', {x=2,y=-2,z=0}},
    -- })
end

return addMapBlocks
