local Pics = require 'data.pics'

local function newWorld()
  local model ={}
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
    model.animt = model.animt + action.dt
    model.animt2 = model.animt2 + action.dt
  end

  return model, nil
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
  love.graphics.draw(pic.image,pic.quad,x,y)
  x = x + pic.rect.w
  love.graphics.draw(pic2.image,pic2.quad,x,y)
  x = x + pic2.rect.w
  love.graphics.draw(pic3.image,pic3.quad,x,y)

  y = y + pic.rect.h
  x = 0
  love.graphics.setColor(255,255,255,100)
  love.graphics.draw(pic.image,pic.quad,x,y)
  love.graphics.draw(pic2.image,pic2.quad,x,y)
  love.graphics.draw(pic3.image,pic3.quad,x,y)
  love.graphics.setColor(255,255,255,255)

  y = y + pic.rect.h
  if model.animt < 1 then
    love.graphics.draw(pic.image,pic.quad,x,y)
  elseif model.animt < 2 then
    love.graphics.draw(pic2.image,pic2.quad,x,y)
  else
    love.graphics.draw(pic3.image,pic3.quad,x,y)
    if model.animt > 3 then
      model.animt = 0
    end
  end

  x = x + pic.rect.w
  if model.animt2 < 0.16 then
    love.graphics.draw(pic2.image,pic2.quad,x,y)
  else
    love.graphics.draw(pic3.image,pic3.quad,x,y)
    if model.animt2 > 0.32 then
      model.animt2 = 0
    end
  end
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
