require_relative "light_show"

ENV['TZ'] ||= "America/Denver"

PIXELS = 24
renderers = []

if `uname -a` =~ /armv6l/ # raspberry pi
  require_relative "light_show/neopixel_renderer"
  neopixel = LightShow::NeopixelRenderer.new \
    :led_count => PIXELS,
    :led_pin   => 18,
    :offset    => 8 # for sideways, 14 for upright
  renderers << neopixel
else
  require_relative "light_show/console_renderer"
  renderers << LightShow::ConsoleRenderer.new
end


clock = LightShow::Animation.new do |clk|
  clk.forever
  clk.delay_ms 50

  # Combine these animations additively
  clk << LightShow::Additive.new do |add|

    # Draw the clock hands
    add << LightShow::ClockHand.new(0.5, 0, 0, :interval => 60*60, :count => 12)
    add << LightShow::ClockHand.new(0, 0.5, 0, :interval => 60, :count => 60)
    add << LightShow::ClockHand.new(0, 0, 0.5, :interval => 1, :count => 60)

    # Draw a pendulum
    add << LightShow::Pendulum.new(0.1, 0.04, 0, :period => 2, :clockwise => true)

    # And fade in the clock face itself every so often
    add << LightShow::Animation.new do |face|
      face << LightShow::SolidColor.new(0,0,0, :frames => 150)
      fade = LightShow::FadeInOut.new \
        :animation        => LightShow::ClockFace.new(8.0/256, 16.0/256),
        :animation_frames => 10, # it's infinite, so only keep it for a bit
        :fade_in_frames   => 20,
        :fade_out_frames  => 20
      face << fade
    end
  end
end

# Don't start the clock out at full brightness, fade it in over a second.
fade_in = LightShow::FadeInOut.new \
  :animation => clock,
  :fade_in_frames => 20

# Run the whole thing and fade it out gracefully on shutdown
runner = LightShow::Interrupt.new(fade_in) do |shutdown|
  shutdown.delay_ms 10
  shutdown << LightShow::FadeToColor.new(0, 0, 0, :steps => 50)
end

# Starting frame. Always gotta start somewhere.
black = LightShow.color_frame(PIXELS)

# Run it, with Ctrl-C to shut it down gracefully.
puts "Running clock animation. Ctrl-C to stop."
trap("INT") { runner.stop! }
runner.frames(black).each do |frame|
  renderers.each { |renderer| renderer.render frame }
end

puts # Clear the line
