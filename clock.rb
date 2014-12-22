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


main = LightShow::Animation.new do |a|
  a.forever
  a.delay_ms 50
  a << LightShow::Additive.new do |add|
    add << LightShow::ClockHand.new(0.5, 0, 0, :interval => 60*60, :count => 12)
    add << LightShow::ClockHand.new(0, 0.5, 0, :interval => 60, :count => 60)
    add << LightShow::ClockHand.new(0, 0, 0.5, :interval => 1, :count => 60)
    add << LightShow::Animation.new do |face|
      fade = LightShow::FadeInOut.new \
        :animation        => LightShow::ClockFace.new(8.0/256, 16.0/256),
        :animation_frames => 20, # it's infinite, so only keep it for a bit
        :fade_in_frames   => 20,
        :fade_out_frames  => 20
      face << fade
      face << LightShow::SolidColor.new(0,0,0, :frames => 140) # 7 seconds at 50ms
    end
    add << LightShow::Pendulum.new(0.1, 0.025, 0, :period => 4)
  end
end

runner = LightShow::Interrupt.new(main) do |shutdown|
  shutdown.delay_ms 10
  shutdown << LightShow::ColorWipe.new(0, 0, 0)
end

black = LightShow.color_frame(PIXELS)
trap("INT") { runner.stop! }
runner.frames(black).each do |frame|
  renderers.each { |renderer| renderer.render frame }
end
puts
