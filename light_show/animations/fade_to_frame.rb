require_relative "../lerp"

module LightShow
  class FadeToFrame
    include Lerp

    def initialize(frame, steps)
      @frame, @steps = frame, steps
    end

    def frames(previous)
      Enumerator.new do |y|
        1.upto(@steps) do |step|
          t = step.to_f/@steps
          y << previous.zip(@frame).map { |from, to| lerp(from, to, t) }
        end
      end
    end

  end
end
