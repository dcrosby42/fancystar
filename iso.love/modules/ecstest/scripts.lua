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


-- S.walkFR = function (context)
--   local e = context.entity
--   e.isoSprite.picname = anim_tshirt_fr_walk(e.timers.animation.t)
-- end
--
S.doTheAnim = function (context)
  local e = context.entity
  local sp = e.isoSprite
  local spriteDef = context.resources.sprites[sp.id]
  local t = e.timers.animation.t
  -- e.isoSprite.picname = anim_tshirt_fr_walk(e.timers.animation.t)
  e.isoSprite.picname = spriteDef.animBundle[sp.action][sp.dir].picNameAtTime(t)
end

return S
