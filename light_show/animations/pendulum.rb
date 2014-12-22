module LightShow
  class Pendulum
    # Create a new pendulum animation.
    # r, g, b    - The color of the pendulum
    # :period    - Optional time in seconds for the full back-and-forth
    # :clockwise - Optional, only go clockwise instead of back and forth.
    #              Use half the period if doing this.
    def initialize(r, g, b, opts = {})
      @color     = [r, g, b]
      @period    = opts.fetch(:period, 2)
      @clockwise = opts.fetch(:clockwise, false)
    end

    def frames(previous)
      length = previous.length
      Enumerator.new do |y|
        loop do
          frame = LightShow.color_frame(length)
          t = Time.now.to_f % @period / @period # constrain to 0.0-1.0
          if @clockwise
            t = t * Math::PI # map it to 0-pi
          else
            t = t * Math::PI * 2 # map it to 0-2pi
          end
          pos = (-Math.cos(t)/2 + 0.5) * length # then to 0-1 again, then length
          left = pos.floor
          right = (pos.floor + 1) % length # could wrap
          frame[left]  = scaled_color(1 - (pos - pos.floor))
          frame[right] = scaled_color(1 - (pos.ceil - pos))
          y << frame
        end
      end
    end

    def scaled_color(scale)
      @color.map { |v| v * scale }
    end
  end
end
