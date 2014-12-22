module LightShow
  class Rainbow
    attr_reader :iterations

    def initialize(opts = {})
      @iterations = opts.fetch(:iterations, 1)
    end

    def frames(previous)
      length = previous.length
      rainbow = LightShow.rainbow(256)

      Enumerator.new do |y|
        (256 * iterations).times do |n|
          y << rainbow.rotate(-n % 256).slice(0, length)
        end
      end
    end
  end
end
