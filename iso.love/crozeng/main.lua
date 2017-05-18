-- Enable loading a dir as a package via ${package}/init.lua
package.path = package.path .. ";./?/init.lua"

require 'crozeng.helpers'
local ModuleLoader = require 'crozeng.moduleloader'

local DefaultConfig = {
  width = love.graphics.getWidth(),
  height = love.graphics.getHeight(),
}

local Config = DefaultConfig

local Hooks = {}

local RootModule
local world

function loadItUp(opts)
  if not opts then opts={} end
  Config = tcopy(DefaultConfig)
  if Hooks.module_name then
    RootModule = ModuleLoader.load(Hooks.module_name)
    ModuleLoader.debug_deps()
  elseif Hooks.module then
    RootModule = Hooks.module
  end
  if not RootModule then
    error("Please specify Hooks.module_name or Hooks.module")
  end
  if not RootModule.newWorld then error("Your module must define a .newWorld() function") end
  if not RootModule.updateWorld then error("Your module must define an .updateWorld() function") end
  if not RootModule.drawWorld then error("Your module must define a .drawWorld() function") end


  if opts.doOnload ~= false then
    if Hooks.onload then
      Hooks.onload()
    end
    Config.width = love.graphics.getWidth()
    Config.height = love.graphics.getHeight()
  end

  world = RootModule.newWorld(Hooks.moduleOpts)
end

local function reloadRootModule()
  if Hooks.module_name then
    local names = ModuleLoader.list_deps_of(Hooks.module_name)
    for i=1,#names do
      ModuleLoader.uncache_package(names[i])
    end
    ModuleLoader.uncache_package(Hooks.module_name)


    ok,err = pcall(function() loadItUp({doOnload=false}) end)
    if not ok then
      print("crozeng: RELOAD FAIL!")
      print(err)
      print(debug.traceback())
    end
  end
end

function love.load()
  loadItUp()
end

local function updateWorld(action)
  local newworld, sidefx = RootModule.updateWorld(world, action)
  if newworld then
    world = newworld
  end
  if sidefx then
    for i=1,#sidefx do
      if sidefx[i].type == 'crozeng.reloadRootModule' then
        reloadRootModule()
      end
    end
  end
end

local dtAction = {type="tick", dt=0}
function love.update(dt)
  dtAction.dt = dt
  updateWorld(dtAction)
end

function love.draw()
  RootModule.drawWorld(world)
end

--
-- INPUT EVENT HANDLERS
--
-- NOTE: I reuse these template actions for "efficiency" however
-- this means RootModule.updateWorld must NOT store references to them. :(
-- TODO: just generate a new action structure each time to avoid potential errors.
local keyboardAction = {type="keyboard", action='', key='', ctrl=false, lctrl=false, lctrl=false, shift=false, lshift=false, lshift=false,  gui=false, lgui=false, lgui=false}
local function toKeyboardAction(state,key)
  keyboardAction.state=state
  keyboardAction.key=key
  for _,mod in ipairs({"ctrl","shift","gui"}) do
    keyboardAction[mod] = false
    keyboardAction["l"..mod] = false
    keyboardAction["r"..mod] = false
    if love.keyboard.isDown("l"..mod) then
      keyboardAction["l"..mod] = true
      keyboardAction[mod] = true
    elseif love.keyboard.isDown("r"..mod) then
      keyboardAction["r"..mod] = true
      keyboardAction[mod] = true
    end
  end
  return keyboardAction
end
function love.keypressed(key, _scancode, _isrepeat)
  updateWorld(toKeyboardAction("pressed",key))
end
function love.keyreleased(key, _scancode, _isrepeat)
  updateWorld(toKeyboardAction("released",key))
end

local mouseAction = {type="mouse", state=nil, x=0, y=0, dx=0,dy=0,button=0, isTouch=0}
function toMouseAction(s,x,y,b,it,dx,dy)
  mouseAction.state=s
  mouseAction.x=x
  mouseAction.y=y
  mouseAction.button=b
  mouseAction.isTouch=it
  mouseAction.dx=dx
  mouseAction.dy=dy
  return mouseAction
end

function love.mousepressed(x,y, button, isTouch, dx, dy)
  updateWorld(toMouseAction("pressed",x,y,button,isTouch))
end

function love.mousereleased(x,y, button, isTouch)
  updateWorld(toMouseAction("released",x,y,button,isTouch))
end

function love.mousemoved(x,y, dx,dy, isTouch)
  updateWorld(toMouseAction("moved",x,y,nil,isTouch,dx,dy))
end

local touchAction = {type="touch", state=nil, id='', x=0, y=0, dx=0, dy=0}
function toTouchAction(s,id,x,y,dx,dy)
  touchAction.state= s
  touchAction.id = id
  touchAction.x=x
  touchAction.y=y
  touchAction.dx=dx
  touchAction.dy=dy
  return touchAction
end

function love.touchpressed(id, x,y, dx,dy, pressure)
  updateWorld(toTouchAction("pressed",id,x,y,dx,dy))
end
function love.touchmoved(id, x,y, dx,dy, pressure)
  updateWorld(toTouchAction("moved",id,x,y,dx,dy))
end
function love.touchreleased(id, x,y, dx,dy, pressure)
  updateWorld(toTouchAction("released",id,x,y,dx,dy))
end

local joystickAction = {type="joystick", id='TODO', controlType='', control='', value=0}
function toJoystickAction(controlType, control, value)
  joystickAction.id = 'TODO'
  joystickAction.controlType=controlType
  joystickAction.control=control
  joystickAction.value=(value or 0)
  return joystickAction
end

function love.joystickaxis( joystick, axis, value )
  updateWorld(toJoystickAction("axis", axis, value))
end

function love.joystickpressed( joystick, button )
  updateWorld(toJoystickAction("button",button,1))
end

function love.joystickreleased( joystick, button )
  updateWorld(toJoystickAction("button", button,0))
end

function love.resize(w,h)
  updateWorld({type='resize',w=w, h=h})
end

return Hooks
