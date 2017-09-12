local Pics = require 'data.pics'

local function handleMouse(model,action)
  if action.state == 'moved' then
    if model.mouse.down then
      if model.mouse.pan then
        model.view.x = model.view.x + action.dx
        model.view.y = model.view.y + action.dy
      end
    end
  elseif action.state == 'pressed' then
    model.mouse.down = true
    if action.button == 1 then
      model.mouse.pan = true
    else
      model.mouse.move = true
    end
  elseif action.state == 'released' then
    model.mouse.down = false
    model.mouse.move = false
    model.mouse.pan = false
  end
end

local function drawFramesetDebug(frameset, label, x,y, t)
  love.graphics.print(label,x,y)
  y = y + 15
  local topy = y

  -- Animate at 1 fps
  local lt = (t % #frameset) + 1
  local fidx = math.floor(lt)
  local pic = frameset[fidx]
  love.graphics.draw(pic.image, pic.quad, x,y)
  y = y + pic.rect.h
  love.graphics.print(""..fidx.." ("..math.round(lt,2)..")", x,y)
  y = topy

  x = x + frameset[1].rect.w + 20

  -- Draw the individual frames:
  for i,pic in ipairs(frameset) do
    love.graphics.draw(pic.image, pic.quad, x,y)
    y = y + pic.rect.h
    -- love.graphics.print(pic.name,x,y)
    love.graphics.print(i,x,y)
    x = x + pic.rect.w + 1
    y = topy
  end

  y = y + frameset[1].rect.h + 15 + 15
  x = 0

  return x,y
end

local function drawCharacterFramesetDebug(framesets, framesetName, x,y, t)
  local char = framesets[framesetName]
  for dir,actions in pairs(char) do
    for action,frames in pairs(actions) do
      x,y = drawFramesetDebug(frames, framesetName.."."..dir.."."..action, x,y, t)
    end
  end
  return x,y
end

local function newWorld()
  local model ={}
  model.t = 0
  model.view={x=0, y=0, scale=1.5, zoomInc=0.25}
  model.mouse={down=false,pan=false,move=false}

  model.p = Pics.load()

  return model
end

local function updateWorld(model,action)
  if action.type == 'tick' then
    model.t = model.t + action.dt

  elseif action.type == "mouse" then
    handleMouse(model,action)
  end

  return model, nil
end


local function drawWorld(model)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(255,255,255)

  love.graphics.push()
  love.graphics.translate(model.view.x, model.view.y)
  -- love.graphics.scale(model.view.scale,model.view.scale)

  local x,y = drawCharacterFramesetDebug(model.p.framesets, "maya",0,0, model.t)
  local x,y = drawCharacterFramesetDebug(model.p.framesets, "freya",x,y, model.t)
  local x,y = drawCharacterFramesetDebug(model.p.framesets, "ninjatest",x,y, model.t)
  local x,y = drawCharacterFramesetDebug(model.p.framesets, "tshirt_guy",x,y, model.t)
  local x,y = drawCharacterFramesetDebug(model.p.framesets, "ninja",x,y, model.t*48)

  love.graphics.pop()
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
