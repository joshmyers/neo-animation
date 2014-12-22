require_relative "theater_chase"

module LightShow
  class TheaterChaseRainbow < TheaterChase
    attr_reader :colors
    attr_reader :spacing

    def initialize(opts = {})
      @spacing    = opts.fetch(:spacing, 3)
      @colors     = LightShow.rainbow(256)
    end

    def frames(previous)
      length = previous.length

      Enumerator.new do |y|
        256.times do |offset|
          spacing.times do |space|
            frame = LightShow.color_frame(length, 0, 0, 0)
            (0...length).step(spacing) { |i| frame[space+i] = colors[i + length - offset] }
            y << frame
          end
        end
      end
    end
  end
end
