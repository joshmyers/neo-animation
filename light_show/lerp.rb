module LightShow
  module Lerp
    def lerp(from, to, t)
      from.zip(to).map do |a,b|
        a + (b - a) * t
      end
    end
  end
end
