module LightShow
  class ColorWipe
    def initialize(r, g, b)
      @color = [r, g, b]
    end

    def frames(previous)
      frame = previous.dup

      Enumerator.new do |y|
        previous.length.times do |i|
          frame[i] = @color
          y << frame
        end
      end
    end

  end
end
