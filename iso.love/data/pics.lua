local DataLoader = require 'dataloader'
local Pics = {}

local function loadAllImages()
  local imgsByName = {}
  local imgfiles = DataLoader.listAssetFiles("images")
  for _,fname in ipairs(imgfiles) do
    local name = fname:match("images/(.+)")
    imgsByName[name] = love.graphics.newImage(fname)
  end
  return imgsByName
end

-- CharAnimMap : name face action frame#
local function test()
  local all = loadAllImages()
  print(tdebug(all))
end

Pics.load = function()
  local images = loadAllImages()
  local pics = {}

  local img = images["tshirt_guy.png"]
  local x = 104
  local y = 158
  local w = 50
  local h = 100
  pics["tshirt_guy.fl.stand.1"] = {
    image=img,
    quad=love.graphics.newQuad(x, y, w, h, img:getDimensions()),
    rect={x=x,y=y,w=w,h=h},
  }
  x = 40
  pics["tshirt_guy.fl.walk.1"] = {
    image=img,
    quad=love.graphics.newQuad(x, y, w, h, img:getDimensions()),
    rect={x=x,y=y,w=w,h=h},
  }
  x = 168
  pics["tshirt_guy.fl.walk.2"] = {
    image=img,
    quad=love.graphics.newQuad(x, y, w, h, img:getDimensions()),
    rect={x=x,y=y,w=w,h=h},
  }
  return {
    images=images,
    pics=pics,
  }
end

Pics.test=function() end

return Pics
