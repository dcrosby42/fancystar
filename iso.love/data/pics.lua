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

local function addAnimPics(stuff, imgname, name, defs)
  local anim = {}
  stuff.anims[name] = anim

  local img = stuff.images[imgname]

  for i,def in ipairs(defs) do
    local pathstr = def[1]
    local x,y,w,h = unpack(def[2])
    local picname = name .. "." .. pathstr
    local pic = {
      image=img,
      name=picname,
      quad=love.graphics.newQuad(x, y, w, h, img:getDimensions()),
      rect={x=x,y=y,w=w,h=h},
    }
    stuff.pics[picname] = pic

    local dir,action,frstr = unpack(split(pathstr,"."))
    local frnum = tonumber(frstr)
    anim[dir] = anim[dir] or {}
    anim[dir][action] = anim[dir][action] or {}
    anim[dir][action][frnum] = pic
  end
end

Pics.load = function()
  local images = loadAllImages()
  local pics = {}
  local anims = {}

  local stuff = {
    images=images,
    pics=pics,
    anims=anims,
  }

  addAnimPics(stuff, "tshirt_guy.png",
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

  return stuff
end

Pics.test=function() end

return Pics
