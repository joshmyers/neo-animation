module LightShow
  # Display and rotate an evenly-distributed rainbow
  class RainbowCycle
    attr_reader :iterations

    def initialize(opts = {})
      @iterations = opts.fetch(:iterations, 5)
    end

    def frames(previous)
      Enumerator.new do |y|
        iterations.times do
          256.times do |wheel_offset|
            offset = wheel_offset.to_f / 256
            y << LightShow.rainbow(previous.length, -offset)
          end
        end
      end
    end
  end
end
