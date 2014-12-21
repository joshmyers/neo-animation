module LightShow
  class FadeToFrame
    def initialize(frame, steps)
      @frame, @steps = frame, steps
    end

    def each_frame(previous)
      1.upto(@steps) do |step|
        t = step.to_f/@steps
        yield previous.zip(@frame).map { |from, to| lerp(from, to, t) }
      end
    end

    def lerp(from, to, t)
      from.zip(to).map do |a,b|
        a + (b - a) * t
      end
    end
  end
end
