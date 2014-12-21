module LightShow
  # Display and rotate an evenly-distributed rainbow
  class RainbowCycle
    attr_reader :iterations

    def initialize(opts = {})
      @iterations = opts.fetch(:iterations, 5)
    end

    def each_frame(previous)
      iterations.times do
        256.times do |wheel_offset|
          offset = wheel_offset.to_f / 256
          yield LightShow.rainbow(previous.length, -offset)
        end
      end

      # (0...256*iterations).each do |jj|
      #   self.length.times { |ii| self[ii] = wheel(((ii * 256 / self.length) + jj) & 0xff) }
      #   self.show
      #   sleep(wait_ms / 1000.0)
      # end


    end
  end
end
