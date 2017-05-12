-- local tile_img_w = 64
function calc_tile_side_from_image_width(imgw)
  return math.pow(math.pow(imgw,2) / 2, 0.5)
end

ZRatio = 40 / calc_tile_side_from_image_width(64)
print(ZRatio)
-- print(tile_img_w)
-- print(tile_side)
-- print(40/tile_side)

tile_img_w = 64
tile_side = calc_tile_side_from_image_width(tile_img_w)
zfactor = ZRatio * tile_side
print(tile_img_w)
print(tile_side)
print(zfactor)



