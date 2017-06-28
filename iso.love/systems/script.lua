
-- Script system

local context = {
  script='',
  entity='',
  estore='',
  input='',
  res='',
  args={},
}

return defineUpdateSystem(hasComps('script'), function(e,estore,input,res)
  if e.script.on == 'tick' then
    local scriptFunc = res.scripts[e.script.scriptName]
    if scriptFunc then
      context.script = script
      context.entity = e
      context.estore = estore
      context.input = input
      context.res = res
      context.args = {}
      scriptFunc(context)
    else
      print("ScriptSystem: entity "..e.eid.."scriptName '"..e.script.scriptName.."' is not registered")
    end
  end
end)
