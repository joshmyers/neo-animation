#!/usr/bin/env ruby

require 'sonos'
require_relative "light_show"

PIXELS = 117
LIGHTNING_COLORS = [
  { r: 125, g: 249, b: 255 },
  { r: 44,  g: 117, b: 255 },
  { r: 83,  g: 104, b: 120 }
]

renderers = []

if `uname -a` =~ /armv6l/
  require_relative "light_show/neopixel_renderer"
  neopixel = LightShow::NeopixelRenderer.new \
    :led_count      => PIXELS,
    :led_pin        => 18,
    :led_brightness => 100,
    :offset         => 1 # for sideways, 14 for upright
  renderers << neopixel
else
  require_relative "light_show/console_renderer"
  renderers << LightShow::ConsoleRenderer.new
end

rolling_lightning = LightShow::Controller.new do |c|
  c["white"]    = LightShow::Spinner.new(1,1,1, :length => 24)
  c["lightning"] = LightShow::Spinner.new(0.48828125, 0.97265625, 0.99609375, :length => 24)
end

animation = LightShow::Animation.new do |a|
  a.delay_ms 100
  LIGHTNING_COLORS.each do |color|
    a << LightShow::ThunderclapLightning.new(color[:r], color[:g], color[:b], iterations: 10)
  end
  #a.delay_ms 20
  #a << rolling_lightning
  #a.delay_ms 1
  #a << LightShow::RainbowCycle.new
end

runner = LightShow::Interrupt.new(animation) do |shutdown|
  shutdown.delay_ms 10
  shutdown << LightShow::ColorWipe.new(0, 0, 0)
end

black = LightShow.color_frame(PIXELS, 0,0,0)

trap("INT") { runner.stop! }

system = Sonos::System.new
speaker = system.speakers.first
speaker.play('http://skyfog1.s3.amazonaws.com/thunder1.mp3')

runner.frames(black).each do |frame|
  renderers.each { |renderer| renderer.render frame }
end
