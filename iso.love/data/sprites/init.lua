local Colors = require "colors"
local function load()
  return {
    maya1= {
      id="maya1",
      offset={x=0.3, y=0.3, z=0},
      size={x=0.6, y=0.6, z=1.55},
      imageOffset={x=38, y=114},
    },
    freya1= {
      id="freya1",
      offset={x=0.35, y=0.3, z=0},
      size={x=0.7, y=0.6, z=1.55},
      imageOffset={x=38, y=114},
    },
    tshirt_guy= {
      id="tshirt_guy",
      -- offset={x=0.30, y=0.3, z=0},
      offset={x=0.2, y=0.2, z=0},
      size={x=0.4, y=0.4, z=1.45},
      -- imageOffset={x=24, y=108},
      imageOffset={x=23, y=102},
      animBundle={
        fallbackPicname='tshirt_guy.fl.stand.1',
        stand={
          fr={reduce='flipbook', opts={
            prefix="tshirt_guy.fr.stand.",
            numFrames=1,
            frameInterval=0.15,
          }},
          fl={reduce='flipbook', opts={
            prefix="tshirt_guy.fl.stand.",
            numFrames=1,
            frameInterval=0.15,
          }},
          br={reduce='flipbook', opts={
            prefix="tshirt_guy.br.stand.",
            numFrames=1,
            frameInterval=0.15,
          }},
          bl={reduce='flipbook', opts={
            prefix="tshirt_guy.bl.stand.",
            numFrames=1,
            frameInterval=0.15,
          }},
        },
        walk={
          fr={reduce='flipbook', opts={
            prefix="tshirt_guy.fr.walk.",
            numFrames=2,
            frameInterval=0.15,
          }},
          fl={reduce='flipbook', opts={
            prefix="tshirt_guy.fl.walk.",
            numFrames=2,
            frameInterval=0.15,
          }},
          br={reduce='flipbook', opts={
            prefix="tshirt_guy.br.walk.",
            numFrames=2,
            frameInterval=0.15,
          }},
          bl={reduce='flipbook', opts={
            prefix="tshirt_guy.bl.walk.",
            numFrames=2,
            frameInterval=0.15,
          }},
        }
      }
    },
    blockRed = {
      id="blockRed",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.Red,
    },
    blockBlue = {
      id="blockBlue",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.Blue,
    },
    blockGreen = {
      id="blockGreen",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.Green,
    },
    blockWhite = {
      id="blockWhite",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
    },
    blockYellow = {
      id="blockYellow",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.Yellow,
    },
  }
end

return {
  load=load
}
