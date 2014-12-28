module LightShow
  class Spinner
    def initialize(r, g, b, opts={})
      @color  = [r, g, b]
      @period = opts.fetch(:period, 1)
      @length = opts.fetch(:length, 5)
    end

    def frames(previous)
      length = previous.length
      frame  = LightShow.color_frame(length)
      frames = {} # may as well precalculate 'em

      0.upto(@length-1) do |offset|
        pos = (length - offset) % length
        color = scaled_color(1 - offset*(1.0/@length))
        frame[pos] = color
      end
      0.upto(@length - 1) do |offset|
        frames[offset] = frame.rotate(-offset)
      end

      Enumerator.new do |y|
        loop do
          t = Time.now.to_f % @period / @period # constrain to 0.0-1.0
          offset = (t * length).round % length
          y << frames[offset]
        end
      end
    end

    def scaled_color(scale)
      @color.map { |v| v * scale }
    end
  end
end
