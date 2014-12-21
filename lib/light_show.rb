# LightShow animations are sequences of frames. A frame is defined as a list of
# pixels (color values), but can be anything as long as its associated renderer
# knows what to do with them. For the console and neopixel renderers, frames are
# arrays of [r,g,b] values where r, g, and b are floating point values with the
# range of 0.0-1.0.
#
# Animation instances must implement an `each_frame` method which takes a
# previous frame value as an argument. `each_frame` may yield subsequent frames,
# which will then be rendered.
module LightShow
end
