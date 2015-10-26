module LightShow
  class ThunderclapLightning
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
            (0...length).step(spacing) do |i|
              real_color = rand(0..100) > 90 ? color.map { |x| x/256.to_f } : [0, 0, 0]
              spacing.times do |t|
                frame[space+i+t] = real_color
              end
            end
            y << frame
          end
        end
      end
    end

  end
end
