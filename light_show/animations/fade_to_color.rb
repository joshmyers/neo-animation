module LightShow
  class FadeToColor
    def initialize(color, steps)
      @color, @steps = color, steps
    end

    def each_frame(previous)
      1.upto(@steps) do |step|
        t = step.to_f/@steps
        yield previous.map { |from| lerp(from, @color, t) }
      end
    end

    def lerp(from, to, t)
      from.zip(to).map do |a,b|
        a + (b - a) * t
      end
    end
  end
end

