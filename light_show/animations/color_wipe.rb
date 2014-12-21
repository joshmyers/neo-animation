module LightShow
  class ColorWipe
    def initialize(r, g, b)
      @color = [r, g, b]
    end

    def each_frame(previous)
      frame = previous.dup
      previous.length.times do |i|
        frame[i] = @color
        yield frame
      end
    end
  end
end
