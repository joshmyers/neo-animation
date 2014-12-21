module LightShow

  # An animation with a given delay in milliseconds between frames
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

end
