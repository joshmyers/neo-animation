require_relative "../lerp"

module LightShow
  # Fade an animation in, display it for awhile, then fade it out.
  #
  # Uses the active animation for the fades. If the animation finishes before
  # this is faded out, the last frame is kept and faded out.
  class FadeInOut
    include Lerp

    # :animation - the animation to fade in and out
    # :animation_frames - Optional number of frames to run the animation for at
    #                     "full brightness". nil means until it's done, or forever.
    # :fade_in_frames   - optional number of frames to fade in, default 10
    # :fade_out_frames  - optional number of frames to fade out, default 10
    def initialize(opts = {})
      @animation        = opts.fetch :animation
      @animation_frames = opts.fetch :animation_frames, nil
      @fade_in_frames   = opts.fetch :fade_in_frames, 10
      @fade_out_frames  = opts.fetch :fade_out_frames, 10
    end

    def frames(previous)
      count = 0
      Enumerator.new do |y|
        fade_in = to_levels @fade_in_frames
        fade_out = to_levels @fade_out_frames
        black = LightShow.color_frame(previous.length)
        last_frame = previous

        @animation.frames(previous).each do |frame|

          if level = fade_in.shift
            # Fading in
            frame = previous.zip(frame).map { |from, to| lerp(from, to, level) }
          elsif @animation_frames && count == @animation_frames
            # Have yielded the configured number of full-brightness frames
            if level = fade_out.shift
              # Fade it out
              frame = frame.zip(black).map { |from, to| lerp(from, to, level) }
            else
              break # Done fading out, stop.
            end
          else
            # At full brightness, just render the frame and keep count
            count += 1
          end
          y << frame
          last_frame = frame
        end

        # Fade the static last frame if there are any fade levels remaining
        fade_out.each do |level|
          y << last_frame.zip(black).map { |from, to| lerp(from, to, level) }
        end
      end
    end

    def to_levels(steps)
      if steps > 0
        1.upto(steps).map { |step| step.to_f/steps }
      else
        []
      end
    end
  end
end
