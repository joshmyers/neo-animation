# A demonstration/exploration of generating animation "frames" by combining
# objects that emit sequences of frames, with the following goals:
#
# * Declarative syntax for convenience and readability
# * Composability, for easily assembling larger animations from smaller pieces
# * Interruptability (see Flagged), so an animation sequence can be interrupted
# * Lazily-evaluated combinations so clock-based animations can be mixed.

# A top-level animation.
class Animation

  # Initialize a new animation. Yields the new instance for configuration.
  def initialize
    @animations = []
    @loop       = nil
    @delay_ms   = 0
    yield self
  end

  # Append a lower-level animation to this animation.
  def <<(anim)
    anim = WithDelay.new(@delay_ms, anim) if @delay_ms && @delay_ms > 0
    if @forever
      @loop << anim
    else
      @animations << anim
    end
  end

  # Set the delay in milliseconds for subsequent added animations.
  def delay_ms(ms)
    @delay_ms = ms
  end

  # Iterate and yield each frame of each added animation.
  def each_frame(previous = nil, &block)
    previous = iterate_frames @animations, previous, &block

    if @loop && @loop.any?
      loop { iterate_frames @loop, previous, &block }
    end
  end

  # Run any animations added after this statement in a loop forever.
  def forever
    raise ArgumentError, "there's only one forever!" if @loop
    @forever = true
    @loop = []
  end

  protected

  def iterate_frames(animations, previous)
    animations.each do |animation|
      animation.each_frame(previous) do |frame|
        previous = frame
        yield frame
      end
    end
    previous
  end
end

# An animation with a delay between each frame.
class WithDelay
  def initialize(ms, animation)
    @ms = ms
    @animation = animation
  end

  def each_frame(previous)
    @animation.each_frame(previous) do |frame|
      yield frame
      sleep @ms/1000.0
    end
  end
end

# A simple value.
class Value
  def initialize(value)
    @value = value
  end

  def each_frame(previous)
    yield "#{@value}"
  end
end

# A single timestamp
class Timestamp
  def each_frame(previous)
    yield Time.now.iso8601
  end
end

# Timestamps for forever.
class Clock
  def each_frame(previous)
    loop { yield Time.now.iso8601 }
  end
end

# Runs a child animation until the flag is set.
class Flagged
  def initialize(anim)
    @anim = anim
    @flag = false
  end

  def flag!
    @flag = true
  end

  def each_frame(previous)
    @anim.each_frame(previous) do |frame|
      break if @flag
      yield frame
    end
  end
end

# A nice shutdown animation.
class Shutdown
  def each_frame(previous)
    str = "shutting down"
    str.length.downto(0) do |len|
      yield str.slice(0, len)
    end
    yield "done."
  end
end

# Step from the previous value (if present) to the given value.
class FadeTo
  def initialize(value)
    @value = value
  end

  def each_frame(previous)
    previous = previous.to_i
    list = if previous - 1 > @value
             (previous - 1).downto @value
           elsif previous + 1 < @value
             (previous + 1).upto(@value)
           else
             []
           end
    list.each { |v| yield v }
  end
end

# Step from a value to another.
class FromTo
  def initialize(from, to)
    @from, @to = from, to
  end

  def each_frame(previous)
    enum = @from > @to ? @from.downto(@to) : @from.upto(@to)
    enum.each { |v| yield v }
  end
end

# Combine animations.
class Combination

  # Initialize a new combination of animations. Yields the new instance.
  def initialize
    @animations = []
    yield self
  end

  # Add an animation to this combination.
  def <<(animation)
    @animations << animation
  end

  # Iterate over the combined animations, lazily evaluating each frame.
  #
  # If none or only one animation is provided, no combination is performed.
  # Iteration stops if any animation returns a nil frame.
  def each_frame(previous, &block)
    return if @animations.empty?
    if @animations.size == 1
      # Pass-through, no combining needed
      @animations.each_frame(previous, &block)
    else
      # Wrap each animation as a lazily-evaluated enumerator
      enums = @animations.map do |animation|
        Enumerator.new do |yielder|
          animation.each_frame(previous) do |frame|
            yielder << frame
          end
        end.lazy # lazy is critical!
      end

      # Then zip them together, combining each set of frames
      enums.first.zip(*enums[1..-1]).each do |frames|
        break if frames.any?(&:nil?)
        block.call combine_frames(frames)
      end
    end
  end

  # Combine a set of frames. Override this to define your own behavior.
  def combine_frames(frames)
    frames.map(&:to_s).join(", ")
  end
end

# Combine frame values by computing their sum.
class AddFrames < Combination
  def combine_frames(frames)
    frames.map(&:to_i).inject(:+)
  end
end

# ---------- Example --------- #

# bounce from a previous value (default 0) to 5, then 3, then 5, then 0
bounce = Animation.new do |a|
  a << FadeTo.new(5)
  a << FadeTo.new(3)
  a << FadeTo.new(5)
  a << FadeTo.new(0)
end

main = Animation.new do |a|
  # Demonstrate timing changes
  a.delay_ms 50
  a << Value.new("faster")
  a << bounce
  a.delay_ms 200
  a << Value.new("slower")
  a << FadeTo.new(6)

  # Demonstrate lazy combinations
  a.delay_ms 1000
  a << Value.new("lazy combiner")
  a << Combination.new do |c|
    c << FromTo.new(0,4) # terminate at 4 (no more values)
    c << FromTo.new(20,30)
    c << Clock.new # to show laziness
  end

  # Demonstrate a custom combination (summing values)
  a.delay_ms 100
  a << Value.new("adding frame values")
  a << AddFrames.new do |c|
    c << FromTo.new(0, 4)
    c << FromTo.new(0, 4)
  end

  # Demonstrate an infinite loop
  a << Value.new("tick tock forever")
  a.forever
  a.delay_ms 1000
  a << Timestamp.new
end

# A fast shutdown animation
shutdown = Animation.new do |a|
  a.delay_ms 10
  a << Value.new("caught interrupt")
  a << Shutdown.new
end

# Wrap the main animation in an interruptable instance
flagged = Flagged.new(main)

# How to render each frame (print it out)
render = lambda { |frame| puts "frame: #{frame}" }

# Stop the animation on ctrl-c, and run a shutdown animation
trap("INT") do
  flagged.flag!
  print "\r"
  shutdown.each_frame(&render)
end

# Run the whole thing.
flagged.each_frame(nil, &render)
