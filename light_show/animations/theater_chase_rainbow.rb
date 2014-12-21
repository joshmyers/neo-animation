require_relative "theater_chase"

module LightShow
  class TheaterChaseRainbow < TheaterChase
    attr_reader :colors
    attr_reader :spacing

    def initialize(opts = {})
      @spacing    = opts.fetch(:spacing, 3)
      @colors     = LightShow.rainbow(256)
    end

    def each_frame(previous)
      length = previous.length

      256.times do |offset|
        spacing.times do |space|
          frame = LightShow.color_frame(length, 0, 0, 0)
          (0...length).step(spacing) { |i| frame[space+i] = colors[i + length - offset] }
          yield frame
        end
      end
    end
  end
end
