-- isoSpriteAnimSystem
return defineUpdateSystem(hasComps('isoSprite','isoSpriteAnimated','timer'), function(e,estore,input,resources)
  local timer = e.timers[e.isoSpriteAnimated.timer]
  local spriteDef = resources.sprites[e.isoSprite.id]
  if timer and spriteDef then
    e.isoSprite.picname = spriteDef.animBundle.picNameAtTime(e.isoSprite.action, e.isoSprite.dir, timer.t)
  end
end)
