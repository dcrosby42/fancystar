
  print("save dir: "..love.filesystem.getSaveDirectory())
  print("user dir: "..love.filesystem.getUserDirectory())
  print("app dir: "..love.filesystem.getAppdataDirectory())
  files = love.filesystem.getDirectoryItems( "." )
  for _,file in ipairs(files) do
    print(file)
  end
  local myData = {
    one={two="three!"}
  }
  local myText = serialize(myData)
  love.filesystem.write("serialized.lua",myText,#myText)
  local chunk = love.filesystem.load("data.lua")
  local d = chunk()
  print(tdebug(d))
