module LightShow

  # Combine animations.
  class Combination

    # Initialize a new combination of animations. Yields the new instance.
    def initialize
      @animations = []
      yield self
    end

    # Add an animation to this combination.
    def <<(animation)
      @animations << animation
    end

    # Frames for the combined animations, lazily evaluating each frame.
    #
    # If none or only one animation is provided, no combination is performed.
    # Iteration stops if any animation returns a nil frame.
    def frames(previous)
      return [] if @animations.empty?
      return @animations.first.frames(previous) if @animations.size == 1

      # Lazily zip the next frames of each animation together. Ruby 1.9.3
      # doesn't have lazy enumerators or lazy zip, so do it by hand.
      Enumerator.new do |y|
        enums = @animations.map { |anim| anim.frames(previous).each }

        loop do
          begin
            frames = enums.map(&:next)
            y << combine_frames(frames)
          rescue StopIteration
            break
          end
        end
      end
    end

    # Combine a set of frames.
    #
    # Defaults to calling combine_colors with the colors for each pixel.
    #
    # Override this to define your own behavior.
    def combine_frames(frames)
      frames.first.zip(*frames[1..-1]).map do |pixels|
        combine_pixels pixels
      end
    end

    # Combine pixels by calling combine_values on each of r, g, and b.
    def combine_pixels(pixels)
      pixels.first.zip(*pixels[1..-1]).map do |values|
        combine_values values
      end
    end

    def combine_values(colors)
      raise NotImplementedError, "must implement combine_values"
    end
  end
end
