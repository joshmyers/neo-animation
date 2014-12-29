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

controller = LightShow::Controller.new do |c|
  c["red"]    = LightShow::Spinner.new(0.5, 0, 0, :length => 24)
  c["yellow"] = LightShow::Spinner.new(0.5, 0.25, 0, :length => 24)
  c["green"]  = LightShow::SolidColor.new(0, 0.5, 0, :frames => nil)
  c.default "red"
end

spinner = LightShow::Animation.new do |a|
  a.forever
  a.delay_ms 20
  a << controller
end

# Starting frame. Always gotta start somewhere.
black = LightShow.color_frame(PIXELS)

stopped = false
trap("INT") { stopped = true }

Thread.abort_on_exception = true
Thread.new do
  names = [
    ["red", 100],
    ["yellow", 50],
    ["green", 20]
  ]
  loop do
    sleep 3
    names.rotate!
    name, frames = *names.first
    controller.switch_to name, frames
  end
end

spinner.frames(black).each do |frame|
  renderers.each { |renderer| renderer.render frame }
  break if stopped
end
renderers.each { |r| r.render black }
puts
