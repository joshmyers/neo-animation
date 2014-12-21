$:.unshift "./lib"
require "lightshow"
require "lightshow/console_renderer"

class Every
  def initialize(interval)
    @interval = interval
    @t = 0
  end

  def tick(t)
    @t += t
    if @t >= @interval
      @t -= @interval
      yield
    end
  end
end

class Animations
  def initialize(pixels, animations)
    @animations = animations
    current.reset(pixels)
  end

  def current
    @animations.first
  end

  def next?
    current.done?
  end

  def rotate
    pixels = current.pixels
    @animations.rotate!
    current.reset(pixels)
    current
  end
end

class Wipe
  attr_reader :pixels

  def initialize(color, direction=:up)
    @color     = color
    @direction = direction
    reset nil
  end

  def reset(pixels)
    @pixels = pixels
    @step = 0
  end

  def done?
    @step == @pixels.length
  end

  def next
    return @pixels if done?
    if @direction == :up
      @pixels[@step] = @color
    else
      @pixels[@pixels.length - @step - 1] = @color
    end
    @step += 1
    @pixels
  end
end

class Fade
  def initialize(target_color, steps)
    @target_color = target_color
    @steps = steps
    @frames = []
  end

  def reset(pixels)
    @frames = 0.upto(@steps).map do |step|
      t = step.to_f/@steps
      pixels.map do |pixel|
        lerp(pixel, @target_color, t)
      end
    end
  end

  def done?
    @frames.size <= 1
  end

  def next
    @frames.shift unless done?
    pixels
  end

  def pixels
    @frames.first
  end

  def lerp(from, to, t)
    from.zip(to).map do |a,b|
      a + (b - a) * t
    end
  end

end

class Reverse
  attr_reader :pixels
  def initialize(renderer)
    @renderer = renderer
  end
  def reset(pixels)
    @pixels = pixels
    @done = false
  end
  def done?
    @done
  end
  def next
    @done = true
    @renderer.reverse = !@renderer.reverse
    @pixels
  end
end

class Offset
  attr_reader :pixels
  def initialize(renderer)
    @renderer = renderer
  end
  def reset(pixels)
    @pixels = pixels
    @done = false
  end
  def done?
    @done
  end
  def next
    @done = true
    @renderer.offset = (@renderer.offset + 1) % pixels.length
    @pixels
  end
end

fps = 48
delay = 1.0/fps
pixels = [[0,0,0]] * 24
renderer = Lightshow::ConsoleRenderer.new

trap("INT") {
  print "\r"
  wipe = Fade.new([0,0,0], 10)
  wipe.reset pixels
  while !wipe.done?
    renderer.render wipe.next
    sleep delay
  end
  puts
  exit
}

animations = Animations.new pixels, [
  Wipe.new([1,0,0]),
  Wipe.new([0,1,0]),
  Wipe.new([0,0,1]),
  # Fade.new([1,1,1], 10),
  Fade.new([0,0,0], 10),
  Reverse.new(renderer),
  Offset.new(renderer)
]
interval = Every.new(1.0/pixels.size)

loop do
  anim = animations.current
  interval.tick(delay) do
    pixels = anim.next
    renderer.render pixels
  end
  animations.rotate if animations.next?
  sleep delay
end
