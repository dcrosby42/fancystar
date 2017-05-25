
local function newModuleSub(modname,key)
  print("newModuleSub: "..modname)
  local module = require("modules."..modname)
  local state = module.newWorld()
  return {name=modname, key=key, module=module, state=state}
end

local function newWorld()
  local model ={
    subs={
      template=newModuleSub("template","f1"),
      newui=newModuleSub("newui","f2"),
      -- devui=newModuleSub("devui","f3"),
    },
    current="template",
  }
  return model
end

local function updateWorld(model,action)
  if action.type == 'keyboard' then
    if action.state == 'pressed' then
      for k,sub in pairs(model.subs) do
        if sub.key == action.key then
          model.current = k
          if action.gui then
            local sub = model.subs[model.current]
            sub.state = sub.module.newWorld()
          end
          return model, nil
        end
      end
    end
  end
  local sub = model.subs[model.current]
  newstate, fx = sub.module.updateWorld(sub.state, action)
  sub.state = newstate
  return model, fx
end

local function drawWorld(model)
  local sub = model.subs[model.current]
  sub.module.drawWorld(sub.state)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
