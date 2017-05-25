require 'crozeng/helpers'
local Colors = require 'colors'
local Iso = require 'iso'
local spaceToScreen = Iso.spaceToScreen
local spaceToScreen_ = Iso.spaceToScreen_
local newBlock = Iso.newBlock
local IsoDebug = require 'isodebug'

local BlenderCube96 = "images/blender_cube_96.png"
local Maya = "images/maya_trans.png"


local function newCubeSprite(model,pos,color,name)
  color = color or Colors.White
  name = name or "cube"
  local s = newBlock(pos, {x=1,y=1,z=1}, color, name)
  s.type = "sprite"
  local img = model.images[BlenderCube96]
  s.image = {
    name = BlenderCube96,
    offx = img:getWidth() / 2,
    offy = img:getHeight(),
    width = img:getWidth(),
    height = img:getHeight(),
  }
  s.dbg = {}
  return s
end

local function newMayaSprite(model,loc,color,name)
  color = color or Colors.White
  name = name or "Maya"
  local img = model.images[Maya]
  local ih = img:getHeight()
  local iw = img:getWidth()
  -- ih=106 iw=68
  local size = {
    x = Iso.imgWidthToWorldWidth(56), -- iw - 12
    y = Iso.imgWidthToWorldWidth(56),
    z = Iso.imgHeightToWorldHeight(96), -- ih - 10
  }
  local center = { x=0.5, y=0.5, z=0 }
  local pos = {
    x = loc.x - (size.x*center.x),
    y = loc.y - (size.y*center.y),
    z = loc.z - (size.z*center.z)
  }

  local s = newBlock(pos, size, color, name)

  s.type = "sprite"
  s.image = {
    name = Maya,
    width = iw,
    height = ih,
    offx = 38, -- iw / 2 + 4,
    offy = 114, -- ih + 8,
  }
  s.dbg = { box=false, imgbounds=false }
  return s
end

