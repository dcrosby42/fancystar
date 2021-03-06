local Newui = require 'modules/newui'
local Editor = require 'modules/editor'
local Editor2 = require 'modules/editor2'
local Animtest = require 'modules/animtest'
local EcsTest = require 'modules/ecstest'

local function newModuleSub(module,key)
  local state = module.newWorld()
  return {key=key, module=module, state=state}
end

local function newWorld(opts)
  opts = opts or {}
  local model ={
    subs={
      ecstest=newModuleSub(EcsTest,"f1"),
      editor2=newModuleSub(Editor2,"f2"),
      editor=newModuleSub(Editor,"f3"),
      animtest=newModuleSub(Animtest,"f4"),
      newui=newModuleSub(Newui,"f5"),
    },
  }
  model.current = opts.current or "editor2"
  return model
end

local function updateWorld(model,action)
  if action.type == 'keyboard' then
    if action.state == 'pressed' then
      for k,sub in pairs(model.subs) do
        if sub.key == action.key then
          model.current = k
          print("Switcher: '"..k.."'")
          if action.gui then
            print("Switcher: resetting world state")
            local sub = model.subs[model.current]
            sub.state = sub.module.newWorld()
          end
          return model, nil
        end
      end
      if action.key == 'escape' then
        return model, {{type="crozeng.reloadRootModule", opts={current=model.current}}}
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
