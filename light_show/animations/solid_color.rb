module LightShow
  class SolidColor
    def initialize(r, g, b, opts = {})
      @color = [r,g,b]
      @frames = opts.fetch(:frames, 1)
    end

    def frames(prev)
      frame = [@color] * prev.length
        Enumerator.new do |y|
          if @frames.nil?
            loop  { y << frame }
          else
            @frames.times { y << frame }
          end
        end
    end
  end
end
