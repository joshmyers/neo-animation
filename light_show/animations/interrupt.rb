module LightShow

  # Wrap an animation with interrupt-handling ability.
  #
  # Yields an animation that runs on shutdown(keep it short!)
  class Interrupt
    def initialize(animation)
      @animation = animation
      @stopped   = false
      @shutdown  = Animation.new do |a|
        yield a
      end
    end

    def stop!
      @stopped = true
    end

    def frames(previous)
      Enumerator.new do |y|
        @animation.frames(previous).each do |frame|
          break if @stopped
          y << frame
          previous = frame
        end

        @shutdown.frames(previous).each do |frame|
          y << frame
        end
      end
    end
  end
end
