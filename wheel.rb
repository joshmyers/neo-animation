require_relative "light_show"

PIXELS = 24
renderers = []

if `uname -a` =~ /armv6l/ # raspberry pi
  require_relative "light_show/neopixel_renderer"
  neopixel = LightShow::NeopixelRenderer.new \
    :led_count      => PIXELS,
    :led_pin        => 18,
    :led_brightness => 63,
    :offset         => 8 # for sideways, 14 for upright
  renderers << neopixel
else
  require_relative "light_show/console_renderer"
  renderers << LightShow::ConsoleRenderer.new
end

main = LightShow::Animation.new do |a|
  a.forever
  a.delay_ms 20
  a << LightShow::RainbowCycle.new
end

runner = LightShow::Interrupt.new(main) do |shutdown|
  shutdown.delay_ms 10
  shutdown << LightShow::ColorWipe.new(0, 0, 0)
end

black = LightShow.color_frame(PIXELS, 0,0,0)
trap("INT") { runner.stop! }
runner.frames(black).each do |frame|
  renderers.each { |renderer| renderer.render frame }
end
puts
