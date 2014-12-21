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

    # Iterate over the combined animations, lazily evaluating each frame.
    #
    # If none or only one animation is provided, no combination is performed.
    # Iteration stops if any animation returns a nil frame.
    def each_frame(previous, &block)
      return if @animations.empty?
      if @animations.size == 1
        # Pass-through, no combining needed
        @animations.each_frame(previous, &block)
      else
        # Wrap each animation as a lazily-evaluated enumerator
        enums = @animations.map do |animation|
          Enumerator.new do |yielder|
            animation.each_frame(previous) do |frame|
              yielder << frame
            end
          end.lazy # lazy is critical!
        end

        # Then zip them together, combining each set of frames
        enums.first.zip(*enums[1..-1]).each do |frames|
          break if frames.any?(&:nil?)
          block.call combine_frames(frames)
        end
      end
    end

    # Combine a set of frames. Override this to define your own behavior.
    def combine_frames(frames)
      raise NotImplementedError, "must implement combine_frames"
    end
  end
end
