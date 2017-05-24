require 'crozeng/helpers'
local Colors = require 'colors'
local Iso = require 'iso'
local spaceToScreen = Iso.spaceToScreen
local spaceToScreen_ = Iso.spaceToScreen_
local newBlock = Iso.newBlock
local IsoDebug = require 'isodebug'

local BlenderCube96 = "images/blender_cube_96.png"


local function newSprite(name,imgInfo,pos,size)
  local sprite = newBlock(pos,size,Color.White,name)
  sprite.type = "sprite"
  sprite.image = imgInfo
  return sprite
end

local function addCubeSprite(model)
  local s = newBlock({x=0, y=0, z=0}, {x=1,y=1,z=1}, Colors.White, "cubeSprite")
  s.type = "sprite"
  local img = model.images[BlenderCube96]
  s.image = {
    name = BlenderCube96,
    offx = img:getWidth() / 2,
    offy = img:getHeight(),
    width = img:getWidth(),
    height = img:getHeight(),
  }
  table.insert(model.blocks, s)
end

local function newWorld()

  local blocks = {
    newBlock({x=1,y=1,z=0},{x=1,y=2,z=0.3}, Colors.Blue, "Blue"),
    newBlock({x=2,y=2,z=0},{x=1,y=2,z=1.25}, Colors.Red, "Red"),
    newBlock({x=4,y=0,z=0},{x=1,y=1,z=1}, Colors.Yellow, "Yellow"),
  }

  local model ={
    viewoff={x=400,y=300},
    blocks = blocks,
    selectedBlock = 1,
    doSort = true,
    drawSpriteGeom=true,
    images = {},
  }

  model.images[BlenderCube96] = love.graphics.newImage(BlenderCube96)

  addCubeSprite(model)

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

    elseif action.key == 'b' then
      model.drawSpriteGeom = not model.drawSpriteGeom

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
  love.graphics.draw(
    img,
    x,y,
    0,                                 -- rotation
    1,1,                               -- scalex,scaley
    offx, offy -- xoff,yoff
  )
  if model.drawSpriteGeom then
    love.graphics.setColor(255,0,0)
    love.graphics.points(x,y)
    love.graphics.rectangle("line",x-offx,y-offy,block.image.width,block.image.height)
  end
  love.graphics.setColor(unpack(Colors.White))
end

local function drawWorld(model)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.push()
  love.graphics.translate(model.viewoff.x,model.viewoff.y)

  IsoDebug.drawFloorGrid()

  local blocks = model.blocks
  if model.doSort then
    blocks = Iso.sortBlocks(blocks)
  end

  for i=1,#blocks do
    if blocks[i].type == "sprite" then
      drawSprite(model, blocks[i])
      if model.drawSpriteGeom then
        IsoDebug.drawBlock(blocks[i])
      end
    else
      IsoDebug.drawBlock(blocks[i])
    end
    IsoDebug.drawBlockSil(blocks[i])
  end

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

  love.graphics.pop()

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

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
