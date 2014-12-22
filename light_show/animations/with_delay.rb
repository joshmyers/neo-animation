module LightShow

  # An animation with a given delay in milliseconds between frames
  class WithDelay
    def initialize(ms, animation)
      @ms = ms
      @animation = animation
    end

    def frames(previous)
      Enumerator.new do |y|
        @animation.frames(previous).each do |frame|
          y << frame
          sleep @ms/1000.0
        end
      end
    end
  end
end
