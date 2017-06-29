local R = {}

local function mkTimeLookupFunc(data)
  return function(t)
    local newVal = nil
    for i=1, #data, 2 do
      if t >= data[i] then
        newVal = data[i+1]
      else
        return newVal
      end
    end
    return newVal
  end
end

local function mkFlipbookAnimFunc(opts)
  -- Generate the datapoints:
  local data = {}
  local t = 0
  for i = 1,opts.numFrames do
    table.insert(data,t)
    table.insert(data, opts.prefix .. i)
    t = t + opts.frameInterval
  end

  local tlookup = mkTimeLookupFunc(data)
  if opts.loop ~= false then
    local runtime = (opts.numFrames * opts.frameInterval)
    return function(t)
      return tlookup(t % runtime)
    end
  end
  return tlookup
end

local Reducers = {
  flipbook=mkFlipbookAnimFunc
}

-- Walk through all the sprites' animBundles and generate a picNameAtTime() func
local function reduceSpriteAnimBundles(sprites)
  for sid,sprite in pairs(sprites) do
    if sprite.animBundle then
      for actionName,dirs in pairs(sprite.animBundle) do
        for dirName, animDef in pairs(dirs) do
          local reducer = Reducers[animDef.reduce]
          assert(reducer, "No animation reducer defined for '"..animDef.reduce.."'")
          animDef.picNameAtTime = reducer(animDef.opts)
        end
      end
    end
  end
end

local function load()
  local r = {}
  r.scripts = require 'modules.ecstest.scripts'
  r.sprites = require('data.sprites').load()
  reduceSpriteAnimBundles(r.sprites)
  return r
end

return {
  load=load
}
