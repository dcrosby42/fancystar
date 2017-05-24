local crozeng = require 'crozeng.main'

-- crozeng.module_name = 'modules/devui'
-- crozeng.module_name = 'modules/isoblockdemo'
crozeng.module_name = 'modules/isoblockdemo2'

crozeng.onload = function()
  love.window.setMode(800, 600, {
    resizable=true,
    minwidth=400,
    minheight=300,
    highdpi=false
  })
  -- print("Pixelscale: "..love.window.getPixelScale())
end
