local S = {}

-- local context = {
--   script='',
--   entity='',
--   estore='',
--   input='',
--   res='',
--   args={},
-- }
local tshirt_rotate_graph = {
  ["tshirt_guy.fl.stand.1"] = "tshirt_guy.bl.stand.1",
  ["tshirt_guy.bl.stand.1"] = "tshirt_guy.br.stand.1",
  ["tshirt_guy.br.stand.1"] = "tshirt_guy.fr.stand.1",
  ["tshirt_guy.fr.stand.1"] = "tshirt_guy.fl.stand.1",
}

S.rotateTshirtGuy = function (context)
  local e = context.entity
  if e.timers.rotate.alarm then
    e.isoSprite.picname = tshirt_rotate_graph[e.isoSprite.picname]
  end
end

local dir = "fr"
local tshirt_animate_graph = {
  ["tshirt_guy."..dir..".walk.1"] = "tshirt_guy."..dir..".walk.2",
  ["tshirt_guy."..dir..".walk.2"] = "tshirt_guy."..dir..".walk.1",
}

S.animateTshirtGuy = function (context)
  local e = context.entity
  if e.timers.animate.alarm then
    local next = tshirt_animate_graph[e.isoSprite.picname]
    if not next then
      next = "tshirt_guy.fl.stand.1"
    end
    e.isoSprite.picname = next
  end
end

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
  if opts.loop then
    local runtime = (opts.numFrames * opts.frameInterval)
    return function(t)
      return tlookup(t % runtime)
    end
  end
  return tlookup
end

local anim_tshirt_fr_walk = mkFlipbookAnimFunc({
  prefix="tshirt_guy.fl.walk.",
  numFrames=2,
  frameInterval=0.15,
  loop=true,
})

S.walkFR = function (context)
  local e = context.entity
  e.isoSprite.picname = anim_tshirt_fr_walk(e.timers.animation.t)
end

return S
