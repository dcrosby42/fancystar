local crozeng = require 'crozeng.main'

-- crozeng.module_name = 'modules/devui'
-- crozeng.module_name = 'modules/isoblockdemo'
-- crozeng.module_name = 'modules/isoblockdemo2'
-- crozeng.module_name = 'modules/newui'
crozeng.module_name = 'modules/switcher'

crozeng.onload = function()
  love.window.setMode(1024, 768, {
    resizable=true,
    minwidth=400,
    minheight=300,
    highdpi=false
  })
  -- print("Pixelscale: "..love.window.getPixelScale())
end
