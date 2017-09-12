local Widgets = {}

local function num2str(num)
  return tostring(math.round(num,3))
end

Widgets.Vector3 = function(suit, label, vec, scratch)
  local rstate = {
    changed=false
  }
  suit.layout:push(suit.layout:row())
  suit.Label(label, suit.layout:row(50,30))
  if scratch.editing then
    local xin = suit.Input(scratch.x, {id=label.."x"}, suit.layout:col())
    local yin = suit.Input(scratch.y, {id=label.."y"}, suit.layout:col())
    local zin = suit.Input(scratch.z, {id=label.."z"}, suit.layout:col())
    local save = suit.Button("s", {id=label.."s"}, suit.layout:col(15))
    if suit.Button("c", {id=label.."c"}, suit.layout:col()).hit then
      scratch.editing = false
    end
    if xin.submitted or yin.submitted or zin.submitted or save.hit then
      scratch.editing = false
      vec.x = tonumber(scratch.x.text)
      vec.y = tonumber(scratch.y.text)
      vec.z = tonumber(scratch.z.text)
      rstate.changed = true
    end
  else
    local xin = suit.Label(num2str(vec.x), suit.layout:col())
    local yin = suit.Label(num2str(vec.y), suit.layout:col())
    local zin = suit.Label(num2str(vec.z), suit.layout:col())
    local bt = suit.Button("e", {id=label.."e"},suit.layout:col(15))
    if bt.hit or xin.hit or yin.hit or zin.hit then
      scratch.editing = true
      scratch.x.text = num2str(vec.x)
      scratch.y.text = num2str(vec.y)
      scratch.z.text = num2str(vec.z)
    end
  end
  suit.layout:pop()
  return rstate
end

  -- maya1= {
  --   type="sprite",
  --   id="maya1",
  --   name="Maya",
  --   image={name=Maya, offx=38, offy=114},
  --   offp={x=0.5, y=0.5, z=0},
  --   size={x=0.6, y=0.6, z=1.55},
  --   debug={color=Colors.White},
  -- }
Widgets.Sprite = function(suit, label, spr, scratch)
  local rstate = {
    changed=false
  }
  suit.Label(label..":", suit.layout:row())
  -- local nameW = Widgets.(suite,"Name", spr.image.name, )
  local sizeW = Widgets.Vector3(suit,"Size", spr.size, scratch.size)
  local offpW = Widgets.Vector3(suit,"Offp", spr.offp, scratch.offp)

  rstate.changed = sizeW.changed or offpW.changed
  return rstate
end


return Widgets
