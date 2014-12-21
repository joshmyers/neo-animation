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

    def each_frame(previous)
      @animation.each_frame(previous) do |frame|
        break if @stopped
        yield frame
        previous = frame
      end

      @shutdown.each_frame(previous) do |frame|
        yield frame
      end
    end
  end
end
