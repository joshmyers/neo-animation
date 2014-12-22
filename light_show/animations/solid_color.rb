module LightShow
  class SolidColor
    def initialize(r, g, b, opts = {})
      @color = [r,g,b]
      @frames = opts.fetch(:frames, 1)
    end

    def frames(prev)
      [[@color] * prev.length] * @frames
    end
  end
end
