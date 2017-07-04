

return defineUpdateSystem(hasComps('gravity','vel'), function(e, estore, input,res)
  if e.adjacents and e.adjacents.bottom then
    -- nothing
  else
    e.vel.z = e.vel.z - 0.1
  end
end)
