module LightShow
  # Render a permanent clock face. Assumes a 24-pixel ring.
  class ClockFace
    # dark is for the 1, 2, 4, 5, 7, 8, 10, 11 marks
    # bright is for the 12, 3, 6, 9 marks
    def initialize(dark, bright)
      @dark = [dark] * 3
      @bright = [bright] * 3
    end

    def frames(previous)
      frame = LightShow.color_frame(previous.length, 0, 0, 0)
      (0...frame.length).step(2).each do |i|
        frame[i] = i/2 % 3 == 0 ? @bright : @dark
      end
      Enumerator.new { |y| loop { y << frame } }
    end
  end
end
