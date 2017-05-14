local crozeng = require 'crozeng.main'

crozeng.module_name = 'modules/devui'

crozeng.onload = function()
  love.window.setMode(1024, 768, {
    resizable=true,
    minwidth=400,
    minheight=300,
    highdpi=false
  })
  -- print("Pixelscale: "..love.window.getPixelScale())
end
