local DataLoader = require 'dataloader'

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
  print(tdebug(loadAllImages()))
end

return {
  test=test
}
