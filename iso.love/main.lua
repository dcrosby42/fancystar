local crozeng = require 'crozeng.main'

crozeng.module = require 'modules/devui'

crozeng.onload = function()
  love.window.setMode(1024,768)
end
