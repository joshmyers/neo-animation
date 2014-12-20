# NEXT: combining, and iteration based on previous frames.

class Animation
  def initialize
    @animations = []
    @loop = nil
    @delay_ms = 0
    yield self
  end

  def delay_ms(ms)
    @delay_ms = ms
  end

  def forever
    raise ArgumentError, "there's only one forever!" if @loop
    @forever = true
    @loop = []
  end

  def <<(anim)
    anim = Delayed.new(@delay_ms, anim) if @delay_ms && @delay_ms > 0
    if @forever
      @loop << anim
    else
      @animations << anim
    end
  end

  def each(&block)
    iterate_frames @animations, &block

    if @loop && @loop.any?
      loop { iterate_frames @loop, &block }
    end
  end

  protected

  def iterate_frames(animations)
    animations.each do |animation|
      animation.each { |frame| yield frame }
    end
  end
end

class Delayed
  def initialize(ms, animation)
    @ms = ms
    @animation = animation
  end

  def each
    @animation.each do |frame|
      yield frame
      sleep @ms/1000.0
    end
  end
end

class Value
  def initialize(color)
    @color = color
  end

  def each
    yield @color
  end
end

class Timestamp
  def each
    yield Time.now.iso8601
  end
end

class Flagged
  def initialize(anim)
    @anim = anim
    @flag = false
  end

  def flag!
    @flag = true
  end

  def each
    @anim.each do |frame|
      break if @flag
      yield frame
    end
  end
end

bounce = Animation.new do |a|
  0.upto(5) { |n| a << Value.new(n) }
  4.downto(1) { |n| a << Value.new(n) }
end

main = Animation.new do |a|
  a.delay_ms 50
  a << bounce
  a.delay_ms 200
  a << bounce
  a.delay_ms 1000
  a.forever
  a << Timestamp.new
end

shutdown = Animation.new do |a|
  a.delay_ms 10
  a << Value.new("shutting down...")
  5.downto(1).each do |n|
    a << Value.new(n)
  end
end

render = lambda { |frame| puts "frame: #{frame}" }

flagged = Flagged.new(main)

trap("INT") do
  flagged.flag!
  shutdown.each(&render)
end

flagged.each(&render)
