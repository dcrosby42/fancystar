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

return S
