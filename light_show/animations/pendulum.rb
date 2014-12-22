module LightShow
  class Pendulum
    def initialize(r, g, b, opts = {})
      @color = [r, g, b]
      @period = opts.fetch(:period, 2)
    end

    def frames(previous)
      length = previous.length
      Enumerator.new do |y|
        frame = LightShow.color_frame(length)
        t = Time.now.to_f % @period / @period # constrain to 0.0-1.0
        t = t * Math::PI * 2 # map it to 0-2pi
        pos = (-Math.cos(t)/2 + 0.5) * length # then to 0-1 again, then length
        left = pos.floor
        right = (pos.floor + 1) % length # could wrap
        frame[left]  = scaled_color(1 - (pos - pos.floor))
        frame[right] = scaled_color(1 - (pos.ceil - pos))
        y << frame
      end
    end

    def scaled_color(scale)
      @color.map { |v| v * scale }
    end
  end
end
