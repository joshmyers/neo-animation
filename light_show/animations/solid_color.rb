module LightShow
  class SolidColor
    def initialize(r, g, b)
      @color = [r,g,b]
    end

    def each_frame(prev)
      yield [@color] * prev.length
    end
  end
end
