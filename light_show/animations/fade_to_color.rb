module LightShow
  class FadeToColor
    def initialize(r, g, b, opts = {})
      @color = [r,g,b]
      @steps = opts.fetch(:steps, 10)
    end

    def frames(previous)
      Enumerator.new do |y|
        1.upto(@steps) do |step|
          t = step.to_f/@steps
          y << previous.map { |from| lerp(from, @color, t) }
        end
      end
    end

    def lerp(from, to, t)
      from.zip(to).map do |a,b|
        a + (b - a) * t
      end
    end
  end
end

