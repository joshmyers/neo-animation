module LightShow
  class ClockHand
    # :interval - number of seconds per 'tick'
    # :count    - how many intervals per clock face
    def initialize(r, g, b, opts = {})
      @color = [r, g, b]
      @interval = opts.fetch :interval
      @count = opts.fetch :count
    end

    def frames(previous)
      length = previous.length
      Enumerator.new do |y|
        loop do
          frame = LightShow.color_frame(length)
          now = Time.now
          midnight = Time.new(now.year, now.month, now.day)
          t = now.to_f - midnight.to_i
          position = t % (@interval * @count) / @interval / @count * length
          left = position.floor
          right = (position.floor + 1) % length # could wrap
          frame[left]  = scaled_color(1 - (position - position.floor))
          frame[right] = scaled_color(1 - (position.ceil - position))
          y << frame
        end
      end

    end

    def scaled_color(scale)
      @color.map { |v| v * scale }
    end
  end

end
