module LightShow
  class TheaterChase
    attr_reader :color
    attr_reader :spacing
    attr_reader :iterations

    def initialize(r, g, b, opts = {})
      @color      = [r, g, b]
      @spacing    = opts.fetch(:spacing, 3)
      @iterations = opts.fetch(:iterations, 10)
    end

    def frames(previous)
      Enumerator.new do |y|
        length = previous.length
        iterations.times do
          spacing.times do |space|
            frame = LightShow.color_frame(length)
            (0...length).step(spacing) { |i| frame[space+i] = color }
            y << frame
          end
        end
      end
    end

  end
end
