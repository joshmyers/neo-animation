require "light_show/with_delay"

module LightShow
  # A top-level animation, which may itself contain many smaller animations and
  # can control both frame delay and looping forever.
  #
  class Animation

    # Public: Initialize a new animation.
    #
    # Yields the new instance for configuration.
    def initialize
      @animations = []
      @loop       = nil
      @delay_ms   = 0
      yield self
    end

    # Public: Add a lower-level animation to this animation.
    def <<(anim)
      anim = WithDelay.new(@delay_ms, anim) if @delay_ms && @delay_ms > 0
      if @forever
        @loop << anim
      else
        @animations << anim
      end
    end

    # Public: Set the frame delay in milliseconds for subsequent added animations.
    def delay_ms(ms)
      @delay_ms = ms
    end

    # Public: Iterate and yield each frame of each added animation.
    def each_frame(previous, &block)
      previous = iterate_frames @animations, previous, &block

      if @loop && @loop.any?
        loop { iterate_frames @loop, previous, &block }
      end
    end

    # Public: Run any animations added after this statement in a loop forever.
    def forever
      raise ArgumentError, "there's only one forever!" if @loop
      @forever = true
      @loop = []
    end

    # Internal: iterate over a set of animations, starting with a previous value
    # (if present). Tracks the last frame of an animation and hands it to the
    # next one in line.
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

end
