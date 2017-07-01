local moverSpeed = 0.04
return defineUpdateSystem(hasComps('controller','isoSprite','isoSpriteAnimated'), function(e,estore,input,resources)
  if e.controller.lefty ~= 0 then
    local dy = e.controller.lefty * -moverSpeed
    e.isoPos.y = e.isoPos.y + dy
    if e.controller.lefty < 0 then
      -- up left
      e.isoSprite.dir = 'bl'
      e.isoSprite.action = 'walk'
    else
      -- down right
      e.isoSprite.dir = 'fr'
      e.isoSprite.action = 'walk'
    end
  elseif e.controller.leftx ~= 0 then
    local dx = e.controller.leftx * moverSpeed
    e.isoPos.x = e.isoPos.x + dx
    if e.controller.leftx > 0 then
      -- up right
      e.isoSprite.dir = 'br'
      e.isoSprite.action = 'walk'
    else
      -- down left
      e.isoSprite.dir = 'fl'
      e.isoSprite.action = 'walk'
    end
  else
      e.isoSprite.action = 'stand'
  end
  -- print("scripts.moverTest: dir="..e.isoSprite.dir.." action="..e.isoSprite.action)
end)
