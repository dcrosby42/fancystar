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
    ninja= {
      id="ninja",
      offset={x=0.3, y=0.3, z=0},
      size={x=0.6, y=0.6, z=1.6},
      imageOffset={x=48, y=123},
      animBundle={
        fallbackPicname='ninja.fl.stand.1',
        stand={
          fl={reduce='flipbook', opts={
            prefix="ninja.fl.stand.",
            numFrames=25,
            frameInterval=1/25,
          }},
          fr={reduce='flipbook', opts={
            prefix="ninja.fr.stand.",
            numFrames=25,
            frameInterval=1/25,
          }},
          br={reduce='flipbook', opts={
            prefix="ninja.br.stand.",
            numFrames=25,
            frameInterval=1/25,
          }},
          bl={reduce='flipbook', opts={
            prefix="ninja.bl.stand.",
            numFrames=25,
            frameInterval=1/25,
          }},
        },
        walk={
          fl={reduce='flipbook', opts={
            prefix="ninja.fl.walk.",
            numFrames=24,
            -- frameInterval=1/24,
            frameInterval=1/48,
          }},
          fr={reduce='flipbook', opts={
            prefix="ninja.fr.walk.",
            numFrames=24,
            -- frameInterval=1/24,
            frameInterval=1/48,
          }},
          br={reduce='flipbook', opts={
            prefix="ninja.br.walk.",
            numFrames=24,
            -- frameInterval=1/24,
            frameInterval=1/48,
          }},
          bl={reduce='flipbook', opts={
            prefix="ninja.bl.walk.",
            numFrames=24,
            -- frameInterval=1/24,
            frameInterval=1/48,
          }},
        }
      }
    },
    ninjatest= {
      id="ninjatest",
      offset={x=0.3, y=0.3, z=0},
      size={x=0.6, y=0.6, z=1.55},
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
      defaultPicname="blender_cube_96",
    },
    blockBlue = {
      id="blockBlue",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.Blue,
      defaultPicname="blender_cube_96",
    },
    blockGreen = {
      id="blockGreen",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.Green,
      defaultPicname="blender_cube_96",
    },
    blockWhite = {
      id="blockWhite",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
      defaultPicname="blender_cube_96",
    },
    blockYellow = {
      id="blockYellow",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.Yellow,
      defaultPicname="blender_cube_96",
    },
    blockGrass = {
      id="blockGrass",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
      defaultPicname="grass_block",
    },
    blockGrassPath1 = {
      id="blockGrassPath1",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
      defaultPicname="grass_block_path_1",
    },
    blockGrassPath2 = {
      id="blockGrassPath2",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
      defaultPicname="grass_block_path_2",
    },
    blockGrassPathCorner1 = {
      id="blockGrassCorner1",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
      defaultPicname="grass_block_path_corner_1",
    },
    blockGrassPathCorner2 = {
      id="blockGrassCorner2",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
      defaultPicname="grass_block_path_corner_2",
    },
    blockGrassPathCorner3 = {
      id="blockGrassCorner3",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
      defaultPicname="grass_block_path_corner_3",
    },
    blockGrassPathCorner4 = {
      id="blockGrassCorner4",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
      defaultPicname="grass_block_path_corner_4",
    },
    blockCrate = {
      id="blockCrate",
      offset={x=0, y=0, z=0},
      size={x=1, y=1, z=1},
      imageOffset={x=48, y=128},
      color=Colors.White,
      defaultPicname="crate",
    },
  }
end

return {
  load=load
}
