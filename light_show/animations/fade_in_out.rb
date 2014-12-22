module LightShow
  # Fade an animation in, display it for awhile, then fade it out.
  #
  # Uses the first and last frames of the animation for the fade.
  class FadeInOut

    # :animation - the animation to fade in and out
    # :animation_frames - optional number of frames to run the animation for
    #                     nil means run until the animation finishes.
    # :fade_in_frames   - optional number of frames to fade in, default 10
    # :fade_out_frames  - optional number of frames to fade out, default 10
    def initialize(opts = {})
      @animation        = opts.fetch :animation
      @animation_frames = opts.fetch :animation_frames, nil
      @fade_in_frames   = opts.fetch :fade_in_frames, 10
      @fade_out_frames  = opts.fetch :fade_out_frames, 10
    end

    def frames(previous)
      return [] unless first_frame = @animation.frames(previous).each.first

      Enumerator.new do |y|
        last_frame = nil
        fade_in = FadeToFrame.new(first_frame, @fade_in_frames)
        fade_in.frames(previous).each do |frame|
          last_frame = frame
          y << frame
        end

        frame_count = 0
        if @animation_frames.nil? || @animation_frames > 0
          @animation.frames(last_frame).each do |frame|
            last_frame = frame
            y << frame
            frame_count += 1
            break if @animation_frames && frame_count == @animation_frames
          end
        end

        fade_out = FadeToColor.new(0, 0, 0, :steps => @fade_out_frames)
        fade_out.frames(last_frame).each do |frame|
          y << frame
        end
      end
    end

  end
end