local function genCheckerboard(x1,y1, x2,y2, z1,z2, c1,c2)
  c1 = c1 or Colors.White
  c2 = c2 or c1
  local items = {}
  for z=z1,z2 do
    for x=x1,x2 do
      for y=y1,y2 do
        print("GenCheckerboard "..x..","..y..","..z)
        local color = c1
        if (x + y +   z) % 2 == 0 then
          color = c2
        end
        items[#items+1] = {pos={x=x,y=y,z=z},color=color}
      end
    end
  end
  return items
end

local function newWorld()


  local model ={
    images = {},
    viewoff={x=400,y=500},
    selectedBlock = 1,

    doSort = true,
    drawFloor=true,
    drawSprites=true,
    drawSpriteGeom=false,
    drawHelp=false,
    drawOverlapInfo=false,
    drawSil=false,
  }
  model.images[BlenderCube96] = love.graphics.newImage(BlenderCube96)
  model.images[Maya] = love.graphics.newImage(Maya)
  model.blocks = {}
  -- table.insert(model.blocks, newBlock({x=1,y=1,z=0},{x=1,y=2,z=0.3}, Colors.Blue, "Blue"))
  -- table.insert(model.blocks, newBlock({x=2,y=2,z=0},{x=1,y=2,z=1.25}, Colors.Red, "Red"))
  -- table.insert(model.blocks, newBlock({x=4,y=0,z=0},{x=1,y=1,z=1}, Colors.Yellow, "Yellow"))

  -- table.insert(model.blocks, newCubeSprite(model, {x=0,y=0,z=0}, Colors.Blue))
  -- table.insert(model.blocks, newCubeSprite(model, {x=1,y=0,z=0}, Colors.Red))
  -- table.insert(model.blocks, newCubeSprite(model, {x=0,y=0,z=-1}, Colors.White))
  table.insert(model.blocks, newMayaSprite(model, {x=1.5,y=3.5,z=0}))

  local items = genCheckerboard(0,0,5,5, -1,-1, Colors.White,Colors.Green)
  tconcat(items, genCheckerboard(0,5,5,5, 0,1, Colors.Blue,Colors.White))
  tconcat(items, genCheckerboard(0,0,5,0, 0,0, Colors.White,Colors.Blue))
  tconcat(items, genCheckerboard(0,0, 0,5, 2,2, Colors.Blue,Colors.White))
  tconcat(items, genCheckerboard(0,0, 0,0, 1,1, Colors.Red))
  for _,item in ipairs(items) do
    table.insert(model.blocks, newCubeSprite(model, item.pos, item.color))
  end

  model.blockIndex = lcopy(model.blocks)


  return model
end

local WASD_INC = 0.25
local function wasd(dir,model,action)
  local block = model.blockIndex[model.selectedBlock]
  if dir == "up" then
    if action.ctrl then
      block.size.y = block.size.y + WASD_INC
    else
      block.pos.y = block.pos.y + WASD_INC
    end
  elseif dir == "down" then
    if action.ctrl then
      block.size.y = block.size.y - WASD_INC
    else
      block.pos.y = block.pos.y - WASD_INC
    end
  elseif dir == "left" then
    if action.ctrl then
      block.size.x = block.size.x - WASD_INC
    else
      block.pos.x = block.pos.x - WASD_INC
    end
  elseif dir == "right" then
    if action.ctrl then
      block.size.x = block.size.x + WASD_INC
    else
      block.pos.x = block.pos.x + WASD_INC
    end
  elseif dir == "float" then
    if action.ctrl then
      block.size.z = block.size.z + WASD_INC
    else
      block.pos.z = block.pos.z + WASD_INC
    end
  elseif dir == "sink" then
    if action.ctrl then
      block.size.z = block.size.z - WASD_INC
    else
      block.pos.z = block.pos.z - WASD_INC
    end
  end
end

local function updateWorld(model,action)
  if action.type == "keyboard" and action.state == "pressed" then

    if action.key == 'w' then wasd('up',model,action)
    elseif action.key == 's' then wasd('down',model,action)
    elseif action.key == 'a' then wasd('left',model,action)
    elseif action.key == 'd' then wasd('right',model,action)
    elseif action.key == 'z' then wasd('sink',model,action)
    elseif action.key == 'x' then wasd('float',model,action)

    elseif action.key == 't' then
      model.doSort = not model.doSort

    elseif action.key == 'g' then
      model.drawSpriteGeom = not model.drawSpriteGeom
    elseif action.key == 'b' then
      model.drawSprites = not model.drawSprites

    elseif action.key == 'r' then
      return model, {{type="crozeng.reloadRootModule"}}
    elseif action.key == 'space' then
      model.selectedBlock = model.selectedBlock + 1
      if model.selectedBlock > #model.blockIndex then
        model.selectedBlock = 1
      end
    end
  end
  return model, nil
end


local function drawSprite(model,block)
  local img = model.images[block.image.name]
  local x,y = spaceToScreen_(block.pos.x, block.pos.y, block.pos.z)
  local r,g,b,a = unpack(block.color)
  local offx = block.image.offx
  local offy = block.image.offy
  love.graphics.setColor(r,g,b,a)
  if model.drawSprites then
    love.graphics.draw(
      img,
      x,y,
      0,                                 -- rotation
      1,1,                               -- scalex,scaley
      offx, offy -- xoff,yoff
    )
  end
  if model.drawSpriteGeom or block.dbg.imgbounds then
    -- love.graphics.setColor(255,0,0)
    love.graphics.points(x,y)
    love.graphics.rectangle("line",x-offx,y-offy,block.image.width,block.image.height)
  end
  love.graphics.setColor(unpack(Colors.White))
end

local function drawWorld(model)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.push()
  love.graphics.translate(model.viewoff.x,model.viewoff.y)

  if model.drawFloor then
    IsoDebug.drawFloorGrid()
  end

  local blocks = model.blocks
  if model.doSort then
    blocks = Iso.sortBlocks(blocks)
  end

  for i=1,#blocks do
    if blocks[i].type == "sprite" then
      drawSprite(model, blocks[i])
      if model.drawSpriteGeom or blocks[i].dbg.box then
        IsoDebug.drawBlock(blocks[i])
      end
    else
      IsoDebug.drawBlock(blocks[i])
    end
    if model.drawSil then
      IsoDebug.drawBlockSil(blocks[i])
    end
  end

  if model.drawOverlapInfo then
    local pry = 75
    for i=1,#blocks do
      local a = blocks[i]
      for j=i+1,#blocks do
        local b = blocks[j]
        if Iso.blocksOverlap(a,b) then
          local axis = Iso.getSpaceSepAxis(a,b)
          if not axis then axis = "?" end
          local frontBlock = Iso.getFrontBlock(a,b)
          local fbname = "??"
          if frontBlock then fbname=frontBlock.name end
          love.graphics.print(a.name.." overlaps "..b.name.." sepAxis="..axis.." FRONT="..fbname,0,pry)
          pry = pry + 15
        end
      end
    end
  end

  love.graphics.pop()

  if model.drawHelp then
    local tx = 0
    local ty = 0
    local block = model.blockIndex[model.selectedBlock]
    love.graphics.print("Hit 'space' to cycle selected block: "..block.name, tx,ty)
    ty = ty + 15
    love.graphics.print("Hit 't' to toggle topo-sort: "..tostring(model.doSort), tx,ty)
    ty = ty + 15
    love.graphics.print("Hit 'r' to reload app", tx,ty)
    ty = ty + 15
    love.graphics.print("Use [wasdzx] to move block: "..block.pos.x..","..block.pos.y..","..block.pos.z, tx,ty)
    ty = ty + 15
    love.graphics.print("Use CTRL-[wasdzx] to resize block: "..block.size.x..","..block.size.y..","..block.size.z, tx,ty)
    ty = ty + 15
  end




end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
