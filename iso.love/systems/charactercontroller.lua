local moverSpeed = 0.04
return defineUpdateSystem(hasComps('controller','isoSprite','vel','isoSpriteAnimated'), function(e,estore,input,resources)
  e.vel.z = 0
  e.vel.x = 0
  e.vel.y = 0
  if e.controller.lefty ~= 0 then
    e.vel.y = e.controller.lefty * -moverSpeed
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
    e.vel.x = e.controller.leftx * moverSpeed
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
end)
