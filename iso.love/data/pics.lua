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

local function test()
end

local function buildPic(stuff, imgname,name,pathstr,rect)
  local img = stuff.images[imgname]
  local x,y,w,h = unpack(rect or {})
  if x == nil then
    x = 0
    y = 0
  end
  if w == nil then
    w = img:getWidth()
    h = img:getHeight()
  end
  local picname = name .. "." .. pathstr
  local pic = {
    image=img,
    name=picname,
    quad=love.graphics.newQuad(x, y, w, h, img:getDimensions()),
    rect={x=x,y=y,w=w,h=h},
  }
  stuff.pics[picname] = pic
  return pic
end

local function updateFrameset(stuff, name, pathstr, pic)
  local dir,action,frstr = unpack(split(pathstr,"."))
  local frnum = tonumber(frstr)

  stuff.framesets[name] = stuff.framesets[name] or {}
  local frameset = stuff.framesets[name]
  frameset[dir] = frameset[dir] or {}
  frameset[dir][action] = frameset[dir][action] or {}
  frameset[dir][action][frnum] = pic
  return frameset
end

local function buildPicAndFrameset(stuff,imgname,name,pathstr,rect)
  local pic = buildPic(stuff,imgname,name,pathstr,rect)
  frameset = updateFrameset(stuff,name,pathstr,pic)
end

local function buildPicsAndFramesets(stuff, imgname, name, defs)
  for i,def in ipairs(defs) do
    local pathstr,rect = unpack(def)
    buildPicAndFrameset(stuff, imgname, name, pathstr, rect)
  end
end

Pics.load = function()
  local images = loadAllImages()
  local pics = {}
  local framesets = {}

  local stuff = {
    images=images,
    pics=pics,
    framesets=framesets,
  }

  buildPicAndFrameset(stuff, "maya_trans.png", "maya", "fl.stand.1")

  buildPicAndFrameset(stuff, "freya_trans.png", "freya", "fl.stand.1")

  buildPicsAndFramesets(stuff, "tshirt_guy.png",
    "tshirt_guy", {
    {'fl.stand.1', {104,158, 50,100}},

    {'fl.walk.1', {40,158, 50,100}},
    {'fl.walk.2', {168,158, 50,100}},

    {'fr.stand.1', {102,287, 50,100}},

    {'fr.walk.1', {40,287, 50,100}},
    {'fr.walk.2', {168,287, 50,100}},

    {'bl.stand.1', {102,543, 50,100}},

    {'bl.walk.1', {40,543, 50,100}},
    {'bl.walk.2', {168,543, 50,100}},

    {'br.stand.1', {328,543, 50,100}},

    {'br.walk.1', {262,543, 50,100}},
    {'br.walk.2', {390,543, 50,100}},
  })

  -- print(tdebug(pics))
  -- print(tdebug(framesets))
  return stuff
end

Pics.test=function() end

return Pics
