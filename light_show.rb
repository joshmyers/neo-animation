# LightShow animations are sequences of frames. A frame is defined as a list of
# pixels (color values), but can be anything as long as its associated renderer
# knows what to do with them. For the console and neopixel renderers, frames are
# arrays of [r,g,b] values where r, g, and b are floating point values with the
# range of 0.0-1.0.
#
# Animation instances must implement a `frames` method, which returns an
# enumerator or enumeratable collection that responds to #each.
module LightShow

  # Return a frame of pixel_count pixels filled with the given color.
  def self.color_frame(pixel_count, r = 0, g = 0, b = 0)
    [[r, g, b]] * pixel_count
  end

  def self.rainbow(steps, offset=0)
    steps.times.map do |step|
      color_wheel step.to_f/steps + offset
    end
  end

  # Return r/g/b in for a value in the range (0.0, 1.0)
  def self.color_wheel(val)
    val -= val.floor if val < 0
    val -= val.floor if val > 1

    if val <= 1/3.0
      [val * 3, 1-val*3, 0]
    elsif val <= 2/3.0
      val -= 1/3.0
      [1 - val * 3, 0, val * 3]
    else
      val -= 2/3.0
      [0, val * 3, 1 - val * 3]
    end
  end
end

require_relative "light_show/animation"
require_relative "light_show/combination"
require_relative "light_show/animations/color_wipe"
require_relative "light_show/animations/fade_to_color"
require_relative "light_show/animations/interrupt"
require_relative "light_show/animations/rainbow"
require_relative "light_show/animations/rainbow_cycle"
require_relative "light_show/animations/solid_color"
require_relative "light_show/animations/theater_chase"
require_relative "light_show/animations/theater_chase_rainbow"
