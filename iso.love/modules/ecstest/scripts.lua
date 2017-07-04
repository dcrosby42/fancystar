local S = {}

-- Context structure: script, entity, estore, input, resources, args

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

-- local moverSpeed = 0.04
-- S.moverTest = function(context)
--   local e = context.entity
--   if e.controller.lefty ~= 0 then
--     local dy = e.controller.lefty * -moverSpeed
--     e.pos.y = e.pos.y + dy
--     if e.controller.lefty < 0 then
--       -- up left
--       e.isoSprite.dir = 'bl'
--       e.isoSprite.action = 'walk'
--     else
--       -- down right
--       e.isoSprite.dir = 'fr'
--       e.isoSprite.action = 'walk'
--     end
--   elseif e.controller.leftx ~= 0 then
--     local dx = e.controller.leftx * moverSpeed
--     e.pos.x = e.pos.x + dx
--     if e.controller.leftx > 0 then
--       -- up right
--       e.isoSprite.dir = 'br'
--       e.isoSprite.action = 'walk'
--     else
--       -- down left
--       e.isoSprite.dir = 'fl'
--       e.isoSprite.action = 'walk'
--     end
--   else
--       e.isoSprite.action = 'stand'
--   end
--   -- print("scripts.moverTest: dir="..e.isoSprite.dir.." action="..e.isoSprite.action)
-- end

return S
