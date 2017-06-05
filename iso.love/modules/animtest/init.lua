local Pics = require 'data.pics'

local function newWorld()
  local model ={}
  model.t = 0
  model.animt = 0
  model.animt2 = 0
  model.p = Pics.load()

  -- model.allImages = Pics.picAtanims

  model.dude = {
    -- timer={t=0},
    pic={name="tshirt_guy"},
    -- anim={name='dude'}
  }
  return model
end

local function updateWorld(model,action)
  if action.type == 'tick' then
    model.t = model.t + action.dt
    model.animt = model.animt + action.dt
    model.animt2 = model.animt2 + action.dt
  end

  return model, nil
end

local function drawAnimDebug(anim, label, x,y, t)
  love.graphics.print(label,x,y)
  y = y + 15
  local topy = y

  -- Animate at 1 fps
  local lt = (t % #anim) + 1
  local fidx = math.floor(lt)
  local pic = anim[fidx]
  love.graphics.draw(pic.image, pic.quad, x,y)
  y = y + pic.rect.h
  love.graphics.print(""..fidx.." ("..math.round(lt,2)..")", x,y)
  y = topy

  x = x + anim[1].rect.w + 20

  -- Draw the individual frames:
  for i,pic in ipairs(anim) do
    love.graphics.draw(pic.image, pic.quad, x,y)
    y = y + pic.rect.h
    -- love.graphics.print(pic.name,x,y)
    love.graphics.print(i,x,y)
    x = x + pic.rect.w + 1
    y = topy
  end



  y = y + anim[1].rect.h + 15
  x = 0

  return x,y
end

local function drawWorld(model)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(255,255,255)

  -- local img = model.p.images["tshirt_guy.png"]
  local pic = model.p.pics["tshirt_guy.fl.stand.1"]
  local pic2 = model.p.pics["tshirt_guy.fl.walk.1"]
  local pic3 = model.p.pics["tshirt_guy.fl.walk.2"]
  -- print(tdebug(model.p.pics))
  local x = 0
  local y = 0
  x,y = drawAnimDebug(model.p.anims.tshirt_guy.fl.stand, "tshirt_guy.fl.stand",x,y, model.t)
  x,y = drawAnimDebug(model.p.anims.tshirt_guy.fl.walk, "tshirt_guy.fl.walk",x,y, model.t)
  x,y = drawAnimDebug(model.p.anims.tshirt_guy.fr.stand, "tshirt_guy.fr.stand",x,y, model.t)
  x,y = drawAnimDebug(model.p.anims.tshirt_guy.fr.walk, "tshirt_guy.fr.walk",x,y, model.t)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
