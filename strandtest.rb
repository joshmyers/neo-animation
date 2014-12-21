require_relative "light_show"

PIXELS = 24

renderers = []

require_relative "light_show/console_renderer"
renderers << LightShow::ConsoleRenderer.new

if `uname -a` =~ /armv6l/ # raspberry pi
  require_relative "light_show/neopixel_renderer"
  neopixel = LightShow::NeopixelRenderer.new \
    :led_count      => PIXELS,
    :led_pin        => 18,
    :led_brightness => 31,
    :offset         => 8 # for sideways, 14 for upright
  renderers << neopixel
end

main = LightShow::Animation.new do |a|
  a.forever

  # Color wipe animations
  a.delay_ms 75
  # a << LightShow::ColorWipe.new(1, 0, 0) # red color wipe
  # a << LightShow::ColorWipe.new(0, 1, 0) # green color wipe
  # a << LightShow::ColorWipe.new(0, 0, 1) # blue color wipe

  # Theater chase animations
  a.delay_ms 100
  # a << LightShow::SolidColor.new(0, 0, 0)
  # a << LightShow::TheaterChase.new(1, 1, 1)
  # a << LightShow::TheaterChase.new(1, 0, 0)
  # a << LightShow::TheaterChase.new(0, 0, 1)

  a.delay_ms 20
  # a << LightShow::Rainbow.new
  # a << LightShow::RainbowCycle.new

  a.delay_ms 75
  a << LightShow::TheaterChaseRainbow.new
end

runner = LightShow::Interrupt.new(main) do |shutdown|
  shutdown.delay_ms 10
  shutdown << LightShow::ColorWipe.new(0, 0, 0)
end

black = LightShow.color_frame(PIXELS, 0,0,0)

trap("INT") { runner.stop! }

runner.each_frame(black) do |frame|
  renderers.each { |renderer| renderer.render frame }
end

# failsafe
renderers.each { |renderer| renderer.render black }
puts
