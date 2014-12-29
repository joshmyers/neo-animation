require "thread"

module LightShow
  class Controller
    include Lerp

    def initialize
      @animations = {}
      @lock = Mutex.new
      yield self
    end

    def []=(name, animation)
      @animations[name] = animation
    end

    def default(name)
      @default = name
    end

    def frames(previous)
      return if @animations.empty?

      @lock.synchronize do
        @current = (@animations[@default] || @animations.values.first).frames(previous).each
        @next = nil
        @transition_frames = 0
        @remaining_frames = 0
        @prev = previous
      end

      Enumerator.new do |y|
        loop do
          if frame = next_frame
            y << next_frame
            @prev = frame
          else
            break
          end
        end
      end
    end

    def next_frame
      @lock.synchronize do
        if @next && @remaining_frames == 0
          @current = @next
          @next = nil
        end

        frame = @current.next

        if @next
          if @remaining_frames > 0
            t = 1 - @remaining_frames/@transition_frames.to_f
            next_frame = @next.next
            frame = frame.zip(next_frame).map do |from, to|
              lerp from, to, t
            end
            @remaining_frames -= 1
          end
        end

        frame
      end
    rescue StopIteration
      nil
    end

    def switch_to(name, transition_frames)
      unless animation = @animations[name]
        raise ArgumentError, "unknown animation #{name}"
      end

      @lock.synchronize do
        @transition_frames = @remaining_frames = transition_frames
        @current = @next if @next
        @next = animation.frames(@prev).each
      end
    end

  end
end
